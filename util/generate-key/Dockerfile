FROM python:3-slim

WORKDIR /genkey
COPY requirements.txt .

RUN pip install -r requirements.txt

COPY pvcy-genkey.py .

CMD ["python3", "pvcy-genkey.py"]
