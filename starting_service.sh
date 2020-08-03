#Step1: Starting ETCD service locally
/tmp/etcd-download-test/etcd --name etcd \
--cert-file=/tmp/cert/etcd.crt \
--key-file=/tmp/cert/etcd.key \
--trusted-ca-file=/tmp/cert/ca.crt \
--client-cert-auth \
--advertise-client-urls=https://0.0.0.0:2379 \
--listen-client-urls=https://0.0.0.0:2379 \
&

# #Step2: Starting Kube-api service locally
# /tmp/kubernetes/server/bin/kube-apiserver \
# --advertise-address=${SERVER_IP} \
# --allow-privileged=true \
# --authorization-mode=Node,RBAC \
# --insecure-port=0 \
# --secure-port=6443 \
# --service-cluster-ip-range=10.32.0.0/24 \
# --enable-bootstrap-token-auth=true \
# ### OWN
# --tls-cert-file=/tmp/cert/kube-api.crt \
# --tls-private-key-file=/tmp/cert/kube-api.key \
# ### ETCD
# --etcd-certfile=/tmp/cert/apiserver-etcd-client.crt \
# --etcd-keyfile=/tmp/cert/apiserver-etcd-client.key \
# ### SA
# --service-account-key-file=/tmp/cert/service-account.crt \
# ### kubelet
# --kubelet-client-certificate=/tmp/cert/apiserver-etcd-client.crt \
# --kubelet-client-key=/tmp/cert/apiserver-etcd-client.key \
# ### Public keys
# --client-ca-file=/tmp/cert/ca.crt \
# --etcd-cafile=/tmp/cert/ca.crt \

#Step2: Starting Kube-api service locally
/tmp/kubernetes/server/bin/kube-apiserver \
--advertise-address=${SERVER_IP} \
--allow-privileged=true \
--authorization-mode=Node,RBAC \
--insecure-port=0 \
--secure-port=6443 \
--etcd-servers=https://127.0.0.1:2379 \
--service-cluster-ip-range=10.32.0.0/24 \
--enable-bootstrap-token-auth=true \
--tls-cert-file=/tmp/cert/kube-api.crt \
--tls-private-key-file=/tmp/cert/kube-api.key \
--etcd-certfile=/tmp/cert/apiserver-etcd-client.crt \
--etcd-keyfile=/tmp/cert/apiserver-etcd-client.key \
--service-account-key-file=/tmp/cert/service-account.crt \
--kubelet-client-certificate=/tmp/cert/apiserver-etcd-client.crt \
--kubelet-client-key=/tmp/cert/apiserver-etcd-client.key \
--client-ca-file=/tmp/cert/ca.crt \
--etcd-cafile=/tmp/cert/ca.crt 

#Step3: Adding kube-controller manager cluster info
./kubectl config set-cluster k8s_hard \
--certificate-authority=/tmp/cert/ca.crt \
--embed-certs=true \
--server=https://127.0.0.1:6443 \
--kubeconfig=kube-controller-manager.kubeconfig

#Step3.1: Adding kube-controller manager cluster info
./kubectl config set-credentials system:kube-controller-manager \
--client-certificate=/tmp/cert/kube-controller-manager.crt \
--client-key=/tmp/cert/kube-controller-manager.key \
--embed-certs=true \
--kubeconfig=kube-controller-manager.kubeconfig

#Step3.2: 
./kubectl config set-context default \
--user=system:kube-controller-manager \
--cluster=k8s_hard \
--kubeconfig=kube-controller-manager.kubeconfig

#Step3.3: To add the default context
./kubectl config use-context default \
--kubeconfig=kube-controller-manager.kubeconfig

#Step3.4: To view the system:kube-controller-manager kubeconfig
./kubectl config view --kubeconfig=kube-controller-manager.kubeconfig

#Step3.5: To start kube-controller-manager
./kube-controller-manager \
--address=0.0.0.0 \
--kubeconfig=/tmp/kubernetes/server/bin/kube-controller-manager.kubeconfig \
--cluster-signing-cert-file=/tmp/cert/ca.crt \
--cluster-signing-key-file=/tmp/cert/ca.key \
--root-ca-file=/tmp/cert/ca.crt \
--service-account-private-key-file=/tmp/cert/service-account.key \
--use-service-account-credentials=true \
--v=2 \
&

#Step4: Adding kube-scheduler manager cluster info
./kubectl config set-cluster k8s_hard \
--certificate-authority=/tmp/cert/ca.crt \
--embed-certs=true \
--server=https://127.0.0.1:6443 \
--kubeconfig=kube-scheduler.kubeconfig

#Step4.1: Adding kube-scheduler manager cluster info
./kubectl config set-credentials system:kube-scheduler \
--client-certificate=/tmp/cert/kube-scheduler.crt \
--client-key=/tmp/cert/kube-scheduler.key \
--embed-certs=true \
--kubeconfig=kube-scheduler.kubeconfig

#Step4.2: 
./kubectl config set-context default \
--user=system:kube-scheduler \
--cluster=k8s_hard \
--kubeconfig=kube-scheduler.kubeconfig

#Step4.3: To add the default context
./kubectl config use-context default \
--kubeconfig=kube-scheduler.kubeconfig

#Step4.4: To view the system:kube-scheduler-manager kubeconfig
./kubectl config view --kubeconfig=kube-scheduler.kubeconfig

#Step4.5: To start kube-scheduler service
./kube-scheduler \
--kubeconfig=/tmp/kubernetes/server/bin/kube-scheduler.kubeconfig \
--authentication-kubeconfig=/tmp/kubernetes/server/bin/kube-scheduler.kubeconfig \
--authorization-kubeconfig=/tmp/kubernetes/server/bin/kube-scheduler.kubeconfig \
--bind-address=127.0.0.1 \
&

#Step5 Adding kube config for kube-admin user
./kubectl config set-cluster k8s_hard \
--certificate-authority=/tmp/cert/ca.crt \
--embed-certs=true \
--server=https://127.0.0.1:6443 \
--kubeconfig=kube-admin.kubeconfig

#Step5.1: Adding kube-kube-admin manager cluster info
./kubectl config set-credentials kube-admin \
--client-certificate=/tmp/cert/kube-admin.crt \
--client-key=/tmp/cert/kube-admin.key \
--embed-certs=true \
--kubeconfig=kube-admin.kubeconfig

#Step5.2: 
./kubectl config set-context default \
--user=kube-admin \
--cluster=k8s_hard \
--kubeconfig=kube-admin.kubeconfig

#Step5.3: To add the default context
./kubectl config use-context default \
--kubeconfig=kube-admin.kubeconfig

#Step5.4: To view the system:kube-admin-manager kubeconfig
./kubectl config view --kubeconfig=kube-admin.kubeconfig

#Step6: Add data in etcd
/tmp/etcd-download-test/etcdctl \
--cacert /tmp/cert/ca.crt \
--cert /tmp/cert/etcd-client.crt \
--endpoints https://127.0.0.1:2379 \
--key /tmp/cert/etcd-client.key \
put name anna

#Step4: Retrive data from etcd
/tmp/etcd-download-test/etcdctl --cacert /tmp/cert/ca.crt --cert /tmp/cert/etcd-client.crt --key /tmp/cert/etcd-client.key get name

./kubectl get pod --certificate-authority /tmp/cert/ca.crt --client-certificate /tmp/cert/etcd-client.crt --client-key /tmp/cert/etcd-client.key -s https://127.0.0.1:6443

./kubectl get componentstatus --kubeconfig=kube-admin.kubeconfig