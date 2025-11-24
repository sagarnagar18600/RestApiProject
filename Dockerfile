
# Dockerfile
FROM python:3.13-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

# Install OS deps and ODBC 18 for SQL Server (needed by pyodbc)
# Includes unixodbc (driver manager) and runtime libraries required by msodbcsql18.
RUN apt-get update && apt-get install -y --no-install-recommends \
      curl gnupg ca-certificates \
    && curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /usr/share/keyrings/microsoft-prod.gpg \
    && curl https://packages.microsoft.com/config/debian/12/prod.list | tee /etc/apt/sources.list.d/mssql-release.list \
    && apt-get update \
    && ACCEPT_EULA=Y apt-get install -y --no-install-recommends \
         msodbcsql18 \
         unixodbc \
         unixodbc-dev \
         libssl3 \
         libgssapi-krb5-2 \
         libkrb5-3 \
         libstdc++6 \
    && ldconfig \
    && odbcinst -q -d \
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

# Healthcheck: prefer /health if you add that route; else "/" works too.
# Tip: add to app.py:
#   @app.route("/health")
#   def health(): return jsonify(status="ok"), 200
HEALTHCHECK --interval=30s --timeout=5s --retries=3 CMD python -c "import urllib.request,sys; \
  sys.exit(0) if urllib.request.urlopen('http://localhost:8000/health').status < 500 else sys.exit(1)" || exit 1

# IMPORTANT: use factory to create app
# If your app module is named differently, adjust "app:create_app()"
# Optional: enable access logs for troubleshooting by adding --access-logfile -
CMD ["gunicorn", "-w", "4", "-b", "0.0.0.0:8000", "--access-logfile", "-", "app:create_app()"]
