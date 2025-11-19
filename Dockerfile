FROM python:3.13

WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . .

ENV FLASK_APP=app
ENV FLASK_RUN_PORT=5000
EXPOSE 5000

CMD ["python", "-m", "flask", "run", "--host=0.0.0.0"]
