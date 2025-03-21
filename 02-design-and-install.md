## What is the purpose of a cluster 
- This determines the amount of resources needed to host the cluster
- kubeadm is suitable for this kind/minikube provisioned on cloud providers or local VM

  
## Hosting production level 
- High availabltiy multi node cluster with muipltiple master nodes is recommeded
- kubeadm or GCP or Kops on AWS or other supported platforms 
- Up to 5000 nodes in the cluster 
- Up to 150,000 PODs in the cluster
- 300,00 containers
- up too 100 pods PER Node
- 251-500 (16 vCPU 30GB, C4.4xlarge)

## On Prem
- Use Kubeadm for on-prem
- GKE for GCP
- Kops for AWS
- Azure Kubernetes Service for Azure 

## Nodes
- Virtual or Physical Machines
- Mininum of 4 Node Cluster(Size based on workload)
- Master vs Worker Nodes
- Lunux X86_64 Architecture


## ETCD
- It is advisable to seperate the ETCD cluster from the master nodes to its own cluster nodes 

## Chooding akubernetes clusters
- On windows there no binaries to install k8, must rely on Vmware or Hyper-V workstation or VirtualBox to create linux VMs to run kubernetes

## Solutions for minimal deployment on local computer: single node cluster 
- minikube
- kubeadm(single/multiple nodes)" requires VMS to be ready

- **production**
- Turnkey solutions or hosted or managed solutions 
   - turnkey solutions:
       - You provision VMSS
       - CONFIGURE vms
       - uSE SCRIPTS TO DEPLOY CLUSTER
       - Maintain VMs yourself
       - E.g Kuubernetes on AWS using KOPS
  - managed/Hosted  solutions
       - kubernetes-As-A-Service
       - Porvider provisions VMs
       - Provider installs kubernetes
       - provider maintains VMS
       - E.g Google Container Enginer, AWS EKS
   
- **TURNKEY SOLUTIONS** - More like on-premises solutions
    - Openshift - On prem kubernetes platfrom
    - cloud foundry container runtime using tool called BOSH
    - vmWARE CLOUD pks
    - vAGRANT HELPS with useful scripts to deploy kubernetes cluster on diff cloud service

- **Hosted Solutions**
   - GKE
   - Openshift Online
   - Azure Kubernetes Service
   - AWS EKS 
    
## for the practice use Virtual Box 
- One master, two workers using virtual box


## High Availablity in cluster 
- Consideer mnltiple master nodes in PROD
- Consider that for the controleplane componets as well.
- In HA the components must run in active-stanby mode and not in parallel
- Leader election process same for scheduler and controller manager 
- e.g `kuber-controller-manager --leader-elect true ` - This is set by default.

```yaml
kube-controller-manager --leader-elect tue
                        --leader-elect-lease-duration 15s
                         --leader-elect-renew-deadline 10s 
```

## What are the controlplane components 
- API Server
- ETCD
- Controller Manager
- Scheduler

## Stacked Topology 
- when etcd is part of the master nodes

## External ETCD topology
- Seperate
- The API server is the only component that talks to the ETCD
- Make sure in the API server, in  `/etc/sysemd/system/kube-apiserver.service` is pointing to the righ etcd address
- `--etcd-servers=https://10.240.0.10:2379,https://10.240.0.11:2379`
- ETCD is a distribyted systems

## ETCD in HA 
RAFT Protocol for distributed concensus

Advised to have an odd number 
- Only one of the instances nodes is responsible for processing the WRITE
- You can read from any of the instance
- One node becomes the leader
- Majority(Quorum) = N/2 + 1
- Quorum is the min number of nodes for the cluster to func properly or make a successful write
- Quorom of 3 is 2
- Quorum of 5 is 3
- Recommended  having a min of 3 nodes in a ETCD cluster


## To install ETCD on a cluster

```yaml
wget -q --https-only \ "https://github.com/coreos/etcd/releases/download/v3.3.9/etcd-v3.3.9-linux-amd64.tar.gz

tar -xvf etcd-v3.3.9-linux-amd64.tar.gz

mv etcd-v3.3.9-linux-amd64/etcd* /usr/local/bin

mkdir -p /etc/etcd /var/lib/etcd

cp ca.pem kubernetes-key.pem kubernetes.pem /etc/etcd/

configure the etcd.service

## note this - where ETCD SERVICE KNOWS THAT IS part of a cluster and where its peer are.
--initial-clusteer peer1=https://${PEER1_IP}:2380,peer-2=https://${PEER2_IP}:2380 \\

## use etcdctl utitliy for interaction

export ETCDCTL_API=3
etcdctl put name john

etcdctl get name

etcdctl get / --prefix --keys-only 
```

