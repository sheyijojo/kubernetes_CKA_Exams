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

## A new user michelle joined the team. She will be focusing on the nodes in the cluster.
## Create the required ClusterRoles and ClusterRoleBindings so she gets access to the nodes.


Use the command kubectl create to create a clusterrole and clusterrolebinding for user michelle to grant access to the nodes.
After that test the access using the command:

 kubectl auth can-i list nodes --as michelle.

## answer

k create clusterrole michelleuser --verb=list --resource=nodes

k create clusterrolebinding michellebind --clusterrole=michelleuser --user=michelle


## michelle's responsibilities are growing and now she will be responsible for storage as well.
## Create the required ClusterRoles and ClusterRoleBindings to allow her access to Storage.
## Get the API groups and resource names from command kubectl api-resources. Use the given spec:


kubectl auth can-i list storageclasses --as michelle

 k create clusterrole storage-admin --verb=get,list,watch --resource=storageclasses,persistentvolumes

 k create clusterrolebinding michelle-storage-admin --clusterrole=storage-admin --user=michelle

k get clusterrole storage-admin -o yaml


apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  creationTimestamp: "2024-09-24T17:23:23Z"
  name: storage-admin
  resourceVersion: "1253"
  uid: 359a0c92-d7f7-426b-9c6b-8ae4bf445c20
rules:
- apiGroups:
  - ""
  resources:
  - persistentvolumes
  verbs:
  - get
  - list
  - watch
- apiGroups:
  - storage.k8s.io
  resources:
  - storageclasses
  verbs:
  - get
  - list
  - watch

```

## Service Accounts in Kubernetes 
Every namespace has a default service account 
```yaml
## There are two kinds of accounts -
- service account - used by machines like jenkins, prometheus
- user account - e.g admin user

## create a service account

kubectl create serviceaccount dashboard-sa

kubectl get serviceaccount
## service account create token stored as a secret object

kubectl describe secret <secret-name>

curl https:49u34u34/spi -insecure --header "Authroization: Bearer sdssdmdsdmdmsdmsdm"

## Default service account with secret token is automatically mounted as volume mount in a pod by default
## a vol is automtaiclaly creaeted for the service acount

kubectl exec -it my-dashboard -- ls /var/run/secrets/kubernetes.io/serviceaccount

## The flow
- create service account
kuubectl create serviceaccounts logging-dash

- create a token for the service account
kubectl create token logging-dash



## You shouldn't have to copy and paste the token each time. The Dashboard application is programmed to read token from the secret mount location.
However currently, the default service account is mounted. Update the deployment to use the newly created ServiceAccount


Edit the deployment to change ServiceAccount from default to dashboard-sa.

or edit the deployment and add serviceAccountName

kubectl set serviceaccount deploy/web-dashboard dashboard-sa



## make sure is inside the container spec
    spec:
      containers:
      - env:
        - name: PYTHONUNBUFFERED
          value: "1"
        image: gcr.io/kodekloud/customimage/my-kubernetes-dashboard
        imagePullPolicy: Always
        name: web-dashboard
        ports:
        - containerPort: 8080
          protocol: TCP
        resources: {}
        terminationMessagePath: /dev/termination-log
        terminationMessagePolicy: File
      dnsPolicy: ClusterFirst
      restartPolicy: Always
      schedulerName: default-scheduler
      securityContext: {}
      serviceAccount: dashboard-sa
      serviceAccountName: dashboard-sa
      terminationGracePeriodSeconds: 30


```

## Private Repository 

```yaml
docker login private-registry.io

docker run private-registry.io/apps/internal-app

## use image on pods on the worker nodes from private registry
- hOW DO WE IMPLEMENT THE AUTH

docker create secret docker-registry --help

## CREATE A SECRET object  called docker-registry with the credentials in it 
kubectl create secret docker-registry <secret-name>  \
--docker-server=  \
--docker-username=  \
--docker-email=    \


## on the pod
spec:
  containers:
  imagePullSecrets:
  - name: <secret-name>


k create secret docker-registry private-reg-cred \
 --docker-server=myprivateregistry.com:5000 \
 --docker-username=docker_user  \
 --docker-email=dock_user@myprivateregistry.com \
 --docker-password=dock_password
secret/private-reg-cred created

```

## DOCKER SECURITY 

```yaml
## advisable to speicifi user to run processes in a container

USER 1000

docker run --user=1001 ubuntu sleep 3600

## Check what users can do in linux

/usr/include/linux/capability.h

root user in container does not have has much capabikity as that of linux HOST

## CONTROL CAPBILITY TO A USER

docker run --cap-add MAC_ADMIN ubuntu
docker run --cap-drop KILL ubuntu

## run with all priviledges

docker run --privileged ubuntu 
```

## Security Context 
```yaml
## security context on the spec/kubernetes level 
spec:
 securityContext:
    runAsUser: 1000
 containers:
   - name: ubuntu
     image: ubuntu
     comannd: ["sleep", "3600"]


