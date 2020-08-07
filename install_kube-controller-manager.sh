# Trun off the swap memory 
#https://frankdenneman.nl/2018/11/15/kubernetes-swap-and-the-vmware-balloon-driver/#:~:text=Kubernetes%20requires%20to%20disable%20the,unable%20to%20create%20memory%20pressure.
sudo swapoff -a
mkdir $HOME/.kube

# Step1: Genereate kube-controller-manager private key
#Use OPENSSL tool to generate the private key.
openssl genrsa -out $HOME/cert/kube-controller-manager.key 2048

# Step2: Generate the Certificate signing request.
openssl req -new \
 -key $HOME/cert/kube-controller-manager.key \
 -subj "/CN=system:kube-controller-manager" \
 -out $HOME/cert/kube-controller-manager.csr

# Step3: Sign the csr requested certificate and provide a publick key along with certificate
openssl x509 -req -days 100 \
-in $HOME/cert/kube-controller-manager.csr \
-CA $HOME/cert/ca.crt \
-CAkey $HOME/cert/ca.key \
-out $HOME/cert/kube-controller-manager.crt

# Step4: Copy the binaries to the user bin
sudo cp $HOME/kubernetes-server/kubernetes/server/bin/kube-controller-manager /usr/bin/
sudo cp $HOME/kubernetes-server/kubernetes/server/bin/kubectl /usr/bin/

# Step5.1: Adding kube-controller manager cluster info
kubectl config set-cluster k8s_hard \
--certificate-authority=$HOME/cert/ca.crt \
--embed-certs=true \
--server=https://127.0.0.1:6443 \
--kubeconfig=$HOME/.kube/kube-controller-manager.kubeconfig

# Step5.2: Adding kube-controller manager cluster info
kubectl config set-credentials system:kube-controller-manager \
--client-certificate=$HOME/cert/kube-controller-manager.crt \
--client-key=$HOME/cert/kube-controller-manager.key \
--embed-certs=true \
--kubeconfig=$HOME/.kube/kube-controller-manager.kubeconfig

# Step5.3: Adding kube-controller manager context
kubectl config set-context default \
--user=system:kube-controller-manager \
--cluster=k8s_hard \
--kubeconfig=$HOME/.kube/kube-controller-manager.kubeconfig

# Step5.4: To add the default context
kubectl config use-context default \
--kubeconfig=$HOME/.kube/kube-controller-manager.kubeconfig

# Step6: Creating kube-controller-manager service as a system service.
cat <<EOF | sudo tee /etc/systemd/system/kube-controller-manager.service
[Unit]
Description=kube-controller-manager

[Service]
ExecStart=/usr/bin/kube-controller-manager \\
--address=0.0.0.0 \\
--kubeconfig=${HOME}/.kube/kube-controller-manager.kubeconfig \\
--cluster-signing-cert-file=${HOME}/cert/ca.crt \\
--cluster-signing-key-file=${HOME}/cert/ca.key \\
--root-ca-file=${HOME}/cert/ca.crt \\
--service-account-private-key-file=${HOME}/cert/service-account.key \\
--use-service-account-credentials=true \\
--v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# Step7: Start a local kube-controller-manager server
systemctl daemon-reload
systemctl start kube-controller-manager
systemctl status kube-controller-manager

# Step8: To view the system:kube-controller-manager kubeconfig
echo -------kubectl config view--------
echo ----------------------------------
kubectl config view --kubeconfig=$HOME/.kube/kube-controller-manager.kubeconfig
