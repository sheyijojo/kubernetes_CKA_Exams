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
     