## security context on the container level 
spec:
 containers:
   - name: ubuntu
     image: ubuntu
     comannd: ["sleep", "3600"]
     securityContext:
        runAsUser: 1000
        capablities:
           add:  ["MAC_ADMIN"]

//CAPABILTIES ARE ONLY SUPPORTED A THE CONTAINER LEVEL 


## check which user is running processes on a pod

kubectl exec ubuntu-sleeper -- whoami 

```
## Network Policy
- By default, all pods talk to each other 
- link a Network Policy to a pod
Use labels and selectors
- label the pod
- use podSelector in the network policy 
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metada:
  name: db-policy
spec:
  podSelector:
    matchLabels:
       role: db
  policyTypes:
  - Ingress
  ingress:
  - from
    - podSelector:
        matchlabels:
           name: api-pod
      namespaceSelector:
          matchLabels:
              name: prod
    - ipBlock:
        cidr: 192.168.5.10/32
   ports:
   - protocol: TCP
     PORT: 3306 

  
## add external ip not part of the cluster , see abobe


## EGRESS: what if nrtwork egress from the DB to the backup server

apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metada:
  name: db-policy
spec:
  podSelector:
    matchLabels:
       role: db
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from
    - podSelector:
        matchlabels:
           name: api-pod
      namespaceSelector:
          matchLabels:
              name: prod
    ports:
    - protocol: TCP
      port: 3306

  egress:
   - to
     - ipBlock:
        cidr: 192.168.5.10/32
   ports:
   - protocol: TCP
     port: 80

```

```yaml
## Networking contd
kuubectl get networkpolicies

Create a network policy to allow traffic from the Internal application only to the payroll-service and db-service.


Use the spec given below. You might want to enable ingress traffic to the pod to test your rules in the UI.

Also, ensure that you allow egress traffic to DNS ports TCP and UDP (port 53) to enable DNS resolution from the internal pod.

## My note
So this is allowing internal app to allow traffic out only to DB and payroll and not the external app

- Policy Name: internal-policy
- Policy Type: Egress
- Egress Allow: payroll
- Payroll Port: 8080
- Egress Allow: mysql
- MySQL Port: 3306 



apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: internal-policy
  namespace: default
spec:
  podSelector:
    matchLabels:
      name: internal
  policyTypes:
  - Egress
  - Ingress
  ingress:
    - {}
  egress:
  - to:
    - podSelector:
        matchLabels:
          name: mysql
    ports:
    - protocol: TCP
      port: 3306

  - to:
    - podSelector:
        matchLabels:
          name: payroll
    ports:
    - protocol: TCP
      port: 8080

```
##kubectx
```yaml
https://github.com/ahmetb/kubectx

Throughout the course, you have had to work on several different namespaces in the practice lab environments. In some labs, you also had to switch between several contexts.

While this is excellent for hands-on practice, in a real “live” Kubernetes cluster implemented for production,

there could be a possibility of often switching between a large number of namespaces and clusters.

This can quickly become a confusing and overwhelming task if you have to rely on kubectl alone.

This is where command line tools such as kubectx and kubens come into the picture.

Reference:https://github.com/ahmetb/kubectx

Kubectx:

With this tool, you don’t have to make use of lengthy “kubectl config” commands to switch between contexts. This tool is particularly useful to switch context between clusters in a multi-cluster environment.

Installation:

sudo git clone https://github.com/ahmetb/kubectx /opt/kubectx

sudo ln -s /opt/kubectx/kubectx /usr/local/bin/kubectx

Syntax:

To list all contexts:

kubectx

To switch to a new context:

kubectx

To switch back to the previous context:

kubectx –

To see the current context:

kubectx -c

Kubens:

This tool allows users to switch between namespaces quickly with a simple command.

Installation:

sudo git clone https://github.com/ahmetb/kubectx /opt/kubectx

sudo ln -s /opt/kubectx/kubens /usr/local/bin/kubens
Syntax:

To switch to a new namespace:

kubens

To switch back to previous namespace:

kubens –

```

## STORAGE

