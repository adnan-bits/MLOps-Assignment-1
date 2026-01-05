#!/usr/bin/env python3
"""
Simple script to run MLflow training experiment.
Checks prerequisites and runs training.
"""

import sys
import subprocess
from pathlib import Path

def check_mlflow():
    """Check if MLflow is installed."""
    try:
        import mlflow
        print(f"✅ MLflow is installed (version: {mlflow.__version__})")
        return True
    except ImportError:
        print("❌ MLflow is not installed")
        print("\nPlease install MLflow first:")
        print("  pip install mlflow matplotlib seaborn")
        print("\nOr:")
        print("  conda install -c conda-forge mlflow matplotlib seaborn")
        return False

def check_data():
    """Check if processed data exists."""
    data_path = Path("data/processed/heart_disease_processed.csv")
    if data_path.exists():
        print("✅ Processed data found")
        return True
    else:
        print("❌ Processed data not found")
        print("\nPlease run preprocessing first:")
        print("  python scripts/preprocess_data.py")
        return False

def main():
    """Main function."""
    print("=" * 60)
    print("MLflow Training Experiment - Prerequisites Check")
    print("=" * 60)
    
    # Check prerequisites
    mlflow_ok = check_mlflow()
    data_ok = check_data()
    
    if not mlflow_ok or not data_ok:
        print("\n" + "=" * 60)
        print("Please fix the issues above and try again.")
        print("=" * 60)
        sys.exit(1)
    
    # Run training
    print("\n" + "=" * 60)
    print("Starting MLflow Training...")
    print("=" * 60)
    
    train_script = Path("src/models/train_with_mlflow.py")
    
    try:
        subprocess.run([sys.executable, str(train_script)], check=True)
        print("\n" + "=" * 60)
        print("✅ Training completed successfully!")
        print("=" * 60)
        print("\nNext steps:")
        print("1. Open a NEW terminal window")
        print("2. Run: cd /Users/a0k04ou/Desktop/MLOPs")
        print("3. Run: mlflow ui --backend-store-uri file://$(pwd)/mlruns --port 5000")
        print("4. Open browser: http://localhost:5000")
        print("=" * 60)
    except subprocess.CalledProcessError as e:
        print(f"\n❌ Training failed: {e}")
        sys.exit(1)
    except KeyboardInterrupt:
        print("\n\nTraining interrupted by user.")
        sys.exit(1)

if __name__ == "__main__":
    main()

