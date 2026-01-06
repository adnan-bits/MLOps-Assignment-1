# Kubernetes Deployment Manifests

This directory contains Kubernetes manifests for deploying the Heart Disease Prediction API.

## Files Overview

- `namespace.yaml` - Creates the `mlops` namespace
- `deployment.yaml` - Deploys the API with 3 replicas
- `service.yaml` - ClusterIP service for internal access
- `service-nodeport.yaml` - NodePort service for external access (alternative)
- `configmap.yaml` - Configuration for the API
- `pvc.yaml` - Persistent volume claim for model files
- `ingress.yaml` - Ingress for external access (requires ingress controller)
- `kustomization.yaml` - Kustomize configuration for managing resources

## Prerequisites

1. **Kubernetes cluster** (minikube, kind, GKE, EKS, AKS, or local cluster)
2. **kubectl** configured to access your cluster
3. **Docker image** built and available:
   - For local clusters: Image must be available locally or in a registry
   - For cloud clusters: Image must be pushed to a container registry

## Quick Start

### 1. Build and Push Docker Image

#### For Local Development (minikube/kind):

```bash
# Build image
docker build -t heart-disease-api:latest .

# For minikube, load image into minikube
minikube image load heart-disease-api:latest

# For kind, load image into kind
kind load docker-image heart-disease-api:latest
```

#### For Cloud/Remote Clusters:

```bash
# Tag image for your registry
docker tag heart-disease-api:latest <your-registry>/heart-disease-api:latest

# Push to registry
docker push <your-registry>/heart-disease-api:latest

# Update deployment.yaml to use the registry image
```

### 2. Prepare Models

The deployment expects models in a PersistentVolume. You have two options:

#### Option A: Use PersistentVolume (Recommended for Production)

```bash
# Create a pod to copy models
kubectl run model-copy-pod --image=busybox --rm -it --restart=Never -- \
  sh -c "echo 'Copy your models here'"

# Or use kubectl cp after creating the PVC
kubectl apply -f pvc.yaml
# Then copy models to the volume
```

#### Option B: Use ConfigMap (For Small Models)

If models are small, you can use ConfigMap (not recommended for production).

### 3. Deploy to Kubernetes

#### Using kubectl (Basic):

```bash
# Create namespace
kubectl apply -f namespace.yaml

# Create PVC for models
kubectl apply -f pvc.yaml

# Create ConfigMap
kubectl apply -f configmap.yaml

# Deploy application
kubectl apply -f deployment.yaml

# Create service
kubectl apply -f service.yaml

# Optional: Create ingress
kubectl apply -f ingress.yaml
```

#### Using Kustomize:

```bash
# Deploy everything
kubectl apply -k .

# Or with specific namespace
kubectl apply -k . -n mlops
```

### 4. Verify Deployment

```bash
# Check namespace
kubectl get namespace mlops

# Check pods
kubectl get pods -n mlops

# Check services
kubectl get services -n mlops

# Check deployment
kubectl get deployment -n mlops

# View pod logs
kubectl logs -f deployment/heart-disease-api -n mlops

# Describe pod for troubleshooting
kubectl describe pod -l app=heart-disease-api -n mlops
```

### 5. Access the API

#### Using ClusterIP Service (Internal):

```bash
# Port forward to access locally
kubectl port-forward service/heart-disease-api-service 8000:80 -n mlops

# Then access at http://localhost:8000
```

#### Using NodePort Service (External):

```bash
# Apply NodePort service
kubectl apply -f service-nodeport.yaml

# Get node IP
kubectl get nodes -o wide

# Access at http://<node-ip>:30080
```

#### Using Ingress (External with Domain):

```bash
# Apply ingress (requires ingress controller)
kubectl apply -f ingress.yaml

# Update /etc/hosts or DNS
echo "<node-ip> heart-disease-api.local" >> /etc/hosts

# Access at http://heart-disease-api.local
```

## Configuration

### Update Image

If using a container registry, update `deployment.yaml`:

```yaml
spec:
  template:
    spec:
      containers:
      - name: heart-disease-api
        image: <your-registry>/heart-disease-api:latest  # Update this
```

### Adjust Replicas

Edit `deployment.yaml`:

```yaml
spec:
  replicas: 3  # Change number of replicas
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

## Troubleshooting

### Pods Not Starting

```bash
# Check pod status
kubectl get pods -n mlops

# Check pod logs
kubectl logs <pod-name> -n mlops

# Describe pod for events
kubectl describe pod <pod-name> -n mlops
```

### Image Pull Errors

```bash
# For local clusters, ensure image is loaded
minikube image load heart-disease-api:latest
# or
kind load docker-image heart-disease-api:latest

# For remote clusters, ensure image is pushed to registry
docker push <your-registry>/heart-disease-api:latest
```

### Models Not Found

```bash
# Check PVC status
kubectl get pvc -n mlops

# Check if models are mounted
kubectl exec -it <pod-name> -n mlops -- ls -la /app/models
```

### Service Not Accessible

```bash
# Check service endpoints
kubectl get endpoints -n mlops

# Test service from within cluster
kubectl run -it --rm debug --image=busybox --restart=Never -n mlops -- \
  wget -qO- http://heart-disease-api-service/health
```

## Scaling

### Manual Scaling

```bash
kubectl scale deployment heart-disease-api --replicas=5 -n mlops
```

### Horizontal Pod Autoscaler (HPA)

Create `hpa.yaml`:

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: heart-disease-api-hpa
  namespace: mlops
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: heart-disease-api
  minReplicas: 3
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
```

Apply:
```bash
kubectl apply -f hpa.yaml
```

## Cleanup

```bash
# Delete all resources
kubectl delete -k .

# Or delete individually
kubectl delete -f deployment.yaml
kubectl delete -f service.yaml
kubectl delete -f configmap.yaml
kubectl delete -f pvc.yaml
kubectl delete -f namespace.yaml
```

## Production Considerations

1. **Image Registry**: Use a proper container registry (Docker Hub, GCR, ECR, ACR)
2. **Secrets**: Store sensitive data in Kubernetes Secrets
3. **Resource Limits**: Adjust based on workload
4. **Health Checks**: Verify liveness/readiness probes
5. **Monitoring**: Add Prometheus metrics and monitoring
6. **Logging**: Configure centralized logging
7. **Security**: Use RBAC, network policies, and pod security policies
8. **Backup**: Backup models and configuration

## Next Steps

After Phase 7, proceed to:
- **Phase 8**: Monitoring and logging integration
- Add Prometheus metrics
- Configure Grafana dashboards
- Set up alerting

