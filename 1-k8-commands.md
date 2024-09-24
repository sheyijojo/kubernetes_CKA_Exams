## Here’s a tip!

- As you might have seen already, creating and editing YAML files is a bit difficult, especially in the CLI. 
- During the exam, you might find it difficult to copy and paste YAML files from the browser to the terminal.

- Using the kubectl run command can help in generating a YAML template. And sometimes, you can even get away with just the kubectl run command without having to create a YAML file at all. 

- For example, if you were asked to create a pod or deployment with a specific name and image, you can simply run the kubectl run command.

- Use the below set of commands and try the previous practice tests again, but this time, try to use the below commands instead of YAML files. Try to use these as much as you can going forward in all exercises.

- Reference (Bookmark this page for the exam. It will be very handy):



`https://kubernetes.io/docs/reference/kubectl/conventions/`

## Create an NGINX Pod

`kubectl run nginx --image=nginx`

Generate POD Manifest YAML file (-o yaml). Don’t create it(–dry-run)

`kubectl run nginx --image=nginx --dry-run=client -o yaml`


## Create a deployment

`kubectl create deployment --image=nginx nginx`


## Generate Deployment YAML file (-o yaml). Don’t create it(–dry-run)

`kubectl create deployment --image=nginx nginx --dry-run=client -o yaml`


## Generate Deployment YAML file (-o yaml). Don’t create it(–dry-run) and save it to a file.

`kubectl create deployment --image=nginx nginx --dry-run=client -o yaml > nginx-deployment.yaml`


## Make necessary changes to the file (for example, adding more replicas) and then create the deployment.

`kubectl create -f nginx-deployment.yaml`


`kubectl create deployment httpd-frontend --image=httpd:2.4-alpine --replicas=3`

**OR**
```yaml

In k8s version 1.19+, we can specify the –replicas option to create a deployment with 4 replicas.

kubectl create deployment --image=nginx nginx --replicas=4 --dry-run=client -o yaml > nginx-deployment.yaml
```
## Create a service 

```
kubectl create service nodeport <service-name> --tcp=<port>:<target-port> -o yaml > service-definition-1.yaml


kubectl create service nodeport my-service --tcp=80:80 -o yaml > service-definition-1.yaml

kubectl create service nodeport webapp-service --tcp=30080:8080 -o yaml > service-definition-1.yaml


```
## notice there is no labels in this configuration. Labels is what is used to associate a specific template.

### sample with declarative mode

```yaml
---
apiVersion: v1
kind: Service
metadata:
  name: webapp-service
  namespace: default
spec:
  ports:
  - nodePort: 30080
    port: 8080
    targetPort: 8080
  selector:
    name: simple-webapp
  type: NodePort

```

```yaml
apiVersion: v1
kind: Service
metadata:
  name: webapp-service
  creationTimestamp: "2024-08-27T16:19:59Z"

  namespace: default
  resourceVersion: "1329"
  uid: 048927bc-7419-4225-9be6-0e9fc71a93b3
spec:
  clusterIP: 10.43.130.130
  clusterIPs:
  - 10.43.130.130
  externalTrafficPolicy: Cluster
  internalTrafficPolicy: Cluster
  ipFamilies:
  - IPv4
  ipFamilyPolicy: SingleStack
  ports:
  - name: 8080-8080
    nodePort: 30080
    port: 8080
    protocol: TCP
    targetPort: 8080
  selector:
    name: simple-webapp
  sessionAffinity: None
  type: NodePort
status:
  loadBalancer: {}

```

## Namespaces

```yaml
kubectl run redis --image=redis --namespace=finance

kubectl get pods --namespace=research

kubectl get pods -n=researchnamespace

kubectl get pods --all-namespaces

kubectl get pods -A

kubectl run redis --image=redis:alpine --labels=tier=db

kubectl create service clusterip redis-service --tcp=6379:6379



kubectl create service clusterip redis-service --tcp=6379



kubectl run custom-nginx --image=nginx --port=8080


kubectl create ns dev-ns
```

```yaml
## Create a new deployment called redis-deploy in the dev-ns namespace with the redis image. It should have 2 replicas.


Use imperative commands.

`kubectl create deployment redis-deploy --image=redis --replicas=2 --namespace=dev-ns

kubectl expose pod httpd --port 80
```

## nodeport for manual scheduling 
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  containers:
  - image: nginx
    name: nginx
  nodeName: node01  # Replace with the name of the node you want to schedule the pod on

```

## check if the scheduler is runnig in namesystem
`kubectl get pods -n kube-system`

## Instead of deleting a pod, you can replace 
`kubectl replace --force -f nginx.yaml`

`kubectl get pods --watch`

## get a pod name with the selector to get the label

`kubectl get pods --selector app=App1`
`kubectl get pods --selector app=App1  --no-headers | wc -l`
`kubectl get pods --selector env=dev`

## get all objects in an env
`kubectl get all --selector env=prod`


## get all pods in different env 
`kubectl get pods -l 'env in (prod,finance,frontend)`

## Identify the POD which is part of the prod environment, the finance BU and of frontend tier?
`kubectl get pods -l env=prod,bu=finance,tier=frontend`

OR

`kubectl get all --selector env=prod,bu=finance,tier=frontend`

## Taints and Tolerance
Tains are ste on Nodes, tolerance are set on pods. 
- `kubectl taint nodes node-name key=value:taint-effect`

- `kubectl taint nodes node1 app=blue:NoSchedule`
`NoSchedule | PreferNoSchedule | NoExecute`

## check the taint deployed automatically on master node 

`kubectl describe node kubemaster | grep Taint`

## Remove taint from a node
`kubectl taint nodes controlplane example-key:NoSchedule-`

`kubectl taint nodes controlplane node-role.kubernetes.io/control-plane:NoSchedule-`

