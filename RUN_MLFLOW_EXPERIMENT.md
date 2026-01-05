# Run MLflow Experiment - Step by Step

## Step 1: Install MLflow

Open your terminal and run:

```bash
pip install mlflow matplotlib seaborn
```

If you're using conda:
```bash
conda install -c conda-forge mlflow matplotlib seaborn
```

## Step 2: Verify Installation

```bash
python -c "import mlflow; print('MLflow version:', mlflow.__version__)"
```

You should see: `MLflow version: 2.x.x`

## Step 3: Run the MLflow Training

```bash
cd /Users/a0k04ou/Desktop/MLOPs
python src/models/train_with_mlflow.py
```

## Step 4: Start MLflow UI

After training completes, in a **new terminal window**, run:

```bash
cd /Users/a0k04ou/Desktop/MLOPs
mlflow ui --backend-store-uri file://$(pwd)/mlruns --port 5000
```

## Step 5: View Results

Open your browser and go to:
```
http://localhost:5000
```

## What You'll See

- **Experiment**: "heart_disease_prediction"
- **Runs**: 
  - Logistic_Regression
  - Random_Forest
- **Metrics**: Accuracy, Precision, Recall, ROC-AUC
- **Artifacts**: Models, confusion matrices, classification reports

## Troubleshooting

### If MLflow installation fails:
Try:
```bash
pip install --upgrade pip
pip install mlflow
```

### If port 5000 is busy:
```bash
mlflow ui --backend-store-uri file://$(pwd)/mlruns --port 5001
```
Then access at http://localhost:5001

### If you see "No experiments found":
Make sure you've run `train_with_mlflow.py` successfully first.


