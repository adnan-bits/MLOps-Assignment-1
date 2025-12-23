# Quick Start Guide

This guide will help you quickly get started with the Heart Disease Prediction MLOps project.

## Prerequisites

- Python 3.8 or higher
- pip package manager

## Setup Steps

### 1. Create Virtual Environment

```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

### 2. Install Dependencies

```bash
pip install -r requirements.txt
```

### 3. Download and Preprocess Data

```bash
# Download raw data
python scripts/download_data.py

# Preprocess data
python scripts/preprocess_data.py
```

### 4. Run Exploratory Data Analysis

Open Jupyter Notebook:
```bash
jupyter notebook notebooks/01_eda.ipynb
```

Run all cells to see:
- Data overview and statistics
- Missing value analysis
- Class distribution
- Feature distributions (histograms)
- Correlation heatmap
- Feature analysis by target

### 5. Train Models

**Option A: Train without MLflow tracking**
```bash
python src/models/train.py
```

**Option B: Train with MLflow tracking (Recommended)**
```bash
python src/models/train_with_mlflow.py
```

After training with MLflow, view results:
```bash
mlflow ui --backend-store-uri file://$(pwd)/mlruns
```

Then open http://localhost:5000 in your browser.

### 6. Run Modeling Notebook

Open Jupyter Notebook:
```bash
jupyter notebook notebooks/02_modeling.ipynb
```

This notebook includes:
- Model training (Logistic Regression and Random Forest)
- Model evaluation with multiple metrics
- Model comparison
- ROC curves
- Confusion matrices
- Feature importance analysis

## Project Structure

```
MLOPs/
├── data/
│   ├── raw/              # Raw dataset files
│   └── processed/        # Cleaned and processed datasets
├── notebooks/
│   ├── 01_eda.ipynb      # Exploratory Data Analysis
│   └── 02_modeling.ipynb # Model development
├── src/
│   ├── data/             # Data processing modules
│   ├── models/           # Model training scripts
│   └── api/              # API endpoints (Phase 4+)
├── scripts/              # Utility scripts
│   ├── download_data.py
│   └── preprocess_data.py
├── models/               # Saved trained models
├── tests/                # Unit tests (Phase 5)
└── requirements.txt      # Python dependencies
```

## Next Steps

After completing Phases 1-3, proceed with:
- **Phase 4**: Model Packaging & Reproducibility
- **Phase 5**: CI/CD Pipeline & Automated Testing
- **Phase 6**: Model Containerization
- **Phase 7**: Production Deployment
- **Phase 8**: Monitoring & Logging
- **Phase 9**: Documentation & Reporting

## Troubleshooting

### Import Errors
If you encounter import errors, make sure:
1. You're in the project root directory
2. Virtual environment is activated
3. All dependencies are installed: `pip install -r requirements.txt`

### Data Not Found
If data files are not found:
1. Run `python scripts/download_data.py` first
2. Then run `python scripts/preprocess_data.py`

### MLflow Issues
If MLflow UI doesn't start:
- Check that `mlruns/` directory exists
- Try: `mlflow ui --backend-store-uri file:///absolute/path/to/mlruns`

## Support

For issues or questions, refer to the main README.md file.