## Create a pod in yaml but do not run
`kubectl run nginx --image=nginx --dry-run=client -o yaml > bee.yaml`

## get more inforation like nodes from this command 
`kubectl get pods -o wide`

## Label a Node for NodeSelector section
`kubectl label nodes <node-name> <label-key>=<label-value>`

`kubectl label nodes node-1 size=Large`


`kubectl label nodes node01 color=blue`

## specify node selector in the pod-sefintion file
```yaml

spec:
  nodeSelector:
    size: Large
```yaml
## Node Affinity and Antiffinity is better and address complex needs, spec affinit should be under pods not Deployment
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key:  size ##disktype
            operator: In  ##NotIn ##exist
            values:
            -  Large   ##ssd
            -  Medium          
  containers:
  - name: nginx
    image: nginx
    imagePullPolicy: IfNotPresent
```

## sample task 
`kubectl create deployment red --replicas=2 --image=nginx -o yaml > sample.yaml`

## Dry run
```yaml
kubectl create deployment red --replicas=2 --image=nginx --dry-run=client -o yaml > sample.yaml

```

## Create Deployment with Affinity to a Label on controlnode
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  creationTimestamp: null
  labels:
    app: red
  name: red
spec:
  replicas: 2
  selector:
    matchLabels:
      app: red
  strategy: {}
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: red
    spec:
      affinity:
        nodeAffinity:
         requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
             - matchExpressions:
               - key: node-role.kubernetes.io/control-plane
                 operator: In
                 values:
                    - ""

      containers:
      - image: nginx
        name: nginx
        resources: {}
status: {}
```

## Resource and Request 
- specified in the spec container
```yaml
spec.containers[].resources.limits.cpu
spec.containers[].resources.limits.memory
spec.containers[].resources.limits.hugepages-<size>
spec.containers[].resources.requests.cpu
spec.containers[].resources.requests.memory
spec.containers[].resources.requests.hugepages-<size>
```
## Resource example
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: frontend
spec:
  containers:
  - name: app
    image: images.my-company.example/app:v4
    resources:
      requests:
        memory: "64Mi"
        cpu: "250m"
      limits:
        memory: "128Mi"
        cpu: "500m"
  - name: log-aggregator
    image: images.my-company.example/log-aggregator:v6
    resources:
      requests:
        memory: "64Mi"
        cpu: "250m"
      limits:
        memory: "128Mi"
        cpu: "500m"

```

## Daemonsets
`kubectl get daemonsets`

## get in all namespace
`kubectl get daemonsets -A`

## Namespace continued
`kubectl describe daemonsets kube-proxy -n kube-system`

## Daemonsets shortcut
`kubectl describe ds kube-flannel-ds -n kube-system`

## copy from the documentation or use deployment dry run and change it 
`kubectl create deployment elasticsearch -n kube-system --image=aaas --dry-run=client -o yaml`

```yaml
## No replicas
## change the image name
##
kubectl create -f fluendt.yaml

kubectly get ds -n kube-system
```

## get static pods
- static pods usually have node name appended to their name, clue to know them
- check for the owner reference session, check the kind and name. The kind should be like a Node. otherwise could be Relicaset, or any other object 

## another way of getting pod yaml from a running pod
`kubectl get pod name-of-pod -n kube-system -o yaml`
`kubectl get nodes`


## find config files in linux 
`find /etc -type f -name "*.conf"`
```yaml
## How many static pods exist in this cluster in all namespaces 
kubectl get pods -A

## path to directory for the static pod
check the kubelt conf
cat /var/lib/kubelet/config.yaml   ##for any given static pod config
## check for static pod path

```

## create a static pod name static-busybox that uses the busy-box image and the command sleep 1000

```yaml
kubectl run static-busybox --image=busybox --dry-run=client -o yaml --command -- sleep 1000 > static-busybox.yaml 
cp static-busybox.yaml  /etc/kubernetes/manifests/
```

## watch while your pods get deployed 
`kubectl get pods --watch`

## to get nodes in manifest file in another nodes
```yaml
## ssh into the nodes
kubectl get nodes -o wide

ssh internalipaddr

ls /etc/kubernetes/manifests/

## check the kuubelet config
cat /var/lib/kubelet
```

## Debug schedulers

```yaml
`kubectl get events -o wide`

## schedulers logs
  - kubectl logs my-custom-scheduler --name-space=kube-system

## find an image witing  a pod
kubectl describe pod pod-name -n kube-system | grep Image

```
## configmap sample
```yaml
apiVersion: v1
data:
  my-scheduler-config.yaml: |
    apiVersion: kubescheduler.config.k8s.io/v1
    kind: KubeSchedulerConfiguration
    profiles:
      - schedulerName: my-scheduler
    leaderElection:
      leaderElect: false
kind: ConfigMap
metadata:
  creationTimestamp: null
  name: my-scheduler-config
  namespace: kube-system

```
## custom scheduler.
```
apiVersion: v1
kind: Pod 
metadata:
  name: nginx
spec:
  containers:
  - image: nginx
    name: nginx
  schedulerName: 
     my-scheduler

```
## kubectl logs
`kubectl logs podname`

## See status of deployment 
`kubectl rollout status deployment/myapp-deployment`

## see history of deployment 

`kubectl rollout history deployment/myapp-deployment`

## Undo a deployment rollout 
`kubectl rollout undo deployment/myapp-deployment`

## create deployments

`kubectl create -f deployment-definiition.yaml`
## Get Depployment
`kubectl get deployments`

## update - be careful, it creates a new config
`kubectl apply -f deployment-definition.yaml`

## deployment status - Deployment files will have diff configs
`kubectl set image deployment/myapp-deployment nginx=nginx:1.9.1`

## Edit 
`kubectl edit deployment frontend`

or

`k set image deployment frontend simple-webapp=kodkloud/webapp-clor:v2`


`kubectl get deployments frontend  --watch`
`k get deploy`

`k describe deploy frontend`



## Application Lifecycle 

```yaml
## docker
CMD

