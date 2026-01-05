"""
Setup script for Heart Disease Prediction MLOps project.
"""

from setuptools import setup, find_packages
from pathlib import Path

# Read README for long description
readme_file = Path(__file__).parent / "README.md"
long_description = ""
if readme_file.exists():
    long_description = readme_file.read_text(encoding='utf-8')

setup(
    name="heart-disease-mlops",
    version="1.0.0",
    description="Heart Disease Prediction MLOps Project",
    long_description=long_description,
    long_description_content_type="text/markdown",
    author="MLOps Assignment",
    packages=find_packages(exclude=["tests", "tests.*"]),
    python_requires=">=3.9",
    install_requires=[
        "pandas>=2.1.4",
        "numpy>=1.26.2",
        "scikit-learn>=1.3.2",
        "matplotlib>=3.8.2",
        "seaborn>=0.13.0",
    ],
    extras_require={
        "mlflow": ["mlflow>=2.9.2"],
        "api": ["fastapi>=0.109.0", "uvicorn>=0.27.0", "pydantic>=2.5.3"],
        "dev": ["pytest>=7.4.4", "pytest-cov>=4.1.0", "pylint>=3.0.3", "flake8>=7.0.0"],
    },
)