## Installing Kubernetes the hard way

`https://www.youtube.com/watch?v=uUupRagM7m0&list=PL2We04F3Y_41jYdadX55fdJplDvgNGENo`


The GIT Repo for this tutorial can be found here:` https://github.com/mmumshad/kubernetes-the-hard-way`

- Follow the instructions to install
- Virtual box
- Vagrant

## Installing using kubeadm - the less hard way 
https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/

https://github.com/kodekloudhub/certified-kubernetes-administrator-course

## Introduction to Deployment with kubeadm 

```md
## kubeadm takes care of many task s
- couple of nodes physical or virtual machines
- one for master and the rest for worker  nodes
- install container runtime containerd on all the nodes
- install kudeadm tool on all the nodes for boostraping the k8 solution in  the right order
- initialize the master server
- Ensure network preresuite are met like the pod network
- Then worker nodes join the master nodes 

```

## Using Kubedam tools

```yaml
## vagrant file
https://github.com/kodekloudhub/certified-kubernetes-administrator-course/blob/master/kubeadm-clusters/virtualbox/Vagrantfile

## installing kubeadm documentation

https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/

- vagrant status
- vagrant up

- vagrant ssh kubemaster

- logout 

uptime

## read more on Cgroup drivers
- cGROUP DRIVERS ARE good for resource management

- kubelet and container runtime need to interact with a cgroup

- you need a cgroup driver for a container-d runtime

## check which init - like systemd
ps -p 1

## configuring the systemd to cgroup driver
for all nodes

## on master
sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=192.168.56.2 


## admin.conf file
sudo chown &(id -u)"(id -g) $Home/.kube/config

##check the networking addons
install weave netw  on master node

## make sure you set the IPALLOC on weavenet pod deamonset

## join the worker nodes
- the token to join is found when you run kubeadm init
## go back to master nodes

kubectl get nodes


## verify everything is working

kubectl run nginx --image=nginx 
```

##
```yaml

cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

sudo sysctl --system

## The container runtime has already been installed on both nodes, so you may skip this step.
## Install kubeadm, kubectl and kubelet on all nodes:

sudo apt-get update

sudo apt-get install -y apt-transport-https ca-certificates curl

curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update

# To see the new version labels
sudo apt-cache madison kubeadm

sudo apt-get install -y kubelet=1.31.0-1.1 kubeadm=1.31.0-1.1 kubectl=1.31.0-1.1

sudo apt-mark hold kubelet kubeadm kubectl


## Questions

- Initialize Control Plane Node (Master Node). Use the following options:
- apiserver-advertise-address - Use the IP address allocated to eth0 on the controlplane node
- apiserver-cert-extra-sans - Set it to controlplane
- pod-network-cidr - Set to 10.244.0.0/16
Once done, set up the default kubeconfig file and wait for node to be part of the cluster

## working on it

## Ques: - apiserver-advertise-address - Use the IP address allocated to eth0 on the controlplane node
kubeadm init --apiserver-advertise-address 192.123.323.23
//ip addr of eth0 - the first ip
## Ques: - apiserver-cert-extra-sans - Set it to controlplane
ans:
kubeadm init --apiserver-cert-extra-sans=controlplane --apiserver-advertise-address 192.133.43.3 --pod-network-cidr=10.244.0.0/16


## To install a network plugin, we will go with Flannel as the default choice. For inter-host communication, we will utilize the eth0 interface.


Please ensure that the Flannel manifest includes the appropriate options for this configuration.


Refer to the official documentation for the procedure.

curl -LO https://raw.githubusercontent.com/flannel-io/flannel/v0.20.2/Documentation/kube-flannel.yml

Open the kube-flannel.yml file using a text editor.

Locate the args section within the kube-flannel container definition. It should look like this:
  args:
  - --ip-masq
  - --kube-subnet-mgr

Add the additional argument - --iface=eth0 to the existing list of arguments.

Now apply the modified manifest kube-flannel.yml file using kubectl:
kubectl apply -f kube-flannel.yml
```