```yaml
## Understand docker file system
## dockwe default location for file, images , volumes, containers
/var/lib/docker

## after writing dockerfile and building the file
## when u run docker run, docker creates a final writeable container layer

## The layer exist as long as the container exist, it dies if the container dies

## what if the want top persist data from a database

docker volume create data_volume

## mount the volume to the default location where mysql stores data 

docker run -v data_volume:/var/lib/mysql mysql

## bind mounting - external host(docker host) has a data location  /data/mysql

docker run -v /data/mysql:/var/libmysql mysql

## new way under docker
docker run \ --mount type=bind,source=/data/mysql,target=/var/lib/mysql mysql

docker uses strogge drivers to drive all these ops

Storage drivers help manage storage on images and containers

Volume drivers: Volumes are managed by volume driver pluggins : the default vol driver plugin is local


## other examples
Local| Azure File Storgae | Convoy | DigitalOcean Block Storgae | Flocker | gce-docker

| Nteapp | Rexray | Portwoex | Vmarew vphere

## storage drivers - Dependent on OS
AUFS | ZFS | BTRFS | DEVICE MAPPER | OVERLAY

## example of volumes on my local computer
─ docker volume inspect buildx_buildkit_devops-builder0_state                                              ─╯
[
    {
        "CreatedAt": "2024-08-07T16:45:54Z",
        "Driver": "local",
        "Labels": null,
        "Mountpoint": "/var/lib/docker/volumes/buildx_buildkit_devops-builder0_state/_data",
        "Name": "buildx_buildkit_devops-builder0_state",
        "Options": null,
        "Scope": "local"
    }

## using rexray volume driver to provision ebs volume from was in the cloud
//when container exit, data is saved in the cloud

docker run -it \
  --name mysql
  --volume-driver rexray/ebs
  --mount src=ebs-vol,target=/var/lib/mysql mysql 
```
## Now Kubernetes Volume 
Key Difference:
- Volumes are ephemeral and scoped within a Pod’s lifecycle unless backed by a persistent solution.
- Storage, especially through PVs and PVCs, is a more permanent solution and can outlive the Pod or be reused by different Pods.
- So, volumes are more about how data is mounted and accessed in running containers,
-  while storage often refers to the broader, persistent, and external data storage mechanisms.
```yaml
CRI - Container Runtime Interface
CNI - Container Networking Interface
CSI - Container Storage Interface

With CSI, you can develop your driver for your own storage to work with k8
e.g Amazon EBS, DELL EMC, GlusterFS all have CSI drivers

## Volumes in Kubernetes
To persist data in kubernetes, attach volume to the pod

## volume and mounts
- volume is spec level
- A volume needs a storage
- Use a dir in the host location for example
- Every file created in the volume would be stored in the dir data on my node
- After specificing the vol and storage,  to access it from the container,mount it to  ..
- a dir inside the container 
spec:
  containers
  volumes:
  - name: data-volume
    hostPath:
       path: /data
       type: Directory

## to access the volume from a container uding volume mount
- volume mount is spec.container level 
spec:
  containers
  - image: alpine
     volumeMounts:
     - mountPath: /opt
       name: data-volume 
   

volumes:
  - name: data-volume
    hostPath:
       path: /data
       type: Directory

Not recommeded on production level

Support of diff types of strogae solutions

- NFS,glusterFS, Flocker, ceph, scaleio, aws, Azure disk

  volumes:
  - name: data-volume
    awsElasticBlockStore:
       volumeID: <volume-id>
       fstype: ext4



## Persistent volume
- volumes stated above is only bound to pod definition file

- Need more centrally managed and user can carve out vols as needed

- PV is a cluster wide pool of storage volumes configured by an admin to be used by users deploying volume on the cluster using PVC

## example
kubectl create -f pvi-file.yaml

k get persistentvolume

## Persistent volume

apiVersion: v1
kind: PersistentVolume
metadata:
   name: pv-vol1
spec:
   accessModes:
       - ReadWriteOnce
   capacity:
      storage: 1Gi
   awsElasticBlockStore:
      volumeID: <volume-id>
      fstype: ext4

## Persistent Claims
Make a storage available to a node
user creates a set of PVCs to use for storage
- k8 binds PV to PVC - One-to-One


apiVersion: v1
kind: PersistentVolumeClaim
metadata:
   name: myclaim
spec:
  accessModes:
     - ReadWriteOnce
  resources:
     requests:
       storage: 500Mi 

k create -f .yaml

k get persistentvolumeclaim

k delete persistentvolumecmaim myclaim


## persistent volume
Create a Persistent Volume with the given specification.



Volume Name: pv-log

- Storage: 100Mi
- Access Modes: ReadWriteMany
- Host Path: /pv/log
- Reclaim Policy: Retain

apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-log
spec:
  accessModes:
     - ReadWriteMany
  capacity:
     storage: 100Mi
  hostPath:
        path: /pv/log

  persistentVolumeReclaimPolicy: Retain
```
## persistentvolumeclaim - make a storage available to a node
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: myclaim
spec:
  accessModes:
    - ReadWriteOnce
 # volumeMode: Filesystem
  resources:
    requests:
      storage: 8Gi
```
```yaml
### Let us claim some of that storage for our application. Create a Persistent Volume Claim with the given specification.

Volume Name: claim-log-1
Storage Request: 50Mi
Access Modes: ReadWriteOnce


##
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: claim-log-1
spec:
  accessModes:
    - ReadWriteOnce
  volumeMode: Filesystem
  resources:
    requests:
      storage: 50Mi



kubectl exec webapp -- cat /log/app.log

