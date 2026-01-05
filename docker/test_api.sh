#!/bin/bash
# Script to test the Dockerized API

set -e

API_URL="http://localhost:8000"

echo "============================================================"
echo "Testing Heart Disease Prediction API"
echo "============================================================"

# Wait for API to be ready
echo "Waiting for API to be ready..."
for i in {1..30}; do
    if curl -s "${API_URL}/health" > /dev/null 2>&1; then
        echo "✓ API is ready!"
        break
    fi
    if [ $i -eq 30 ]; then
        echo "✗ API failed to start"
        exit 1
    fi
    sleep 1
done

# Test health endpoint
echo ""
echo "1. Testing /health endpoint..."
curl -s "${API_URL}/health" | python -m json.tool
echo ""

# Test root endpoint
echo "2. Testing / endpoint..."
curl -s "${API_URL}/" | python -m json.tool
echo ""

# Test prediction endpoint
echo "3. Testing /predict endpoint..."
curl -s -X POST "${API_URL}/predict" \
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
    }' | python -m json.tool
echo ""

# Test model info endpoint
echo "4. Testing /model/info endpoint..."
curl -s "${API_URL}/model/info" | python -m json.tool
echo ""

echo "============================================================"
echo "All API tests completed!"
echo "============================================================"

