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
openssl x509 -req -days 30 -in /tmp/cert/etcd-client.key -CA /tmp/cert/ca.crt -CAkey /tmp/cert/ca.key -out /tmp/cert/etcd-client.crt
