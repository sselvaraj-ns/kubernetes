# Kubernetes server version.
K8S_VER=v1.18.0

# Remove the old kubernetes files if any.
rm -f $HOME/kubernetes-server-linux-amd64.tar.gz
rm -rf $HOME/kubernetes-server && mkdir -p $HOME/kubernetes-server

# Download and install the Kubernetes server binaries.
curl -L https://dl.k8s.io/${K8S_VER}/kubernetes-server-linux-amd64.tar.gz  -o $HOME/kubernetes-server-linux-amd64.tar.gz
tar -xzvf $HOME/kubernetes-server-linux-amd64.tar.gz -C $HOME/kubernetes-server
rm -f $HOME/kubernetes-server-linux-amd64.tar.gz

# Verify the kubectl installation.
echo ------verfiying the kubectl installation-----
$HOME/kubernetes-server/kubernetes/server/bin/kubectl version