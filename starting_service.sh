
#Step1: Starting ETCD service locally
/tmp/etcd-download-test/etcd --name etcd \
--cert-file=/tmp/cert/etcd.crt \
--key-file=/tmp/cert/etcd.key \
--trusted-ca-file=/tmp/cert/ca.crt \
--client-cert-auth \
--advertise-client-urls=https://127.0.0.1:2379 \
--listen-client-urls=https://127.0.0.1:2379

#Step2: Add data in etcd
/tmp/etcd-download-test/etcdctl --cacert /tmp/cert/ca.crt --cert /tmp/cert/etcd-client.crt --key /tmp/cert/etcd-client.key put name anna

#Step3: Retrive data from etcd
/tmp/etcd-download-test/etcdctl --cacert /tmp/cert/ca.crt --cert /tmp/cert/etcd-client.crt --key /tmp/cert/etcd-client.key get name
