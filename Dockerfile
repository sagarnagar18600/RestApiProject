# Dockerfile
FROM python:3.13-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

# Install OS deps, build tools, unixODBC, and Microsoft ODBC Driver 18 for SQL Server
# We also install bash (optional; useful for debugging), though the entrypoint uses /bin/sh.
RUN apt-get update && apt-get install -y --no-install-recommends \
      curl gnupg ca-certificates \
      build-essential pkg-config \
      unixodbc unixodbc-dev \
      libssl3 libgssapi-krb5-2 libkrb5-3 libstdc++6 \
      bash \
    && curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /usr/share/keyrings/microsoft-prod.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/microsoft-prod.gpg] https://packages.microsoft.com/debian/12/prod bookworm main" > /etc/apt/sources.list.d/mssql-release.list \
    && apt-get update \
    && ACCEPT_EULA=Y apt-get install -y --no-install-recommends msodbcsql18 \
    && ldconfig \
    && odbcinst -q -d || true \
    && rm -rf /var/lib/apt/lists/*

# Install Python deps
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip setuptools wheel \
 && pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Normalize line endings on entrypoint (fixes Windows CRLF issues) and make it executable
RUN sed -i 's/\r$//' docker-entrypoint.sh && chmod +x docker-entrypoint.sh

# Create non-root user for security
RUN useradd -m appuser
USER appuser

# Expose Gunicorn port
EXPOSE 8000

# Healthcheck: make sure you have /health route in app.py
HEALTHCHECK --interval=30s --timeout=5s --retries=3 CMD python -c "import urllib.request,sys; \
  sys.exit(0) if urllib.request.urlopen('http://localhost:8000/health').status < 500 else sys.exit(1)" || exit 1

# Use /bin/sh to execute the entrypoint script (robust against format quirks)
ENTRYPOINT ["/bin/sh", "./docker-entrypoint.sh"]

# Start Gunicorn (factory callable)
CMD ["gunicorn", "-w", "4", "-b", "0.0.0.0:8000", "--access-logfile", "-", "app:create_app()"]
