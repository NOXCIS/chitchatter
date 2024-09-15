#!/bin/sh

generate_self_signed_ssl() {
    local key_file="certs/selfsigned.key"
    local cert_file="certs/selfsigned.crt"
    local csr_file="certs/selfsigned.csr"
    local days_valid=365

    # Create "certs" directory if it doesn't exist
    mkdir -p certs

    # Generate private key
    openssl genpkey -algorithm RSA -out "$key_file"

    # Generate certificate signing request (CSR)
    openssl req -new -key "$key_file" -out "$csr_file" -subj "/C=US/ST=FL/L=Miami/O=NoxCorp/OU=GhostWorks/CN=Noxcis"

    # Generate self-signed certificate
    openssl x509 -req -days "$days_valid" -in "$csr_file" -signkey "$key_file" -out "$cert_file"

    # Provide information about the generated files
    echo "Self-signed SSL key: $key_file"
    echo "Self-signed SSL certificate: $cert_file"
    echo "Certificate signing request: $csr_file"
}

# Generate SSL and start nginx
generate_self_signed_ssl && nginx

# Keep the container running
tail -f /dev/null
