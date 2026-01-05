# MLflow Quick Start Guide

## Quick Setup and Run

### Step 1: Install MLflow

```bash
pip install mlflow matplotlib seaborn
```

### Step 2: Run Training with MLflow

```bash
python src/models/train_with_mlflow.py
```

### Step 3: Start MLflow UI

```bash
mlflow ui --backend-store-uri file://$(pwd)/mlruns --port 5000
```

### Step 4: View Results

Open your browser and go to:
```
http://localhost:5000
```

## Using the Helper Script

For an interactive experience, use the helper script:

```bash
python scripts/run_mlflow.py
```

This script will:
1. Check if MLflow is installed
2. Check if data is processed
3. Give you options to:
   - Run training only
   - Start UI only
   - Run training and start UI

## What You'll See

After running training, you'll see:
- **Logistic Regression** run with metrics
- **Random Forest** run with metrics
- Confusion matrix plots
- Classification reports
- Feature importance (for Random Forest)

In the MLflow UI, you can:
- Compare both models
- View detailed metrics
- Download models
- View confusion matrices

## Troubleshooting

### MLflow not installed?
```bash
pip install mlflow
```

### Port 5000 already in use?
```bash
mlflow ui --backend-store-uri file://$(pwd)/mlruns --port 5001
```
Then access at http://localhost:5001

### No experiments showing?
Make sure you've run `train_with_mlflow.py` successfully first.

## Full Documentation

See `docs/MLFLOW_GUIDE.md` for detailed documentation.


