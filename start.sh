#!/bin/sh

generate_self_signed_ssl() {
    local key_file="certs/selfsigned.key"
    local cert_file="certs/selfsigned.crt"
    local csr_file="certs/selfsigned.csr"
    local config_file="certs/openssl.cnf"
    local days_valid=365

    # Create "certs" directory if it doesn't exist
    mkdir -p certs

    # Create an OpenSSL config file with subjectAltName and X.509 basic constraints
    cat > "$config_file" <<EOF
[req]
default_bits = 2048
prompt = no
default_md = sha256
distinguished_name = dn
req_extensions = req_ext
x509_extensions = v3_ca  # X.509 extensions for the certificate

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
# Basic constraints for X.509
basicConstraints = critical, CA:TRUE, pathlen:0
keyUsage = critical, digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth
EOF

    # Generate private key
    openssl genpkey -algorithm RSA -out "$key_file"

    # Generate certificate signing request (CSR) using the config
    openssl req -new -key "$key_file" -out "$csr_file" -config "$config_file"

    # Generate self-signed certificate with SAN extension and X.509 basic constraints
    openssl x509 -req -days "$days_valid" -in "$csr_file" -signkey "$key_file" \
    -out "$cert_file" -extfile "$config_file" -extensions req_ext -extensions v3_ca 

}

echo '
Starting...
░░      ░░░  ░░░░  ░░        ░░        ░░░      ░░░  ░░░░  ░░░      ░░░        ░
▒  ▒▒▒▒  ▒▒  ▒▒▒▒  ▒▒▒▒▒  ▒▒▒▒▒▒▒▒  ▒▒▒▒▒  ▒▒▒▒  ▒▒  ▒▒▒▒  ▒▒  ▒▒▒▒  ▒▒▒▒▒  ▒▒▒▒
▓  ▓▓▓▓▓▓▓▓        ▓▓▓▓▓  ▓▓▓▓▓▓▓▓  ▓▓▓▓▓  ▓▓▓▓▓▓▓▓        ▓▓  ▓▓▓▓  ▓▓▓▓▓  ▓▓▓▓
█  ████  ██  ████  █████  ████████  █████  ████  ██  ████  ██        █████  ████
██      ███  ████  ██        █████  ██████      ███  ████  ██  ████  █████  ████
                                                                                
'
# Generate SSL and start nginx
generate_self_signed_ssl >> /dev/null 2>&1 && nginx

# Keep the container running
tail -f /dev/null