## SPECIFY DIFFERENT cmd to satrt a docker

docker run ubuntu [COMMAND]
docker run ubuntu sleep 5

## Make the change permanent
FROM ubuntu

CMD sleep 5

docker build -t ubuntu-sleepr .

docker run ubuntu-sleeper

## change optionall 5 secs

docker run ubuntu-sleeper 10

## ADD ENTRYPOINT IN THE DOCKERFILE, to append additional CLI inout
FROM Ubuntu

ENTRYPOINT["sleep"]

docker run ubuntu-sleeper 10

## Add default value like 5 even if you forget on command line

FROM Ubuuntu

ENTRYPOINT ["sleep"]

CMD["5"]

docker run ubuntu-sleeper 10

## In Kubernetes Pod
Anything appended to the command goes to the args property in K8


## for example

docker run --name ubuntu-sleeper ubuntu-sleeper 10

entrypoiit for dockerfile is sleep
CMD in Dockerfile == ARGS in Kubernetes

to overwrite ENTRPOINT will be command in Kubernetes

apiVersion: v1
kind: Pod
metadata:
  name: ubuntu-sleeper-pod
spec:
   containers:
     - name: ubuntu-sleeper
       image: ubuntu-sleeper
       command: ["sleep2.0"]
       args: ["10"] 

```

## Another options for command 

```yaml
apiVersion: v1 
kind: Pod 
metadata:
  name: ubuntu-sleeper-3 
spec:
  containers:
  - name: ubuntu
    image: ubuntu
    command:
      -  "sleep"
      -  "1200"
```

## Approach for editing 
```yaml
`kuubectl edit pod name-of-the-pod`

`kubectl replace --force -f /tmp/kuubectl-edit-2623.yaml`  

`kubectl run nginx --image=nginx -- <arg1> <arg2> ... <argN> `
```
## Config Map

```yaml
kubectl create configmap  <config-name> --from-literal=<key>=<value> 


kubectl create configmap  app-config --from-literal=APP_COLOR=blue \
                                      --from-literal=APP_MOD=prod


kubectl create configmap <config-name> --from-file=<path-to-file>

kubectl get configmaps
```

## Secrets

```yaml

kubectl create secret generic db-secret --from-literal=DB_Host=sql01  --from-literal=DB_User=root  --from-literal=DB_password=passw
ord123

kubectl create secret generic

kubectl create secret generic \ 
app-secret --from-literal=DB_HOST=mysql \
           --from-literal=DB_HOST=root  \
           --from-literal=DB_password=passwrd

kubectl create secret generic <secret-name> --from-file=<path-to-file>

kubectl create secret generic \ app-secret --from-file=app_secret.properties  


**declarivative**

- kubectl create -f secret-data.yaml

- The data must be in encoded form in secrets. Screts are encoded but not encrypyted

- Do not check in secret objects to SCM along the code 

encrypt ETCD data at rest

**on linux**

- echo -n 'mysql' | base64

- kubectl get secreats

- kubectl describe secrets

- kubectl get secret app-secret -o yaml


https://www.youtube.com/watch?v=MTnQW9MxnRI

```
**decode secrets**
  
`echo -n "bXlzcWw' | base64 --decode`
## logs 
`kubectl -n elastic-stack  logs kibana`

## exec into a pod container 
`kubectl -n elastic-stack exec -it app -- cat /log/app.log`

```yaml
spec:
  containers:
   - name : simpleapp
     image: simpleapp
     ports:
       - containerPort: 8080
     envFrom:
       - secretRef:
            name: app-secret


## single env
env:
 - name: DB_Password
   vakueFrom:
     secretkeyRef:
       name: app-secret
       key: DB_Password

## volumes
volumes:
- name: app-secret-volume
  secret:
    secretName: app-secret

```

## Creating a Multi Container Pod
```yaml
kubectl run yellow --image=busybox --dry-run=client -o yaml --command -- sleep 1000 > mysample.yaml

k get pods -n elastic-stack

k -n elastic-stack logs kibana

## Edit the pod in the elastic-stack namespace to add a sidecar container to send logs to Elastic Search. Mount the log volume to the sidecar container.

https://kubernetes.io/docs/tasks/access-application-cluster/communicate-containers-same-pod-shared-volume/

## can exec into a runing pod

k -n elastic-stack exec -it app -- cat /log/app.log

## edit pod in a namespace
k edit pod app -n elastic-stack

```

## Error - pods not valid after editing a pod

Run this 

`k edit pod app -n elastic-stack`

`k replace --force -f /tmp/kubectl-edit2222323.yaml`

This will delete the pod and recreate a new one 

## Get all information on all pods
```yaml
`k describe pod`

## An app wuth inti:CrashLoopBackoff

check the logs of pod

k logs orange

## check the logs of the inti container
k logs orange -c init-myservcie
```
## Os Updates

When working with workloads on a node
```yaml
## drain workloads to move to another node
kubectl drain node-1

pods are gracefully terminated, no pods can be schedules on this node

## The kubectl uncordon command is used to mark a Kubernetes node as schedulable again after it was previously cordone

kubectl uncordon node-1

## The kubectl cordon command is used to mark a Kubernetes node as unschedulable. 

kubectl cordon node-01


k describe nodes

## Get pods with node details 
 k get pods -o wide
```

