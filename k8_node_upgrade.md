## Upgrade

To seamlessly transition from Kubernetes v1.29 to v1.30 and gain access to the packages specific to the desired Kubernetes minor version, 

follow these essential steps during the upgrade process. This ensures that your environment is appropriately configured and aligned with the features and improvements introduced in Kubernetes v1.30.

## On the controlplane node:

Use any text editor you prefer to open the file that defines the Kubernetes apt repository.

`vim /etc/apt/sources.list.d/kubernetes.list`
Update the version in the URL to the next available minor release, i.e v1.30.

deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /


After making changes, save the file and exit from your text editor. Proceed with the next instruction.

`apt update`

`apt-cache madison kubeadm`
Based on the version information displayed by apt-cache madison, it indicates that for Kubernetes version 1.30.0, the available package version is 1.30.0-1.1. Therefore, to install kubeadm for Kubernetes v1.30.0, use the following command:

`apt-get install kubeadm=1.30.0-1.1`
Run the following command to upgrade the Kubernetes cluster.

`kubeadm upgrade plan v1.30.0`

`kubeadm upgrade apply v1.30.0`

Note that the above steps can take a few minutes to complete.

Now, upgrade the version and restart Kubelet. Also, mark the node (in this case, the "controlplane" node) as schedulable.

`apt-get install kubelet=1.30.0-1.1`

`systemctl daemon-reload`

`systemctl restart kubelet`
