#! /bin/bash
set -e

HOST_IP=$(ip route get 1 | awk '{print $7; exit}')

mkdir -p ./headscale/{config,lib,run}

cp config.yaml headscale/config/config.yaml

# Go to the certs folder, and check if they exist. If they don't they are generated

mkdir -p ./certs
cd certs

if [[(! -f ca.key) || (! -f ca.crt) ]]; then
    echo "generating ca.crt"
    sudo openssl genrsa -out ca.key 4096 # generate key

    sudo openssl req -x509 -new -nodes -key ca.key -sha256 -days 3650 \
        -subj "/CN=Headscale CA" -out ca.crt # generate cert
else
    echo "Using existing ca.crt"
fi

if [[(! -f headscale.key) ]]; then
    echo "generating headscale.crt"
    sudo openssl genrsa -out headscale.key 4096 # generate key
 
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
    # generate cert
    sudo openssl req -new -key headscale.key -out headscale.csr -config headscale.cnf 
    # sign cert with ca cert
    sudo openssl x509 -req -in headscale.csr -CA ca.crt -CAkey ca.key -CAcreateserial \
        -out headscale.crt -days 365 -sha256 -extensions v3_req -extfile headscale.cnf
else
    echo "Using existing headscale.crt"
fi

#copy into headscale/config/certs

mkdir -p ../headscale/config/certs
sudo cp headscale.crt ../headscale/config/certs/headscale.crt

# trust ca cert
sudo cp ca.crt /usr/local/share/ca-certificates/
sudo update-ca-certificates

# add headscale.local to the hostfile
echo "$HOST_IP headscale.local" | sudo tee -a /etc/hosts 
