#!/usr/bin/env bash
# Script to set up a local Kubernetes cluster for development

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo "============================================================"
echo "Local Kubernetes Cluster Setup"
echo "============================================================"
echo ""

# Detect OS
OS="$(uname -s)"
case "${OS}" in
    Linux*)     MACHINE=Linux;;
    Darwin*)    MACHINE=Mac;;
    *)          MACHINE="UNKNOWN:${OS}"
esac

echo "Detected OS: ${MACHINE}"
echo ""

# Check if kubectl is installed
if ! command -v kubectl > /dev/null 2>&1; then
    echo -e "${YELLOW}kubectl is not installed${NC}"
    echo ""
    if [ "${MACHINE}" = "Mac" ]; then
        echo "Installing kubectl via Homebrew..."
        if command -v brew > /dev/null 2>&1; then
            brew install kubectl
        else
            echo -e "${RED}Homebrew not found. Please install kubectl manually.${NC}"
            echo "See: https://kubernetes.io/docs/tasks/tools/"
            exit 1
        fi
    else
        echo "Please install kubectl manually."
        echo "See: https://kubernetes.io/docs/tasks/tools/"
        exit 1
    fi
else
    echo -e "${GREEN}✓ kubectl is installed${NC}"
fi

# Check if cluster already exists
if kubectl cluster-info > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Kubernetes cluster is already running${NC}"
    kubectl cluster-info
    echo ""
    echo "You can proceed with deployment:"
    echo "  bash scripts/deploy_to_k8s.sh"
    exit 0
fi

echo ""
echo "No Kubernetes cluster detected."
echo ""
echo "Choose a setup option:"
echo ""
echo "1. minikube (Recommended - Easy to use)"
echo "2. kind (Kubernetes in Docker)"
echo "3. Docker Desktop Kubernetes (macOS/Windows only)"
echo "4. Exit and set up manually"
echo ""
read -p "Enter choice [1-4]: " choice

case $choice in
    1)
        echo ""
        echo "Setting up minikube..."
        
        # Check if minikube is installed
        if ! command -v minikube > /dev/null 2>&1; then
            echo "Installing minikube..."
            if [ "${MACHINE}" = "Mac" ] && command -v brew > /dev/null 2>&1; then
                brew install minikube
            else
                echo -e "${RED}Please install minikube manually${NC}"
                echo "See: https://minikube.sigs.k8s.io/docs/start/"
                exit 1
            fi
        fi
        
        echo "Starting minikube cluster..."
        minikube start
        
        echo "Enabling addons..."
        minikube addons enable ingress || echo "Ingress addon not available"
        minikube addons enable metrics-server || echo "Metrics server not available"
        
        echo ""
        echo -e "${GREEN}✓ minikube cluster is ready!${NC}"
        kubectl cluster-info
        ;;
        
    2)
        echo ""
        echo "Setting up kind..."
        
        # Check if kind is installed
        if ! command -v kind > /dev/null 2>&1; then
            echo "Installing kind..."
            if [ "${MACHINE}" = "Mac" ] && command -v brew > /dev/null 2>&1; then
                brew install kind
            else
                echo -e "${RED}Please install kind manually${NC}"
                echo "See: https://kind.sigs.k8s.io/"
                exit 1
            fi
        fi
        
        echo "Creating kind cluster..."
        kind create cluster --name mlops
        
        echo ""
        echo -e "${GREEN}✓ kind cluster is ready!${NC}"
        kubectl cluster-info --context kind-mlops
        ;;
        
    3)
        if [ "${MACHINE}" != "Mac" ]; then
            echo -e "${RED}Docker Desktop Kubernetes is only available on macOS and Windows${NC}"
            exit 1
        fi
        
        echo ""
        echo -e "${YELLOW}Docker Desktop Kubernetes Setup${NC}"
        echo ""
        echo "Please follow these steps manually:"
        echo "1. Open Docker Desktop"
        echo "2. Go to Settings → Kubernetes"
        echo "3. Check 'Enable Kubernetes'"
        echo "4. Click 'Apply & Restart'"
        echo "5. Wait for Kubernetes to start"
        echo ""
        echo "Then verify with:"
        echo "  kubectl cluster-info"
        echo ""
        exit 0
        ;;
        
    4)
        echo ""
        echo "Exiting. For manual setup, see: docs/KUBERNETES_SETUP.md"
        exit 0
        ;;
        
    *)
        echo -e "${RED}Invalid choice${NC}"
        exit 1
        ;;
esac

echo ""
echo "============================================================"
echo "Cluster Setup Complete!"
echo "============================================================"
echo ""
echo "Verify cluster:"
echo "  kubectl get nodes"
echo ""
echo "Deploy the API:"
echo "  bash scripts/deploy_to_k8s.sh"
echo ""

