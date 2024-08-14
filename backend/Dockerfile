FROM python:3.11-alpine3.16

RUN apk update && apk add --no-cache \
    build-base \
    libffi-dev \
    musl-dev

COPY requirements.txt /temp/requirements.txt
COPY src /src
WORKDIR /src

RUN pip install --upgrade pip setuptools wheel
RUN pip install -r /temp/requirements.txt

RUN adduser --disabled-password zabit

USER zabit

EXPOSE 8000
