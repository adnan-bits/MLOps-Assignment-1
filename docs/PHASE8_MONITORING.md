# Phase 8: Monitoring and Logging

## Overview

Phase 8 implements comprehensive monitoring and logging for the Heart Disease Prediction API, enabling:
- Prometheus metrics collection
- Enhanced structured logging
- Request/response tracking
- Performance monitoring
- Error tracking and alerting

## Components

### 1. Prometheus Metrics (`src/api/monitoring.py`)

The API exposes Prometheus-compatible metrics at `/metrics` endpoint:

#### HTTP Metrics
- **`http_requests_total`**: Total HTTP requests by method, endpoint, and status code
- **`http_request_duration_seconds`**: Request duration histogram by method and endpoint
- **`active_requests`**: Current number of active requests being processed

#### Prediction Metrics
- **`predictions_total`**: Total predictions made by prediction label
- **`prediction_probability`**: Probability distribution histogram by prediction label

#### Model Metrics
- **`model_loaded`**: Model load status (1=loaded, 0=not loaded)

### 2. Enhanced Logging

Structured logging with support for:
- **JSON format** (for production/log aggregation)
- **Text format** (for development)
- Configurable log levels
- Request/response logging via middleware
- Error tracking with stack traces

### 3. Metrics Middleware

Automatic collection of:
- Request counts
- Request duration
- Status codes
- Active request tracking

## Usage

### Access Metrics

```bash
# Get Prometheus metrics
curl http://localhost:8000/metrics

# Or in browser
open http://localhost:8000/metrics
```

### Metrics Endpoint

The `/metrics` endpoint returns metrics in Prometheus text format:

```
# HELP http_requests_total Total HTTP requests
# TYPE http_requests_total counter
http_requests_total{endpoint="/predict",method="POST",status_code="200"} 42.0

# HELP http_request_duration_seconds HTTP request duration in seconds
# TYPE http_request_duration_seconds histogram
http_request_duration_seconds_bucket{endpoint="/predict",method="POST",le="0.005"} 5.0
http_request_duration_seconds_bucket{endpoint="/predict",method="POST",le="0.01"} 15.0
...

# HELP predictions_total Total predictions made
# TYPE predictions_total counter
predictions_total{prediction_label="Disease Present"} 25.0
predictions_total{prediction_label="No Disease"} 17.0
```

### Configure Logging

Set environment variables:

```bash
# Log level (DEBUG, INFO, WARNING, ERROR, CRITICAL)
export LOG_LEVEL=INFO

# Use JSON format (for production)
export JSON_LOGS=true

# Or text format (for development)
export JSON_LOGS=false
```

### Example Log Output

**Text Format:**
```
2024-01-06 10:30:45 - src.api.app - INFO - module:app:function:predict:line:160 - Prediction request received
2024-01-06 10:30:45 - src.api.app - INFO - module:app:function:predict:line:165 - Prediction made: Disease Present (probability: 0.8523)
```

**JSON Format:**
```json
{
  "timestamp": "2024-01-06T10:30:45.123456",
  "level": "INFO",
  "logger": "src.api.app",
  "message": "Prediction made: Disease Present (probability: 0.8523)",
  "module": "app",
  "function": "predict",
  "line": 165
}
```

## Prometheus Integration

### Scrape Configuration

Add to `prometheus.yml`:

```yaml
scrape_configs:
  - job_name: 'heart-disease-api'
    scrape_interval: 15s
    static_configs:
      - targets: ['localhost:8000']
        labels:
          service: 'heart-disease-api'
          environment: 'production'
```

### Kubernetes ServiceMonitor (if using Prometheus Operator)

```yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: heart-disease-api
  namespace: mlops
spec:
  selector:
    matchLabels:
      app: heart-disease-api
  endpoints:
  - port: http
    path: /metrics
    interval: 15s
```

## Grafana Dashboards

### Key Metrics to Monitor

1. **Request Rate**: `rate(http_requests_total[5m])`
2. **Error Rate**: `rate(http_requests_total{status_code=~"5.."}[5m])`
3. **Request Latency**: `histogram_quantile(0.95, http_request_duration_seconds_bucket)`
4. **Prediction Distribution**: `predictions_total`
5. **Model Status**: `model_loaded`
6. **Active Requests**: `active_requests`

