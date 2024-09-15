# Use a specific version of Alpine
FROM alpine:3.18

# Set working directory
WORKDIR /opt/app

# Copy app source code to container
COPY . /opt/app/
# Install npm and required packages
RUN apk add --no-cache npm git nginx openssl && \
    rm /etc/nginx/http.d/default.conf && \
    mv /opt/app/default.conf /etc/nginx/http.d/ && \
    chmod +x /opt/app/start.sh

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
