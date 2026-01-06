# Heart Disease Prediction - MLOps Project

End-to-end machine learning solution for predicting heart disease risk using modern MLOps practices.

## Project Structure

```
├── data/
│   ├── raw/              # Raw dataset files
│   └── processed/        # Cleaned and processed datasets
├── notebooks/
│   ├── 01_eda.ipynb      # Exploratory Data Analysis
│   └── 02_modeling.ipynb # Model development and evaluation
├── src/
│   ├── data/             # Data processing modules
│   ├── models/           # Model training and evaluation
│   └── api/              # API endpoints
├── tests/                # Unit tests
├── scripts/              # Utility scripts
├── .github/workflows/    # CI/CD pipelines
├── docker/              # Docker configurations
├── k8s/                 # Kubernetes manifests
└── docs/                # Documentation

```

## Setup Instructions

### 1. Clone the Repository
```bash
git clone <repository-url>
cd MLOps
```

### 2. Create Virtual Environment
```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

### 3. Install Dependencies
```bash
pip install -r requirements.txt
```

### 4. Download Data
```bash
python scripts/download_data.py
```

### 5. Run Data Preprocessing
```bash
python scripts/preprocess_data.py
```

### 6. Run EDA
Open and run `notebooks/01_eda.ipynb` in Jupyter

### 7. Train Models
```bash
python src/models/train.py
```

Or use MLflow tracking:
```bash
python src/models/train_with_mlflow.py
```

### 8. Load and Test Models (Phase 4)
```bash
# Test model inference
python scripts/test_model_inference.py

# Load model for predictions
python src/models/load_model.py

# Reproduce training (with fixed random seeds)
python scripts/reproduce_training.py
```

### 9. Run API Locally (Phase 6)
```bash
# Start the FastAPI server
python scripts/run_api_local.py

# Or use uvicorn directly
uvicorn src.api.app:app --reload --host 0.0.0.0 --port 8000
```

The API will be available at:
- API: http://localhost:8000
- Interactive Docs: http://localhost:8000/docs
- Health Check: http://localhost:8000/health

### 10. Install Docker (Required for Phase 6)

**If Docker is not installed**, install it first:

- **macOS**: Download [Docker Desktop](https://www.docker.com/products/docker-desktop) or use `brew install --cask docker`
- **Linux (Ubuntu/Debian)**: `sudo apt-get install docker.io && sudo systemctl start docker`
- **Linux (CentOS/RHEL)**: `sudo yum install docker && sudo systemctl start docker`
- **Windows**: Download [Docker Desktop](https://www.docker.com/products/docker-desktop)

Verify installation:
```bash
docker --version
docker info
```

### 11. Build and Run Docker Container (Phase 6)

**📖 Quick Start Guide**: See [docs/PHASE6_QUICKSTART.md](docs/PHASE6_QUICKSTART.md) for step-by-step instructions.
```bash
# Build Docker image
docker build -t heart-disease-api:latest .

# Run container
docker run -d -p 8000:8000 --name heart-disease-api heart-disease-api:latest

# Test the containerized API
bash docker/test_api.sh

# Or use the automated script (checks for Docker automatically)
bash scripts/build_and_test_docker.sh

# View logs
docker logs heart-disease-api

# Stop container
docker stop heart-disease-api
docker rm heart-disease-api
```

**Note**: The `build_and_test_docker.sh` script will check if Docker is installed and provide installation instructions if it's missing.

### 12. Test API Endpoints
```bash
# Health check
curl http://localhost:8000/health

# Single prediction
curl -X POST http://localhost:8000/predict \
  -H "Content-Type: application/json" \
  -d @test_request.json

# Model info
curl http://localhost:8000/model/info
```

### 13. Set Up Kubernetes Cluster (Required for Phase 7)

**If you don't have a Kubernetes cluster**, set one up first:

**Quick Setup (Automated):**
```bash
bash scripts/setup_local_k8s.sh
```

**Manual Setup Options:**

1. **minikube** (Recommended):
   ```bash
   brew install minikube kubectl
   minikube start
   ```

2. **kind** (Kubernetes in Docker):
   ```bash
   brew install kind kubectl
   kind create cluster --name mlops
   ```

3. **Docker Desktop** (macOS/Windows):
   - Open Docker Desktop → Settings → Kubernetes → Enable

**📖 Detailed Setup Guide**: See [docs/KUBERNETES_SETUP.md](docs/KUBERNETES_SETUP.md)

**Verify cluster:**
```bash
kubectl cluster-info
kubectl get nodes
```

### 14. Deploy to Kubernetes (Phase 7)

**📖 Kubernetes Guide**: See [k8s/README.md](k8s/README.md) and [docs/PHASE7_KUBERNETES.md](docs/PHASE7_KUBERNETES.md) for detailed instructions.

**Prerequisites:**
- ✅ Kubernetes cluster set up (see step 13)
- ✅ kubectl installed and configured
- ✅ Docker image built

**Quick Deploy:**
```bash
# Automated deployment
bash scripts/deploy_to_k8s.sh

# Or manually
cd k8s
kubectl apply -f namespace.yaml
kubectl apply -f pvc.yaml
kubectl apply -f configmap.yaml
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
```

**Access the API:**
```bash
# Port forward
kubectl port-forward service/heart-disease-api-service 8000:80 -n mlops

# Check status
kubectl get pods -n mlops
kubectl get services -n mlops

# View logs
kubectl logs -f deployment/heart-disease-api -n mlops
```

**Cleanup:**
```bash
bash scripts/undeploy_from_k8s.sh
```

## Dataset

Heart Disease UCI Dataset from UCI Machine Learning Repository
- 14 features (age, sex, blood pressure, cholesterol, etc.)
- Binary target: presence/absence of heart disease

## Features

- ✅ Data preprocessing and EDA
- ✅ Multiple ML models (Logistic Regression, Random Forest)
- ✅ MLflow experiment tracking
- ✅ Model packaging and reproducibility (Phase 4)
- ✅ CI/CD pipeline with GitHub Actions
- ✅ **FastAPI REST API for model serving** (Phase 6)
- ✅ **Docker containerization** (Phase 6)
- ✅ **Kubernetes deployment** (Phase 7)
- ⏳ Monitoring and logging (Phase 8)

## License

This project is for educational purposes.

