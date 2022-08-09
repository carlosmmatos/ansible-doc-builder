FROM python:latest
RUN apt-get update && apt-get upgrade -y
RUN apt-get update && apt-get install -y --no-install-recommends rsync vim; rm -rf /var/lib/apt/lists/*
RUN pip install --upgrade pip && pip install ansible-core antsibull
COPY build.sh /build.sh
CMD ["python3"]
