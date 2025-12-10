FROM python:3.13-slim

# Ставим только то, что нужно для установки uv
# With pip.
COPY --from=ghcr.io/astral-sh/uv:latest /uv /bin/uv

WORKDIR /app

COPY pyproject.toml uv.lock ./

# uv умеет читать requirements.txt напрямую
RUN uv sync --no-dev --frozen --no-cache

COPY . .


CMD ["uv", "run", "python", "main_agent/run.py"]