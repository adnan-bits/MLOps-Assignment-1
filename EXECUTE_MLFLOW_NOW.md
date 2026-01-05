# Execute MLflow Training - Quick Steps

## Step 1: Install MLflow (Run this in your terminal)

```bash
pip install mlflow matplotlib seaborn
```

If that doesn't work, try:
```bash
pip install --upgrade pip
pip install mlflow matplotlib seaborn
```

Or with conda:
```bash
conda install -c conda-forge mlflow matplotlib seaborn
```

## Step 2: Verify Installation

```bash
python -c "import mlflow; print('MLflow version:', mlflow.__version__)"
```

## Step 3: Run MLflow Training

Once MLflow is installed, run:

```bash
cd /Users/a0k04ou/Desktop/MLOPs
python src/models/train_with_mlflow.py
```

This will:
- Load and preprocess the data
- Train Logistic Regression model
- Train Random Forest model
- Log all metrics, parameters, and artifacts to MLflow
- Create confusion matrix plots
- Save models to MLflow

## Step 4: Start MLflow UI

After training completes, in a **NEW terminal window**, run:

```bash
cd /Users/a0k04ou/Desktop/MLOPs
mlflow ui --backend-store-uri file://$(pwd)/mlruns --port 5000
```

## Step 5: View Results

Open your browser and navigate to:
```
http://localhost:5000
```

You'll see:
- Experiment: "heart_disease_prediction"
- Two runs: Logistic_Regression and Random_Forest
- All metrics (Accuracy, Precision, Recall, ROC-AUC)
- Confusion matrices
- Classification reports
- Saved models

## Quick One-Liner Commands

**Install and run training:**
```bash
pip install mlflow matplotlib seaborn && cd /Users/a0k04ou/Desktop/MLOPs && python src/models/train_with_mlflow.py
```

**Start UI (in new terminal):**
```bash
cd /Users/a0k04ou/Desktop/MLOPs && mlflow ui --backend-store-uri file://$(pwd)/mlruns --port 5000
```