## Kubernetes Releases and K8 CLuster Upgrade 
```yaml
https://kubernetes.io/docs/concepts/overview/kubernetes-api/

Here is a link to Kubernetes documentation if you want to learn more about this topic (You don’t need it for the exam, though):

https://github.com/kubernetes/community/blob/master/contributors/devel/sig-architecture/api-conventions.md

https://github.com/kubernetes/community/blob/master/contributors/devel/sig-architecture/api_changes.md

## cluster Update Process

```
```yaml

## Using kubeadm tool, kubeadm does not install or upgrade kubelets.
## check the current local version of kubeadm tool, also check the remote version

vim /etc/apt/sources.list.d/kubernetes.list

## What is the latest version available for an upgrade with the current version of the kubeadm tool installed?
kubeadm upgrade plan 

## Notes: to upgrade the cluster, upgrade the kubeadm tool first

## lets say we will upgrade the MASTER NODE first, actually upgrade the controlplane first 

## drain the controleplane node
k drain controlplane --ignore-daemonsets


## upgrade the control plane components
## check the docs for admin with kubeadm

https://v1-30.docs.kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-upgrade/

## kubeadm ---> master components -----> kubelets --------> workernodes

apt update
## first 

On the controlplane node:
Use any text editor you prefer to open the file that defines the Kubernetes apt repository.


vim /etc/apt/sources.list.d/kubernetes.list

## Update the version in the URL to the next available minor release, i.e v1.30.
deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /


## install and upgrade the kubeadm
apt update
apt-get upgrade -y kubeadm=1.12.0-00

## Find the latest 1.30 version in the list.
## It should look like 1.30.x-*, where x is the latest patch.
apt-cache madison kubeadm
sudo apt-mark unhold kubeadm && \
sudo apt-get update && sudo apt-get install -y kubeadm='1.30.x-*' && \
sudo apt-mark hold kubeadm

## example I used
sudo apt-mark unhold kubeadm && sudo apt-get update && sudo apt-get install -y kubeadm='1.30.0-1.1' && sudo apt-mark hold kubeadm

//e.g  sudo apt-get update && sudo apt-get install -y kubeadm='1.30.0-0' && \
## now, update all the control components

drain the master node first 1
kubectl drain controlplane

kubeadm upgrade apply 1.12.0

## Check for the new plan with the update 
kubeadm upgrade plan

## upgrade the kubelet if on master nodes

sudo apt-mark unhold kubelet kubectl && \
sudo apt-get update && sudo apt-get install -y kubelet='1.30.0-1.1' kubectl='1.30.0-1.1' && \
sudo apt-mark hold kubelet kubectl

systemctl daemon-reload

systemctl restart kubelet
or

apt-get upgrade -y kubelet=1.12.0-00
apt-get install kubelet=1.30.0-1.1
systemctl restart kubelet

k get nodes 
## workers node not updated yet

## update them one after the other 
kubectl drain node-1

apt-get install kubeadm=1.30.0-1.1

# Upgrade the node 
kubeadm upgrade node

## Now, upgrade the version and restart Kubelet.

apt-get install kubelet=1.30.0-1.1

systemctl daemon-reload

systemctl restart kubelet

systemctl restart kubelet

## make the node schedulable

kubectl uncordon node-1
```

## Backup - Resource configs

```yaml

## example of using the imperative way
`kubectl get all -all-namespaces -o yaml > all-deploy-services.yaml`

`k get pods --all-namespaces `

## Do not need to stress, ark(Now Velero can help with the backup)

## We can backup the sates in ETCD  and it brings all our data back

data storage location can be found in the etcd.service
--data-dir-/var/lib/etcd

## can take snapshot of the ETCD server
ETCDCLT_API=3 etcdctl \ snapshot save snapshot.db

## status of the snapshot
ETCDCLT_API=3 etcdctl \ snapshot status snapshot.db

## restore the dcluster from this backup at a later point in time

- Stop the kube api server, because the etcd will be restarted and kubeapi depends on it 
service kube=apiserver stop

## Then restore
ETCDCTL_API=3 etcdctl \ snapshot restore snapshot.db \ --data-dir /var/lib/etcd-from-backup

## then configure etcd.service to use the new data dir
--data-dir=/var/lib/etcd-from-backup

systemctl daemon-reload

service etcd restart

service kube-apiserver start

export ETCDCTL_API=3
## remember to specify the additional flaga

ETCDCTL_API=3 etcdctl --endpoints=https://[127.0.0.1]:2379 \
--cacert=/etc/kubernetes/pki/etcd/ca.crt \
--cert=/etc/kubernetes/pki/etcd/server.crt \
--key=/etc/kubernetes/pki/etcd/server.key \
snapshot save /opt/snapshot-pre-boot.db



## Know the services running
kubectl get services
##

k describe service <service-name>





## What is the version of ETCD running on the cluster?, Check the ETCD Pod or Process
`k describe pod etcd-controlplane -n kube-system | grep Image`

## Where is the ETCD server certificate file located?

 kubectl -n kube-system describe pod etcd-controlplane | grep '\--cert-file'


--cert-file=/etc/kubernetes/pki/etcd/server.crt

Where is the ETCD CA Certificate file located?

--trusted-ca-file=/etc/kubernetes/pki/etcd/ca.crt


## The master node in our cluster is planned for a regular maintenance reboot tonight. While we do not anticipate anything to go wrong,
## we are required to take the necessary backups. Take a snapshot of the ETCD database using the built-in snapshot functionality.


Store the backup file at location /opt/snapshot-pre-boot.db


Use the etcdctl snapshot save command. You will have to make use of additional flags to connect to the ETCD server.

--endpoints: Optional Flag, points to the address where ETCD is running (127.0.0.1:2379)

--cacert: Mandatory Flag (Absolute Path to the CA certificate file)

--cert: Mandatory Flag (Absolute Path to the Server certificate file)

--key: Mandatory Flag (Absolute Path to the Key file)


## solution

ETCDCTL_API=3 etcdctl --endpoints=https://[127.0.0.1]:2379 \
--cacert=/etc/kubernetes/pki/etcd/ca.crt \
--cert=/etc/kubernetes/pki/etcd/server.crt \
--key=/etc/kubernetes/pki/etcd/server.key \
snapshot save /opt/snapshot-pre-boot.db

```


