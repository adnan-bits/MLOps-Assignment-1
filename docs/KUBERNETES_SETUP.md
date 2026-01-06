# Kubernetes Cluster Setup Guide

This guide helps you set up a local Kubernetes cluster for testing Phase 7 deployment.

## Option 1: minikube (Recommended for macOS/Linux)

### Installation

**macOS:**
```bash
brew install minikube
```

**Linux:**
```bash
# Download minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
```

**Windows:**
Download from: https://minikube.sigs.k8s.io/docs/start/

### Start minikube

```bash
# Start minikube cluster
minikube start

# Verify cluster is running
minikube status

# Check kubectl connection
kubectl cluster-info
```

### Configure kubectl

minikube automatically configures kubectl. Verify:

```bash
kubectl get nodes
```

You should see your minikube node.

### Enable Addons (Optional)

```bash
# Enable ingress controller (for Ingress support)
minikube addons enable ingress

# Enable metrics server (for HPA)
minikube addons enable metrics-server
```

### Stop/Start minikube

```bash
# Stop cluster
minikube stop

# Start cluster
minikube start

# Delete cluster
minikube delete
```

---

## Option 2: kind (Kubernetes in Docker)

### Installation

**macOS:**
```bash
brew install kind
```

**Linux:**
```bash
# Download kind
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind
```

**Windows:**
Download from: https://kind.sigs.k8s.io/docs/user/quick-start/

### Create Cluster

```bash
# Create a cluster
kind create cluster --name mlops

# Verify
kubectl cluster-info --context kind-mlops
```

### Delete Cluster

```bash
kind delete cluster --name mlops
```

---

## Option 3: Docker Desktop (macOS/Windows)

Docker Desktop includes a built-in Kubernetes cluster.

### Enable Kubernetes

1. Open Docker Desktop
2. Go to Settings → Kubernetes
3. Check "Enable Kubernetes"
4. Click "Apply & Restart"
5. Wait for Kubernetes to start

### Verify

```bash
kubectl cluster-info
kubectl get nodes
```

---

## Option 4: Cloud Clusters

### Google Kubernetes Engine (GKE)

```bash
# Install gcloud CLI
# https://cloud.google.com/sdk/docs/install

# Authenticate
gcloud auth login

# Create cluster
gcloud container clusters create mlops-cluster \
  --num-nodes=3 \
  --zone=us-central1-a

# Configure kubectl
gcloud container clusters get-credentials mlops-cluster \
  --zone=us-central1-a
```

### Amazon EKS

```bash
# Install AWS CLI and eksctl
# https://docs.aws.amazon.com/eks/latest/userguide/getting-started-eksctl.html

# Create cluster
eksctl create cluster --name mlops-cluster --region us-east-1
```

### Azure AKS

```bash
# Install Azure CLI
# https://docs.microsoft.com/en-us/cli/azure/install-azure-cli

# Create cluster
az aks create --resource-group mlops-rg --name mlops-cluster

# Configure kubectl
az aks get-credentials --resource-group mlops-rg --name mlops-cluster
```

---

## Verify Setup

After setting up any cluster, verify it's working:

```bash
# Check cluster connection
kubectl cluster-info

# Check nodes
kubectl get nodes

# Check if you can create resources
kubectl get namespaces
```

If all commands work, your cluster is ready!

---

## Troubleshooting

### kubectl: command not found

**Install kubectl:**

**macOS:**
```bash
brew install kubectl
```

**Linux:**
```bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
```

**Windows:**
Download from: https://kubernetes.io/docs/tasks/tools/install-kubectl-windows/

### Cannot connect to cluster

1. **Check if cluster is running:**
   ```bash
   # For minikube
   minikube status
   
   # For kind
   kind get clusters
   
   # For Docker Desktop
   # Check Docker Desktop → Kubernetes status
   ```

2. **Check kubectl context:**
   ```bash
   kubectl config get-contexts
   kubectl config current-context
   ```

3. **Set correct context:**
   ```bash
   # For minikube
   kubectl config use-context minikube
   
   # For kind
   kubectl config use-context kind-mlops
   ```

### minikube start fails

**Common issues:**

1. **Virtualization not enabled:**
   - Enable virtualization in BIOS
   - For macOS: Use HyperKit or VirtualBox driver

2. **Driver issues:**
   ```bash
   # Try different driver
   minikube start --driver=virtualbox
   # or
   minikube start --driver=hyperkit
   ```

3. **Insufficient resources:**
   ```bash
   # Allocate more resources
   minikube start --memory=4096 --cpus=2
   ```

### Docker Desktop Kubernetes not starting

1. Restart Docker Desktop
2. Check Docker Desktop logs
3. Reset Kubernetes in Docker Desktop settings
4. Ensure Docker Desktop has enough resources allocated

---

## Quick Setup Script

For macOS with Homebrew:

```bash
#!/bin/bash
# Quick setup for minikube

# Install minikube and kubectl
brew install minikube kubectl

# Start minikube
minikube start

# Enable addons
minikube addons enable ingress
minikube addons enable metrics-server

# Verify
kubectl cluster-info
kubectl get nodes
```

---

## Next Steps

Once your cluster is set up:

1. **Verify connection:**
   ```bash
   kubectl cluster-info
   ```

2. **Deploy the API:**
   ```bash
   bash scripts/deploy_to_k8s.sh
   ```

3. **Check deployment:**
   ```bash
   kubectl get pods -n mlops
   ```

---

## Recommended Setup for Local Development

**For macOS:**
- Use **minikube** (easiest) or **Docker Desktop Kubernetes**

**For Linux:**
- Use **minikube** or **kind**

**For Windows:**
- Use **Docker Desktop Kubernetes** or **minikube**

**For Production:**
- Use **GKE**, **EKS**, or **AKS** (cloud-managed clusters)

---

## Resources

- [minikube Documentation](https://minikube.sigs.k8s.io/docs/)
- [kind Documentation](https://kind.sigs.k8s.io/)
- [kubectl Documentation](https://kubernetes.io/docs/reference/kubectl/)
- [Docker Desktop Kubernetes](https://docs.docker.com/desktop/kubernetes/)

