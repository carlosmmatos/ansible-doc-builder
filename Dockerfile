FROM python:3.10
RUN apt-get update && apt-get install -y --no-install-recommends rsync vim; rm -rf /var/lib/apt/lists/*
RUN pip install ansible-core antsibull
COPY build.sh /build.sh
CMD ["python3"]
