# kubernetes hard way installation
Kubernetes installation on MAC  

Step1: Install Virtual Box  
VitualBox Installation: https://www.virtualbox.org/  

Step2: Install ubuntu on Virtual Box  
Ubuntu Installation: https://releases.ubuntu.com/xenial/   
	• RAM: 2GB  
	• Disk: 10G  

Step3: Install openssh-server and docker  
sh install_docker.sh

Step4: Install/Configure Master as a Root CA server for certifications creation and validation.  
sh install_ca_server.sh  

Step5: Add the bellow env   
SERVER_IP=<MASTER-HOST-IP>  
SERVER_IP=$(ip addr show | grep -v '127.0\|172.17' | grep -oP '(?<=inet\s)\d+(\.\d+){3}')  

Step6: Download and install ETCD binaries  
sh install_etcd.sh  

Step6: Download and install Kubernetes binaries  
sh install_k8s_server.sh

Step7: Installing kube-apiserver  
sh install_kube-apiserver.sh

Step8: Installing kube-controller-manger  
sh install_kube-controller-manager.sh

Step9: Installing kube-scheduler  
sh install_kube-scheduler.sh

Step10: Add Kube-admin kubeconfig  
sh install kube-admin.sh


