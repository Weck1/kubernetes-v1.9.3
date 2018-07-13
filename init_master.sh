#! /bin/sh   
#######################################################
# $Name: init_master.sh 　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　 
# $Version: v1.0 　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　
# $Function: init master
# $Author: xiaojun.wu@ebaotech.com
# $Create Date: 2018-07-13
# $Description: install kubernetes1.9.3 in Master
#######################################################


#设置kubernetes源

cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-\$basearch
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

#安装软件
yum install -y kubelet-1.9.3 kubeadm-1.9.3 kubectl-1.9.3

#设置iptables参数
cat <<EOF >  /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

#取消enforce
setenforce 0

#设置kubernetes cgroup driver和docker一致

sed -i "s/cgroup-driver=systemd/cgroup-driver=cgroupfs/g" /etc/systemd/system/kubelet.service.d/10-kubeadm.conf

#设置fail-swap-on=false

echo "Environment=\"KUBELET_EXTRA_ARGS=--fail-swap-on=false\"" >>/etc/systemd/system/kubelet.service.d/10-kubeadm.conf

#重启kubelet

systemctl daemon-reload && systemctl restart kubelet

#初始化cluster
rm -rf /etc/kubernetes/*
rm -rf /var/lib/etcd/*
kubeadm init --kubernetes-version=v1.9.3 --pod-network-cidr=10.244.0.0/16 --ignore-preflight-errors=swap

#设置配置文件
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config


#设置KUBECONFIG到环境变量
echo "export KUBECONFIG=/etc/kubernetes/admin.conf" >>~/.bash_profile
source ~/.bash_profile



#创建flannel网络
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/v0.9.1/Documentation/kube-flannel.yml
