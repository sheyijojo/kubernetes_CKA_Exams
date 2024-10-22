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
- Leader election process sma e for scheduler and controller manager 
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
- 
