#!/bin/sh



# Function to generate SSL certificates for localhost using mkcert
generate_cert_for_localhost() {
    local cert_dir="/etc/nginx/ssl"
    local domain=$DOMAIN_NAME

    # Check if mkcert is installed
    if ! command -v mkcert >/dev/null 2>&1; then
        echo "mkcert is not installed. Installing mkcert..."

        # Install mkcert on Alpine
        apk add nss-tools curl
        curl -L -o /usr/local/bin/mkcert https://github.com/FiloSottile/mkcert/releases/download/v1.4.4/mkcert-v1.4.4-linux-amd64
        chmod +x /usr/local/bin/mkcert

        # Install the local CA
        mkcert -install
    fi

    # Create the certificate directory if it doesn't exist
    mkdir -p "$cert_dir"

    # Generate the certificate for localhost
    echo "Generating certificate for localhost"
    mkcert "$domain" "127.0.0.1" "::1"

    # Move the certificate and key to the certificate directory
    mv "$domain+2.pem" "$cert_dir/$domain+2.pem"
    mv "$domain+2-key.pem" "$cert_dir/$domain+2-key.pem"

    echo "Certificate and key generated and moved to $cert_dir:"
    echo " - $cert_dir/$domain+2.pem"
    echo " - $cert_dir/$domain+2-key.pem"
}








# Graceful shutdown function for SIGTERM
graceful_shutdown() {
    echo "SIGTERM received, shutting down Nginx..."
    nginx -s quit
    exit 0
}

# Trap SIGTERM signal to trigger graceful shutdown
trap 'graceful_shutdown' SIGTERM

echo '
Starting...
░░      ░░░  ░░░░  ░░        ░░        ░░░      ░░░  ░░░░  ░░░      ░░░        ░
▒  ▒▒▒▒  ▒▒  ▒▒▒▒  ▒▒▒▒▒  ▒▒▒▒▒▒▒▒  ▒▒▒▒▒  ▒▒▒▒  ▒▒  ▒▒▒▒  ▒▒  ▒▒▒▒  ▒▒▒▒▒  ▒▒▒▒
▓  ▓▓▓▓▓▓▓▓        ▓▓▓▓▓  ▓▓▓▓▓▓▓▓  ▓▓▓▓▓  ▓▓▓▓▓▓▓▓        ▓▓  ▓▓▓▓  ▓▓▓▓▓  ▓▓▓▓
█  ████  ██  ████  █████  ████████  █████  ████  ██  ████  ██        █████  ████
██      ███  ████  ██        █████  ██████      ███  ████  ██  ████  █████  ████
                                                                                
'

generate_cert_for_localhost >> /dev/null 2>&1 &&
nginx



# Keep the container running
tail -f /dev/null