k get pod webapp -o yaml > sample.yaml

k replace -f sample.yaml --force

k get pv,pvc



##  Update the Access Mode on the claim to bind it to the PV.

apiVersion: v1
items:
- apiVersion: v1
  kind: PersistentVolumeClaim
  metadata:
    creationTimestamp: "2024-09-27T17:22:41Z"
    finalizers:
    - kubernetes.io/pvc-protection
    name: claim-log-1
    namespace: default
    resourceVersion: "1769"
    uid: 2235d2ea-9f46-4c78-ad16-d25ccac2154f
  spec:
    accessModes:
    - ReadWriteMany
    resources:
      requests:
        storage: 50Mi
    volumeMode: Filesystem
    volumeName: pv-log
  status:
    phase: Bound
kind: List
metadata:
  resourceVersion: ""

```

## Storage classes
- eliminate the need for a pv
- create a storage class and reference it in a PVC
```yaml
## Static prvisioning

gcloud beta compute disks create \
   --size 1GB
   --REGION US-EAST-1
   pd-disk


## Dynamic provisioning 
- create a storage class object

 kubectl get storageclasses

## STEPS
- Create a storage class object
- storage class creates pv automatically
- pvc reference the storage class at the spec level
spec:
  storageClassName: google-storage
- reference the PVC in the volumes of pod at the spec level 
## notes
info
- The Storage Class called local-storage makes use of VolumeBindingMode set to WaitForFirstConsumer.
- This will delay the binding and provisioning of a PersistentVolume until a Pod using the PersistentVolumeClaim is created.
```

## Networking in Linux
```yaml
## In Linux
## list and modify interfaces on the host
ip link

## see the ip addrs assigned to those interfaces ip addr 
ip addr 


## set ip addrs to those interfaces

ip addr add 192.168.1.10/24 dev eth0

## persist this changes
edit in the /etc/network/interfaces file.

## view the routes
ip route

## add entry into the routing table
ip route add 192.168.1.0/24 via 192.168.2.1

## check if ip forwarding is enabled, must be set to 1

cat  /proc/sys/net/ipv4/ip_forward

```
## DNS configuration in Linux Host
```yaml
## host A wanna ping system B with a host name db - name resolution
- on host A
cat >> /etc/hosts
2323.232.2323.232  db

## managing can be hard
- move entries into a DNS server to manage the hosts
- every host has a `dns resolution file ` `/etc/resolv.conf`
- add an entry into to it and specufy the addr of the dns server
- namserver 192.168.1.100
- dont need entry anymore in /etc/hosts
- if both local and dns server have the same entry, it ist looks at the local
- order is configured at cat /etc/nsswitch.conf

## shorthand for long Domain name such as web for web.mycompany.com
/etc/resolv.conf
search     mycompany.com

ping web

## test dns resolution
ping
## doesnt consider /ect/host file , only dns server
nslookup www.google.com
dig www.google.com

## can configure your computer as a DNS server using coredns solution 


https://coredns.io/plugins/kubernetes/
https://github.com/kubernetes/dns/blob/master/docs/specification.md
```

## Network Namspaces in Linux

```yaml
## To create a network namespace on a linux host
## In general, containers too have a ns to isolate itself from the host

ip netns add red
ip netns add blue

## list the network namespaces 
ip netns 

## run inside the ns to check for interfaces, syou can run for host too
## this network ns do not have interface yet and no network connnectivity 
ip netns exec red ip link
ip -n red link

## connect two namespaces using a virtual internet pair/cable
- use a virtual ethernet pair 

ip link add veth-red type veth peer name veth-blue

## attach each virtual interface to ns respectively
- so each ns get a networ interfce
ip link set veth-red netns red

ip link set veth-blue netns blue


## can assign ip addr to each ns
ip -n red addr add 192.168.15.1 dev veth-red

ip -n blue addr add 192.168.15.2 dev veth-blue

## bring up the interfaces
ip -n red link set veth-red up
ip -n blue link set veth-blue up


## ping from red ns to blue ns

ip netns exec red ping 192.168.15.2

## check the arp table

ip netns exec red arp

## connect all/multiple namespaces from the host
- the host is not aware of these namespaces created earlier
- so we need a virtual switch for this, just another namespace

- on the host - using the linux bridge virtual switch
## create a bridge, which is more like an interface

- ip link add v-net-0 type brigde

## check the newly created virtual interface
ip link

## turn up the virtual network switch  
ip link set dev v-net-0 up

- it is more like an interface for the host
- and switch for the namespace they can connect to

## connect the ns to the bridge network


- connect all ns to the briddge

## delete the virtual cablelinks to the ns created earlier
- the veth-blue deletes automatically

ip -n red link del veth-red


## connect to the bridge network
- first create a virtual link
- Remember this - `ip link add veth-red type veth peer name veth-blue`

