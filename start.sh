#!/bin/sh

generate_self_signed_ssl() {
    local key_file="certs/selfsigned.key"
    local cert_file="certs/selfsigned.crt"
    local csr_file="certs/selfsigned.csr"
    local days_valid=365

    mkdir -p certs

<<<<<<< Updated upstream
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
=======
    cat > "$config_file" <<EOF
[req]
default_bits = 2048
prompt = no
default_md = sha256
distinguished_name = dn
req_extensions = req_ext
x509_extensions = v3_ca

[dn]
C = US
ST = FL
L = Miami
O = NoxCorp
OU = GhostWorks
CN = Noxcis

[req_ext]
subjectAltName = @alt_names

[alt_names]
IP.1 = 127.0.0.1

[v3_ca]
basicConstraints = critical, CA:TRUE, pathlen:0
keyUsage = critical, digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth
EOF

    openssl genpkey -algorithm RSA -out "$key_file"
    openssl req -new -key "$key_file" -out "$csr_file" -config "$config_file"
    openssl x509 -req -days "$days_valid" -in "$csr_file" -signkey "$key_file" \
        -out "$cert_file" -extfile "$config_file" -extensions req_ext -extensions v3_ca
}

# Graceful shutdown function for SIGTERM
graceful_shutdown() {
    echo "SIGTERM received, shutting down Nginx and tail..."
    nginx -s quit
    killall tail
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
generate_self_signed_ssl >> /dev/null 2>&1 && nginx
>>>>>>> Stashed changes

# Keep the container running and trap SIGTERM
tail -f /dev/null
