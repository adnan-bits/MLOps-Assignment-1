# Phase 7: Kubernetes Deployment

## Overview

Phase 7 implements Kubernetes deployment manifests for the Heart Disease Prediction API, enabling:
- Container orchestration and scaling
- High availability with multiple replicas
- Load balancing across pods
- Health checks and auto-recovery
- Resource management and limits
- Easy deployment and management

## Components

### 1. Kubernetes Manifests

All manifests are located in the `k8s/` directory:

- **`namespace.yaml`** - Creates the `mlops` namespace
- **`deployment.yaml`** - Deploys the API with 3 replicas and PVC
- **`deployment-no-pvc.yaml`** - Alternative deployment without PVC (models in image)
- **`service.yaml`** - ClusterIP service for internal access
- **`service-nodeport.yaml`** - NodePort service for external access
- **`configmap.yaml`** - Configuration for the API
- **`pvc.yaml`** - Persistent volume claim for model files
- **`ingress.yaml`** - Ingress for external access (requires ingress controller)
- **`hpa.yaml`** - Horizontal Pod Autoscaler for automatic scaling
- **`kustomization.yaml`** - Kustomize configuration

### 2. Deployment Scripts

- **`scripts/deploy_to_k8s.sh`** - Automated deployment script
- **`scripts/undeploy_from_k8s.sh`** - Cleanup script

## Prerequisites

1. **Kubernetes Cluster**
   - minikube (local development)
   - kind (local development)
   - GKE, EKS, AKS (cloud)
   - Any Kubernetes 1.20+ cluster

2. **kubectl** installed and configured
   ```bash
   kubectl version --client
   kubectl cluster-info
   ```

3. **Docker Image**
   - Built locally: `docker build -t heart-disease-api:latest .`
   - For local clusters: Load image into cluster
   - For remote clusters: Push to container registry

## Quick Start

### Option 1: Automated Deployment

```bash
# Deploy everything automatically
bash scripts/deploy_to_k8s.sh
```

The script will:
- Check for kubectl
- Build Docker image if needed
- Load image into cluster (minikube/kind)
- Deploy all Kubernetes resources
- Wait for deployment to be ready
- Show access instructions

### Option 2: Manual Deployment

#### Step 1: Prepare Docker Image

**For minikube:**
```bash
docker build -t heart-disease-api:latest .
minikube image load heart-disease-api:latest
```

**For kind:**
```bash
docker build -t heart-disease-api:latest .
kind load docker-image heart-disease-api:latest
```

**For remote clusters:**
```bash
docker build -t <registry>/heart-disease-api:latest .
docker push <registry>/heart-disease-api:latest
# Update deployment.yaml with registry image
```

#### Step 2: Deploy to Kubernetes

```bash
cd k8s

# Create namespace
kubectl apply -f namespace.yaml

# Create PVC (if using persistent storage)
kubectl apply -f pvc.yaml

# Create ConfigMap
kubectl apply -f configmap.yaml

# Deploy application
kubectl apply -f deployment.yaml

# Create service
kubectl apply -f service.yaml
```

#### Step 3: Verify Deployment

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

#### Step 4: Access the API

**Port Forward (Recommended for testing):**
```bash
kubectl port-forward service/heart-disease-api-service 8000:80 -n mlops
# Access at http://localhost:8000
```

**NodePort (External access):**
```bash
kubectl apply -f service-nodeport.yaml
# Access at http://<node-ip>:30080
```

**Ingress (With domain):**
```bash
kubectl apply -f ingress.yaml
# Configure DNS or /etc/hosts
# Access at http://heart-disease-api.local
```

## Deployment Options

### Option A: With Persistent Volume (Recommended for Production)

Uses `deployment.yaml` which mounts models from a PVC:

```bash
kubectl apply -f pvc.yaml
kubectl apply -f deployment.yaml
```

**Pros:**
- Models can be updated without rebuilding image
- Models persist across pod restarts
- Can share models across replicas

**Cons:**
- Requires PVC setup
- Need to copy models to volume

### Option B: Models in Image (Simpler)

Uses `deployment-no-pvc.yaml` which includes models in the Docker image:

```bash
kubectl apply -f deployment-no-pvc.yaml
```

**Pros:**
- Simpler setup
- No PVC required
- Models are versioned with image

