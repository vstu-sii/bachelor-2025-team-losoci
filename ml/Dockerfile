FROM python:3.13-slim

# Ставим только то, что нужно для установки uv
# With pip.
RUN pip install uv

WORKDIR /app

COPY requirements.txt .

# uv умеет читать requirements.txt напрямую
RUN uv pip install --system --no-cache -r requirements.txt

COPY . .


CMD ["uv", "run", "python", "main_agent/run.py"]