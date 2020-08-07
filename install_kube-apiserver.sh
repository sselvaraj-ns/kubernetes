# Step1: Grepping host IP
SERVER_IP=$(ip addr show | grep -v '127.0\|172.17' | grep -oP '(?<=inet\s)\d+(\.\d+){3}')

# Step2: Genereate Kube-API Server Private key
#Use OPENSSL tool to generate the private key.
openssl genrsa -out $HOME/cert/kube-api.key 2048

# Step3: Generate Kube-api Conf
cat > $HOME/cert/kube-api.cnf << EOF
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
CN="kubernetes"

[alt_names]
DNS.0 = kubernetes
DNS.1 = kubernetes.default
DNS.2 = kubernetes.default.svc
DNS.3 = kubernetes.default.svc.cluster.local
IP.0 = 127.0.0.1
IP.1 = 10.32.0.1
IP.2 = ${SERVER_IP}
EOF

# Step4: Generate the Certificate signing request.
openssl req -new \
-key $HOME/cert/kube-api.key \
-out $HOME/cert/kube-api.csr \
-config $HOME/cert/kube-api.cnf

# Step5: Sign the csr requested certificate and provide a publick key along with certificate
openssl x509 -req -days 100 -in $HOME/cert/kube-api.csr \
-CA $HOME/cert/ca.crt \
-CAkey $HOME/cert/ca.key \
-CAcreateserial \
-out $HOME/cert/kube-api.crt \
-extensions v3_req \
-extfile $HOME/cert/kube-api.cnf

# Step6: Genereate Service Account Private key
#Use OPENSSL tool to generate the private key.
openssl genrsa -out $HOME/cert/service-account.key 2048

# Step7: Generate the Certificate signing request.
openssl req -new -key $HOME/cert/service-account.key -subj "/CN=service-account" -out $HOME/cert/service-account.csr

#Step8: Sign the csr requested certificate and provide a publick key along with certificate
openssl x509 -req -days 100 -in $HOME/cert/service-account.csr -CA $HOME/cert/ca.crt -CAkey $HOME/cert/ca.key -out $HOME/cert/service-account.crt

# Step9: Genereate kube-api-etcd-client private key
#Use OPENSSL tool to generate the private key.
openssl genrsa -out $HOME/cert/apiserver-etcd-client.key 2048

# Step10: Generate the Certificate signing request.
openssl req -new -key $HOME/cert/apiserver-etcd-client.key -subj "/CN=apiserver-etcd-client" -out $HOME/cert/apiserver-etcd-client.csr

# Step11: Sign the csr requested certificate and provide a publick key along with certificate
openssl x509 -req -days 100 -in $HOME/cert/apiserver-etcd-client.csr -CA $HOME/cert/ca.crt -CAkey $HOME/cert/ca.key -out $HOME/cert/apiserver-etcd-client.crt

# Step12: Genereate kube-api-kubelet private key
#Use OPENSSL tool to generate the private key.
openssl genrsa -out $HOME/cert/apiserver-kubelet-client.key 2048

# Step13: Generate the Certificate signing request.
openssl req -new -key $HOME/cert/apiserver-kubelet-client.key -subj "/CN=apiserver-kubelet-client" -out $HOME/cert/apiserver-kubelet-client.csr

# Step14: Sign the csr requested certificate and provide a publick key along with certificate
openssl x509 -req -days 100 -in $HOME/cert/apiserver-kubelet-client.csr -CA $HOME/cert/ca.crt -CAkey $HOME/cert/ca.key -out $HOME/cert/apiserver-kubelet-client.crt

# Step15: copy the binaries to the user bin
sudo cp $HOME/kubernetes-server/kubernetes/server/bin/kube-apiserver /usr/bin/

# Step16: Creating kube-apiserver service as a system service.

cat <<EOF | sudo tee /etc/systemd/system/kube-apiserver.service
[Unit]
Description=kube-apiserver

[Service]
ExecStart=/usr/bin/kube-apiserver \\
--advertise-address=${SERVER_IP} \\
--allow-privileged=true \\
--authorization-mode=Node,RBAC \\
--insecure-port=0 \\
--secure-port=6443 \\
--etcd-servers=https://127.0.0.1:2379 \\
--service-cluster-ip-range=10.32.0.0/24 \\
--enable-bootstrap-token-auth=true \\
--tls-cert-file=${HOME}/cert/kube-api.crt \\
--tls-private-key-file=${HOME}/cert/kube-api.key \\
--etcd-certfile=${HOME}/cert/apiserver-etcd-client.crt \\
--etcd-keyfile=${HOME}/cert/apiserver-etcd-client.key \\
--service-account-key-file=${HOME}/cert/service-account.crt \\
--kubelet-client-certificate=${HOME}/cert/apiserver-kubelet-client.key \\
--kubelet-client-key=${HOME}/cert/apiserver-kubelet-client.key \\
--client-ca-file=${HOME}/cert/ca.crt \\
--etcd-cafile=${HOME}/cert/ca.crt 
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# start a local kube-apiserver server
systemctl daemon-reload
systemctl start kube-apiserver
systemctl status kube-apiserver

# Step17: To view the system running kube-apiserver process
#journalctl -u kube-apiserver