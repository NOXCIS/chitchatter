# Stage 1: Build the application
FROM node:slim AS builder
LABEL maintainer="NOXCIS"

WORKDIR /opt/app
RUN apt-get update

RUN apt-get install git python3 -y

COPY . /opt/app/


# Install npm dependencies and build the application
RUN npm install \
    && npm run build




# Stage 2: Prepare the final runtime environment
FROM alpine:latest

# Set working directory
WORKDIR /opt/app

# Install nginx and OpenSSL for runtime
RUN apk add --no-cache \
    nginx \
    openssl 

# Copy the built application from the build stage
COPY --from=builder /opt/app/dist /opt/app/dist

# Copy nginx configuration and startup script
COPY default.conf /etc/nginx/http.d/default.conf
COPY start.sh /opt/app/

# Ensure the start script is executable
RUN chmod +x /opt/app/start.sh

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 CMD \
    sh -c 'pgrep nginx > /dev/null && pgrep tail > /dev/null' || exit 1
    
# Start the application using the start script
CMD ["sh", "-c", "trap 'nginx -s quit' SIGTERM; /opt/app/start.sh & wait"]

#CMD ["/opt/app/start.sh"]
STOPSIGNAL SIGTERM
