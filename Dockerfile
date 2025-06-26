# Use Python 3.12 slim image
FROM python:3.12-slim

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Poetry
RUN pip install poetry

# Configure Poetry
ENV POETRY_NO_INTERACTION=1 \
    POETRY_VENV_IN_PROJECT=1 \
    POETRY_CACHE_DIR=/tmp/poetry_cache

# Copy Poetry files
COPY pyproject.toml poetry.lock ./

# Install dependencies without the current project
RUN poetry install --only=main --no-root && rm -rf $POETRY_CACHE_DIR

# Install additional dependencies for the API
RUN poetry add fastapi "uvicorn[standard]"

# Copy source code and README.md
COPY src/ ./src/
COPY README.md ./

# Install the current project (hackathon package)
RUN poetry install --only-root

# Expose port
EXPOSE 8000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1

# Run the API server
CMD ["poetry", "run", "uvicorn", "src.hackathon.agents.conversation.api:app", "--host", "0.0.0.0", "--port", "8000"]