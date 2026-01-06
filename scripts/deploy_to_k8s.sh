#!/usr/bin/env bash
# Script to deploy Heart Disease API to Kubernetes

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
K8S_DIR="${PROJECT_ROOT}/k8s"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "============================================================"
echo "Kubernetes Deployment Script"
echo "============================================================"

# Check if kubectl is installed
if ! command -v kubectl > /dev/null 2>&1; then
    echo -e "${RED}Error: kubectl is not installed${NC}"
    echo ""
    echo "Install kubectl:"
    echo "  macOS: brew install kubectl"
    echo "  Linux: See https://kubernetes.io/docs/tasks/tools/"
    echo ""
    exit 1
fi

# Check if kubectl can connect to cluster
if ! kubectl cluster-info > /dev/null 2>&1; then
    echo -e "${RED}Error: Cannot connect to Kubernetes cluster${NC}"
    echo ""
    echo "You need to set up a Kubernetes cluster first."
    echo ""
    echo "Quick setup options:"
    echo ""
    echo "1. minikube (Recommended for local development):"
    echo "   brew install minikube"
    echo "   minikube start"
    echo ""
    echo "2. kind (Kubernetes in Docker):"
    echo "   brew install kind"
    echo "   kind create cluster --name mlops"
    echo ""
    echo "3. Docker Desktop:"
    echo "   Open Docker Desktop → Settings → Kubernetes → Enable"
    echo ""
    echo "For detailed setup instructions, see:"
    echo "  docs/KUBERNETES_SETUP.md"
    echo ""
    echo "After setting up a cluster, verify with:"
    echo "  kubectl cluster-info"
    echo "  kubectl get nodes"
    echo ""
    exit 1
fi

echo -e "${GREEN}✓ kubectl is configured${NC}"

# Check if Docker image exists locally
IMAGE_NAME="heart-disease-api:latest"
if ! docker images | grep -q "heart-disease-api"; then
    echo -e "${YELLOW}Warning: Docker image '${IMAGE_NAME}' not found locally${NC}"
    echo ""
    echo "Building Docker image..."
    cd "${PROJECT_ROOT}"
    docker build -t "${IMAGE_NAME}" .
    echo -e "${GREEN}✓ Docker image built${NC}"
else
    echo -e "${GREEN}✓ Docker image found${NC}"
fi

# Detect cluster type
CLUSTER_TYPE="unknown"
if command -v minikube > /dev/null 2>&1 && minikube status > /dev/null 2>&1; then
    CLUSTER_TYPE="minikube"
    echo -e "${GREEN}✓ Detected minikube cluster${NC}"
    echo "Loading image into minikube..."
    minikube image load "${IMAGE_NAME}" || echo "Image load failed, continuing..."
elif command -v kind > /dev/null 2>&1 && kind get clusters > /dev/null 2>&1; then
    CLUSTER_TYPE="kind"
    echo -e "${GREEN}✓ Detected kind cluster${NC}"
    echo "Loading image into kind..."
    kind load docker-image "${IMAGE_NAME}" || echo "Image load failed, continuing..."
else
    echo -e "${YELLOW}Warning: Could not detect cluster type${NC}"
    echo "If using a remote cluster, ensure the image is pushed to a registry"
    echo "and update deployment.yaml with the registry image path"
fi

# Deploy to Kubernetes
echo ""
echo "============================================================"
echo "Deploying to Kubernetes"
echo "============================================================"

cd "${K8S_DIR}"

# Apply resources in order
echo "Creating namespace..."
kubectl apply -f namespace.yaml || {
    echo -e "${RED}Failed to create namespace${NC}"
    exit 1
}

# Wait for namespace to be ready
sleep 1

echo "Creating PVC..."
PVC_CREATED=false
if kubectl apply -f pvc.yaml 2>/dev/null; then
    PVC_CREATED=true
    echo "PVC created successfully"
else
    echo -e "${YELLOW}Warning: PVC creation failed or already exists${NC}"
    # Check if PVC exists
    if kubectl get pvc heart-disease-models-pvc -n mlops > /dev/null 2>&1; then
        PVC_CREATED=true
        echo "PVC already exists"
    fi
fi

