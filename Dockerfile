FROM python:3.11-slim

WORKDIR /app

COPY app/requirements.txt .

# Install the app's libraries, then remove build tools the app doesn't need at runtime
RUN pip install --no-cache-dir -r requirements.txt \
    && pip uninstall -y setuptools wheel

COPY app/app.py .

EXPOSE 5000

CMD ["python", "app.py"]
