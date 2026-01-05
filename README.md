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

## Dataset

Heart Disease UCI Dataset from UCI Machine Learning Repository
- 14 features (age, sex, blood pressure, cholesterol, etc.)
- Binary target: presence/absence of heart disease

## Features

- ✅ Data preprocessing and EDA
- ✅ Multiple ML models (Logistic Regression, Random Forest)
- ✅ MLflow experiment tracking
- ✅ **Model packaging and reproducibility** (Phase 4)
- ✅ CI/CD pipeline with GitHub Actions
- ✅ Docker containerization
- ✅ Kubernetes deployment
- ✅ Monitoring and logging

## License

This project is for educational purposes.

