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
# --service-account-key-file=/tmp/cert/service-account.key \
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
--service-account-key-file=/tmp/cert/service-account.key \
--kubelet-client-certificate=/tmp/cert/apiserver-etcd-client.crt \
--kubelet-client-key=/tmp/cert/apiserver-etcd-client.key \
--client-ca-file=/tmp/cert/ca.crt \
--etcd-cafile=/tmp/cert/ca.crt 

#Step3: Add data in etcd
/tmp/etcd-download-test/etcdctl \
--cacert /tmp/cert/ca.crt \
--cert /tmp/cert/etcd-client.crt \
--endpoints https://127.0.0.1:2379 \
--key /tmp/cert/etcd-client.key \
put name anna

#Step4: Retrive data from etcd
/tmp/etcd-download-test/etcdctl --cacert /tmp/cert/ca.crt --cert /tmp/cert/etcd-client.crt --key /tmp/cert/etcd-client.key get name


