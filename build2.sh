#! /bin/bash
set -e

HOST_IP=$(ip route get 1 | awk '{print $7; exit}')

mkdir -p ./headscale/{config,lib,run}

cp config.yaml headscale/config/config.yaml

mkdir -p headscale/config/certs
cd headscale/config/certs

# Generate openssl config with SAN
cat > openssl-san.cnf <<EOF
[req]
default_bits       = 2048
prompt             = no
default_md         = sha256
req_extensions     = req_ext
distinguished_name = dn

[dn]
CN = headscale.local

[req_ext]
subjectAltName = @alt_names

[alt_names]
DNS.1 = headscale.local

[v3_ca]
subjectAltName = @alt_names
basicConstraints = critical, CA:true
keyUsage = critical, keyCertSign, digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth, clientAuth
EOF


sudo openssl req -x509 -newkey rsa:4096 -keyout headscale.key -out headscale.crt \
    -days 365 -config openssl-san.cnf -nodes -extensions v3_ca

sudo cp headscale.crt /usr/local/share/ca-certificates/
sudo update-ca-certificates
echo "$HOST_IP headscale.local" | sudo tee -a /etc/hosts
