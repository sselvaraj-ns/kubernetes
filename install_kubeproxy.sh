# Step1: Genereate kube-controller-manager private key
#Use OPENSSL tool to generate the private key.
openssl genrsa -out $HOME/cert/kubeproxy.key 2048

# Step2: Generate the Certificate signing request.
openssl req -new \
 -key $HOME/cert/kubeproxy.key \
 -subj "/CN=system:kube-proxy" \
 -out $HOME/cert/kubeproxy.csr

# Step3: Sign the csr requested certificate and provide a publick key along with certificate
openssl x509 -req -days 100 \
-in $HOME/cert/kubeproxy.csr \
-CA $HOME/cert/ca.crt \
-CAkey $HOME/cert/ca.key \
-out $HOME/cert/kubeproxy.crt


cat <<EOF | sudo tee ${HOME}/kubeproxy/kubeproxy-config.yaml
apiVersion: kubeproxy.config.k8s.io/v1alpha1
kind: KubeProxyConfiguration
clientConnection:
    kubeconfig: "${HOME}/.kube/kube-proxy.kubeconfig"
mode: "iptables"
clusterCIDR: "10.200.0.0/16"
EOF


----

cat <<EOF | sudo tee /etc/systemd/system/kubeproxy.service
[Unit]
Description=Kube Proxy

[Service]
ExecStart=/usr/bin/kube-proxy \\
--config=${HOME}/kubeproxy/kubeproxy-config.yaml \\
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF


---

# Step5.1: Adding kube-controller manager cluster info
kubectl config set-cluster k8s_hard \
--certificate-authority=$HOME/cert/ca.crt \
--embed-certs=true \
--server=https://192.168.1.14:6443 \
--kubeconfig=$HOME/.kube/kube-proxy.kubeconfig

# Step5.2: Adding kube-controller manager cluster info
kubectl config set-credentials system:kube-proxy \
--client-certificate=$HOME/cert/kubeproxy.crt \
--client-key=$HOME/cert/kubeproxy.key \
--embed-certs=true \
--kubeconfig=$HOME/.kube/kube-proxy.kubeconfig

# Step5.3: Adding kube-controller manager context
kubectl config set-context default \
--user=system:kube-proxy \
--cluster=k8s_hard \
--kubeconfig=$HOME/.kube/kube-proxy.kubeconfig

# Step5.4: To add the default context
kubectl config use-context default \
--kubeconfig=$HOME/.kube/kube-proxy.kubeconfig