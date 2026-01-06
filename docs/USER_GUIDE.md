# User Guide: Heart Disease Prediction API

This guide explains how to use the Heart Disease Prediction API for making predictions.

## Table of Contents

1. [API Overview](#api-overview)
2. [Getting Started](#getting-started)
3. [API Endpoints](#api-endpoints)
4. [Making Predictions](#making-predictions)
5. [Example Code](#example-code)
6. [Error Handling](#error-handling)
7. [Best Practices](#best-practices)

---

## API Overview

The Heart Disease Prediction API is a RESTful service that predicts the risk of heart disease based on patient health data.

### Base URL
- **Local**: `http://localhost:8000`
- **Docker**: `http://localhost:8000`
- **Kubernetes**: Depends on deployment (use port-forward or ingress)

### API Version
Current version: **1.0.0**

---

## Getting Started

### 1. Check API Status
```bash
curl http://localhost:8000/health
```

Expected response:
```json
{
  "status": "healthy",
  "model_loaded": true,
  "message": "API is ready to serve predictions"
}
```

### 2. View API Documentation
Open in browser: `http://localhost:8000/docs`

This provides interactive Swagger UI where you can:
- View all endpoints
- Test API calls
- See request/response schemas

---

## API Endpoints

### 1. Health Check
**GET** `/health`

Check if the API is running and the model is loaded.

**Response:**
```json
{
  "status": "healthy",
  "model_loaded": true,
  "message": "API is ready to serve predictions"
}
```

### 2. API Information
**GET** `/`

Get API information and available endpoints.

**Response:**
```json
{
  "message": "Heart Disease Prediction API",
  "version": "1.0.0",
  "endpoints": {
    "health": "/health",
    "predict": "/predict",
    "metrics": "/metrics",
    "docs": "/docs"
  }
}
```

### 3. Single Prediction
**POST** `/predict`

Make a prediction for a single patient.

**Request Body:**
```json
{
  "age": 63,
  "sex": 1,
  "cp": 1,
  "trestbps": 145,
  "chol": 233,
  "fbs": 1,
  "restecg": 2,
  "thalach": 150,
  "exang": 0,
  "oldpeak": 2.3,
  "slope": 3,
  "ca": 0,
  "thal": 6
}
```

**Response:**
```json
{
  "prediction": 1,
  "prediction_label": "Disease Present",
  "probability": 0.85,
  "confidence": 0.85
}
```

### 4. Batch Prediction
**POST** `/predict/batch`

Make predictions for multiple patients.

**Request Body:**
```json
[
  {
    "age": 63,
    "sex": 1,
    "cp": 1,
    "trestbps": 145,
    "chol": 233,
    "fbs": 1,
    "restecg": 2,
    "thalach": 150,
    "exang": 0,
    "oldpeak": 2.3,
    "slope": 3,
    "ca": 0,
    "thal": 6
  },
  {
    "age": 37,
    "sex": 1,
    "cp": 2,
    "trestbps": 130,
    "chol": 250,
    "fbs": 0,
    "restecg": 0,
    "thalach": 187,
    "exang": 0,
    "oldpeak": 3.5,
    "slope": 1,
    "ca": 0,
    "thal": 3
  }
]
```

**Response:**
```json
{
  "predictions": [
    {
      "prediction": 1,
      "prediction_label": "Disease Present",
      "probability": 0.85,
      "confidence": 0.85
    },
    {
      "prediction": 0,
      "prediction_label": "No Disease",
      "probability": 0.25,
      "confidence": 0.75
    }
  ],
  "count": 2
}
```

### 5. Model Information
**GET** `/model/info`

Get information about the loaded model.

**Response:**
```json
{
  "model_name": "random_forest",
  "model_type": "RandomForestClassifier",
  "preprocessor_loaded": true,
  "training_metrics": {
    "accuracy": 0.85,
    "precision": 0.82,
    "recall": 0.88,
    "roc_auc": 0.91
  }
}
```

### 6. Metrics
**GET** `/metrics`

Get Prometheus metrics (for monitoring).

---

## Making Predictions

### Using cURL

#### Single Prediction
```bash
curl -X POST http://localhost:8000/predict \
  -H "Content-Type: application/json" \
  -d '{
    "age": 63,
    "sex": 1,
    "cp": 1,
    "trestbps": 145,
    "chol": 233,
    "fbs": 1,
    "restecg": 2,
    "thalach": 150,
    "exang": 0,
    "oldpeak": 2.3,
    "slope": 3,
    "ca": 0,
    "thal": 6
  }'
```

#### Using File
```bash
curl -X POST http://localhost:8000/predict \
  -H "Content-Type: application/json" \
  -d @test_request.json
```

### Using Python

```python
import requests

# API endpoint
url = "http://localhost:8000/predict"

# Patient data
patient_data = {
    "age": 63,
    "sex": 1,
    "cp": 1,
    "trestbps": 145,
    "chol": 233,
    "fbs": 1,
    "restecg": 2,
    "thalach": 150,
    "exang": 0,
    "oldpeak": 2.3,
    "slope": 3,
    "ca": 0,
    "thal": 6
}

# Make prediction
response = requests.post(url, json=patient_data)
result = response.json()

print(f"Prediction: {result['prediction_label']}")
print(f"Probability: {result['probability']:.2%}")
print(f"Confidence: {result['confidence']:.2%}")
```

### Using JavaScript/Node.js

```javascript
const axios = require('axios');

const patientData = {
  age: 63,
  sex: 1,
  cp: 1,
  trestbps: 145,
  chol: 233,
  fbs: 1,
  restecg: 2,
  thalach: 150,
  exang: 0,
  oldpeak: 2.3,
  slope: 3,
  ca: 0,
  thal: 6
};

axios.post('http://localhost:8000/predict', patientData)
  .then(response => {
    console.log('Prediction:', response.data.prediction_label);
    console.log('Probability:', response.data.probability);
  })
  .catch(error => {
    console.error('Error:', error.response.data);
  });
```

---

## Feature Descriptions

| Feature | Type | Range | Description |
|---------|------|-------|-------------|
| `age` | float | 0-120 | Age in years |
| `sex` | int | 0-1 | Sex (1=male, 0=female) |
| `cp` | int | 1-4 | Chest pain type (1-4) |
| `trestbps` | float | 0+ | Resting blood pressure (mm Hg) |
| `chol` | float | 0+ | Serum cholesterol (mg/dl) |
| `fbs` | int | 0-1 | Fasting blood sugar > 120 (1=true, 0=false) |
| `restecg` | int | 0-2 | Resting electrocardiographic results |
| `thalach` | float | 0+ | Maximum heart rate achieved |
| `exang` | int | 0-1 | Exercise induced angina (1=yes, 0=no) |
| `oldpeak` | float | 0+ | ST depression induced by exercise |
| `slope` | int | 1-3 | Slope of peak exercise ST segment |
| `ca` | int | 0-3 | Number of major vessels colored by flourosopy |
| `thal` | int | 3-7 | Thalassemia (3=normal, 6=fixed, 7=reversible) |

---

## Error Handling

### Common Errors

#### 1. Model Not Loaded (503)
```json
{
  "detail": "Model not loaded. Please check /health endpoint."
}
```
**Solution**: Ensure models are trained and available.

#### 2. Validation Error (422)
```json
{
  "detail": [
    {
      "loc": ["body", "age"],
      "msg": "ensure this value is less than or equal to 120",
      "type": "value_error.number.not_le"
    }
  ]
}
```
**Solution**: Check input values are within valid ranges.

#### 3. Server Error (500)
```json
{
  "detail": "Prediction failed: <error message>"
}
```
**Solution**: Check API logs for details.

### Error Response Format
All errors follow this format:
```json
{
  "detail": "Error message or validation details"
}
```

---

## Best Practices

### 1. Always Check Health First
```python
response = requests.get("http://localhost:8000/health")
if response.json()["status"] == "healthy":
    # Proceed with predictions
    pass
```

### 2. Validate Input Data
- Ensure all required fields are present
- Check value ranges
- Handle missing data appropriately

### 3. Handle Errors Gracefully
```python
try:
    response = requests.post(url, json=data, timeout=10)
    response.raise_for_status()
    result = response.json()
except requests.exceptions.RequestException as e:
    print(f"Request failed: {e}")
except ValueError as e:
    print(f"Invalid response: {e}")
```

### 4. Use Batch Predictions for Multiple Records
Instead of multiple single requests, use batch endpoint:
```python
# Good: Batch request
patients = [patient1, patient2, patient3]
response = requests.post(f"{url}/batch", json=patients)

# Avoid: Multiple single requests
for patient in patients:
    response = requests.post(url, json=patient)
```

### 5. Set Appropriate Timeouts
```python
response = requests.post(url, json=data, timeout=30)
```

### 6. Monitor API Metrics
```python
# Check metrics endpoint
metrics = requests.get("http://localhost:8000/metrics")
# Parse and monitor key metrics
```

---

## Example Code

### Complete Python Example

```python
import requests
import json
from typing import Dict, List

class HeartDiseaseAPI:
    def __init__(self, base_url: str = "http://localhost:8000"):
        self.base_url = base_url
    
    def health_check(self) -> Dict:
        """Check API health."""
        response = requests.get(f"{self.base_url}/health")
        response.raise_for_status()
        return response.json()
    
    def predict(self, patient_data: Dict) -> Dict:
        """Make a single prediction."""
        response = requests.post(
            f"{self.base_url}/predict",
            json=patient_data,
            timeout=10
        )
        response.raise_for_status()
        return response.json()
    
    def predict_batch(self, patients: List[Dict]) -> Dict:
        """Make batch predictions."""
        response = requests.post(
            f"{self.base_url}/predict/batch",
            json=patients,
            timeout=30
        )
        response.raise_for_status()
        return response.json()
    
    def get_model_info(self) -> Dict:
        """Get model information."""
        response = requests.get(f"{self.base_url}/model/info")
        response.raise_for_status()
        return response.json()

# Usage
api = HeartDiseaseAPI()

# Check health
health = api.health_check()
print(f"API Status: {health['status']}")

# Make prediction
patient = {
    "age": 63,
    "sex": 1,
    "cp": 1,
    "trestbps": 145,
    "chol": 233,
    "fbs": 1,
    "restecg": 2,
    "thalach": 150,
    "exang": 0,
    "oldpeak": 2.3,
    "slope": 3,
    "ca": 0,
    "thal": 6
}

result = api.predict(patient)
print(f"Prediction: {result['prediction_label']}")
print(f"Probability: {result['probability']:.2%}")
```

---

## Integration Examples

### Flask Application
```python
from flask import Flask, request, jsonify
import requests

app = Flask(__name__)
API_URL = "http://localhost:8000"

@app.route('/predict', methods=['POST'])
def predict():
    patient_data = request.json
    response = requests.post(f"{API_URL}/predict", json=patient_data)
    return jsonify(response.json())
```

### Django Application
```python
from django.http import JsonResponse
import requests

def predict_view(request):
    if request.method == 'POST':
        patient_data = request.POST.dict()
        response = requests.post(
            "http://localhost:8000/predict",
            json=patient_data
        )
        return JsonResponse(response.json())
```

---

## Support

For issues or questions:
1. Check API documentation: `http://localhost:8000/docs`
2. Review logs for errors
3. Check health endpoint status
4. Consult deployment guide for setup issues

---

## References

- [API Documentation](http://localhost:8000/docs)
- [Deployment Guide](DEPLOYMENT_GUIDE.md)
- [Project README](../README.md)

