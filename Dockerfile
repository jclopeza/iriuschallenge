FROM python:3.11-slim

WORKDIR /app

COPY src/ .

RUN apt-get update && apt-get install -y libgomp1 && apt-get clean

RUN pip install -r requirements.txt

EXPOSE 8000

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]