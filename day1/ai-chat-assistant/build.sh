#!/bin/bash

resolve_python() {
    if command -v python3.11 >/dev/null 2>&1; then
        command -v python3.11
        return
    fi
    if command -v pyenv >/dev/null 2>&1; then
        local pyenv_python
        pyenv_python="$(pyenv which python3.11 2>/dev/null || true)"
        if [ -n "$pyenv_python" ] && [ -x "$pyenv_python" ]; then
            echo "$pyenv_python"
            return
        fi
    fi
    if command -v python3 >/dev/null 2>&1; then
        local version
        version="$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')"
        case "$version" in
            3.11|3.12|3.13)
                command -v python3
                return
                ;;
        esac
    fi
    echo "ERROR: Python 3.11+ required. Install with: pyenv install 3.11.7" >&2
    exit 1
}

PYTHON="$(resolve_python)"

echo "🚀 Building AI Chat Assistant..."

# Build Backend
echo "🐍 Building Python Backend..."
cd backend

# Create virtual environment if it doesn't exist
if [ ! -d "venv" ]; then
    "$PYTHON" -m venv venv
fi

# Activate virtual environment
source venv/bin/activate

# Upgrade pip and install dependencies
pip install --upgrade pip
pip install -r requirements.txt

# Run backend tests
echo "🧪 Running backend tests..."
python -m pytest tests/ -v

echo "✅ Backend build complete!"

cd ..

# Build Frontend
echo "⚛️ Building React Frontend..."
cd frontend

# Install Node.js dependencies
npm install

# Run frontend tests
echo "🧪 Running frontend tests..."
npm test -- --coverage --watchAll=false

# Build for production
echo "📦 Building for production..."
npm run build

echo "✅ Frontend build complete!"

cd ..

echo "🎉 Build completed successfully!"
echo "📋 Next steps:"
echo "   1. Run './start.sh' to start the application"
echo "   2. Open http://localhost:3000 in your browser"
echo "   3. Start chatting with your AI assistant!"
