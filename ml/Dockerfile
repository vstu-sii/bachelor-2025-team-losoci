FROM python:3.11

WORKDIR /app

COPY reqirements.txt .
RUN pip install --no-cache-dir -r reqirements.txt

COPY . .

ENV PYTHONPATH=/app/ml

EXPOSE 8000

CMD bash -c "python ml/api/main.py & python ml/api/run.py"