## Restore a backup

```yaml
First Restore the snapshot:

export ETCDCTL_API=3
etcdctl  --data-dir /var/lib/etcd-from-backup \ snapshot restore /opt/snapshot-pre-boot.db



Note: In this case, we are restoring the snapshot to a different directory but in the same server where we took the backup (the controlplane node)
As a result, the only required option for the restore command is the --data-dir.


## update the k8 dir 
Next, update the
vim  /etc/kubernetes/manifests/etcd.yaml:

- We have now restored the etcd snapshot to a new path on the controlplane - /var/lib/etcd-from-backup,
- so, the only change to be made in the YAML file,
- is to change the hostPath for the volume called etcd-data from old directory (/var/lib/etcd) to the new directory (/var/lib/etcd-from-backup).

volumes:
  - hostPath:
      path: /var/lib/etcd-from-backup
      type: DirectoryOrCreate
    name: etcd-data

- With this change, /var/lib/etcd on the container points to /var/lib/etcd-from-backup on the controlplane (which is what we want).

- When this file is updated, the ETCD pod is automatically re-created as this is a static pod placed under the /etc/kubernetes/manifests directory.



Note 1: As the ETCD pod has changed it will automatically restart, and also kube-controller-manager and kube-scheduler.
Wait 1-2 to mins for this pods to restart. You can run the command: watch "crictl ps | grep etcd" to see when the ETCD pod is restarted.

- Note 2: If the etcd pod is not getting Ready 1/1, then restart it by
- kubectl delete pod -n kube-system etcd-controlplane
- and wait 1 minute.

Note 3: This is the simplest way to make sure that ETCD uses the restored data after the ETCD pod is recreated. You don't have to change anything else.


If you do change --data-dir to /var/lib/etcd-from-backup in the ETCD YAML file,
make sure that the volumeMounts for etcd-data is updated as well,
with the mountPath pointing to /var/lib/etcd-from-backup (THIS COMPLETE STEP IS OPTIONAL AND NEED NOT BE DONE FOR COMPLETING THE RESTORE)
```

## working with multiple k8 clusters 

```yaml
## get the all clusters
k config get-clusters 
k config get-context

# How many nodes (both controlplane and worker) are part of cluster1?
# Make sure to switch the context to cluster1:


kubectl get pods -n kube-system  | grep etcd

## ECTD Can run as a pod(stacked topology or configured externally(no pods) in clusters
kubectl config use-context cluster1

## you will notice that etcd is running as a pod:
## This means that ETCD is set up as a Stacked ETCD Topology
where the distributed data storage cluster provided by etcd is stacked
on top of the cluster formed by the nodes managed by kubeadm that run control plane components.

## How is ETCD configured for cluster2?

Also, there is NO static pod configuration for etcd under the static pod path:
ls /etc/kubernetes/manifests/ | grep -i etcd


 kubectl -n kube-system describe pod etcd-cluster1-controlplane | grep data-dir
      --data-dir=/var/lib/etcd


## for cluster 2
## If you check out the pods running in the kube-system namespace in cluster2,
## you will notice that there are NO etcd pods running in this cluster!
## ssh cluster2-controlplane
## ls /etc/kubernetes/manifests/ | grep -i etcd


## However, if you inspect the process on the controlplane for cluster2,
## you will see that that the process for the kube-apiserver is referencing an external etcd datastore:

 ps -ef | GREP_COLOR='01;31' grep --color=always 'etcd'
 ps -ef | grep etcd

## You can see the same information by inspecting the kube-apiserver pod (which runs as a static pod in the kube-system namespace):
## The kubeapi server needs the etcd datastore and as such why we reference it.
kubectl -n kube-system describe pod kube-apiserver-cluster2-controlplane 

```

## external server 
How many nodes are part of the ETCD cluster that etcd-server is a part of?

