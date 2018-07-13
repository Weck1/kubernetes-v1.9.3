# kubernetes-v1.9.3


[![Submit Queue Widget]][Submit Queue] [![GoDoc Widget]][GoDoc] [![CII Best Practices](https://bestpractices.coreinfrastructure.org/projects/569/badge)](https://bestpractices.coreinfrastructure.org/projects/569)
<img src="https://github.com/kubernetes/kubernetes/raw/master/logo/logo.png" width="100">

---





## 1. Environment Information

| server name | IP            | docker version | kubernets version |
| ----------- | ------------- | -------------- | ----------------- |
| master1     | 192.168.9.128 | 17.03.2-ce     | 1.9.3             |
| node1       | 192.168.9.131 | 17.03.2-ce     | 1.9.3             |
| node1       | 192.168.9.132 | 17.03.2-ce     | 1.9.3             |



# 2. Docker Installation

- ### Install docker-17.03.2 on master1 ,node1 and node2

*If you need to use http proxy to access the outside ,please change http IP proxy address.*

```
export http_proxy=http://192.168.9.128:3128
export no_proxy="localhost,127.0.0.0/8,10.96.0.0/12,10.244.0.0/16,192.168.9.0/24"
export https_proxy=http://192.168.9.128:3128
sed -i 's/obsoletes=1/obsoletes=0/g' /etc/yum.conf
```



**docker-ce  repository configuration and  docker installation**

```
cd /etc/yum.repos.d && wget https://download.docker.com/linux/centos/docker-ce.repo
yum makecache fast
yum remove docker-ce container-selinux -y
rm -rf /var/lib/docker
yum install docker-ce-17.03.2.ce-1.el7.centos -y

cat <<EOF > /etc/docker/daemon.json
{
        "registry-mirrors": ["http://8e337a58.m.daocloud.io"],
        "bip": "172.17.1.1/24",
        "insecure-registries": ["docker-all.repo.ebaotech.com"]
}
EOF

```

**Add http proxy for docker**

```
cat <<EOF > /etc/systemd/system/docker.service.d/http-proxy.conf
[Service]
Environment="HTTP_PROXY=http://192.168.9.128:3128/"
Environment="HTTPS_PROXY=http://192.168.9.128:3128/"
Environment="NO_PROXY=localhost,127.0.0.0/8,192.168.9.0/24"
EOF


systemctl daemon-reload && systemctl enable docker && systemctl start docker
```



##  3.  Kubernetes  Installtion

- ### Install kubelet-1.9.3 , kubeadm-1.9.3 and kubectl-1.9.3  on master1 ,node1 and node2

  

kubernetes  yum repository Configuration and installation

- [ ] Google repository 

```
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-\$basearch
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg

```

- [ ] Aliyun repository

```
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-\$basearch
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF
```

- change parameter

```
setenforce 0
cat <<EOF >  /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config 
```

- keep the kubernetes's cgroup driver the same as docker's cgroup driver

```bash
sed -i "s/cgroup-driver=systemd/cgroup-driver=cgroupfs/g" /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
```



- disable swap

```
swapoff -a
#And you can disable swap in /etc/fstab 
```



- Restart kubelet

systemctl daemon-reload && systemctl restart kubelet 



## 4. Use kubeadm to initilize Kubernetes master

- "**kubeadm init**"command initializes a Kubernetes master node 

```
kubeadm init --kubernetes-version=v1.9.3 --pod-network-cidr=10.244.0.0/16 
```

After execution finished ,you will get "**kubeadm join command** ",please note,we will execute it on node.

- Example **kubeadm join** command :

```
kubeadm join --discovery-token abcdef.1234567890abcdef --discovery-token-ca-cert-hash sha256:1234..cdef 192.168.9.128:6443
```



-  Kube configuration

```
mkdir -p $HOME/.kube
/bin/cp -f /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

```



-  Create flannel network 

```
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/v0.9.1/Documentation/kube-flannel.yml

```



---

*You can use **init_master.sh** script to install kuberenetes  software on master and initilize master and use **init_node.sh** to install software on node1 and node2.*



## 5. Join node1 and node2 into Cluster

- Execute  **kubeadm join** command in nodes:

```
kubeadm join --discovery-token abcdef.1234567890abcdef --discovery-token-ca-cert-hash sha256:1234..cdef 192.168.9.128:6443

```
## 6. All node status

All status are Ready ,That's OK.

```bash
[root@master1 example]# kubectl get node
NAME      STATUS    ROLES     AGE       VERSION
master1   Ready     master    2h        v1.9.3
node1     Ready     <none>    1h        v1.9.3
node2     Ready     <none>    1h        v1.9.3

```





----

## 7. Install  Træfik 

Træfik listens to service registry/orchestrator API and instantly  generates the routes so your microservices are connected to the outside  world 

![Architecture](https://docs.traefik.io/img/architecture.png) 

```
kubectl apply -f traefik/
```



Træfik Dashboard

![1531476544482](./image/1531476544482.png)



## #8. Kubernetes Dashboard 

- Create Dashboard

```
kubectl appy -f monitor/dashboard/
```

- Access Dashboard

  https://192.168.9.131:31111

![](./image/741ED7F8-976A-464a-8ECB-4BEE1F4EFEA7.png)

- Get token

```kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep admin-user | awk '{print $1}')
#kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep admin-user | awk '{print $1}')

Name:         admin-user-token-l89x7
Namespace:    kube-system
Labels:       <none>
Annotations:  kubernetes.io/service-account.name=admin-user
              kubernetes.io/service-account.uid=4dfb84e5-8672-11e8-8d8a-0050562042cf

Type:  kubernetes.io/service-account-token

Data
====
ca.crt:     1025 bytes
namespace:  11 bytes
token:      eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJrdWJlLXN5c3RlbSIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VjcmV0Lm5hbWUiOiJhZG1pbi11c2VyLXRva2VuLWw4OXg3Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZXJ2aWNlLWFjY291bnQubmFtZSI6ImFkbWluLXVzZXIiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC51aWQiOiI0ZGZiODRlNS04NjcyLTExZTgtOGQ4YS0wMDUwNTYyMDQyY2YiLCJzdWIiOiJzeXN0ZW06c2VydmljZWFjY291bnQ6a3ViZS1zeXN0ZW06YWRtaW4tdXNlciJ9.wwJ_x92OFsnU-CSwgF8NGVprA7LebMbvyucTGQE2yjkXqY2nd7fm3hLoaqO999seBYAtCF21pamy-hBpqlxGuewoNFcOc8WY2XJbClPKgSN0AOuQeZw9sHy6Q3vk7yRbC2wiuxI0h267IQO4wA7pDdPi-OvivaZr6qIlhCYqOzwrHG-oxrv-s18znzOzMjjEQHwmOT0Cfu8LjgK7sodDnVet-qQof5FPX6Fvm7bhf1dh8E-GGqo2HEUHGzLUSdi61-BL3NVCrBX0cRwi0XRuSOnUOjcODP-U7Q1vpyPuOBsaZ72gskZziJlAh1Bgp3_cWTbw_JFb_ohDcG7BA6kzwQ
```

- Login into dashboard

  ![](./image/70EDF94E-66AB-4f18-B871-D069FF9C66F2.png)



# #9.Monitor cluster with heapster,influxdb and grafana

- Create monitor service

```
kubectl apply -f monitor/heapster/
```

-    Add monitor-dev.ebaotech.com into DNS or C:\Windows\System32\drivers\etc\hosts

```
192.168.9.131  monitor-dev.ebaotech.com
```

-    Access grafana dashboard

![](./image/3B87DDDE-D1AB-44cd-AA01-1D0D5D651BB1.png)



## 10.Website example

-  Execute example/ghost.sh

```
cd example
sh ghost.sh
```

-    Add ghost-dev.ebaotech.com into DNS or C:\Windows\System32\drivers\etc\hosts

```
192.168.9.131  ghost-dev.ebaotech.com
```

-  Access website

  ![](./image/0988DDDE-D0A1-41ba-99E1-C605B90FEAA6.png)

- FRONTEnd and BACKENDS

  ![](./image/F33D1DFB-D352-4b8c-A45F-75D5708204C3.png)