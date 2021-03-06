# This will install docker and other pre-request before starting kubernetes installation

sudo apt-get install git
sudo apt-get install vim
sudo apt-get update
sudo apt-get install openssh-server

sudo apt-get update
sudo apt-get install apt-transport-https \
ca-certificates curl gnupg-agent software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

sudo apt-key fingerprint 0EBFCD88

add-apt-repository "deb [arch=amd64] \
https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io



