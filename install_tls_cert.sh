#Step0: Make cert directory
mkdir /tmp/cert 

#Root Public Certificate should be available in all components

#Step1: Create local server as a CA server for generating users certification.
#Use OPENSSL tool to generate the private key.
openssl genrsa -out /tmp/cert/ca.key 1024

#Step2: Generate the Certificate signing request.
openssl req -new -key /tmp/cert/ca.key -subj "/CN=KUBERNETES-CA" -out /tmp/cert/ca.csr

#Step3: Sign the csr requested certificate and provide a publick key along with certificate
openssl x509 -req -days 30 -in /tmp/cert/ca.csr -signkey ca.key -out /tmp/cert/ca.crt

#Step4: We got the two main files. CA private key (ca.key) and CA public key (ca-cert.crt) self signed.
openssl x509 -in /tmp/cert/ca.crt -text -noout

#Step5: To check cert in online decoder
#https://www.sslshopper.com/certificate-decoder.html


#Step6: Create ETCD Private Key.
#Use OPENSSL tool to generate the private key.
openssl genrsa -out /tmp/cert/etcd.key 2048

#Step7: Generate CA Conf for ETCD
cat > /tmp/cert/etcd.cnf << EOF
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
IP.1 = 192.168.1.13
EOF

#Step8: Generate the Certificate signing request for etcd.
openssl req -new -key /tmp/cert/etcd.key -out /tmp/cert/etcd.csr -config /tmp/cert/etcd.cnf

#Step9: Generate ETCD cert by signing root CA private key.
openssl x509 -req -days 30 -in /tmp/cert/etcd.csr \
-CA /tmp/cert/ca.crt \
-CAkey /tmp/cert/ca.key \
-CAcreateserial \
-out /tmp/cert/etcd.crt \
-extensions v3_req -extfile \
/tmp/cert/etcd.cnf

#Step10: Genereate ETCD Client(etcdctl) Private key
#Use OPENSSL tool to generate the private key.
openssl genrsa -out /tmp/cert/etcd-client.key 2048

#Step11: Generate the Certificate signing request.
openssl req -new -key /tmp/cert/etcd-client.key -subj "/CN=etcd-client" -out /tmp/cert/etcd-client.csr

#Step12: Sign the csr requested certificate and provide a publick key along with certificate
openssl x509 -req -days 30 -in /tmp/cert/etcd-client.csr -CA /tmp/cert/ca.crt -CAkey /tmp/cert/ca.key -out /tmp/cert/etcd-client.crt

#Step13: Genereate Kube-API Server Private key
#Use OPENSSL tool to generate the private key.
openssl genrsa -out /tmp/cert/kube-api.key 2048

#Step14: Generate Kube-api Conf
cat > /tmp/cert/kube-api.cnf << EOF
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
DNS.0 = kubernetes
DNS.1 = kubernetes.default
DNS.2 = kubernetes.default.svc
DNS.3 = kubernetes.default.svc.cluster.local
IP.0 = 127.0.0.1
IP.1 = 10.32.0.1
IP.2 = ${SERVER_IP}
EOF

#Step15: Generate the Certificate signing request.
openssl req -new -key /tmp/cert/kube-api.key -subj "/CN=api-server" -out /tmp/cert/kube-api.csr -config /tmp/cert/kube-api.cnf

#Step16: Sign the csr requested certificate and provide a publick key along with certificate
openssl x509 -req -days 30 -in /tmp/cert/kube-api.csr \
-CA /tmp/cert/ca.crt \
-CAkey /tmp/cert/ca.key \
-CAcreateserial \
-out /tmp/cert/kube-api.crt \
-extensions v3_req \
-extfile /tmp/cert/kube-api.cnf

#Step17: Genereate Service Account Private key
#Use OPENSSL tool to generate the private key.
openssl genrsa -out /tmp/cert/service-account.key 2048

#Step18: Generate the Certificate signing request.
openssl req -new -key /tmp/cert/service-account.key -subj "/CN=service-account" -out /tmp/cert/service-account.csr

#Step19: Sign the csr requested certificate and provide a publick key along with certificate
openssl x509 -req -days 30 -in /tmp/cert/service-account.csr -CA /tmp/cert/ca.crt -CAkey /tmp/cert/ca.key -out /tmp/cert/service-account.crt


#Step20: Genereate kube-api-etcd-client private key
#Use OPENSSL tool to generate the private key.
openssl genrsa -out /tmp/cert/apiserver-etcd-client.key 2048

#Step21: Generate the Certificate signing request.
openssl req -new -key /tmp/cert/apiserver-etcd-client.key -subj "/CN=apiserver-etcd-client" -out /tmp/cert/apiserver-etcd-client.csr

#Step22: Sign the csr requested certificate and provide a publick key along with certificate
openssl x509 -req -days 30 -in /tmp/cert/apiserver-etcd-client.csr -CA /tmp/cert/ca.crt -CAkey /tmp/cert/ca.key -out /tmp/cert/apiserver-etcd-client.crt

#Step23: Genereate kube-api-kubelet private key
#Use OPENSSL tool to generate the private key.
openssl genrsa -out /tmp/cert/apiserver-kubelet-client.key 2048

#Step24: Generate the Certificate signing request.
openssl req -new -key /tmp/cert/apiserver-kubelet-client.key -subj "/CN=apiserver-kubelet-client" -out /tmp/cert/apiserver-kubelet-client.csr

#Step25: Sign the csr requested certificate and provide a publick key along with certificate
openssl x509 -req -days 30 -in /tmp/cert/apiserver-kubelet-client.csr -CA /tmp/cert/ca.crt -CAkey /tmp/cert/ca.key -out /tmp/cert/apiserver-kubelet-client.crt
