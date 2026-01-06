# Complete Deployment Guide

This guide provides step-by-step instructions for deploying the Heart Disease Prediction API from scratch to production.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Local Development Setup](#local-development-setup)
3. [Docker Deployment](#docker-deployment)
4. [Kubernetes Deployment](#kubernetes-deployment)
5. [Production Deployment](#production-deployment)
6. [Verification](#verification)
7. [Troubleshooting](#troubleshooting)

---

## Prerequisites

### Required Software
- Python 3.9+
- pip
- Git
- Docker (for containerized deployment)
- kubectl (for Kubernetes deployment)
- Kubernetes cluster (for K8s deployment)

### Optional Software
- minikube or kind (for local K8s)
- Prometheus (for monitoring)
- Grafana (for visualization)

---

## Local Development Setup

### Step 1: Clone Repository
```bash
git clone <repository-url>
cd MLOps
```

### Step 2: Create Virtual Environment
```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

### Step 3: Install Dependencies
```bash
pip install -r requirements.txt
```

### Step 4: Download and Preprocess Data
```bash
# Download raw data
python scripts/download_data.py

# Preprocess data
python scripts/preprocess_data.py
```

### Step 5: Train Models
```bash
# Train models
python src/models/train.py

# Or with MLflow tracking
python src/models/train_with_mlflow.py
```

### Step 6: Run API Locally
```bash
# Start API server
python scripts/run_api_local.py

# Or with uvicorn
uvicorn src.api.app:app --reload --host 0.0.0.0 --port 8000
```

### Step 7: Verify API
```bash
# Health check
curl http://localhost:8000/health

# Test prediction
curl -X POST http://localhost:8000/predict \
  -H "Content-Type: application/json" \
  -d @test_request.json

# View API docs
open http://localhost:8000/docs
```

---

## Docker Deployment

### Step 1: Install Docker
See [Docker Installation Guide](DOCKER_INSTALLATION.md)

### Step 2: Build Docker Image
```bash
# Build image
docker build -t heart-disease-api:latest .

# Verify image
docker images | grep heart-disease-api
```

### Step 3: Run Container
```bash
# Run container
docker run -d -p 8000:8000 --name heart-disease-api heart-disease-api:latest

# Or use automated script
bash scripts/build_and_test_docker.sh
```

### Step 4: Test Container
```bash
# Health check
curl http://localhost:8000/health

# Test API
bash docker/test_api.sh
```

### Step 5: View Logs
```bash
docker logs heart-disease-api
docker logs -f heart-disease-api  # Follow logs
```

### Step 6: Stop Container
```bash
docker stop heart-disease-api
docker rm heart-disease-api
```

---

## Kubernetes Deployment

### Step 1: Set Up Kubernetes Cluster

#### Option A: minikube (Recommended for Local)
```bash
# Install minikube
brew install minikube kubectl  # macOS
# Or see: https://minikube.sigs.k8s.io/docs/start/

# Start cluster
minikube start

# Verify
kubectl cluster-info
```

#### Option B: kind
```bash
# Install kind
brew install kind kubectl

# Create cluster
kind create cluster --name mlops

# Verify
kubectl cluster-info --context kind-mlops
```

#### Option C: Cloud Cluster (GKE/EKS/AKS)
See [Kubernetes Setup Guide](KUBERNETES_SETUP.md)

### Step 2: Prepare Docker Image

#### For Local Clusters (minikube/kind)
```bash
# Build image
docker build -t heart-disease-api:latest .

# Load into cluster
minikube image load heart-disease-api:latest
# or
kind load docker-image heart-disease-api:latest
```

#### For Remote Clusters
```bash
# Tag for registry
docker tag heart-disease-api:latest <registry>/heart-disease-api:latest

# Push to registry
docker push <registry>/heart-disease-api:latest

# Update deployment.yaml with registry image
```

### Step 3: Deploy to Kubernetes

#### Automated Deployment
```bash
bash scripts/deploy_to_k8s.sh
```

#### Manual Deployment
```bash
cd k8s

# Create namespace
kubectl apply -f namespace.yaml

# Create PVC (optional, for persistent storage)
kubectl apply -f pvc.yaml

# Create ConfigMap
kubectl apply -f configmap.yaml

# Deploy application
kubectl apply -f deployment.yaml
# Or use deployment-no-pvc.yaml if PVC not available

# Create service
kubectl apply -f service.yaml
```

### Step 4: Verify Deployment
```bash
# Check pods
kubectl get pods -n mlops

# Check services
kubectl get services -n mlops

# Check deployment
kubectl get deployment -n mlops

# View logs
kubectl logs -f deployment/heart-disease-api -n mlops
```

### Step 5: Access API

#### Port Forward
```bash
kubectl port-forward service/heart-disease-api-service 8000:80 -n mlops
# Access at http://localhost:8000
```

#### NodePort
```bash
kubectl apply -f service-nodeport.yaml
# Access at http://<node-ip>:30080
```

#### Ingress
```bash
kubectl apply -f ingress.yaml
# Configure DNS and access via domain
```

### Step 6: Enable Auto-Scaling (Optional)
```bash
kubectl apply -f hpa.yaml
```

---

## Production Deployment

### Step 1: Prepare Production Environment

#### 1.1 Container Registry
```bash
# Push to production registry
docker tag heart-disease-api:latest <prod-registry>/heart-disease-api:v1.0.0
docker push <prod-registry>/heart-disease-api:v1.0.0
```

#### 1.2 Update Deployment
```yaml
# Update k8s/deployment.yaml
image: <prod-registry>/heart-disease-api:v1.0.0
imagePullPolicy: Always
```

#### 1.3 Configure Secrets
```bash
# Create secrets for sensitive data
kubectl create secret generic api-secrets \
  --from-literal=api-key=your-key \
  -n mlops
```

### Step 2: Production Configuration

#### 2.1 Resource Limits
```yaml
# Adjust in deployment.yaml
resources:
  requests:
    memory: "512Mi"
    cpu: "500m"
  limits:
    memory: "1Gi"
    cpu: "1000m"
```

#### 2.2 Replicas
```yaml
# Set appropriate replicas
replicas: 5  # Adjust based on load
```

#### 2.3 Environment Variables
```yaml
env:
- name: LOG_LEVEL
  value: "INFO"
- name: JSON_LOGS
  value: "true"
```

### Step 3: Deploy
```bash
# Apply production configuration
kubectl apply -f k8s/deployment.yaml -n mlops

# Verify
kubectl rollout status deployment/heart-disease-api -n mlops
```

### Step 4: Set Up Monitoring

#### 4.1 Prometheus
```bash
# Apply ServiceMonitor (if using Prometheus Operator)
kubectl apply -f k8s/servicemonitor.yaml

# Or configure Prometheus to scrape /metrics endpoint
```

#### 4.2 Grafana (Optional)
- Import Prometheus as data source
- Create dashboards for metrics
- Set up alerts

---

## Verification

### Health Checks
```bash
# Local
curl http://localhost:8000/health

# Docker
curl http://localhost:8000/health

# Kubernetes
kubectl port-forward service/heart-disease-api-service 8000:80 -n mlops
curl http://localhost:8000/health
```

### API Testing
```bash
# Single prediction
curl -X POST http://localhost:8000/predict \
  -H "Content-Type: application/json" \
  -d @test_request.json

# Batch prediction
curl -X POST http://localhost:8000/predict/batch \
  -H "Content-Type: application/json" \
  -d '[{...}, {...}]'

# Model info
curl http://localhost:8000/model/info

# Metrics
curl http://localhost:8000/metrics
```

### Load Testing (Optional)
```bash
# Install hey or use ab
hey -n 1000 -c 10 http://localhost:8000/health
```

---

## Troubleshooting

### Common Issues

#### 1. API Not Starting
```bash
# Check logs
docker logs heart-disease-api
# or
kubectl logs -f deployment/heart-disease-api -n mlops

# Check if models exist
ls -la models/
```

#### 2. Models Not Found
```bash
# Ensure models are trained
python src/models/train.py

# Check model directory in container
docker exec heart-disease-api ls -la /app/models
```

#### 3. Kubernetes Pods Not Starting
```bash
# Check pod status
kubectl describe pod <pod-name> -n mlops

# Check events
kubectl get events -n mlops --sort-by='.lastTimestamp'
```

#### 4. Service Not Accessible
```bash
# Check service endpoints
kubectl get endpoints -n mlops

# Test from within cluster
kubectl run -it --rm debug --image=busybox --restart=Never -n mlops -- \
  wget -qO- http://heart-disease-api-service/health
```

### Debugging Commands

```bash
# Kubernetes
kubectl get all -n mlops
kubectl describe deployment heart-disease-api -n mlops
kubectl logs -f deployment/heart-disease-api -n mlops

# Docker
docker ps
docker logs heart-disease-api
docker exec -it heart-disease-api /bin/bash
```

---

## Cleanup

### Docker
```bash
docker stop heart-disease-api
docker rm heart-disease-api
docker rmi heart-disease-api:latest
```

### Kubernetes
```bash
# Remove all resources
bash scripts/undeploy_from_k8s.sh

# Or manually
kubectl delete -f k8s/deployment.yaml
kubectl delete -f k8s/service.yaml
kubectl delete namespace mlops
```

---

## Next Steps

After deployment:
1. Set up monitoring dashboards
2. Configure alerting rules
3. Set up log aggregation
4. Implement backup strategies
5. Plan for scaling

---

## References

- [Docker Installation](DOCKER_INSTALLATION.md)
- [Kubernetes Setup](KUBERNETES_SETUP.md)
- [Kubernetes Troubleshooting](K8S_TROUBLESHOOTING.md)
- [Phase 6: Containerization](PHASE6_CONTAINERIZATION.md)
- [Phase 7: Kubernetes](PHASE7_KUBERNETES.md)

