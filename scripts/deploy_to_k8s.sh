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
    echo "Please configure kubectl to connect to your cluster:"
    echo "  kubectl config get-contexts"
    echo "  kubectl config use-context <context-name>"
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
kubectl apply -f namespace.yaml

echo "Creating PVC..."
kubectl apply -f pvc.yaml

echo "Creating ConfigMap..."
kubectl apply -f configmap.yaml

echo "Creating Deployment..."
kubectl apply -f deployment.yaml

echo "Creating Service..."
kubectl apply -f service.yaml

# Wait for deployment
echo ""
echo "Waiting for deployment to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/heart-disease-api -n mlops || {
    echo -e "${RED}Deployment failed to become ready${NC}"
    echo "Check pod status: kubectl get pods -n mlops"
    exit 1
}

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

