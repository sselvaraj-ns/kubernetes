# Step1: Enable IPv4 forwarding
sudo sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g'  /etc/sysctl.conf

curl https://dl.k8s.io/v1.18.0/kubernetes-node-linux-amd64.tar.gz
# 

# Step2: Create kubelet Private Key.
# Use OPENSSL tool to generate the private key.
openssl genrsa -out $HOME/cert/kubelet.key 2048

# Step2: Create Kubelet 
cat > $HOME/cert/kubelet.cnf << EOF
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
O="system:nodes"
OU="Learning"
CN="system:node:anna-worker"

[alt_names]
DNS.1 = anna-worker
IP.0 = 127.0.0.1
IP.1 = 192.168.1.15
EOF

# Step4: Generate the Certificate signing request for etcd.
openssl req -new \
-key $HOME/cert/kubelet.key \
-out $HOME/cert/kubelet.csr \
-config $HOME/cert/kubelet.cnf

# Step5: Generate ETCD cert by signing root CA private key.
openssl x509 -req -days 100 -in $HOME/cert/kubelet.csr \
-CA $HOME/cert/ca.crt \
-CAkey $HOME/cert/ca.key \
-CAcreateserial \
-out $HOME/cert/kubelet.crt \
-extensions v3_req \
-extfile $HOME/cert/kubelet.cnf


#scp kubelet.crt anna@192.168.1.15:/home/anna/cert

#scp kubelet.key anna@192.168.1.15:/home/anna/cert


cat <<EOF | sudo tee /home/anna/kubelet/kubelet-config.yaml
apiVersion: kubelet.config.k8s.io/v1beta1
kind: KubeletConfiguration
authentication:
  anonymous:
    enabled: false
  webhook:
    enabled: true
  x509:
    clientCAFile: /home/anna/cert/ca.crt
authorization:
  mode: Webhook
clusterDNS:
- 10.32.0.10
clusterDomain: cluster.local
runtimeRequestTimeout: "5m"
EOF


# Step5.1: Adding kube-controller manager cluster info
kubectl config set-cluster k8s_hard \
--certificate-authority=$HOME/cert/ca.crt \
--embed-certs=true \
--server=https://192.168.1.14:6443 \
--kubeconfig=$HOME/.kube/kubelet.kubeconfig

# Step5.2: Adding kube-controller manager cluster info
kubectl config set-credentials system:node:anna-worker \
--client-certificate=$HOME/cert/kubelet.crt \
--client-key=$HOME/cert/kubelet.key \
--embed-certs=true \
--kubeconfig=$HOME/.kube/kubelet.kubeconfig

# Step5.3: Adding kube-controller manager context
kubectl config set-context default \
--user=system:node:anna-worker \
--cluster=k8s_hard \
--kubeconfig=$HOME/.kube/kubelet.kubeconfig

# Step5.4: To add the default context
kubectl config use-context default \
--kubeconfig=$HOME/.kube/kubelet.kubeconfig



cat <<EOF | sudo tee /etc/systemd/system/kubelet.service
[Unit]
Description=kubelet
After=docker.service
Requires=docker.service

[Service]
ExecStart=/usr/bin/kubelet \\
--config=${HOME}/kubelet/kubelet-config.yaml \\
--kubeconfig=${HOME}/.kube/kubelet.kubeconfig \\
--tls-cert-file=${HOME}/cert/kubelet.crt \\
--tls-private-key-file=${HOME}/cert/kubelet.key \\
--network-plugin=cni \\
--register-node=true \\
--v=2 
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF


