#! /bin/bash
set -e

HOST_IP=$(ip route get 1 | awk '{print $7; exit}')

mkdir -p ./headscale/{config,lib,run}

cp config.yaml headscale/config/config.yaml

mkdir -p headscale/config/certs
cd headscale/config/certs

sudo openssl genrsa -out ca.key 4096

sudo openssl req -x509 -new -nodes -key ca.key -sha256 -days 3650 \
  -subj "/CN=Headscale CA" \
  -out ca.crt

sudo openssl genrsa -out headscale.key 4096

# Generate openssl config with SAN
cat > headscale.cnf <<EOF
[req]
prompt = no
distinguished_name = dn
req_extensions = v3_req

[dn]
CN = headscale.local

[v3_req]
subjectAltName = @alt_names

[alt_names]
DNS.1 = headscale.local
EOF

sudo openssl req -new -key headscale.key -out headscale.csr -config headscale.cnf

sudo openssl x509 -req -in headscale.csr -CA ca.crt -CAkey ca.key -CAcreateserial \
  -out headscale.crt -days 365 -sha256 -extensions v3_req -extfile headscale.cnf

sudo cp ca.crt /usr/local/share/ca-certificates/
sudo update-ca-certificates
echo "$HOST_IP headscale.local" | sudo tee -a /etc/hosts