ssh into etcd server 
```yaml
ETCDCTL_API=3

ETCDCTL_API=3 etcdctl --endpoints=https://192.21.43.19:2379  --cert=/etc/etcd/pki/etcd.pem   --key=/etc/etcd/pki/etcd-key.pem   --cacert=/etc/etcd/pki/ca.pem    mem
ber list


## Take a backup of etcd on cluster1 and save it on the student-node at the path /opt/cluster1.db
Next, inspect the endpoints and certificates used by the etcd pod. We will make use of these to take the backup.

Remember it is a static pod 

kubectl describe  pods -n kube-system etcd-cluster1-controlplane  | grep advertise-client-urls
      --advertise-client-urls=https://192.160.244.10:2379




kubectl describe  pods -n kube-system etcd-cluster1-controlplane  | grep pki
      --cert-file=/etc/kubernetes/pki/etcd/server.crt
      --key-file=/etc/kubernetes/pki/etcd/server.key
      --peer-cert-file=/etc/kubernetes/pki/etcd/peer.crt
      --peer-key-file=/etc/kubernetes/pki/etcd/peer.key
      --peer-trusted-ca-file=/etc/kubernetes/pki/etcd/ca.crt
      --trusted-ca-file=/etc/kubernetes/pki/etcd/ca.crt
      /etc/kubernetes/pki/etcd from etcd-certs (rw)
    Path:          /etc/kubernetes/pki/etcd


SSH to the controlplane node of cluster1 and then take the backup using the endpoints and certificates we identified above:

 ETCDCTL_API=3 etcdctl --endpoints=https://192.160.244.10:2379 --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/server.crt --key=/etc/kubernetes/pki/etcd/server.key snapshot save /opt/cluster1.db
Snapshot saved at /opt/cluster1.db


Finally, copy the backup to the student-node. To do this, go back to the student-node and use scp as shown below:

 scp cluster1-controlplane:/opt/cluster1.db /opt





## question

An ETCD backup for cluster2 is stored at /opt/cluster2.db. Use this snapshot file to carryout a restore on cluster2 to a new path /var/lib/etcd-data-new.



Once the restore is complete, ensure that the controlplane components on cluster2 are running.


The snapshot was taken when there were objects created in the critical namespace on cluster2. These objects should be available post restore.


If needed, make sure to set the context to cluster2 (on the student-node):


scp /opt/cluster2.db etcd-server:/root


Step 2: Restore the snapshot on the cluster2. Since we are restoring directly on the etcd-server, we can use the endpoint https:/127.0.0.1. Use the same certificates that were identified earlier. Make sure to use the data-dir as /var/lib/etcd-data-new:

etcd-server ~ ➜  ETCDCTL_API=3 etcdctl --endpoints=https://127.0.0.1:2379 --cacert=/etc/etcd/pki/ca.pem --cert=/etc/etcd/pki/etcd.pem
--key=/etc/etcd/pki/etcd-key.pem snapshot restore /root/cluster2.db --data-dir /var/lib/etcd-data-new


{"level":"info","ts":1721940922.0441437,"caller":"snapshot/v3_snapshot.go:296","msg":"restoring snapshot","path":"/root/cluster2.db","wal-dir":"/var/lib/etcd-data-new/member/wal","data-dir":"/var/lib/etcd-data-new","snap-dir":"/var/lib/etcd-data-new/member/snap"}
{"level":"info","ts":1721940922.060755,"caller":"mvcc/kvstore.go:388","msg":"restored last compact revision","meta-bucket-name":"meta","meta-bucket-name-key":"finishedCompactRev","restored-compact-revision":951}
{"level":"info","ts":1721940922.0667593,"caller":"membership/cluster.go:392","msg":"added member","cluster-id":"cdf818194e3a8c32","local-member-id":"0","added-peer-id":"8e9e05c52164694d","added-peer-peer-urls":["http://localhost:2380"]}
{"level":"info","ts":1721940922.0732546,"caller":"snapshot/v3_snapshot.go:309","msg":"restored snapshot","path":"/root/cluster2.db","wal-dir":"/var/lib/etcd-data-new/member/wal","data-dir":"/var/lib/etcd-data-new","snap-dir":"/var/lib/etcd-data-new/member/snap"}


Step 3: Update the systemd service unit file for etcd by running vi /etc/systemd/system/etcd.service and add the new value for data-dir:

[Unit]
Description=etcd key-value store
Documentation=https://github.com/etcd-io/etcd
After=network.target

[Service]
 User=etcd
 Type=notify
 ExecStart=/usr/local/bin/etcd \
 --name etcd-server \
 --data-dir=/var/lib/etcd-data-new \


Step 4: make sure the permissions on the new directory is correct (should be owned by etcd user):

etcd-server /var/lib ➜  chown -R etcd:etcd /var/lib/etcd-data-new


etcd-server /var/lib ➜  ls -ld /var/lib/etcd-data-new/
 /var/lib/etcd-data-new/


Step 5: Finally, reload and restart the etcd service.

etcd-server ~ ➜  systemctl daemon-reload 
etcd-server ~ ➜  systemctl restart etcd




Step 6 (optional): It is recommended to restart controlplane components (e.g. kube-scheduler, kube-controller-manager, kubelet) to ensure that they don't rely on some stale data.

https://github.com/etcd-io/website/blob/main/content/en/docs/v3.5/op-guide/recovery.md
```

## Security in Kubernetes 

```yaml
Acess to the host must be very secured, if that is compromised everything is compromised.

control access to the APISERVER, that is the first line of defense

Auth - RBAC, ABAC , Node Aith

Network policy to restrict communciation between components

## AUTH

You cannot create users but you can create service account

k create serviceaccount sa1

k get serviceaccount

## if using a satic toke

--token-auth-file=user-token-details.csv

## then pass the token as an authorization bearer

curl -v -k https://master-node-ip:6443/api/v1/pods --header "Authorization: Bearer nlnklnavlanaknslnkoanrgoan"

- This is not a recommended auth mechanisim in a clear text
- consider volume mount while providing the auth file in a kubeadm setup
- setup RBA for the new users

## loction of the key in a company's server
cat ~/.ssh/authorized_keys

## Assymetric using openssl to generate pub and private key pair on the server, server can have private key securely

openssl genrsa -out my-bank.key 1024

- user gets the pub key from the server
- user sends the pub key to the server and server decrypyts with priavte key 

This is different from ssh-keygen


## All this comm between browser CA and server known as PKI(Public key Infrastructure )

## naming convention for public key
*.crt *.pem

server.crt
server.pem
client.crt
client.pem

## private key

*.key  *-key.pem
server.key
server-key.pem
client.key
client-key.pem

## flow of PKI
- users need https access to a server
- first server sends a certificate signing request(CSR) to CA
- CA uses its private key to sign CSR - you know all users have a copy of the CA public key
- Signed certifcate is sent back to the server
- server configures the web app with the signed certificate
- users need access, server first sends the certicate with its public key
- users browser reads the certifcate and uses the CA's public key to validate and retrieve the server's public key
- Borwser then generates a symmetric key it uses for communication going forward for all communication.
- The symmetric key is encrypted using the server as public key and sent back to the server
- server uses its private key to decrpyt the message and retrieve the symmetric key
- symmetric key is used for communication going forward
```

## Root cert, Client cert, Server Cert 

```yaml
##  server components that need certs
kuube-api
etcd server
kubelet server

## client components through REST to Kube-Api server
Admin - admin.crt admin.key
scheduler - schedular.crt scheduler.key
kube controller manager
kubeproxy 
```


## Generate Certificate for the cluster 

