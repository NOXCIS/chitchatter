# Stage 1: Build the application
FROM --platform=$BUILDPLATFORM node:20.12.1-slim AS builder
LABEL maintainer="NOXCIS"

WORKDIR /opt/app

COPY . /opt/app/

RUN apt-get update \
    && apt-get install git python3 build-essential -y \
    && npm install @rollup/rollup-linux-arm64-gnu \
    && npm install @swc/core \
    && npm install \
    && npm run build

# Stage 2: Create the runtime environment
FROM alpine:latest

WORKDIR /opt/app

COPY --from=builder /opt/app/dist /opt/app/dist
COPY default.conf /etc/nginx/http.d/default.conf
COPY start.sh /opt/app/

# Install nginx and OpenSSL for runtime
RUN apk add --no-cache \
    nginx \
    openssl \
    iptables \
    && chmod +x /opt/app/start.sh


HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 CMD \
    sh -c 'pgrep nginx > /dev/null && pgrep tail > /dev/null' || exit 1
    
# Start the application using the start script
CMD ["sh", "-c", "trap 'nginx -s quit' SIGTERM; /opt/app/start.sh & wait"]

STOPSIGNAL SIGTERM
