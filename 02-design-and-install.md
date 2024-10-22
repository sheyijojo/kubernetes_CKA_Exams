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