```yaml
## tools
EASYRSA OPENSSL CFSSL

## FIRST generate the CA cert
openssl genrsa -out ca.key 2048

## generate a certifcate signing request

// CN -COMMON NAME
openssl req -new -key ca.key -subj "/CN=KUBERNETES-CA" -out ca.csr

//SIGN USING THE OPENSSL
openssl x509 -req -in ca.csr -signkey ca.key -out ca.crt



## Follow same process for the client but with little tweak by signing with the CA

## Generate cert for Admin user and group /O

openssl genrsa -out admin.key 2048
admin.key

//gen a signing in request
openssl req -new -key admin.key -subj \ "/CN=kube-admin" -out admin.csr
admin.csr

// signing request with an exiting sysems group group in cluster
openssl req -new -key admin.key -subj \ "/CN=kube-admin/O=system:masters" -out admin.csr
admin.csr

## generate a signed public certifcate, this time, specify the ca CERT AND CA key
## we are signing the cert with CA, making it a valid certicate within your cluster

openssl x509 -req -in admin.csr -CA ca.crt -CAkey ca.key -out admin.crt

## for system components like kube-scehduler

prefix the name with the keyword system

## what do you do with cert

can run a curl to kube  api-server

curl https://kube-api-server:6443/api/v1/pods --key admun.key --cert admin.crt --cacert ca.crt


## can use it withing a kube-config.yaml

## every c;ients need the root CA in their configuration

## ETCD deployed as a cluster across multple servers

needs an additional peer-cert for secure communication btw diff members in the cluster
peer.key
peer-trusted-ca-file ca.crt
etcdpeer1.crt
truated-ca-file ca.crt

## kubapi-server

you need the name specified in creating the key

opnessl.cnf file

openssl req -new -key apiserver.key -subj\ "/cn=KUBE=APISERVER" -OUT APISERVER.CSR --config openssl.cnf

openssl.cnf file
[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name
[ v3_req ]
basicConstri=aints = CA:FALSE
keyUsage = nonRepudiation,
subjectAltName = @alt_names
[alt_names]
DNS.1 = kubernetes
DNS.2 = kubernetes.default
dns.3 = kubernetes.default.svc
DNS.4 = KUBERNETES.DEFAULT.SVC.CLUSTER.LOCAL
1P.1 = 10.96.0.1


OPNESSL X509 -req -in apiserver.csr -CA ca.crt -CAkey ca.key -cacreateserial -out apiserver.crt -extensions v3_req -extfile openssl.cnf -days 1000 


## pass the value to usr/local/bin/kube-apiserver 
```

## kubernetes- view certificate details 

```yaml
## The hard way - from scratch

journalctl -u etcd.service -1


cat /etc/systemd/system/kube-apiserver.service

## The automated way - kubeadm

cat /etc/kubernetes/manifests/kube-apiserver.yaml

identify the file where it is stored

## go deeper into the certificate to decode and check details

## lets start with the apiserver cert file
openssl x509 -in /etc/kubernetes/pki/apiserver.crt  -text -noout


kubectl logs etcd-master

## can go down t docker

docker ps -a
docker logs containerid 


## grep additions

 k describe pods -n kube-system kube-apiserver-controlplane | grep -E '\.ca$|\.crt$|'

## kube-apiserver
--tls-cert-file=/etc/kubernetes/pki/apiserver.crt

## Identify the Certificate file used to authenticate kube-apiserver as a client to ETCD Server.
--etcd-certfile=/etc/kubernetes/pki/apiserver-etcd-client.crt

## Identify the ETCD Server Certificate used to host ETCD server.
  --tls-cert-file=/etc/kubernetes/pki/apiserver.crt

## What is the Common Name (CN) configured on the ETCD Server certificate?
--cert-file=/etc/kubernetes/pki/etcd/server.crt


## connection with kube-api server refused
docker ps -a | grep etcd

## use crtctl for crio environments 
crtctl ps -a
//used for envs using crio instead of docker 

```

## Certificates API
```yaml
## TLS Certtificates - Certificates wotkflow and API
Kubernetes has a certificate buit-in API

once a new admin generates its key and sent to KA8Admin
He creates a certificate signing object

converts the admin key to base64

cat jane.csr | base64

place the encoded object in the request filed in the object

## check all siginin requests
kubectl get csr

## approve the reuest

kubectl certifcate approve jane 


## get certifcate in yaml format

kubectl get csr jane -o yank

## to decode it

echo "a0qahqbqdqh0ndqd-qnasqwdnm" | base64 --decode

who does this - controller manager

Anyone who needs to sign certifcate need the CA server root certificcate and provet key

/etc/kubernetes/manifests/kube-controller-manager.yaml

--cluster-signing-cert-file=/etc/kubernetes/pki/ca.crt
--cluster-signing-cert-file=/etc/kubernetes/pki/ca.key
```

## Example of creating and approving certificate 

```yaml
- Create a CertificateSigningRequest object with the name akshay with the contents of the akshay.csr file
- As of kubernetes 1.19, the API to use for CSR is certificates.k8s.io/v1.
- Please note that an additional field called signerName should also be added when creating CSR.
- For client authentication to the API server we will use the built-in signer kubernetes.io/kube-apiserver-client.

## Answer

cat <<EOF | kubectl apply -f -
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: akshay
spec:
  groups:
  - system:admin
  - system:authenticated
  request: $(cat akshay.csr | base64 | tr -d '\n')
  signerName: kubernetes.io/kube-apiserver-client
  usages:
  - client auth 
EOF

kubectl get scr

kubectl certificate approve akshay

kubectl delete csr agent-smith 


```

## kube config

