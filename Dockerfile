FROM python:3.13-slim-bookworm

ENV PYTHONUNBUFFERED=1
ENV HERMES_HOME=/opt/data
ENV PATH="/opt/hermes/.venv/bin:${PATH}"
# Render may run as root — this flag allows the gateway to start
ENV HERMES_ALLOW_ROOT_GATEWAY=1

# Install system dependencies (openssh-client for git, ffmpeg for media, etc.)
RUN apt-get update && apt-get install -y --no-install-recommends \
    git curl ca-certificates ffmpeg gcc python3-dev libffi-dev procps openssh-client && \
    rm -rf /var/lib/apt/lists/*

# Clone Hermes Agent
WORKDIR /opt/hermes
RUN git clone --depth 1 --branch v2026.5.28 https://github.com/nousresearch/hermes-agent.git .

# Install uv (fast dependency resolver)
RUN pip install --no-cache-dir uv

# Install Python dependencies (core + Telegram messaging + extras)
RUN uv sync --frozen --no-install-project --extra all --extra messaging --no-dev && \
    uv pip install --no-cache-dir --no-deps -e "."

# Create config directory
RUN mkdir -p /opt/data

# Copy Hermes configuration
COPY config.yaml /opt/data/config.yaml

# Render injects $PORT env var (10000 for free tier)
EXPOSE 10000

# Start Hermes gateway directly — Render routes traffic to it
CMD ["hermes", "gateway"]