# Determine which deployment file to use
USE_PVC=false
if [ "$PVC_CREATED" = true ] && kubectl get pvc heart-disease-models-pvc -n mlops > /dev/null 2>&1; then
    PVC_STATUS=$(kubectl get pvc heart-disease-models-pvc -n mlops -o jsonpath='{.status.phase}' 2>/dev/null || echo "Pending")
    if [ "$PVC_STATUS" = "Bound" ]; then
        USE_PVC=true
        echo "PVC is bound, using deployment with PVC"
    else
        echo -e "${YELLOW}PVC exists but not bound yet. Using deployment without PVC...${NC}"
    fi
else
    echo "Using deployment without PVC (models in image)"
fi

echo "Creating ConfigMap..."
kubectl apply -f configmap.yaml || {
    echo -e "${RED}Failed to create ConfigMap${NC}"
    exit 1
}

echo "Creating Deployment..."
if [ "$USE_PVC" = true ]; then
    echo "Using deployment with PVC..."
    DEPLOYMENT_FILE="deployment.yaml"
else
    echo "Using deployment without PVC (models in image)..."
    DEPLOYMENT_FILE="deployment-no-pvc.yaml"
fi

if [ ! -f "$DEPLOYMENT_FILE" ]; then
    echo -e "${RED}Error: Deployment file '$DEPLOYMENT_FILE' not found${NC}"
    exit 1
fi

DEPLOYMENT_OUTPUT=$(kubectl apply -f "$DEPLOYMENT_FILE" 2>&1)
DEPLOYMENT_EXIT_CODE=$?

if [ $DEPLOYMENT_EXIT_CODE -ne 0 ]; then
    echo -e "${RED}Failed to create deployment${NC}"
    echo "$DEPLOYMENT_OUTPUT"
    echo ""
    echo "Common issues:"
    echo "1. Image not found - Ensure image is built and available in cluster"
    echo "2. PVC not found - If using deployment.yaml, ensure PVC exists"
    echo ""
    echo "Checking deployment status..."
    kubectl get deployment -n mlops
    kubectl get pods -n mlops
    exit 1
else
    echo "$DEPLOYMENT_OUTPUT"
fi

echo "Creating Service..."
kubectl apply -f service.yaml || {
    echo -e "${RED}Failed to create service${NC}"
    exit 1
}

# Wait a moment for deployment to be registered
sleep 2

# Check if deployment exists
if ! kubectl get deployment heart-disease-api -n mlops > /dev/null 2>&1; then
    echo -e "${RED}Error: Deployment 'heart-disease-api' not found in namespace 'mlops'${NC}"
    echo ""
    echo "Checking what was created:"
    kubectl get all -n mlops
    echo ""
    echo "Checking for errors:"
    kubectl get events -n mlops --sort-by='.lastTimestamp' | tail -10
    exit 1
fi

# Wait for deployment
echo ""
echo "Waiting for deployment to be ready..."
if kubectl wait --for=condition=available --timeout=300s deployment/heart-disease-api -n mlops 2>/dev/null; then
    echo -e "${GREEN}✓ Deployment is ready${NC}"
else
    echo -e "${YELLOW}Warning: Deployment not ready yet, but continuing...${NC}"
    echo "Check status with: kubectl get pods -n mlops"
fi

echo -e "${GREEN}✓ Deployment is ready${NC}"

# Show status
echo ""
echo "============================================================"
echo "Deployment Status"
echo "============================================================"

kubectl get pods -n mlops
echo ""
kubectl get services -n mlops
echo ""
kubectl get deployment -n mlops

echo ""
echo "============================================================"
echo "Access the API"
echo "============================================================"
echo ""
echo "Option 1: Port Forward (Recommended for testing)"
echo "  kubectl port-forward service/heart-disease-api-service 8000:80 -n mlops"
echo "  Then access: http://localhost:8000"
echo ""
echo "Option 2: NodePort (if service-nodeport.yaml is applied)"
echo "  kubectl apply -f service-nodeport.yaml"
echo "  Access at: http://<node-ip>:30080"
echo ""
echo "View logs:"
echo "  kubectl logs -f deployment/heart-disease-api -n mlops"
echo ""
echo "============================================================"

