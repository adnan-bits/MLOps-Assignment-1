# Phase 5: CI/CD & Testing - Quick Start

## ✅ What's Been Created

1. **Unit Tests** (`tests/`):
   - `test_data_processing.py` - Tests for data preprocessing
   - `test_models.py` - Tests for model training and prediction
   - `conftest.py` - Shared test fixtures

2. **Linting Configuration**:
   - `.pylintrc` - Pylint configuration
   - `.flake8` - Flake8 configuration

3. **CI/CD Pipeline**:
   - `.github/workflows/ci.yml` - GitHub Actions workflow

4. **Helper Scripts**:
   - `scripts/run_tests.sh` - Run all tests
   - `scripts/run_linting.sh` - Run linting checks

## 🚀 Quick Commands

### Run Tests Locally

```bash
# Install test dependencies first
pip install pytest pytest-cov

# Run all tests
pytest tests/ -v

# Run with coverage
pytest tests/ -v --cov=src --cov-report=term-missing

# Or use helper script
./scripts/run_tests.sh
```

### Run Linting

```bash
# Install linting tools
pip install flake8 pylint

# Run linting
./scripts/run_linting.sh

# Or manually
flake8 src/ scripts/ tests/
pylint src/ scripts/
```

## 📋 Test Structure

```
tests/
├── __init__.py
├── conftest.py              # Shared fixtures
├── test_data_processing.py  # Data preprocessing tests
└── test_models.py           # Model tests
```

## 🔄 CI/CD Pipeline

The GitHub Actions workflow runs automatically on:
- Push to main/master/develop
- Pull requests to main/master/develop

**Pipeline Jobs:**
1. **Lint** - Code quality checks
2. **Test** - Unit tests with coverage
3. **Train** - Model training
4. **MLflow Training** - MLflow experiments (main/master only)

## 📊 View Results

### Local Testing
```bash
# See test results
pytest tests/ -v

# See coverage report
pytest tests/ --cov=src --cov-report=html
# Open htmlcov/index.html in browser
```

### GitHub Actions
1. Go to your repository on GitHub
2. Click "Actions" tab
3. View workflow runs
4. Click on a run to see details
5. Download artifacts (models, summaries)

## ✅ Verification Checklist

- [ ] Tests pass locally: `pytest tests/ -v`
- [ ] Linting passes: `./scripts/run_linting.sh`
- [ ] GitHub Actions workflow file exists: `.github/workflows/ci.yml`
- [ ] All test files created in `tests/` directory
- [ ] Configuration files present (`.pylintrc`, `.flake8`, `pytest.ini`)

## 🐛 Troubleshooting

### Tests Not Running?
```bash
pip install pytest pytest-cov
pytest tests/ -v
```

### Linting Errors?
- Review output for specific issues
- Some warnings can be ignored (configured)
- Fix critical errors (E9, F63, F7, F82)

### CI/CD Not Triggering?
- Ensure `.github/workflows/ci.yml` is committed
- Check branch name matches triggers
- Verify GitHub Actions is enabled

## 📚 Next Steps

Phase 5 is complete! Ready for:
- **Phase 6**: Model Containerization (Docker)
- **Phase 7**: Production Deployment (Kubernetes)
- **Phase 8**: Monitoring & Logging
- **Phase 9**: Documentation & Reporting

