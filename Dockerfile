FROM alpine:latest AS builder
LABEL maintainer="NOXCIS"

WORKDIR /opt/app

COPY . /opt/app/

RUN apk add --no-cache npm build-base git gcc musl-dev rust cargo linux-headers \
    && npm install \
    && npm run build


FROM alpine:latest

# Set working directory
WORKDIR /opt/app

COPY --from=builder /opt/app/dist /opt/app/dist
COPY default.conf /opt/app/
COPY start.sh /opt/app/



RUN apk update && \
    apk add --no-cache  nginx openssl && \
    rm /etc/nginx/http.d/default.conf && \
    mv /opt/app/default.conf /etc/nginx/http.d/ && \
    chmod +x /opt/app/start.sh



CMD ["/opt/app/start.sh"]

