<<<<<<< Updated upstream
# Use a specific version of Alpine
FROM alpine:3.18

# Set working directory
WORKDIR /opt/app

# Copy app source code to container
COPY . /opt/app/
# Install npm and required packages
RUN apk add --no-cache npm git nginx openssl && \
=======
FROM alpine:latest AS builder
LABEL maintainer="NOXCIS"

WORKDIR /opt/app

COPY . /opt/app/
RUN apk add --no-cache npm build-base git \
    && npm install \
    && npm run build

# Second stage: Running Nginx with SIGTERM handling
FROM alpine:latest
WORKDIR /opt/app
COPY --from=builder /opt/app/dist /opt/app/dist
COPY default.conf /opt/app/
COPY start.sh /opt/app/
RUN apk update && \
    apk add --no-cache nginx openssl && \
>>>>>>> Stashed changes
    rm /etc/nginx/http.d/default.conf && \
    mv /opt/app/default.conf /etc/nginx/http.d/ && \
    chmod +x /opt/app/start.sh

<<<<<<< Updated upstream
# Copy app source code to container
COPY . /opt/app/

# Install node modules
RUN npm install && npm cache clean --force



# Expose necessary port (if your app runs on a specific port)
EXPOSE 443
EXPOSE 3000
EXPOSE 80

# Default command to run the app
#CMD [ "npm", "start" ]
#CMD ["/opt/app/start.sh"]
ENTRYPOINT [ "/opt/app/start.sh" ]
=======
# Trap SIGTERM in the Dockerfile
CMD ["sh", "-c", "trap 'nginx -s quit; killall tail' SIGTERM; /opt/app/start.sh & wait"]
>>>>>>> Stashed changes