## create a red virtual interface and pair with veth-red-br
ip link add veth-red type veth peer name veth-red-br


## create a blue virtual interface and pair veth-blue-0
ip link add veth-blue type veth peer name veth-blue-br

## connect the created one-end interface veth-red and veth-blue to their ns

ip link set veth-red netns red

ip link set veth-blue netns blue

## the other end veth-red-br and veth-blue-br to the bridge network v-net-0

ip link set veth-red-br master v-net-0
ip link set veth-blue-br master v-net-0

## Those interfaces need IP addr
ip -n red addr add 192.168.15.1 dev veth-red

ip -n blue addr add 192.168.15.1 dev veth-blue

## turn the 4 interfaces up to connect to the bridge network 
ip -n red link set  veth-red up

ip -n red link set  veth-red up


## host to ns connectivity

- add ip to brigde network
- remember the interfaces connected to the 192.168.15.0 network
ip addr add 192.168.15.5/24 dev v-net-0

## then try ping ns

ping 192.168.15.1

## reach outisde word through the ethernet port on the host
- Lets say the host would love to connect to a LAN network 192.168.1.0 with host addr 192.168.1.3
- it wont go through
- lets try the blue ns

ip netns exec blue ping 192.168.1.3

//of course unreacheable

//debug and check the route table

ip netns exec blue route to find the network

//no info about other network aside 192.168.15.0



## add an entry to the routing table to create a gateway/door  to the LAN

