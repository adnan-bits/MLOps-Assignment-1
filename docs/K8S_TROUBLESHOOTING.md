# Kubernetes Deployment Troubleshooting

## Common Errors and Solutions

### Error: "deployments.apps 'heart-disease-api' not found"

**Cause:** The deployment wasn't created successfully, or `kubectl wait` ran before the deployment was registered.

**Solutions:**

1. **Check if deployment exists:**
   ```bash
   kubectl get deployment -n mlops
   kubectl get all -n mlops
   ```

2. **Check deployment events:**
   ```bash
   kubectl get events -n mlops --sort-by='.lastTimestamp'
   kubectl describe deployment heart-disease-api -n mlops
   ```

3. **Common causes:**
   - **PVC not found**: If using `deployment.yaml`, the PVC must exist
   - **Image not found**: Docker image must be available in cluster
   - **Namespace not created**: Ensure namespace exists first

4. **Use deployment without PVC:**
   ```bash
   # Delete failed deployment
   kubectl delete deployment heart-disease-api -n mlops
   
   # Use deployment without PVC
   kubectl apply -f k8s/deployment-no-pvc.yaml
   ```

### Error: "persistentvolumeclaim 'heart-disease-models-pvc' not found"

**Cause:** The deployment requires a PVC, but it doesn't exist or isn't bound.

**Solutions:**

1. **Create the PVC:**
   ```bash
   kubectl apply -f k8s/pvc.yaml
   kubectl get pvc -n mlops
   ```

2. **Wait for PVC to be bound:**
   ```bash
   kubectl wait --for=condition=Bound pvc/heart-disease-models-pvc -n mlops --timeout=60s
   ```

3. **Use deployment without PVC instead:**
   ```bash
   kubectl apply -f k8s/deployment-no-pvc.yaml
   ```

### Error: "ImagePullBackOff" or "ErrImagePull"

**Cause:** Kubernetes cannot pull the Docker image.

**Solutions:**

1. **For local clusters (minikube/kind):**
   ```bash
   # minikube
   minikube image load heart-disease-api:latest
   
   # kind
   kind load docker-image heart-disease-api:latest
   ```

2. **For remote clusters:**
   - Push image to container registry
   - Update `deployment.yaml` with registry image path
   - Ensure image pull secrets are configured if needed

3. **Check image name:**
   ```bash
   # Verify image exists locally
   docker images | grep heart-disease-api
   
   # Check deployment image
   kubectl describe deployment heart-disease-api -n mlops | grep Image
   ```

### Error: Pods in "CrashLoopBackOff"

**Cause:** Container is crashing repeatedly.

**Solutions:**

1. **Check pod logs:**
   ```bash
   kubectl logs -f <pod-name> -n mlops
   kubectl logs -f deployment/heart-disease-api -n mlops
   ```

2. **Check pod events:**
   ```bash
   kubectl describe pod <pod-name> -n mlops
   ```

3. **Common causes:**
   - Models not found: Check if models are in `/app/models`
   - Health check failing: Check `/health` endpoint
   - Resource limits: Check if CPU/memory limits are too low

4. **Test container locally:**
   ```bash
   docker run -it heart-disease-api:latest /bin/bash
   # Check if models exist
   ls -la /app/models
   ```

### Error: "Cannot connect to Kubernetes cluster"

**Cause:** kubectl is not configured or cluster is not running.

**Solutions:**

1. **Check cluster status:**
   ```bash
   # minikube
   minikube status
   
   # kind
   kind get clusters
   ```

2. **Configure kubectl:**
   ```bash
   kubectl config get-contexts
   kubectl config use-context <context-name>
   ```

3. **Set up cluster:**
   ```bash
   bash scripts/setup_local_k8s.sh
   ```

### Error: Service not accessible

**Cause:** Service is not properly configured or pods are not ready.

**Solutions:**

1. **Check service endpoints:**
   ```bash
   kubectl get endpoints -n mlops
   kubectl describe service heart-disease-api-service -n mlops
   ```

2. **Check if pods are ready:**
   ```bash
   kubectl get pods -n mlops
   # Pods should be in "Running" state with "1/1" ready
   ```

3. **Test from within cluster:**
   ```bash
   kubectl run -it --rm debug --image=busybox --restart=Never -n mlops -- \
     wget -qO- http://heart-disease-api-service/health
   ```

4. **Use port-forward:**
   ```bash
   kubectl port-forward service/heart-disease-api-service 8000:80 -n mlops
   ```

### Error: Health check failures

**Cause:** Liveness or readiness probes are failing.

**Solutions:**

1. **Check health endpoint:**
   ```bash
   kubectl port-forward service/heart-disease-api-service 8000:80 -n mlops
   curl http://localhost:8000/health
   ```

2. **Adjust probe settings in deployment.yaml:**
   ```yaml
   livenessProbe:
     initialDelaySeconds: 60  # Increase if model loading takes time
     periodSeconds: 10
   ```

3. **Check if API is starting:**
   ```bash
   kubectl logs -f deployment/heart-disease-api -n mlops
   ```

## Debugging Commands

### Check Deployment Status
```bash
kubectl get deployment -n mlops
kubectl describe deployment heart-disease-api -n mlops
kubectl get pods -n mlops
kubectl describe pod <pod-name> -n mlops
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

### Check Events
```bash
kubectl get events -n mlops --sort-by='.lastTimestamp'
kubectl get events -n mlops --field-selector involvedObject.name=heart-disease-api
```

### Check Resources
```bash
kubectl get all -n mlops
kubectl get pvc -n mlops
kubectl get configmap -n mlops
kubectl get service -n mlops
```

### Exec into Pod
```bash
kubectl exec -it <pod-name> -n mlops -- /bin/bash
# Then check:
# - ls -la /app/models
# - curl http://localhost:8000/health
# - ps aux
```

## Quick Fixes

### Redeploy Everything
```bash
# Clean up
bash scripts/undeploy_from_k8s.sh

# Redeploy
bash scripts/deploy_to_k8s.sh
```

### Use Deployment Without PVC
```bash
kubectl delete deployment heart-disease-api -n mlops
kubectl apply -f k8s/deployment-no-pvc.yaml
```

### Restart Deployment
```bash
kubectl rollout restart deployment/heart-disease-api -n mlops
kubectl rollout status deployment/heart-disease-api -n mlops
```

### Scale Deployment
```bash
kubectl scale deployment heart-disease-api --replicas=1 -n mlops
```

## Getting Help

If issues persist:

1. **Check all resources:**
   ```bash
   kubectl get all -n mlops -o wide
   ```

2. **View detailed events:**
   ```bash
   kubectl get events -n mlops --sort-by='.lastTimestamp' | tail -20
   ```

3. **Check cluster status:**
   ```bash
   kubectl cluster-info
   kubectl get nodes
   ```

4. **Review documentation:**
   - `k8s/README.md` - Kubernetes deployment guide
   - `docs/PHASE7_KUBERNETES.md` - Phase 7 documentation
   - `docs/KUBERNETES_SETUP.md` - Cluster setup guide

