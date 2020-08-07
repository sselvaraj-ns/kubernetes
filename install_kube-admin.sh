# Step1: Genereate kube-admin user private key
#Use OPENSSL tool to generate the private key.
openssl genrsa -out $HOME/cert/kube-admin.key 2048

# Step2: Generate the Certificate signing request.
openssl req -new -key $HOME/cert/kube-admin.key -subj "/CN=admin/O=system:masters" -out $HOME/cert/kube-admin.csr

# Step3: Sign the csr requested certificate and provide a publick key along with certificate
openssl x509 -req -days 100 -in $HOME/cert/kube-admin.csr -CA $HOME/cert/ca.crt -CAkey $HOME/cert/ca.key -out $HOME/cert/kube-admin.crt

# Step4.1: Adding kube config for kube-admin user
kubectl config set-cluster k8s_hard \
--certificate-authority=$HOME/cert/ca.crt \
--embed-certs=true \
--server=https://127.0.0.1:6443 \
--kubeconfig=$HOME/.kube/kube-admin.kubeconfig

# Step4.2: Adding kube-kube-admin manager cluster info
kubectl config set-credentials kube-admin \
--client-certificate=$HOME/cert/kube-admin.crt \
--client-key=$HOME/cert/kube-admin.key \
--embed-certs=true \
--kubeconfig=$HOME/.kube/kube-admin.kubeconfig

# Step4.3: 
kubectl config set-context default \
--user=kube-admin \
--cluster=k8s_hard \
--kubeconfig=$HOME/.kube/kube-admin.kubeconfig

# Step4.4: To add the default context
kubectl config use-context default \
--kubeconfig=$HOME/.kube/kube-admin.kubeconfig

# Step5: To view the system:kube-admin-manager kubeconfig
kubectl config view --kubeconfig=$HOME/.kube/kube-admin.kubeconfig