## localhost is the gateway that connects the two networks together
- i.e the network ninterface v-net-0 and the eth0(192.168.1.2) to the LAN network(192.168.1.0) -- LAN host(192.168.1.3


## in the blue namespace, add traffic in the route table

## make blue ns connect to 192.168.1.0/24 via host network 192.168.15.5

ip netns exec blue ip route add 192.168.1.0/24 via 192.168.15.5

## try and ping the LAN network host but no error EXCEPT NO response back
ip netns exec blue ping 192.168.1.3


## Need NAT enabled on the host, to send a message to the LAN
- Mask the ip addr coping from source network with the host add 

iptable -t nat -A POSTROUTING -s 192.168.15.0/24 -j MASQUERADE

## If you ping now, you will be able to reach the outside world
ip netns exec blue ping 192.168.1.3


## make NS to reach internet from the LAN
- It will be unreacheable
- since the ns can reach any network with host
- add a default gateway

ip netns exec blue ip route add default via 192.168.15.5

ip netns exec blue ping 8.8.8.8  - good!

## outside world to ns

ping 192.168.15.2
- not reacheable

## solution
 Two options
- port forwarding roles 
- expose the private addr identity of the ns to the host route table

ist option is the right way

## any traffic coming on port 80 on the local host to be forwarded to port 80 of the ns
iptables -t nat -A PREPOUTING --dport 80 --to-destination 192.168.15.2:80 -j DNAT 







While testing the Network Namespaces, if you come across issues
where you can't ping one namespace from the other, make sure you set the NETMASK while setting IP Address. ie: 192.168.1.10/24

ip -n red addr add 192.168.1.10/24 dev veth-red Another thing to check is FirewallD/IP Table rules.

Either add rules to IP Tables to allow traffic from one namespace to another. Or disable IP Tables all together (Only in a learning environment).
```

## Docker Networking

```yaml
## 1 no network - docker cannot nreach the outisde world and vice-versa 
docker run --network none nginx 


## 2 host network
- container is attached to the host network
- if you deploy a web app on port 80, then the app is available on port 80 on the host

docker run --network host nginx 

## if you try and rerun because it wont work, two process cannot share the same port at the same time

## 3 Bridge network - An internal private network which the docker host and container attach to

docker network ls
bridge

// but on the host, same bridge network is refereed to as docker0
ip link

## get the ns of the container 
docker inspect <networkid>

## on host 
ip link

ip -n <ns id/container network id> link

## external users need ton access the docker container
- use port mapping
- users can access port 80 of the container through the port 8080 on the host 
docker run -p 8080:80 nginx

curl http://192.168.1.10:8080


iptables -nvL -t nat 
```

## Cluster Networking 

```yaml

## Important commands
- ip link
- ip addr
- ip addr add 192.168.1.0/24 dev eth0
- ip route
- ip route add 192.168.1.0/24 via 192.168.2.1
- cat /proc/sys/net/ipv4/ip_forward
- arp
- netstat -plnt
-netstat --help

## K8 consist of master and worker nodes
- Each nodes should have at least one interface connected to a network  with IP addr
- The host should have ubique histname set and a unique mac address 
##  search for numeruc, programs, listening, -i - not case sensitive 

netstat -npl | grep -i scheduler

netstat -npa | grep -i etcd | grep -i 2379 | wc -1

## An important tip about deploying Network Addons in a Kubernetes cluster.

In the upcoming labs, we will work with Network Addons. This includes installing a network plugin in the cluster. While we have used weave-net as an example, please bear in mind that you can use any of the plugins which are described here:

https://kubernetes.io/docs/concepts/cluster-administration/addons/

https://kubernetes.io/docs/concepts/cluster-administration/networking/#how-to-implement-the-kubernetes-networking-model

In the CKA exam, for a question that requires you to deploy a network addon, unless specifically directed, you may use any of the solutions described in the link above.

However, the documentation currently does not contain a direct reference to the exact command to be used to deploy a third-party network addon.

The links above redirect to third-party/ vendor sites or GitHub repositories, which cannot be used in the exam. This has been intentionally done to keep the content in the Kubernetes documentation vendor-neutral.

Note: In the official exam, all essential CNI deployment details will be provided


## exercise

## Question

- What is the network interface configured for cluster connectivity on the controlplane node?

- node-to-node communication

ip a | grep -B2 192.23.97.3

- ip a lists all network interfaces and their IP addresses.
- grep -B2 searches for the string 192.23.97.3 and displays 2 lines before the match.

eth0@if25557: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1450 qdisc noqueue state UP group default 
    link/ether 02:42:c0:17:61:03 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 192.23.97.3/24 brd 192.23.97.255 scope global eth0


- ip show route default 

## What is the port the kube-scheduler is listening on in the controlplane node?
netstat -nplt


## Notice that ETCD is listening on two ports. Which of these have more client connections established?

netstat -anp | grep etcd | grep 2380 | wc -l


## show ip of an interface
ip address show eth0

## show all the bridge interface

ip address show type bridge

## Ques: We use Containerd as our container runtime. What is the interface/bridge created by Containerd on the controlplane node?
- When using Containerd as the container runtime on a Kubernetes control plane node,
- the default interface/bridge created by Containerd is typically called cni0.
- This bridge is managed by the Container Network Interface (CNI) plugins, which Containerd relies on for network connectivity.

- The cni0 bridge connects the various containers running on the node,
- allowing them to communicate with each other and with external networks,
- based on the CNI plugin configuration you're using (e.g., Calico, Flannel).
## Check for CNI bridge using network namespaces
ip nets
```
## Pod Networking 
<img src="https://github.com/sheyijojo/kubernetes_CKA_Exams/blob/main/pdfs/network-1.png?raw=true" alt="Description" width="800">

```yaml
## k8 Networking Model
- Every pod should have an IP Address
- Every pod should be able to talk with every other pod in the same node
- Every pod should be able to talk with every other Pod on other nodes without NAT

## CNI
- CNI helps run script on each pod created automatically
- E.g a cript that helps add IP addr and ns , and connects pods to the route network 

## Container Runtime
- A container runtime on each nodes is responbisible for  creating container
- Container runtime then looks at the CNI configuration and looks for the script I created
- /etc/cni/net.d/net-script.conflist
- Then looks at the bin directory /opt/cni/bin/net-script.sh , and esecutes the script  
```
## CNI in Kubernetes 
```yaml
- In k8, the container plugins are installed  in :
ls /opt/cni/bin

- which plugin to be used is stored here
/etc/cni/net.d/ 
```

## CNI Weave
- Solution based on CNI Weaveworks
```yaml
kubectl apply -f https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml


- so CNI plugin is deployed on the cluster
- It deploys an gent or service on each node
-The communcate with each other to exchange information.
- Waeve makes ure PODS have the correct route configured to reach the agent
- The agent takes of other PODS 


## DEPLOYING WEAVES ON A CLUSTER

- WEAVE and weave peeers can be deployed as services or daemons on each node in d cluster mannaully or deploy as pods in cluster

kubectl get pods -n kube-system

kubectl logs weave-net-59cmb waeve -n kube-system

## questions

## Inspect the kubelet service and identify the container runtime endpoint value is set for Kubernetes.
ps aux | grep -i kubelet | grep containerd

ps aux | grep -i kubelet | grep container-runtime 
```

## Plugin for IP Management - IPAM
```yaml
## CNI outsourced IP management to DHCP and host-local


## questions

## What is the default gateway configured on the PODs scheduled on node01?

- Try scheduling a pod on node01 and check ip route output

ssh node01

ip route

- on control plane
- spec
    nodeName: node01
kubectl run busybox --dry-run=client -o yaml -- sleep 1000 > busybox.yaml
## What POD OP addr range configured on weave

- check the pod logs of the weave agent
- look for ipalloc

kubcetl logs -n kube-system weave-nt-mknr5

kubectl exec busybox -- ip route 
```

## Service Networking 
```YAML
- You will rarely configure pods to talk with each other, you will usually use a SERVICE. 
##When a service is created, it is accessible on all pods on the cluster
- a service is hosted accross a cluster, not bound to a specific node

- a service accesible ONLY within the cluster is known as clusterIp, gets an IP addr attached to it

## Nodeport service
- can expose app on a pods externally on all nodes on the cluster, gets an IP Addr


## How is the service made available to external users through a port on each node
- Generally, we know every node run a kunelet process which is responsible for creating PODS.
- Same kubelet invokes CNI plugging to configure networking for that POD.
- Each node also runs another component known as kube-proxy which gets into action wheneneve a service is created.
- services are not created on each node or assigned to each node, they are a cluster-wide concept.
- Service is just a virtual object


## set kube proxy mode - ways in which kube-proxy creates forwarding rules to forward requests from service to pods..

kube-proxy --proxy-mode [userspace | iptables | ipvs] ...

kubectl get service


## overlapping of IPS

- Make sure a pod and a service IP should not overlap

##  get the service cluster ip range assigned to service when created.

kube-api-server --service-cluster-ip-range ipNet

ps aux | grep kube-api-server

## See the rules created by kube-proxy

iptables -L -t nat | grep db-service

## See these rules also in kube-proxy logs 
cat /var/log/kube-proxy.log

## What network range are the nodes in the cluster part of?
- one way to do this is to make use of the ipcalc utility. If it is not installed, you can install it by running:
- apt update and the apt install ipcalc
-  ip a | grep eth0
- ipcalc -b 10.33.39.8



## What is the range of IP addresses configured for PODs on this cluster?


The network is configured with weave. Check the weave pods logs using the command
-  kubectl logs <weave-pod-name> weave -n kube-system and look for ipalloc-range.
-  k logs -n kube-system weave-net-lfq2s | ipalloc-range

## What is the IP Range configured for the services within the cluster?
cat /etc/kubernetes/manifests/kube-apiserver.yaml   | grep cluster-ip-range

## What type of proxy is the kube-proxy configured to use?

Check the logs of the kube-proxy pods. Run the command: kubectl logs <kube-proxy-pod-name> -n kube-system

k logs kube-proxy-ltbmp  -n kube-system | grep kube-proxy

## General commands

kubectl get all --all-namespaces 

```

## DNS in Kubernetes 
- k8 deploys a built-in DNS server by default when you set up the cluster 
- If you set it up manually, then you have to build it yourself
- How DNS help Pods resolve each other
- Focus is purely on PODs and services within the cluster.
- Whenever the service is created, DNS creates a record and mapping its IP to the DNS
  
```yaml
## can reach a webserver from a pod within the same namespace
curl http://web-service

## Different namespace for the service called apps(lets assume),
curl http://web-service.apps

## all services are further grouped together into another subdomain called svc created by DNS
curl http://web-service.apps.svc


## How services are resolved within the cluster

## FQDN for svc- all services and PODS are groupeed togther into a troot domain for the cluster, which is cluster.local by default 
curl http://web-service.apps.svc.cluster.local


## for pods
k8 replaces the ip wuth dashes
```

## CORE DNS in Kubernetes
Every time a pod or service is created it adds a record for it in its database

```yaml
- Get Information on the root domain of the cluster in the ConfigMap object 
DNS server maps IP address to services but not the same approach to PODs

- For pods it forms hostname by replacing the dots in IP with dashes. it maps ip with pp-dashes
10-244-2-5   10.244.2.5

Recommended DNS server is CoreDNS
- The coreDNS server is deployed as a pod in the kube-system namespace in the k8 kluster - Deployed as two pods for redundancy,

as part of a replicaset.
- This POD runs the coredns EXECUTABLE.
- k8 uses a file called corefile  `cat /etc/coredns/corefile`, which has a number of plugins configured
- the corefile is passed into the pod has a configMap object. 

##  How does pod point to the dns SERVER, what address does the pod use to point to 
- when the dns is deployed, it also creates a service to make it available to other components within a cluster
- The service is known as kube-dns by default. Ip addr of this service is configured as the nameserver on pods automatically by k8- kubelet

## What is the name of the ConfigMap object created for Corefile?

k get configmaps -n kube-system

ans - coredns

root domain - cluster.local


## What name can be used to access the hr web server from the test Application?
## You can execute a curl command on the test pod to test.
## Alternatively, the test Application also has a UI. Access it using the tab at the top of your terminal named test-app.

k get svc
k describe
- check for the Selector that indicates hr




## Where is the configuration file located for configuring the CoreDNS service?
 kubectl -n kube-system describe deployments.apps coredns | grep -A2 Args | grep Corefile


## edit and deploy 
k edit deploy webapp


## From the hr pod nslookup the mysql service and redirect the output to a file /root/CKA/nslookup.out

 k exec -it hr -- nslookup mysql.payroll > /root/CKA/nslookup.out
```
## Ingress in Kubernetes 
```yaml
## You have load balancers provisioned on google cloud
- load balancer is sitting in front of your servcies
- How do you direct traffic from different load balancers, manage ssl certs, firewall rules
- What service does that? A configuration in k8 that manages all the configurations mentioned and many more
- INGRESS is the solution
- Ingress helps users access app using a sigle externaly url
- More like a layer7 Load Balancer that can configured using k8 objects
- Need to publish ingress as a service such as nodepotrt. oNE TIME configuration

## You could configure this withougt Ingress
cOULD USE REVERSE PROXY SUCH AS NGINX, haproxy, TRAEFIK, GCP HTTP(S) Load balancer (GCE), Contour, Istio

## They are also the Ingress controller
- ingress does this in a similar way, with a supported solution like above
- solution doeloyed is known as ingress controller
- Set of Rules you configure  is known as inGRESS RESOURCES, done by using a deifnition file

- k8 cluster does not come with INgress controller by default

## decouples configuration using config map when using example NGINX controller 

## steps
- create ingress controller
- create config map
- Cretae service account role and rolebinding  to access all these objects
- create a service of e.g Nodeport

## create INGRESS resource
- More about routing traffic and whataview

## Use rules when you wanna route traffic on diff conditions
- host field diffentiates a yaml file with multiple domain names and a single domain name 
So there are two paths
1. Splitting traffic by urls with one rule, and split the traffic in two paths
2. Splitting traffic by hostname, use two rules and one path

```
## Ingress Resource


<img src="https://github.com/sheyijojo/kubernetes_CKA_Exams/blob/main/pdfs/ingress-resource.png?raw=true" alt="Description" width="800">

```yaml

## Format 
kubectl create ingress  --rule="host/path=service:port"**

kubectl create ingress ingress-test --rule="wear.my-online-store.com/wear*=wear-service:80"**

```
**Different Controllers Options**
- Different ingress controllers have different options that can be used to customise the way it works. 
- NGINX Ingress controller has many options that can be seen here.
- one such option that we will use in our labs. The Rewrite target option.
```yaml

Two apps - watch and wear app displays at http://:/
- Confure ingress to achieve the below
   - http://:/watch -> http://:/
   - http://:/wear -> http://:/

- When user visits the url on /watch, /wear jis request should be forwarded internally to the http://:/
- /watch and /waer path are what is configured on the ingress controller
- so that we can forward users to the appropriate app in the backend. The app doesnt  have this url/path configured on them.

  without the rewrite-tareg option, this is what happens:

- http://:/watch –> http://:/watch

- http://:/wear –> http://:/wear


- Notice watch and wear at the end of the target URLs. The target applications are not configured with /watch or /wear paths.
- They are different applications built specifically for their purpose,
- so they don’t expect /watch or /wear in the URLs.
- And as such the requests would fail and throw a 404 not found error.

To fix that we want to “ReWrite” the URL when the request is passed on to the watch or wear applications.
 We don’t want to pass in the same path that user typed in. So we specify the rewrite-target option.
This rewrites the URL by replacing whatever is under rules->http->paths->path
which happens to be /pay in this case with the value in rewrite-target. This works just like a search and replace function.

##

apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: test-ingress
  namespace: critical-space
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - http:
      paths:
      - path: /pay
        backend:
          serviceName: pay-service
          servicePort: 8282
 


- For example: replace(path, rewrite-target)

- In our case: replace("/path","/")




## In another example given here, this could also be:
- replace("/something(/|$)(.*)", "/$2")



apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /$2
  name: rewrite
  namespace: default
spec:
  rules:
  - host: rewrite.bar.com
    http:
      paths:
      - backend:
          serviceName: http-svc
          servicePort: 80
        path: /something(/|$)(.*)
``
## Questions 
```

## Ingress steps

<img src="https://github.com/sheyijojo/kubernetes_CKA_Exams/blob/main/pdfs/ingress-steps.png?raw=true" alt="Description" width="800">
## Which namespace is the Ingress Resource deployed in?
```yaml

kubectl get ingress --all-namespaces

## Ingress resources documentation
https://kubernetes.github.io/ingress-nginx/examples/rewrite/


k get pods -A

## create an in  gress
kubectl create ingress myingress -n critical-space --rule="/pay=pay-service:8282"

k get ingress -n critical-space

k logs <podname> -n <namespace-name>


## namespace
kubectl create namespace my-namespace

##
The NGINX Ingress Controller requires a ConfigMap object.

## Create a ConfigMap object with name ingress-nginx-controller in the ingress-nginx namespace.

k create configmap ingress-nginx-controller -n ingress-nginx

## The NGINX Ingress Controller requires two ServiceAccounts.
## Create both ServiceAccount with name ingress-nginx and ingress-nginx-admission in the ingress-nginx namespace.


k create serviceaccount ingress-nginx -n ingress-nginx

k create serviceaccount nginx-admission -n ingress-nginx

## We have created the Roles, RoleBindings, ClusterRoles, and ClusterRoleBindings for the ServiceAccount. Check it out!!

k get roles -n nameofsapce
```