**Cons:**
- Need to rebuild image to update models
- Larger image size

## Configuration

### Adjust Replicas

Edit `deployment.yaml`:

```yaml
spec:
  replicas: 5  # Change number of replicas
```

Or scale dynamically:

```bash
kubectl scale deployment heart-disease-api --replicas=5 -n mlops
```

### Resource Limits

Edit `deployment.yaml`:

```yaml
resources:
  requests:
    memory: "256Mi"
    cpu: "250m"
  limits:
    memory: "512Mi"
    cpu: "500m"
```

### Enable Auto-Scaling

```bash
kubectl apply -f hpa.yaml
```

This will automatically scale between 3-10 replicas based on CPU/memory usage.

## Health Checks

The deployment includes:

- **Liveness Probe**: Checks if container is alive
  - Path: `/health`
  - Initial delay: 30s
  - Period: 10s

- **Readiness Probe**: Checks if container is ready to serve traffic
  - Path: `/health`
  - Initial delay: 10s
  - Period: 5s

## Monitoring

### View Pod Status

```bash
kubectl get pods -n mlops -w
```

### View Logs

```bash
# All pods
kubectl logs -f deployment/heart-disease-api -n mlops

# Specific pod
kubectl logs <pod-name> -n mlops

# Previous container (if restarted)
kubectl logs <pod-name> -n mlops --previous
```

### Describe Resources

```bash
kubectl describe deployment heart-disease-api -n mlops
kubectl describe pod <pod-name> -n mlops
kubectl describe service heart-disease-api-service -n mlops
```

## Troubleshooting

### Pods Not Starting

```bash
# Check pod status
kubectl get pods -n mlops

# Check events
kubectl describe pod <pod-name> -n mlops

# Check logs
kubectl logs <pod-name> -n mlops
```

Common issues:
- Image pull errors → Ensure image is available
- PVC not found → Create PVC first
- Resource limits → Adjust in deployment.yaml
- Health check failures → Check API health endpoint

### Service Not Accessible

```bash
# Check service endpoints
kubectl get endpoints -n mlops

# Test from within cluster
kubectl run -it --rm debug --image=busybox --restart=Never -n mlops -- \
  wget -qO- http://heart-disease-api-service/health
```

### Models Not Found

```bash
# Check if models are mounted
kubectl exec -it <pod-name> -n mlops -- ls -la /app/models

# Check PVC status
kubectl get pvc -n mlops
```

## Cleanup

### Remove All Resources

```bash
# Using script
bash scripts/undeploy_from_k8s.sh

# Or manually
kubectl delete -f deployment.yaml
kubectl delete -f service.yaml
kubectl delete -f configmap.yaml
kubectl delete -f pvc.yaml
kubectl delete namespace mlops
```

## Production Considerations

1. **Image Registry**: Use a proper container registry
2. **Secrets**: Store sensitive data in Kubernetes Secrets
3. **Resource Limits**: Adjust based on workload analysis
4. **Replicas**: Set appropriate number for availability
5. **HPA**: Enable auto-scaling for variable load
6. **Monitoring**: Integrate with Prometheus/Grafana
7. **Logging**: Configure centralized logging
8. **Security**: Use RBAC, network policies, pod security
9. **Backup**: Backup models and configuration
10. **CI/CD**: Automate deployment pipeline

## Local Development with minikube

### Setup minikube

```bash
# Install minikube
brew install minikube  # macOS
# Or see: https://minikube.sigs.k8s.io/docs/start/

# Start minikube
minikube start

# Enable ingress (optional)
minikube addons enable ingress
```

### Deploy

```bash
# Build and load image
docker build -t heart-disease-api:latest .
minikube image load heart-disease-api:latest

# Deploy
bash scripts/deploy_to_k8s.sh
```

### Access

```bash
# Port forward
kubectl port-forward service/heart-disease-api-service 8000:80 -n mlops

# Or use minikube service
minikube service heart-disease-api-service -n mlops
```

## Next Steps

After Phase 7, proceed to:
- **Phase 8**: Monitoring and logging integration
- Add Prometheus metrics endpoint
- Configure Grafana dashboards
- Set up alerting

## References

- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
- [minikube Documentation](https://minikube.sigs.k8s.io/docs/)
- [Kustomize Documentation](https://kustomize.io/)

