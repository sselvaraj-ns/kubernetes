# Step1: Genereate kube-scheduler-manager private key
#Use OPENSSL tool to generate the private key.
openssl genrsa -out $HOME/cert/kube-scheduler.key 2048

# Step2: Generate the Certificate signing request.
openssl req -new -key $HOME/cert/kube-scheduler.key -subj "/CN=system:kube-scheduler" -out $HOME/cert/kube-scheduler.csr

# Step3: Sign the csr requested certificate and provide a publick key along with certificate
openssl x509 -req -days 100 -in $HOME/cert/kube-scheduler.csr -CA $HOME/cert/ca.crt -CAkey $HOME/cert/ca.key -out $HOME/cert/kube-scheduler.crt

# Step4: Copy the binaries to the user bin
sudo cp $HOME/kubernetes-server/kubernetes/server/bin/kube-scheduler /usr/bin/

# Step5.1: Adding kube-scheduler manager cluster info
kubectl config set-cluster k8s_hard \
--certificate-authority=$HOME/cert/ca.crt \
--embed-certs=true \
--server=https://127.0.0.1:6443 \
--kubeconfig=$HOME/.kube/kube-scheduler.kubeconfig

# Step5.2: Adding kube-scheduler manager cluster info
kubectl config set-credentials system:kube-scheduler \
--client-certificate=$HOME/cert/kube-scheduler.crt \
--client-key=$HOME/cert/kube-scheduler.key \
--embed-certs=true \
--kubeconfig=$HOME/.kube/kube-scheduler.kubeconfig

# Step5.3: Adding kube-scheduler manager context
kubectl config set-context default \
--user=system:kube-scheduler \
--cluster=k8s_hard \
--kubeconfig=$HOME/.kube/kube-scheduler.kubeconfig

# Step5.4: To add the default context
kubectl config use-context default \
--kubeconfig=$HOME/.kube/kube-scheduler.kubeconfig

# Step6: Creating kube-scheduler service as a system service.
cat <<EOF | sudo tee /etc/systemd/system/kube-scheduler.service
[Unit]
Description=kube-scheduler

[Service]
ExecStart=/usr/bin/kube-scheduler \
--kubeconfig=${HOME}/.kube/kube-scheduler.kubeconfig \
--authentication-kubeconfig=${HOME}/.kube/kube-scheduler.kubeconfig \
--authorization-kubeconfig=${HOME}/.kube/kube-scheduler.kubeconfig \
--bind-address=127.0.0.1

Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# Step7: Start a local kube-scheduler server
systemctl daemon-reload
systemctl start kube-scheduler
systemctl status kube-scheduler

# Step8: To view the system:kube-scheduler kubeconfig
echo -------kubectl config view--------
echo ----------------------------------
kubectl config view --kubeconfig=$HOME/.kube/kube-controller-manager.kubeconfig

echo -------kubectl get pod------------
echo ----------------------------------
kubectl get po --kubeconfig=$HOME/.kube/kube-controller-manager.kubeconfig

echo -------kubectl get node-----------
echo ----------------------------------
kubectl get no --kubeconfig=$HOME/.kube/kube-controller-manager.kubeconfig

echo -------kubectl get pod------------
echo ----------------------------------
kubectl get pod \
--certificate-authority $HOME/cert/ca.crt \
--client-certificate $HOME/cert/kube-admin.crt \
--client-key $HOME/cert/kube-admin.key \
-s https://127.0.0.1:6443
