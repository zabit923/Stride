FROM python:3.11-alpine3.16

COPY requirements.txt /temp/requirements.txt
COPY src /src
WORKDIR /src

EXPOSE 8000

RUN pip install -r /temp/requirements.txt
RUN adduser --disabled-password zabit

USER zabit
