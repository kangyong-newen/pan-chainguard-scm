FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && \
    apt install -y \
    git \
    curl \
    python3 \
    python3-pip \
    python3-venv \
    ca-certificates && \
    apt clean

WORKDIR /opt

RUN git clone https://github.com/PaloAltoNetworks/pan-chainguard.git

WORKDIR /opt/pan-chainguard

RUN python3 -m venv venv && \
    . venv/bin/activate && \
    pip install --upgrade pip && \
    pip install . && \
    pip install requests

CMD ["/bin/bash"]