### Sample Grafana Dashboard JSON

Create a dashboard with panels for:
- Request rate by endpoint
- Error rate
- P95/P99 latency
- Prediction counts
- Model status
- Active requests

## Monitoring Best Practices

### 1. Alert Rules

Create Prometheus alert rules:

```yaml
groups:
- name: heart_disease_api
  rules:
  - alert: HighErrorRate
    expr: rate(http_requests_total{status_code=~"5.."}[5m]) > 0.1
    for: 5m
    annotations:
      summary: "High error rate detected"

  - alert: ModelNotLoaded
    expr: model_loaded == 0
    for: 1m
    annotations:
      summary: "Model is not loaded"

  - alert: HighLatency
    expr: histogram_quantile(0.95, http_request_duration_seconds_bucket) > 1.0
    for: 5m
    annotations:
      summary: "High request latency detected"
```

### 2. Log Aggregation

For production, use log aggregation tools:
- **ELK Stack** (Elasticsearch, Logstash, Kibana)
- **Loki** (with Grafana)
- **CloudWatch** (AWS)
- **Stackdriver** (GCP)

### 3. Health Checks

The `/health` endpoint can be monitored:
```bash
# Check health
curl http://localhost:8000/health

# Monitor with Prometheus
# Use http_requests_total{endpoint="/health",status_code="200"}
```

## Testing Metrics

### Generate Test Traffic

```bash
# Single prediction
curl -X POST http://localhost:8000/predict \
  -H "Content-Type: application/json" \
  -d @test_request.json

# Batch prediction
curl -X POST http://localhost:8000/predict/batch \
  -H "Content-Type: application/json" \
  -d '[{...}, {...}]'

# Check metrics
curl http://localhost:8000/metrics | grep predictions_total
```

### Verify Metrics

```bash
# Check HTTP metrics
curl http://localhost:8000/metrics | grep http_requests_total

# Check prediction metrics
curl http://localhost:8000/metrics | grep predictions_total

# Check model status
curl http://localhost:8000/metrics | grep model_loaded
```

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `LOG_LEVEL` | `INFO` | Logging level (DEBUG, INFO, WARNING, ERROR, CRITICAL) |
| `JSON_LOGS` | `false` | Use JSON format for logs (true/false) |

## Kubernetes Integration

### Update Deployment

Add environment variables to `k8s/deployment.yaml`:

```yaml
env:
- name: LOG_LEVEL
  value: "INFO"
- name: JSON_LOGS
  value: "true"
```

### ServiceMonitor

If using Prometheus Operator, create `k8s/servicemonitor.yaml`:

```yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: heart-disease-api
  namespace: mlops
spec:
  selector:
    matchLabels:
      app: heart-disease-api
  endpoints:
  - port: http
    path: /metrics
```

## Troubleshooting

### Metrics Not Appearing

1. **Check endpoint**: `curl http://localhost:8000/metrics`
2. **Check logs**: Look for middleware errors
3. **Verify imports**: Ensure prometheus-client is installed

### Logs Not Showing

1. **Check log level**: Set `LOG_LEVEL=DEBUG`
2. **Check format**: Verify `JSON_LOGS` setting
3. **Check handlers**: Verify logging configuration

### High Memory Usage

1. **Check active requests**: Monitor `active_requests` metric
2. **Check request duration**: Long-running requests
3. **Review resource limits**: Adjust in deployment.yaml

## Next Steps

After Phase 8, proceed to:
- **Phase 9**: Final report and documentation
- Set up Grafana dashboards
- Configure alerting rules
- Integrate with log aggregation system

## References

- [Prometheus Documentation](https://prometheus.io/docs/)
- [Prometheus Client Python](https://github.com/prometheus/client_python)
- [FastAPI Monitoring](https://fastapi.tiangolo.com/advanced/middleware/)
- [Grafana Dashboards](https://grafana.com/docs/grafana/latest/dashboards/)

