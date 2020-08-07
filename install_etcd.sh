# Step1: Grepping host IP and creating env
SERVER_IP=$(ip addr show | grep -v '127.0\|172.17' | grep -oP '(?<=inet\s)\d+(\.\d+){3}')

# Step2: Create ETCD Private Key.
# Use OPENSSL tool to generate the private key.
openssl genrsa -out $HOME/cert/etcd.key 2048

# Step3: Generate CA Conf for ETCD
cat > $HOME/cert/etcd.cnf << EOF
[req]
req_extensions = v3_req
default_bits = 2048
distinguished_name = dn
prompt             = no

[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names

[dn]
C="IN"
ST="Karnataka"
L="Bangalore"
O="Self"
OU="Learning"
CN="etcd"

[alt_names]
IP.0 = 127.0.0.1
IP.1 = ${SERVER_IP}
EOF

# Step4: Generate the Certificate signing request for etcd.
openssl req -new -key $HOME/cert/etcd.key -out $HOME/cert/etcd.csr -config $HOME/cert/etcd.cnf

# Step5: Generate ETCD cert by signing root CA private key.
openssl x509 -req -days 100 -in $HOME/cert/etcd.csr \
-CA $HOME/cert/ca.crt \
-CAkey $HOME/cert/ca.key \
-CAcreateserial \
-out $HOME/cert/etcd.crt \
-extensions v3_req -extfile \
$HOME/cert/etcd.cnf

# Step6: Genereate ETCD Client(etcdctl) Private key
#Use OPENSSL tool to generate the private key.
openssl genrsa -out $HOME/cert/etcd-client.key 2048

# Step7: Generate the Certificate signing request.
openssl req -new -key $HOME/cert/etcd-client.key -subj "/CN=etcd-client" -out $HOME/cert/etcd-client.csr

# Step8: Sign the csr requested certificate and provide a publick key along with certificate
openssl x509 -req -days 30 -in $HOME/cert/etcd-client.csr -CA $HOME/cert/ca.crt -CAkey $HOME/cert/ca.key -out $HOME/cert/etcd-client.crt


# Step9: Download and install ETCD binaries
ETCD_VER=v3.4.10

# choose either URL
GOOGLE_URL=https://storage.googleapis.com/etcd
GITHUB_URL=https://github.com/etcd-io/etcd/releases/download
DOWNLOAD_URL=${GOOGLE_URL}

# Remove the old etcd files if any
rm -f $HOME/etcd-${ETCD_VER}-linux-amd64.tar.gz
rm -rf $HOME/etcd-download-test && mkdir -p $HOME/etcd-download-test

# Download the etcd and untar
curl -L ${DOWNLOAD_URL}/${ETCD_VER}/etcd-${ETCD_VER}-linux-amd64.tar.gz -o $HOME/etcd-${ETCD_VER}-linux-amd64.tar.gz
tar xzvf $HOME/etcd-${ETCD_VER}-linux-amd64.tar.gz -C $HOME/etcd-download-test --strip-components=1
rm -f $HOME/etcd-${ETCD_VER}-linux-amd64.tar.gz

# Step10: Verify the etcd 
echo ------verfiying the etcd installation-----
$HOME/etcd-download-test/etcd --version
$HOME/etcd-download-test/etcdctl version

# Step11: Copy the ETCD binaries to the user bin
sudo cp $HOME/etcd-download-test/etcd /usr/bin/
sudo cp $HOME/etcd-download-test/etcdctl /usr/bin/

# Step12: Verify the etcd 
echo ------verfiying the etcd installation-----
etcd --version
etcdctl version

# Step13: Creating ETCD service as a system service.

cat <<EOF | sudo tee /etc/systemd/system/etcd.service
[Unit]
Description=etcd-server

[Service]
ExecStart=/usr/bin/etcd \\
--name etcd \\
--cert-file=${HOME}/cert/etcd.crt \\
--key-file=${HOME}/cert/etcd.key \\
--trusted-ca-file=${HOME}/cert/ca.crt \\
--client-cert-auth \\
--advertise-client-urls=https://0.0.0.0:2379 \\
--listen-client-urls=https://0.0.0.0:2379 
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# Step14: Start a local etcd server
systemctl daemon-reload
systemctl start etcd
systemctl status etcd

# start a local etcd server
#$HOME/etcd-download-test/etcd

# Step15: write,read to etcd
echo -------ETCD PUT and GET-----------
echo ----------------------------------
etcdctl --endpoints=https://127.0.0.1:2379 put foo bar \
 --cacert=$HOME/cert/ca.crt \
 --cert=$HOME/cert/etcd-client.crt \
 --key=$HOME/cert/etcd-client.key

etcdctl --endpoints=https://127.0.0.1:2379 get foo \
 --cacert=$HOME/cert/ca.crt \
 --cert=$HOME/cert/etcd-client.crt \
 --key=$HOME/cert/etcd-client.key

# Step16: To view the system running etcd process
#journalctl -u etcd