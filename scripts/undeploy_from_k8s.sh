#!/usr/bin/env bash
# Script to undeploy Heart Disease API from Kubernetes

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
echo "Kubernetes Undeployment Script"
echo "============================================================"

# Check if kubectl is installed
if ! command -v kubectl > /dev/null 2>&1; then
    echo -e "${RED}Error: kubectl is not installed${NC}"
    exit 1
fi

# Check if kubectl can connect to cluster
if ! kubectl cluster-info > /dev/null 2>&1; then
    echo -e "${RED}Error: Cannot connect to Kubernetes cluster${NC}"
    exit 1
fi

cd "${K8S_DIR}"

# Delete resources
echo "Deleting resources..."

kubectl delete -f deployment.yaml --ignore-not-found=true
kubectl delete -f service.yaml --ignore-not-found=true
kubectl delete -f service-nodeport.yaml --ignore-not-found=true
kubectl delete -f ingress.yaml --ignore-not-found=true
kubectl delete -f configmap.yaml --ignore-not-found=true
kubectl delete -f pvc.yaml --ignore-not-found=true

echo ""
echo -e "${YELLOW}Note: Namespace 'mlops' is not deleted by default${NC}"
echo "To delete namespace: kubectl delete namespace mlops"
echo ""
echo -e "${GREEN}✓ Resources deleted${NC}"

