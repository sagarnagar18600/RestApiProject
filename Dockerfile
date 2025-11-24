
# Dockerfile
FROM python:3.13-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

# Install OS deps and ODBC 18 for SQL Server (needed by pyodbc)
RUN apt-get update && apt-get install -y --no-install-recommends \
      curl gnupg ca-certificates \
    && curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /usr/share/keyrings/microsoft-prod.gpg \
    && curl https://packages.microsoft.com/config/debian/12/prod.list | tee /etc/apt/sources.list.d/mssql-release.list \
    && apt-get update \
    && ACCEPT_EULA=Y apt-get install -y --no-install-recommends msodbcsql18 unixodbc-dev \
    && apt-get purge -y --auto-remove curl gnupg \
    && rm -rf /var/lib/apt/lists/*

# Install Python deps
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy app
COPY . .

# Run as non-root
RUN useradd -m appuser
USER appuser

# Expose the port Gunicorn will bind to
EXPOSE 8000

# Healthcheck (adjust path if you have /health endpoint)
# If you don't have a /health route, you can set it to "/" or add a simple health endpoint.
HEALTHCHECK --interval=30s --timeout=5s --retries=3 CMD python -c "import urllib.request,sys; \
  sys.exit(0) if urllib.request.urlopen('http://localhost:8000/').status < 500 else sys.exit(1)" || exit 1

# IMPORTANT: use factory to create app
# If your app module is named differently, adjust "app:create_app()"
CMD ["gunicorn", "-w", "4", "-b", "0.0.0.0:8000", "app:create_app()"]
