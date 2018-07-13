#! /bin/sh   
#######################################################
# $Name: init_master.sh 　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　 
# $Version: v1.0 　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　
# $Function: init node
# $Author: xiaojun.wu@ebaotech.com
# $Create Date: 2018-07-13
# $Description: install kubernetes1.9.3 in Node
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

#
sed -i "s/cgroup-driver=systemd/cgroup-driver=cgroupfs/g" /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
systemctl daemon-reload && systemctl restart kubelet
#初始化
rm -rf /etc/kubernetes/*
#安装软件
yum install -y kubelet-1.9.3 kubeadm-1.9.3 kubectl-1.9.3
## yum remove -y kubelet kubeadm kubectl

