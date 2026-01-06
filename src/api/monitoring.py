"""
Monitoring and metrics configuration for the API.

Provides Prometheus metrics and enhanced logging.
"""

import time
import logging
from typing import Callable
from functools import wraps

from fastapi import Request, Response
from prometheus_client import Counter, Histogram, Gauge, generate_latest
from prometheus_client import CONTENT_TYPE_LATEST
from starlette.middleware.base import BaseHTTPMiddleware
from starlette.responses import Response as StarletteResponse

# Configure logger
logger = logging.getLogger(__name__)

# Prometheus Metrics
REQUEST_COUNT = Counter(
    'http_requests_total',
    'Total HTTP requests',
    ['method', 'endpoint', 'status_code']
)

REQUEST_DURATION = Histogram(
    'http_request_duration_seconds',
    'HTTP request duration in seconds',
    ['method', 'endpoint']
)

PREDICTION_COUNT = Counter(
    'predictions_total',
    'Total predictions made',
    ['prediction_label']
)

PREDICTION_PROBABILITY = Histogram(
    'prediction_probability',
    'Prediction probability distribution',
    ['prediction_label'],
    buckets=[0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0]
)

MODEL_LOAD_STATUS = Gauge(
    'model_loaded',
    'Model load status (1=loaded, 0=not loaded)'
)

ACTIVE_REQUESTS = Gauge(
    'active_requests',
    'Number of active requests being processed'
)


class MetricsMiddleware(BaseHTTPMiddleware):
    """Middleware to collect HTTP metrics."""

    async def dispatch(self, request: Request, call_next: Callable):
        """Process request and collect metrics."""
        # Skip metrics endpoint
        if request.url.path == "/metrics":
            return await call_next(request)

        method = request.method
        endpoint = request.url.path

        # Track active requests
        ACTIVE_REQUESTS.inc()

        # Measure request duration
        start_time = time.time()
        try:
            response = await call_next(request)
            status_code = response.status_code
        except Exception as e:
            status_code = 500
            logger.error(f"Request failed: {e}", exc_info=True)
            raise
        finally:
            duration = time.time() - start_time
            ACTIVE_REQUESTS.dec()

            # Record metrics
            REQUEST_COUNT.labels(
                method=method,
                endpoint=endpoint,
                status_code=status_code
            ).inc()

            REQUEST_DURATION.labels(
                method=method,
                endpoint=endpoint
            ).observe(duration)

            logger.info(
                f"{method} {endpoint} - "
                f"Status: {status_code} - "
                f"Duration: {duration:.4f}s"
            )

        return response


def record_prediction(prediction_label: str, probability: float):
    """
    Record prediction metrics.
    
    Args:
        prediction_label: Prediction label ("Disease Present" or "No Disease")
        probability: Prediction probability
    """
    PREDICTION_COUNT.labels(prediction_label=prediction_label).inc()
    PREDICTION_PROBABILITY.labels(
        prediction_label=prediction_label
    ).observe(probability)


def update_model_status(loaded: bool):
    """
    Update model load status metric.
    
    Args:
        loaded: Whether model is loaded
    """
    MODEL_LOAD_STATUS.set(1 if loaded else 0)


def get_metrics():
    """
    Get Prometheus metrics in text format.
    
    Returns:
        Metrics in Prometheus text format
    """
    return generate_latest()


def setup_logging(log_level: str = "INFO", json_format: bool = False):
    """
    Setup enhanced logging configuration.
    
    Args:
        log_level: Logging level (DEBUG, INFO, WARNING, ERROR, CRITICAL)
        json_format: Whether to use JSON format (for production)
    """
    level = getattr(logging, log_level.upper(), logging.INFO)

    if json_format:
        import json
        from datetime import datetime

        class JSONFormatter(logging.Formatter):
            """JSON formatter for structured logging."""

            def format(self, record):
                log_data = {
                    'timestamp': datetime.utcnow().isoformat(),
                    'level': record.levelname,
                    'logger': record.name,
                    'message': record.getMessage(),
                    'module': record.module,
                    'function': record.funcName,
                    'line': record.lineno
                }

                if record.exc_info:
                    log_data['exception'] = self.formatException(record.exc_info)

                return json.dumps(log_data)

        formatter = JSONFormatter()
    else:
        formatter = logging.Formatter(
            '%(asctime)s - %(name)s - %(levelname)s - '
            '%(module)s:%(funcName)s:%(lineno)d - %(message)s'
        )

    # Configure root logger
    root_logger = logging.getLogger()
    root_logger.setLevel(level)

    # Remove existing handlers
    for handler in root_logger.handlers[:]:
        root_logger.removeHandler(handler)

    # Add console handler
    console_handler = logging.StreamHandler()
    console_handler.setLevel(level)
    console_handler.setFormatter(formatter)
    root_logger.addHandler(console_handler)

    # Set levels for third-party loggers
    logging.getLogger("uvicorn").setLevel(logging.WARNING)
    logging.getLogger("uvicorn.access").setLevel(logging.WARNING)

    logger.info(f"Logging configured - Level: {log_level}, JSON: {json_format}")

