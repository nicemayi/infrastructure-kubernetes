#!/bin/bash
# default mode is worker
MODE="worker"
if [ $1 = "master" ]; then
    MODE=$1
fi

sudo echo "Step - 1: Installing docker..."

sudo apt-get remove docker docker-engine docker.io containerd runc
sudo apt-get update
sudo apt-get install -y \
   apt-transport-https \
   ca-certificates \
   curl \
   gnupg \
   lsb-release

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo \
 "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
 $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install -y docker-ce=5:20.10.8~3-0~ubuntu-hirsute docker-ce-cli=5:20.10.8~3-0~ubuntu-hirsute containerd.io

# add this config if using private docker registry
# "insecure-registries": ["192.168.10.62:6004"],
sudo cat > /etc/docker/daemon.json <<EOF
{
    "insecure-registries": ["192.168.10.62:6004"],
    "exec-opts": ["native.cgroupdriver=systemd"],
    "log-driver": "json-file",
    "log-opts": {
        "max-size": "100m"
    },
    "storage-driver": "overlay2"
}
EOF
sudo systemctl daemon-reload
sudo systemctl restart docker
echo "Step - 1: Docker installation & configuration done!"

echo "Step - 2: Installing Kubernetes components..."
sudo apt-get update
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF

sudo apt-get update
sudo swapoff -a

sudo apt-get install -qy kubelet=1.22.3-00 kubeadm=1.22.3-00 kubectl=1.22.3-00


if [ $MODE = "master" ]; then
    rm -f ~/.kube
    mkdir -p $HOME/.kube
    sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    sudo chown $(id -u):$(id -g) $HOME/.kube/config

    echo "Installing Calico CNI..."
    kubectl apply -f ./calico/1_tigera-operator.yaml
    kubectl apply -f ./calico/2_custom-resources.yaml

    echo "Installing MetalLB..."
    kubectl apply -f ./metallb/1_namespace.yaml
    kubectl apply -f ./metallb/2_metallb.yaml
    kubectl apply -f ./metallb/3_cluster.yaml
fi

echo "Step - 2: Kubernetes installation Done!"

echo "Now you can spin up new k8s cluster with the following commands:

    sudo kubeadm init --apiserver-advertise-address=<REPLACE_WITH_THIS_HOST_IP> --pod-network-cidr=192.168.0.0/16"

echo "Or if you are at worker node, join the cluster with the output from above."