```yaml

## Use a context with a different file name and location

kubectl config use-context research --kubeconfig /root/my-kube-config 

$HOME/.kube/config 
kubectl config view

## change the context to access production cluster based on the configuration in the cofig file

kubectl config use-context prod-user@production

## To know the current context, run the command:
kubectl config --kubeconfig=/root/my-kube-config current-context


## sample config file with users, context

k config view --kubeconfig my-kube-config

apiVersion: v1
kind: Config

clusters:
- name: production
  cluster:
    certificate-authority: /etc/kubernetes/pki/ca.crt
    server: https://controlplane:6443

- name: development
  cluster:
    certificate-authority: /etc/kubernetes/pki/ca.crt
    server: https://controlplane:6443

- name: kubernetes-on-aws
  cluster:
    certificate-authority: /etc/kubernetes/pki/ca.crt
    server: https://controlplane:6443

- name: test-cluster-1
  cluster:
    certificate-authority: /etc/kubernetes/pki/ca.crt
    server: https://controlplane:6443

contexts:
- name: test-user@development
  context:
    cluster: development
    user: test-user

- name: aws-user@kubernetes-on-aws
  context:
    cluster: kubernetes-on-aws
    user: aws-user

- name: test-user@production
  context:
    cluster: production
    user: test-user

- name: research
  context:
    cluster: test-cluster-1
    user: dev-user

users:
- name: test-user
  user:
    client-certificate: /etc/kubernetes/pki/users/test-user/test-user.crt
    client-key: /etc/kubernetes/pki/users/test-user/test-user.key
- name: dev-user
  user:
    client-certificate: /etc/kubernetes/pki/users/dev-user/developer-user.crt
    client-key: /etc/kubernetes/pki/users/dev-user/dev-user.key
- name: aws-user
  user:
    client-certificate: /etc/kubernetes/pki/users/aws-user/aws-user.crt
    client-key: /etc/kubernetes/pki/users/aws-user/aws-user.key

current-context: test-user@development
preferences: {}


Error in configuration: context was not found for specified context: dev-user@research

```

## API Groups 
```yaml
## Core API and Named API Groups 

## list available groups from your cluster

curl http:/localhost:6443 -k

## list groups on the named api group

curl http://localhost:6443/apis -k | grep "name"

## you need auth for more return from the api

curl http"//localhost:6443 -k
      --key admin.key
      --cert admin.crt
      --cacert ca.crt

## another option is to start a proxy client
- kubectl procy uses cred and certs from your kubeconfig file to access the cluster - port 8002
kubectl proxy

## after the service has started
curl http://locahost:8001 -k

kube proxy is not equal kubectl proxy 
```

## Authorization 

```yaml
## using namespaces to partiction users and service account
Auth supported by kubernetes
- Node Auth
- ABAC(Attribute Based Auth)
- RBAC (Resource Based Auth)
- Webhook


## Authorization Mode

Always Allow

Alwyas Deny

## check the mdoe in the /usr/local/bin/kube-apiserver
- By default 
--authorization-mode=AlwyasAllow

## you can set MUTLIPLE node Auth
- It is done in sequence 
--authorization-mode=Node,RBAC,Webhook



## RBAC

kubectl create role developer --verb=list,create,delete --resource=pods 


kind: Role
- Create a role with a yaml file

kubectl create -f developer-group.yaml

## link a user to the role object  using ROLE BINDING object

kubectl create rolebinding dev-user-binding --role=developer --user=dev-user 


Kind: RoleBinding

kubectl create -f devuser-developer-binding.yaml


## Get roles
kubectl get roles
kubectl get roles -A

ps -aux | grep authorization 

k get roles kube-proxy -n kube-system -o yaml

kubectl get rolebinding

## Check your auth as a user
kubectl auth can-i create deployments

kubectl auth can-i delete nodes

## Test users auth as an Admin without authenticating
kubectl can-i  create depolyments --as dev-user
kubectl can-i  create depolyments --as dev-user -n test

kubectl edit role developer -n blue


## Which account is the kube-proxy role assigned to?

kubectl describe rolebinding kube-proxy -n kube-system

apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  creationTimestamp: "2024-09-23T16:23:51Z"
  name: kube-proxy
  namespace: kube-system
  resourceVersion: "262"
  uid: f5150644-6bca-4031-b974-4269027d1c00
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: kube-proxy
subjects:
- apiGroup: rbac.authorization.k8s.io
  kind: Group
  name: system:bootstrappers:kubeadm:default-node-token


answer is  system:bootstrappers:kubeadm:default-node-token

```
## Task
```yaml

k --as dev-user create deployement nginx --image=nginx -n blue

- Create the necessary roles and role bindings required for the dev-user to create,
- list and delete pods in the default namespace.

Use the given spec:

Role: developer
Role Resources: pods
Role Actions: list
Role Actions: create
Role Actions: delete
RoleBinding: dev-user-binding
RoleBinding: Bound to dev-user



kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  namespace: default
  name: developer
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["list", "create","delete"]

---
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: dev-user-binding
subjects:
- kind: User
  name: dev-user
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: developer
  apiGroup: rbac.authorization.k8s.io


## another example

Add a new rule in the existing role developer to grant the dev-user permissions to create deployments in the blue namespace.


Remember to add api group "apps".


apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  creationTimestamp: "2024-09-23T16:26:01Z"
  name: developer
  namespace: blue
  resourceVersion: "4570"
  uid: 4c353f0d-cb82-405f-a2fe-4797523626d4
rules:
- apiGroups:
  - ""
  resourceNames:
  - blue-app
  - dark-blue-app
  resources:
  - pods
  verbs:
  - get
  - watch
  - create
  - delete
- apiGroups:
  - "apps"
  resources:
  - deployments
  verbs:
  - create

```

## Cluster Roles and Roles Binding 
```yaml

cluster scope resources 
## get resources in a namsepace
kubectl api-resources --namespaced=true

## cluster-scoped roles 

kubectl api-resources --namespaced=false

## Get cluster role
k get clusterroles --no-headers | wc -l

kubectl get clusterroles --no-headers  -o json | jq '.items | length'


## Get cluster role binding

 k get clusterrolebinding --no-headers | wc -l

```


