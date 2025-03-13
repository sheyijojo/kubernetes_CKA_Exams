## Here’s a tip!

- **As you might have seen already, creating and editing YAML files is a bit difficult, especially in the CLI.**
- **During the exam, you might find it difficult to copy and paste YAML files from the browser to the terminal.**
- **Using the kubectl run command can help in generating a YAML template. And sometimes, you can even get away with just the kubectl run command without having to create a YAML file at all.**
- **For example, if you were asked to create a pod or deployment with a specific name and image, you can simply run the kubectl run command.**

- **Use the below set of commands and try the previous practice tests again, but this time, try to use the below commands instead of YAML files. Try to use these as much as you can going forward in all exercises.**

- **Reference (Bookmark this page for the exam. It will be very handy):**

`https://kubernetes.io/docs/reference/kubectl/conventions/`

## ETCD

```yaml
- ETCD binaries is downloaded and is stored on port 2379 by default:
- ETCD is a distributed reliable key-value store that is simple, secure and fast:
- ETCD is a key-value pair form of database:

The default client is the .etcdctl:
./etcdctl

check version with version 3 or 2:
./etcdctl  --version

API version set:
export ETCDCTL_API=3

Set a value:
./etcdctl put key1 value1

./etcdctl get key1:
key1
value1

If you deployed ETCD yourself from scratch:
- Take note of this option passed in the etcd.service:

This is the address the etcd listens to, Ip of the master node:
--advertise-client-urls https://${INTERNAL_IP} \\

- You need the url configured in the kube-api server when it tries to reach the etcd server

If you use kubeadm to deploy your cluster:
- kubeadm deploys the ETCD server for you as a POD in the kubesystem NS


list all keys in the etcd server o the master node:

kubectl exec etcd-master -n kube-system etcdctl get / --prefix -keys-only

The k8 way of storing data in a dir structure:
root dir - registry

registry has these under it:
   - minions/nodes
   - pods
   - replicasets
   - deployments
   - roles
   - secrets

/registry/apiregistration.k8s.io/apiservices/v1.

In PROD, Etcd is in HA:
- ETCD instances must know how to talk with each other across multiple master nodes
- specify the diff instances in the:

--initial-cluster controller-0=https://${CONTROLLER0_IP},controller-1=https://${CONTROLLER1_IP}:2380 \\

```

## ETCD Server API and ETCD CLI

```yaml
Additional information about ETCDCTL Utility ETCDCTL is the CLI tool used to interact with ETCD:

- ETCDCTL can interact with ETCD Server using 2 API versions – Version 2 and Version 3.

ETCD AUTH:
- you must also specify the path to certificate files so that ETCDCTL can authenticate to the ETCD API Server.
-  The certificate files are available in the etcd-master at the following path.

--cacert /etc/kubernetes/pki/etcd/ca.crt
--cert /etc/kubernetes/pki/etcd/server.crt
--key /etc/kubernetes/pki/etcd/server.key


kubectl exec etcd-controlplane -n kube-system -- sh -c "ETCDCTL_API=3 etcdctl get / --prefix --keys-only --limit=10 --cacert /etc/kubernetes/pki/etcd/ca.crt --cert /etc/kubernetes/pki/etcd/server.crt --key /etc/kubernetes/pki/etcd/server.key"

kubeapiserver connects with the etcd server:

--etcd-servers=https://127.0.0.1:2379 \\


If the kube-api server is bootstrapped using kubeadm:
find it at :
cat /etc/kubernetes/manifests/kube-apiserver.yaml


Non-kubeadm set up , find the kubeapi server at the:

cat /etc/systemd/system/kube-apiserver.service

ps -aux | grep kube-apiserver
```

## Kube-API Server

```yaml

## Information on kubeapi is not needed when using kubeadm to bootstrap the installation
- You do not need in
## But you do if have to set it up from scratch:

know this options:
specifying auth for etcd and kubelet within the kubeapiserver:

--etcd-cafile=/var/lib/kubernetes/ca.pem  \\
--etcd-certfile=/var/lib/kuberntes/kubernetes.pem \\
--etcd-keyfile=/var/lib/kubernetes/kubernetes-key.pem

--kubelet-certifcate-authority=/var/lib/kubernetes/ca.pem
--kubelet-client-certificate=/var/lib/kubernetes/kubernetes.pem \\
--kubelet-client-key=/var/lib/kubernetes/kubernetes-key.pem \\
--kubelet-https=true \\
```

## Kube- controller manager

```yaml
watches for the components in the system, and brings the system to the desired functioning state
- manages different controllers:
- watch Status on ships:
- Remediate situation

Controllers:
- Node controller - checks node status for every 5secs
   - Node Monitor Period = 5s
   - Node monitor Grace Period = 40s
   - POD Eviction Timeout = 5m
- Replication controller
- Namespace controller
- Deployment controller
- stateful-set and many more

All these processes are packages inside the kube-controller-manager:
- run as a service if installing from scratch
- you can add the --node-monitor-period=5s options and the rest

You can also add the --controllers flag to activate which controllers to use:
- IF controllers have problem, this is where to look


kubeadm and Non-Kubeadm setup:
- kubeadm setup : /etc/kubernetes/manifests/kube-controller-manager

- non-kubeadm-setup: /etc/systemd/system/kube-controller-manager.service

```

## Kube Scheduler

```yaml
- Responsible for scheduling pods on nodes:
- Decides which pods goes on which nodes:
- It does not actually place the pods on the nodes, thats a KUBELET JOB:
- kubelet is the captain of the ship :

There are many ships with diff sizes, and containers have different workload requirements:

It is important to know what nodes can the pods be scheduled for its destination:

Uses a priority function to see which resources are left like cpu  when the pods has been placed on them

components in kube scheduler
- Resource Requirements and Limits
- Taints and tolerations
- Node Selectors/Affinity
```

## Kubelet

kubescheduler << apiserver << kubelet

```yaml
Captain of the ship:
- They lead all activities on a ship
- Sole point of contact for the master ship
- They load and unload containers on the nodes as instructed by kubescheduler:

Kubelet in the k8 worker nodes:
- registers the node with the k8 cluster
- kubelet talks to the cointainer enginer to pull an image
- kubelet monitors the state of the pods
- reports it to the kube-api server on a timely basis

install kubelet:
kubeadm tool: It does not deploy the kubelet:
Have to install it manually on worker nodes :

same with it from scratch:

can be bootstraped
```

## KubeProxy

```yaml
Every pod can reach other pod because of a networking solution:

- pod network is an internal network that span accross all the nodes in the cluster:
- To which all pods connect to

- Services are used for communication among pods
   - it is not a container, it is virtual components in the k8 memory
   - It uses kube-proxy:
kube proxy is a process that runs on each node in a cluster:
  - looks for new services
  - creates rules on each nodes to forward traffic to svcs to backend port
  - uses ip table rules

installation
kubeadm:
  - runs a pod in the kube-system ns:
  - Infact runs a Daemonset, A single pod is always deployed on each node in the cluster:
service:
  - download the binaries:

kubectl get daemonset -n kube-system


Done with the highlevel Master Components:
```

## Kubectl Pods

```yaml
Create an NGINX Pod:

kubectl run nginx --image=nginx

Generate POD Manifest YAML file (-o yaml). Don’t create it(–dry-run)

kubectl run nginx --image=nginx --dry-run=client -o yaml


kubectl apply -f pod.yaml

kuubectl create -f pod.yaml

Create a deployment:
kubectl create deployment --image=nginx nginx


Generate Deployment YAML file (-o yaml). Don’t create it(–dry-run):
kubectl create deployment --image=nginx nginx --dry-run=client -o yaml


Generate Deployment YAML file (-o yaml). Don’t create it(–dry-run) and save it to a file:

kubectl create deployment --image=nginx nginx --dry-run=client -o yaml > nginx-deployment.yaml


Make necessary changes to the file (for example, adding more replicas) and then create the deployment:

kubectl create -f nginx-deployment.yaml


kubectl create deployment httpd-frontend --image=httpd:2.4-alpine --replicas=3
```

**OR**

```yaml

In k8s version 1.19+, we can specify the –replicas option to create a deployment with 4 replicas:

kubectl create deployment --image=nginx nginx --replicas=4 --dry-run=client -o yaml > nginx-deployment.yaml
```

## ReplicaSet

```yaml

Replicaset is the older tech, Replicaset is a little different.
Role of ReplicaSet is to create multiple instances of a pod
We have the ReplicationController and Replicaset:
- Multiple pods to share the loads among them
- Ensures a number of pods are available
- RC spans across multiple nodes in the cluster

RC- v1
ReplicaSet - apps/v1
Spec:
  replicas: 3
  selector:
     matchLables:
         type: front-end  ## gotten from Replicaset metadata

scaling a replica from 3 to 6:
- edit the replica-definition-file
- edit the replicas to 6

kubectl replace -f replicaset-definition.yaml

run scale, but the num of replicas remain the same inside the file:
kubectl scale --replicas=6 -f replicaset-definition.yaml

k scale --replicas=5 replicaset new-replica-set
```

```yaml
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: replicaset-2

spec:
  replicas: 2
  selector:
    matchLabels:
      tier: nginx
  template:
    metadata:
      labels:
        tier: nginx
    spec:
      containers:
        - name: nginx
          image: nginx
```

## Deployments

```yaml
Deploying in a production env :
Comes higher in the heriarachy
- Upgrade instances seamlessly:
   - Rolling updates
   - Blue-Green:?

similar to the ReplicaSet definition file:

Deployment produces replicas from its specification in the name of the deployments:

Deployment also produces pods in the name of the deployment


kubectl run nginx --image=nginx --dry-run=client -o yaml

kubectl create deployment --image=nginx nginx

kubectl create deployment --image=nginx nginx --dry-run=client -o yaml

kubectl create deployment --image=nginx nginx --dry-run=client -o yaml > nginx-deployment.yaml


```

## Kubernetes services

```yaml
- k8 services Helps us connect apps together with other apps or users:
- services enable loose coupling between microservices in our app:
- k8 svc is just an object just like pod or rs
- Nodeport listens to a port on the node forwards requests to the pods


Create a service:

kubectl create service nodeport <service-name> --tcp=<port>:<target-port> -o yaml > service-definition-1.yaml

kubectl create service nodeport my-service --tcp=80:80 -o yaml > service-definition-1.yaml

kubectl create service nodeport webapp-service --tcp=30080:8080 -o yaml > service-definition-1.yaml

kubectl create deployment --image=nginx nginx --replicas=4 --dry-run=client -o yaml > nginx-deployment.yaml


Target port:
- port on the Pod
e.g 80
Port:
- Port of the service
e.g 80
NodePort: 30000 - 32767
- Port on the node

curl the svc:
curl http://192.168.1.2:30008
```

## sample service with declarative model

```yaml
apiVersion: v1
kind: Service
metadata:
  name: webapp-service
  namespace: default
spec:
  type: Nodeport
  ports:
    - targetPort: 80
      port: 80
      nodePort: 30008
  selector:
    app: myapp
    type: front-end
```

## ClusterIP

```yaml
- Services or tiers of apps need to establish connectivity:
- pods have ip addr but are not static:
- frontend app might need to connect to multiple backend redis:
- A svc is needed for an interface to grp these grp of pods of the backend:
- This is known as a cluster IP:

Use a definition file with kind: Service

apiVersion: v1
kind: Service
metadata
   name: back-end
spec:
   type: ClusterIP
   ports:
     - targetPort: 80
       port: 80
   selector:
     app: myapp
     type: back-end

targetPort - port where the backend is exposed:

port - where the service is exposed:


create clusterip service:
kubectl create service clusterip redis-service --tcp=6379:6379

kubectl create service clusterip redis-service --tcp=6379

kubectl run custom-nginx --image=nginx --port=8080
```

## LoadBalancer Service

```yaml
- Need a loadbalancer service to be configured for only supported cloud platform load balancers
```

## Namespaces

```yaml
- In Kubernetes, namespaces provide a mechanism for isolating groups of resources within a single cluster:
- Names of resources need to be unique within a namespace, but not across namespaces:
- Namespace-based scoping is applicable only for namespaced objects:
- (e.g. Deployments, Services, etc.) and not for cluster-wide objects (e.g. StorageClass, Nodes, PersistentVolumes, etc.):

Connect to a db-service in a ns called "dev"
- mysql.connect("db-service")

DNS:
- mysql.connect("db-service.dev.svc.cluster.local")

cluster.local: domain
svc : service
dev : Namespace
db-service : Service Name

set the context of a ns:
- kubectl config set-context $(kubectl config current-context) --namespace=dev

Namespace Operations:
Can specify Namespace under the metadata section: name: dev
kubectl run redis --image=redis --namespace=finance

kubectl get pods --namespace=research

kubectl get pods -n=researchnamespace

kubectl get pods --all-namespaces

kubectl get pods -A

kubectl run redis --image=redis:alpine --labels=tier=db

create namespace(ns):
kubectl create ns dev-ns

Limit Resource in a ns:
- create a resource quota in yaml file under spec
kind: ResourceQuota
metadata:
   name: compute-quota
   namespace: dev
spec:
   hard:
     pods: "10"
     requests.cpu: "4"
     requests.memory: 5Gi
     limits.cpu: "10"
     limits.memory: 10Gi


Commands under lab tasks:

kubectl get ns --no-headers | wc -l
OR:

kubectl get ns | tail -n +2 | grep "" | wc -l

k get pods -n research --no-headers | wc -l
```

## Imperative commands

```yaml
kubectl create deployment nginx --port 80

kubectl edit deployment nginx

kubectl scale deployment nginx --replicas=5

kubectl set image deployment nginx nginx=nginx:1.18

kubectl replace -f nginx.yaml

To track changes of local yaml file use this:

kubectl replace -f nginx.yaml

completely delete and force changes:
make sure the object exist:

kubectl replace --force -f nginx.yaml

Deploy a redis pod using the redis:alpine image with the labels set to tier=db:
k run redis --image=redis:alpine --labels=tier=db

Create a service redis-service to expose the redis application within the cluster on port 6379:
k expose pod redis --port=6379 --name redis-service


Create a pod called httpd using the image httpd:alpine in the default namespace. Next, create a service of type ClusterIP by the same name (httpd). The target port for the service should be 80:

kubectl run httpd --image=httpd:alpine --port=80 --expose

```

## Declarative

```yaml
create an object if it doesnt exist:
Best approach:

kubectl apply -f nginx.yaml
```

```yaml
Create a new deployment called redis-deploy in the dev-ns namespace with the redis image. It should have 2 replicas.:

Use imperative commands:.

kubectl create deployment redis-deploy --image=redis --replicas=2 --namespace=dev-ns

kubectl expose pod httpd --port 80
```

## Scheduling: nodeport for manual scheduling

```yaml
You do not want to rely on the built-in scheduler:

nodeName is added by default in pods:

apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  containers:
    - image: nginx
      name: nginx
  nodeName: node01 # Replace with the name of the node you want to schedule the pod on
```

## Labels and Selectors

```yaml
Labels and selectors are standard ways to group things together like objects, pods, etc. :

apiVersion: v1
kind: Pod
metadata:
   name: simple-app
   labels:
      app: App1
      function: Front-end



can also match this in a Replicaset:
    - to connect the replicaset to the pod:
    - configure the selector field under the replicaset to match the labels defined on the Pod:
    -  could use single labels or mutliple:

apiVersion: apps/v1
kind: ReplicaSet
metadata:
   name: simple-webapp
   labels:
     app: App1
     function: Front-end
   ## can add annotations as well
   annotations:
      buildversion: 1.34
spec:
   replicas: 3
   selector:
     matchLabels:
        app: App1

   template:
     metadata:
       labels:
         app: App1
         function: Front-end
     spec:
       containers:
       - name: simple-webapp
         image: simple-webapp

properties attached to each item is by labels :
check if the scheduler is running in namesystem:
selectors help you filter:

kubectl get pods -n kube-system

Instead of deleting a pod, you can replace:
kubectl replace --force -f nginx.yaml

kubectl get pods --watch


If I do not know the label name:
k get pods --show-labels=True


get a pod name with the selector to get the label:
select the pods with the label:

kubectl get pods --selector app=App1
k get pods --selector env=dev | wc -l


kubectl get pods --selector app=App1
kubectl get pods --selector app=App1  --no-headers | wc -l
kubectl get pods --selector env=dev

get all objects in an env:

kubectl get all --selector env=prod
k get all --selector env=prod --no-headers | wc -l


get all pods in different env:
`kubectl get pods -l 'env in (prod,finance,frontend)`

Identify the POD which is part of the prod environment, the finance BU and of frontend tier?:
kubectl get pods -l env=prod,bu=finance,tier=frontend

OR

kubectl get all --selector env=prod,bu=finance,tier=frontend

```

## Taints and Tolerance

```yaml
Taints and toleration are used to set restrictions on what pods can be scheduled on a node:

Prevent a pods from being placed on a node by placing a taint on the Node. e.g taint=blue:

Allow a pod to be placed on a node by allowing a toleration on the pod:

Taints and Toleration:
- This is a pod to node relationship, what pods can be placed on the node:
    - Taints are set on Nodes:
    - Toleration are set on pods:

kubectl taint nodes <node-name> key=value:taint-effect

kubectl taint nodes node1 app=blue:NoSchedule

There are three taint-effect:
NoSchedule | PreferNoSchedule | NoExecute

Tolerations are added to pods in the pod definition file:
spec:
   containers"
   - name: nginx-container
     image: nginx
   tolerations:
   - key: "app"
     operator: "Equal"
     value: "blue"
     effect: "NoSchedule"

## Notes on pods
There is another concept called Node Affinity- Discussed lated:
  - Pods can still be placed on Nodes without any taint even the pods has a toleration
  - Node Affinity is what sticks the pod to specific nodes and cannot be placed on any other node



check the taint deployed automatically on master node:
kubectl describe node kubemaster | grep Taint

Remove taint from a node:
kubectl taint nodes controlplane example-key:NoSchedule-

kubectl taint nodes controlplane node-role.kubernetes.io/control-plane:NoSchedule-

Create a pod in yaml but do not run:
kubectl run nginx --image=nginx --dry-run=client -o yaml > bee.yaml

get more information like nodes from this command:
kubectl get pods -o wide


```

## Node Selector

```yaml
Different kind of workloads run in my cluster, would like to dedicate pods to that node:
1. Set limitation on the pod:
   -  You must have first labelled your nodes
spec:
   containers:
   - name: data-processor
     image: data-processor
   nodeSelector:
     size: Large

Label a Node for NodeSelector section:
kubectl label nodes <node-name> <label-key>=<label-value>

kubectl label nodes node-1 size=Large

kubectl label nodes node01 color=blue

```

## Node Affinity

```yaml
Node Affinity and Antiffinity is better and address complex needs, spec affinity should be under pods not Deployment:


apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  containers:
  - name: data-processor
    image: data-processor
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


Node Affinity Types:

What if someone changes the label on the node, and the pod does not have a node to be scheduled on
- requiredDuringSchedulingIgnoredDuringExecution:
- preferredDuringSchedulingRequiredDuringExecution:

There are two stages when considering Node Affinity:
- DuringScheduling -  state where a pod does not exist, is creating the first time
                      - if required during scheduling, and the node label is missing, pod will not be scheduled
                      - if preffered, and label is missing, scheduler will ignore node affinity rule, and place it on node anywhere

- DuringExecution -  state pod is running and a change is made in the env that affects node affinity.
By default, DuringExecution is set to default.
```

## Dry run

```yaml
kubectl create deployment red --replicas=2 --image=nginx --dry-run=client -o yaml > sample.yaml

kubectl create deployment red --replicas=2 --image=nginx -o yaml > sample.yaml
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

A combination of NodeAffinity and Taints & Toleration:
Use taint & tolerations to prevent other pods to be placed on a node:
Use Node Affinity to prevent our pods from being placed on their node

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

A container cannot use more cpu above its limits:

This is not the same as memory, the pod will be terminated if it overshoots OOM:
```

## Daemonsets

```yaml
Daemonsets are like replicasets, but it runs one copy of your pod on each node in your cluster:

Whenever a new node is added to the cluster a replica of the pod is automatically added to that node:

Use cases:

1. Monitoring solution
2. Logs viewer
3. Kube Proxy
4. weave-net(Networking solution)


example:

apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: elasticsearch
  namespace: kube-system
  labels:
    app: shey
spec:
  selector:
    matchLabels:
      app: shey
  template:
    metadata:
      labels:
        app: shey
    spec:
      tolerations:
      containers:
      - name: elasticsearch
        image: registry.k8s.io/fluentd-elasticsearch:1.20

Daemonsets:
kubectl get daemonsets

get DaemonSets in all namespace:
kubectl get daemonsets -A

Namespace continued:
kubectl describe daemonsets kube-proxy -n kube-system

Daemonsets shortcut:
kubectl describe ds kube-flannel-ds -n kube-system

copy from the documentation or use deployment dry run and change it:
kubectl create deployment elasticsearch -n kube-system --image=myimage --dry-run=client -o yaml

No replicas:
change the image name:

kubectl create -f fluendt.yaml

kubectl get ds -n kube-system
```

## static pods contd

```yaml
Static pods are pods that are created by the kubelet on its own without the intervention from the API server

The kubelet creates a static pod using the commands:

 --pod-manifest-path=/etc/kubernetes/manifests` in the kubelet.service:

Can also use --config=kubeconfig.yaml

kubeconfig.yaml:
staticPodPath:  /etc/kubernetes/manifest

check for the static pods using:

docker ps

get static pods:
- static pods usually have node name appended to their name, clue to know them
- check for the owner reference session, check the kind and name. The kind should be like a Node. otherwise could be Replicaset, or any other object

another way of getting pod yaml from a running pod:
kubectl get pod name-of-pod -n kube-system -o yaml
kubectl get nodes


find config files in linux:
find /etc -type f -name "*.conf"

How many static pods exist in this cluster in all namespaces:
kubectl get pods -A

path to directory for the static pod:
check the kubelet conf
cat /var/lib/kubelet/config.yaml   ##for any given static pod config

check for static pod path:

```

## configmap as volume for a scheduler

```yml
Let's create a configmap that the new scheduler will employ using the concept of ConfigMap as a volume.:
We have already given a configMap definition file called my-scheduler-configmap.yaml at /root/ path that will create a configmap with name my-scheduler-config using the content of file /root/my-scheduler-config.yaml:


cat my-scheduler-configmap.yaml

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


cat my-scheduler-config.yaml


apiVersion: kubescheduler.config.k8s.io/v1
kind: KubeSchedulerConfiguration
profiles:
  - schedulerName: my-scheduler
leaderElection:
  leaderElect: false



cat my-scheduler.yaml


apiVersion: v1
kind: Pod
metadata:
  labels:
    run: my-scheduler
  name: my-scheduler
  namespace: kube-system
spec:
  serviceAccountName: my-scheduler
  containers:
  - command:
    - /usr/local/bin/kube-scheduler
    - --config=/etc/kubernetes/my-scheduler/my-scheduler-config.yaml
    image: <use-correct-image>
    livenessProbe:
      httpGet:
        path: /healthz
        port: 10259
        scheme: HTTPS
      initialDelaySeconds: 15
    name: kube-second-scheduler
    readinessProbe:
      httpGet:
        path: /healthz
        port: 10259
        scheme: HTTPS
    resources:
      requests:
        cpu: '0.1'
    securityContext:
      privileged: false
    volumeMounts:
      - name: config-volume
        mountPath: /etc/kubernetes/my-scheduler
  hostNetwork: false
  hostPID: false
  volumes:
    - name: config-volume
      configMap:
        name: my-scheduler-config
```

## exercise

```yaml
create a static pod name static-busybox that uses the busy-box image and the command sleep 1000:

kubectl run static-busybox --image=busybox --dry-run=client -o yaml --command -- sleep 1000 > static-busybox.yaml
cp static-busybox.yaml  /etc/kubernetes/manifests/
```

## watch while your pods get deployed:

`kubectl get pods --watch`

## To get nodes in manifest file in another nodes

```yaml
Logging in kubernetes:

You need a monitoring server to be deployed :
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

kubectl top node

kubectl top pod

Must specify the name of the container explicity:
kubectl logs -f event-simulator-pod event-simulator

ssh into the nodes:

kubectl get nodes -o wide

ssh internalipaddr

ls /etc/kubernetes/manifests/

check the kubelet config:
cat /var/lib/kubelet
```

## Debug schedulers

```yaml
kubectl get events -o wide

schedulers logs :
kubectl logs my-custom-scheduler --name-space=kube-system

find an image witing a pod:
kubectl describe pod pod-name -n kube-system | grep Image

```

## Application Lifecycle

```yaml
kubectl logs:
kubectl logs podname

Rollout and versioning in a deployment:
- A first deployment triggers a rollout, a new rollout tiggers a new  deployment revision, called revision 1
- when the app is upgradedded/container version is updated to a new one, a nwe rollout is triggered, a new deployment revision
- called revision 2 is created

See status of deployment(rollout):
kubectl rollout status deployment/myapp-deployment

see history of deployment:
kubectl rollout history deployment/myapp-deployment

Undo a deployment rollout:
kubectl rollout undo deployment/myapp-deployment

create deployments:
kubectl create -f deployment-definiition.yaml

Get Depployment:
kubectl get deployments

update - be careful, it creates a new config:
kubectl apply -f deployment-definition.yaml

deployment status - Deployment files will have diff configs:
kubectl set image deployment/myapp-deployment nginx=nginx:1.9.1

Edit:
kubectl edit deployment frontend

or:

k set image deployment frontend simple-webapp=kodekloud/webapp-color:v2


kubectl get deployments frontend  --watch

k get deploy

k describe deploy frontend


apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
  namespace: default
spec:
  replicas: 4
  selector:
    matchLabels:
      name: webapp
  strategy:
    type: Recreate
  template:
    metadata:
      labels:
        name: webapp
    spec:
      containers:
      - image: kodekloud/webapp-color:v2
        name: simple-webapp
        ports:
        - containerPort: 8080
          protocol: TCP

```

```yaml

Configuring applications comprises understanding the following concepts:

- Configuring Commands and Arguments on applications

- Configuring Environment Variables

- Configuring Secrets


docker:
CMD

SPECIFY DIFFERENT cmd to start a docker:

docker run ubuntu [COMMAND]
docker run ubuntu sleep 5

## Make the change permanent
FROM ubuntu

CMD sleep 5

docker build -t ubuntu-sleepr .

docker run ubuntu-sleeper

## change optionall 5 secs

docker run ubuntu-sleeper 10

ADD ENTRYPOINT IN THE DOCKERFILE, to append additional CLI inout:
FROM Ubuntu

ENTRYPOINT["sleep"]

docker run ubuntu-sleeper 10

Add default value like 5 even if you forget on command line:

FROM Ubuuntu

ENTRYPOINT ["sleep"]

CMD["5"]

docker run ubuntu-sleeper 10

In Kubernetes Pod:
Anything appended to the command goes to the args property in K8


for example:

docker run --name ubuntu-sleeper ubuntu-sleeper 10

entrypoint for dockerfile is sleep
CMD in Dockerfile == ARGS in Kubernetes

to overwrite ENTRYPOINT will be command in Kubernetes

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
        - "sleep"
        - "1200"
```

## Approach for editing

```yaml
kubectl edit pod name-of-the-pod

kubectl replace --force -f /tmp/kuubectl-edit-2623.yaml

kubectl run nginx --image=nginx -- <arg1> <arg2> ... <argN>

k run webapp-green --image=kodekloud/webapp-color --  --color=green

Configure environment variable:
- env is in array

containers:
- name: simpleapp
  image: simpleimage
  ports:
    - containerPort: 8080
  env:
    - name: APP_COLOR
      value: pink

Other ways are configmap
   env:
    - name: APP_COLOR
      valueFrom:
          configMapKeyRef:

secrets:
   env:
    - name: APP_COLOR
      valueFrom:
          secretKeyRef:

```

## Config Map

```yaml

steps:
- create configmap and inject into the pods:


kubectl create configmap  <config-name> --from-literal=<key>=<value>


kubectl create configmap  app-config --from-literal=APP_COLOR=blue \
                                      --from-literal=APP_MOD=prod


kubectl create configmap <config-name> --from-file=<path-to-file>

kubectl get configmaps

Injecting ConfigMap different ways into pods:

1. ## envFrom
containers:
- name: simpe-app
  image: myimage
  envFrom:
    - configMapRef:
        name: app-config
1. ##single env

env:
  - name: APP_COLOR
    valueFrom:
       configMapKeyRef:
           name: app-config
           key: APP_COLOR

3. Volumes:
volumes
- name: app-config-volume
  configMap
    name: app-config



kubectl create configmap webapp-config-map --from-literal=APP_COLOR=darkblue --from-literal=APP_OTHER=disregard

execise:
spec:
  containers:
  - env:
    - name: APP_COLOR
      valueFrom:
            configMapKeyRef:
              name: webapp-config-map           # The ConfigMap this value comes from.
              key: APP_COLOR
```

## Secrets

```yaml
Secrets are stored in encoded format:
-  Create secret and inject it into pod:

kubectl create secret generic db-secret --from-literal=DB_Host=sql01  --from-literal=DB_User=root  --from-literal=DB_password=passw
ord123

kubectl create secret generic

kubectl create secret generic \
app-secret --from-literal=DB_HOST=mysql \
           --from-literal=DB_HOST=root  \
           --from-literal=DB_password=passwrd

kubectl create secret generic <secret-name> --from-file=<path-to-file>

kubectl create secret generic \ app-secret --from-file=app_secret.properties


declarivative:

- kubectl create -f secret-data.yaml

- The data must be in encoded form in secrets. Secrets are encoded but not encrypyted:

- Do not check in secret objects to SCM along with the code:

encrypt ETCD data at rest

on linux:

- echo -n 'mysql' | base64

kubectl get secrets

kubectl describe secrets

get the encoded value:
kubectl get secret app-secret -o yaml


https://www.youtube.com/watch?v=MTnQW9MxnRI:

decode secrets:
echo -n "bXlzcWw' | base64 --decode

logs:
kubectl -n elastic-stack  logs kibana

exec into a pod container:
kubectl -n elastic-stack exec -it app -- cat /log/app.log

passing env into pod:
containers:
   envFrom:
     - secretRef:
            name: app-secret

can also mount as volume
    volumes:
    - name: app-secret-volume
      secret:
         secretName: app-secret

Do not check in your secret objects to SCM:
Secrets are not encrypted at rest by default in ETCD:
```

```yaml
spec:
  containers:
    - name: simpleapp
      image: simpleapp
      ports:
        - containerPort: 8080
      envFrom:
        - secretRef:
            name: app-secret

single env:
env:
  - name: DB_Password
    valueFrom:
      secretkeyRef:
        name: app-secret
        key: DB_Password

## volumes
volumes:
  - name: app-secret-volume
    secret:
      secretName: app-secret
```

## Encrypting a Secret

```yaml
create a generic secret:
kubectl create secret generic my-secret --from-literal=key1=supersecret

get encoded value:
k get secret my-secret -o yaml

data:
  DB_Host: mysql

encode the secret:
echo -n 'mysql' | base64

decode the secret:
echo -n "dsvfasrwefees" | base64 --decode

Focus here in this demo is the data stored in the etcd server:

How secrets are stored in etcd and get the value encrypted :

ETCDCTL_API=3 etcdctl \
   --cacert=/etc/kubernetes/pki/etcd/ca.crt   \
   --cert=/etc/kubernetes/pki/etcd/server.crt \
   --key=/etc/kubernetes/pki/etcd/server.key  \
   get /registry/secrets/default/my-secret | hexdump -C


install the etcd client to query:
apt-get install etcd-client

check if enryption at rest is configured:
 - done by checking the encryption-provider-config:

ps -aux | grep kube-api | grep "encryption-provider-config"

Also check the kube-apiserver.yaml at /etc/kuberntes/manifest:


Activate encryption:
- Create a config file and pass the encryption-provider-config option
vi enc.yaml
apiVersion: apiserver.config.k8s.io/v1
kind: EncryptionConfiguration
resources:
  - resources:
      - secrets
    providers:
      - aescbc:
          keys:
            - name: key1
              # See the following text for more details about the secret value
              secret: sd24309wnassadasd==


---------
create a Base 64 encoded secret:
head -c 32 /dev/urandon | base66

output: sd24309wnassadasd==

mkdir /etc/kubernetes/enc:

mv enc.yaml /etc/kubernetes/enc

cd /etc/kubernetes/manifest/kube-api-server.yaml

add this line:

--encryption-provider-config=/etc/kubernetes/enc/enc.yaml  # add this line

In the volume mount section of kubeapi-server
    volumeMounts:
    - name: enc                           # add this line
      mountPath: /etc/kubernetes/enc      # add this line
      readOnly: true

In the volume section:
  volumes:

  - name: enc                             # add this line
    hostPath:                             # add this line
      path: /etc/kubernetes/enc           # add this line
      type: DirectoryOrCreate


check if encrypted provider is present:

ps aux | grep kube-api| grep encryp

create another secret file literal:

ensure all secrets are ecrypted:
The command reads all Secrets and then updates them to apply server side encryption:

kubectl get secrets --all-namsepaces -o json | kubectl replace -f -
```

## Creating a Multi Container Pod

```yaml
kubectl run yellow --image=busybox --dry-run=client -o yaml --command -- sleep 1000 > mysample.yaml

k get pods -n elastic-stack

k -n elastic-stack logs kibana

Edit the pod in the elastic-stack namespace to add a sidecar container to send logs to Elastic Search:

Mount the log volume to the sidecar container:.

https://kubernetes.io/docs/tasks/access-application-cluster/communicate-containers-same-pod-shared-volume/:

can exec into a runing pod:

k -n elastic-stack exec -it app -- cat /log/app.log

edit pod in a namespace:
k edit pod app -n elastic-stack

```

## Init containers

```yaml
The process running in the log agent container is expected to stay alive as long as the web application is running:
If any of them fail, the POD restarts:

But at times you may want to run a process that runs to completion in a container.:
For example, a process that pulls a code or binary from a repository that will be used by the main web application.:

That's where initContainers comes in. An initContainer is configured in a pod-like all other containers, except that it is specified inside a initContainers section, like this:

apiVersion: v1
kind: Pod
metadata:
  name: myapp-pod
  labels:
    app: myapp
spec:
  containers:
    - name: myapp-container
      image: busybox:1.28
      command: ["sh", "-c", "echo The app is running! && sleep 3600"]
  initContainers:
    - name: init-myservice
      image: busybox
      command: ["sh", "-c", "git clone"]

You can configure multiple such initContainers as well:
like how we did for multi-containers pod.:
In that case, each init container is run one at a time in sequential order.:
```

## Error - pods not valid after editing a pod

```yaml
Run this:

`k edit pod app -n elastic-stack`

`k replace --force -f /tmp/kubectl-edit2222323.yaml`

This will delete the pod and recreate a new one

## Get all information on all pods

`k describe pod`

## An app wuth inti:CrashLoopBackoff

check the logs of pod:

k logs orange

check the logs of the inti container:

k logs orange -c init-myservcie
```

## Os Updates

> When working with workloads on a node

```yaml
Scenario is when working on the nodes for patches, os updates and so on:

If a pod is not part of a replicaSet it does not come back on:



drain workloads of a node to move them to another node:
kubectl drain node-1
k drain --ignore-daemonsets node01

if a pod is not part of a Replicaset: lost forever:
k drain node01 --force --ignore-daemonsets


pods are gracefully terminated , and recreated on another , no pods can be scheduled on this drained node:

The kubectl uncordon command is used to mark a Kubernetes node as schedulable again after it was previously cordone:

mark a node schedulable:
kubectl uncordon node-1

The kubectl cordon command is used to mark a Kubernetes node as unschedulable.:
kubectl cordon node-01


k describe nodes

## Get pods with node details
 k get pods -o wide
```

## Kubernetes Releases and K8 CLuster Upgrade

````yaml

When we install a kubernetes cluster, we install a specific version of k8:
check the version:
k get nodes

major version was v1.0 - 2015
v1.2.0 - 2016 minor
v1.10.0 - 2018
v1.13.0 - 2018

So some controlplane components have the same version, while some dont:

kube-apiserver  controller-manager kube-scheduler kubelet kube-proxy kubectl: v1.13.4 - same version

ETCD CLUSTER: - v3.2.18  COREDNS: - v1.1.3 - different versions


Ideally, None of the components should be at an higher version than the kubeapi server: X

but.......:


controller manager and kube-scheduler can be at one version lower: X-1
kubelet and kube-proxy can be at two version lower: X-2

However, kubectl: X+1 Can be at one version higher than the kube-apiserver



https://kubernetes.io/docs/concepts/overview/kubernetes-api/

Here is a link to Kubernetes documentation if you want to learn more about this topic (You don’t need it for the exam, though):

https://github.com/kubernetes/community/blob/master/contributors/devel/sig-architecture/api-conventions.md

https://github.com/kubernetes/community/blob/master/contributors/devel/sig-architecture/api_changes.md


k8 supports only the last e last 3 minor releases e.g v.13, v.12, v.11:

Upgrade one version at a time:

## cluster version 1 - demp

```yml
controlplane:
https://kubernetes.io/blog/2023/08/15/pkgs-k8s-io-introduction/

Need to install the write package repos:

echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list

curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg


sudo apt-get update

sudo apt update
sudo apt-cache madison kubeadm


sudo apt-mark unhold kubeadm && \
sudo apt-get update && sudo apt-get install -y kubeadm='1.31.3-1.1*' && \
sudo apt-mark hold kubeadm

kubeadm version

sudo kubeadm upgrade plan

replace x with the patch version you picked for this upgrade:
sudo kubeadm upgrade apply v1.31.0

update the kubelet:
kubectl drain controlplane --ignore --daemonset


sudo apt-mark unhold kubelet kubectl && \
sudo apt-get update && sudo apt-get install -y kubelet='1.31.3-1.1' kubectl='1.31.3-1.1' && \
sudo apt-mark hold kubelet kubectl


sudo systemctl daemon-reload
sudo systemctl restart kubelet

kubectl get node
- node is unscheduled

kubectl uncordone controleplane


upgrading worker nodes:
https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/upgrading-linux-nodes/

change the package repo like above

# replace x in 1.31.x-* with the latest patch version
sudo apt-mark unhold kubeadm && \
sudo apt-get update && sudo apt-get install -y kubeadm='1.31.x-*' && \
sudo apt-mark hold kubeadm

sudo kubeadm upgrade node

update the kubelet:
kubectl drain controlplane --ignore --daemonset

sudo apt-mark unhold kubelet kubectl && \
sudo apt-get update && sudo apt-get install -y kubelet='1.31.3-1.1' kubectl='1.31.3-1.1' && \
sudo apt-mark hold kubelet kubectl

sudo systemctl daemon-reload
sudo systemctl restart kubelet


kubectl uncordone node01

kubectl get node
````

## Cluster Upgrade Version 2

```yaml
kubectl get nodes

kubeadm upgrade plan

upgrade one version at a time:
upgrade kubeadm from 11 to 13:, start with to 12 first:
apt-get upgrade -y kubeadm=1.12.0-00

upgrade cluster:
kubeadm upgrade apply v1.12.0

upgrade kubelet:
apt-get upgrade -y kubelet=1.12.0-00

systemctl restart kubelet

worker nodes:
kubectl drain node-1

apt-get upgrade -y kubeadm=1.12.0-00

kubeadm upgrade node config --kubelet-version v1.12.0

systemctl restart kubelet


```

## Cluster Updgrade Process

```yaml

steps:
- Upgrade the masternodes and components first:
- Upgrade the worker node:

Using kubeadm tool, kubeadm does not install or upgrade kubelets:
check the current local version of kubeadm tool, also check the remote version:

vim /etc/apt/sources.list.d/kubernetes.list

1. check the latest version available for an upgrade with the current version of the kubeadm tool installed?:
kubeadm upgrade plan

2.Notes: to upgrade the cluster, upgrade the kubeadm tool first:

kubeadm upgrade apply v1.31.0

3. you still see masternodes at v1.11:
kubectl get nodes

- This is because, d output of this command, it shows the versions of kubelets on each of these nodes registered:
- with the apiserver and not the version of the apiserver itself:

4.Upgrade the kubelet on the master node:
apt-get upgrade -y kubelet=1.12.0-00
systemctl restart kubelet
apt-get install kubelet=1.31.0-1.1


5.Upgrade the worker nodes: one at a time:

k drain node01
apt-get upgrade -y kubeadm=1.12.0-00
apt-get upgrade -y kubelet=1.12.0-00
kubeadm upgrade node config --kubelet-version v1.12.0
systemctl restart kubelet

6.make the node schedulable:
kubectl uncordon node01

7.drain the controleplane node:
k drain controlplane --ignore-daemonsets

upgrade the control plane components:
check the docs for admin with kubeadm:

8. install the binaries first: on cp and worker nodes:
https://kubernetes.io/blog/2023/08/15/pkgs-k8s-io-introduction/

9.then follow the rest of the instruction here:
https://v1-30.docs.kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-upgrade/



kubeadm ---> master components -----> kubelets --------> workernodes:

On the controlplane node:
Use any text editor you prefer to open the file that defines the Kubernetes apt repository.

vim /etc/apt/sources.list.d/kubernetes.list:

Update the version in the URL to the next available minor release, i.e v1.30:
deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /


install and upgrade the kubeadm:
apt update
apt-get upgrade -y kubeadm=1.12.0-00

Find the latest 1.30 version in the list:
It should look like 1.30.x-*, where x is the latest patch:
apt-cache madison kubeadm
sudo apt-mark unhold kubeadm && \
sudo apt-get update && sudo apt-get install -y kubeadm='1.30.x-*' && \
sudo apt-mark hold kubeadm

example I used:
sudo apt-mark unhold kubeadm && sudo apt-get update && sudo apt-get install -y kubeadm='1.30.0-1.1' && sudo apt-mark hold kubeadm

//e.g  sudo apt-get update && sudo apt-get install -y kubeadm='1.30.0-0' && \
now, update all the control components:

drain the master node first 1:
kubectl drain controlplane

kubeadm upgrade apply 1.12.0

Check for the new plan with the update:
kubeadm upgrade plan

upgrade the kubelet if on master nodes:

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
workers node not updated yet:

update them one after the other:
kubectl drain node-1

apt-get install kubeadm=1.30.0-1.1

Upgrade the node:
kubeadm upgrade node


check the version to be upgraded available:
sudo apt-get update
apt-cache madison kubeadm
apt-cache policy kubeadm

Now, upgrade the version and restart Kubelet.:

apt-get install kubelet=1.30.0-1.1

systemctl daemon-reload

systemctl restart kubelet


make the node schedulable:

kubectl uncordon node-1
```

## Backup - Resource configs

```yaml

example of using the imperative way:
`kubectl get all -all-namespaces -o yaml > all-deploy-services.yaml`

`k get pods --all-namespaces`

Do not need to stress, ark(Now Velero can help with the backup):

We can backup the sates in ETCD  and it brings all our data back:

data storage location can be found in the etcd.service:
--data-dir-/var/lib/etcd

can take snapshot of the ETCD server:
ETCDCLT_API=3 etcdctl \ snapshot save snapshot.db

status of the snapshot:
ETCDCLT_API=3 etcdctl \ snapshot status snapshot.db

restore the the cluster from this backup at a later point in time:

Stop the kube api server, because the etcd will be restarted and kubeapi depends on it :
service kube=apiserver stop

Then restore:
ETCDCTL_API=3 etcdctl \ snapshot restore snapshot.db \ --data-dir /var/lib/etcd-from-backup


then configure etcd.service to use the new data dir:
--data-dir=/var/lib/etcd-from-backup

systemctl daemon-reload

service etcd restart

service kube-apiserver start

export ETCDCTL_API=3
remember to specify the additional flag:

ETCDCTL_API=3 etcdctl --endpoints=https://[127.0.0.1]:2379 \
--cacert=/etc/kubernetes/pki/etcd/ca.crt \
--cert=/etc/kubernetes/pki/etcd/server.crt \
--key=/etc/kubernetes/pki/etcd/server.key \
snapshot save /opt/snapshot-pre-boot.db



Know the services running:
kubectl get services

k describe service <service-name>





What is the version of ETCD running on the cluster?, Check the ETCD Pod or Process:
`k describe pod etcd-controlplane -n kube-system | grep Image`
k logs -n kube-system etcd-controlplane | grep 'etcd version'

Where is the ETCD server certificate file located?:

kubectl -n kube-system describe pod etcd-controlplane | grep '\--cert-file'

--cert-file=/etc/kubernetes/pki/etcd/server.crt

Where is the ETCD CA Certificate file located?:

--trusted-ca-file=/etc/kubernetes/pki/etcd/ca.crt


## The master node in our cluster is planned for a regular maintenance reboot tonight. While we do not anticipate anything to go wrong,

## we are required to take the necessary backups. Take a snapshot of the ETCD database using the built-in snapshot functionality.

k logs -n kube-system etcd-controlplane | grep 'etcd version'

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

- --data-dir=/var/lib/etcd

   volumeMounts:
    - mountPath: /var/lib/etcd
      name: etcd-data
    - mountPath: /etc/kubernetes/pki/etcd
      name: etcd-certs


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


scp cluster1-controlplane:/opt/cluster1.db /opt
scp /opt/cluster2.db etcd-server:/root
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


Take a backup of etcd on cluster1 and save it on the student-node at the path /opt/cluster1.db:
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

Snapshot saved at /opt/cluster1.db:


Finally, copy the backup to the student-node. To do this, go back to the student-node and use scp as shown below:

scp cluster1-controlplane:/opt/cluster1.db /opt/cluster1.db





question:

An ETCD backup for cluster2 is stored at /opt/cluster2.db. Use this snapshot file to carryout a restore on cluster2 to a new path /var/lib/etcd-data-new.



Once the restore is complete, ensure that the controlplane components on cluster2 are running.


The snapshot was taken when there were objects created in the critical namespace on cluster2. These objects should be available post restore.


If needed, make sure to set the context to cluster2 (on the student-node):


scp /opt/cluster2.db etcd-server:/root


Step 2: Restore the snapshot on the cluster2. Since we are restoring directly on the etcd-server, we can use the endpoint https:/127.0.0.1. Use the same certificates that were identified earlier. Make sure to use the data-dir as /var/lib/etcd-data-new:

ETCDCTL_API=3 etcdctl --endpoints=https://127.0.0.1:2379 --cacert=/etc/etcd/pki/ca.pem --cert=/etc/etcd/pki/etcd.pem
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
Access to the host must be very secured, if that is compromised everything is compromised:

control access to the APISERVER, that is the first line of defense:

Auth - RBAC, ABAC , Node Auth:

Network policy to restrict communication between components:



AUTH:

- You cannot create users but you can create service account:

k create serviceaccount sa1

k get serviceaccount

if using text-file to authenticate users: NOT Recommended
--basic-auth-file=user-details.csv

curl -v -k https://master-node-ip:6443/api/v1/pods

if using a static token in the kube-apiserver.service: Not recommended
--token-auth-file=user-token-details.csv

then pass the token as an authorization bearer:

curl -v -k https://master-node-ip:6443/api/v1/pods --header "Authorization: Bearer nlnklnavlanaknslnkoanrgoan"

- This is not a recommended auth mechanisim in a clear text
- consider volume mount while providing the auth file in a kubeadm setup
- setup RBA for the new users

location of the key in a company's server:
cat ~/.ssh/authorized_keys


Certificate Authority (CA):

Assymetric using openssl to generate public and private key pair on the server, server can have private key securely:

openssl genrsa -out my-bank.key 1024

- user gets the pub key from the server
- user sends the pub key to the server and server decrypyts with private key generated above

This is different from ssh-keygen


All this comm between browser CA and server known as PKI(Public key Infrastructure ):

naming convention for public key:
*.crt *.pem

server.crt
server.pem
client.crt
client.pem

private key:

*.key  *-key.pem
server.key
server-key.pem
client.key
client-key.pem

Server certificates are for servers:
Client certificates are for clients:

flow of PKI:
- users need https access to a server:
- first server sends a certificate signing request(CSR) to CA:
- CA uses its private key to sign CSR - you know all users have a copy of the CA public key:
- Signed certifcate is sent back to the server:
- server configures the web app with the signed certificate:
- users need access, server first sends the certicate with its public key inside the cert:
- users browser reads the certifcate and uses the CA's public key to validate and retrieve the server's public key:
- Borwser then generates a symmetric key it uses for communication going forward for all communication.:
- The symmetric key is encrypted using the server as public key and sent back to the server:
- server uses its private key to decrpyt the message and retrieve the symmetric key:
- symmetric key is used for communication going forward:
```

## Root cert, Client cert, Server Cert

```yaml
server components that need certs:
kube-api
etcd server
kubelet server

client components through REST to Kube-Api server:
Admin(us) - admin.crt admin.key
scheduler - schedular.crt scheduler.key
kube controller manager
kubeproxy
```

## Generate Certificate for the cluster

Must have at least one certificate authority that to sign this certificate

```yaml
certificate tools:
EASYRSA OPENSSL CFSSL

FIRST generate the CA cert:
openssl genrsa -out ca.key 2048

generate a certificate signing request:
CN -COMMON NAME:
- more like all of our details without a signature.:
openssl req -new -key ca.key -subj "/CN=KUBERNETES-CA" -out ca.csr

SIGN USING THE OPENSSL with the private key ca key pair:
openssl x509 -req -in ca.csr -signkey ca.key -out ca.crt

Follow same process for the client but with little tweak by signing with the CA:

Generate cert for Admin user and group /O:

openssl genrsa -out admin.key 2048
admin.key:

gen a signing in request:
openssl req -new -key admin.key -subj \ "/CN=kube-admin" -out admin.csr
admin.csr:

signing request with an existing system group group in cluster:
openssl req -new -key admin.key -subj \ "/CN=kube-admin/O=system:masters" -out admin.csr
admin.csr:

generate a signed public certifcate, this time, specify the CA CERT AND CA key:
we are signing the cert with CA, making it a valid certicate within your cluster:

openssl x509 -req -in admin.csr -CA ca.crt -CAkey ca.key -out admin.crt

for system components like kube-scehduler:

prefix the name with the keyword system:

what do you do with cert:

can run a curl to kube  api-server:

curl https://kube-api-server:6443/api/v1/pods --key admin.key --cert admin.crt --cacert ca.crt


can use it within a kube-config.yaml:

every clients need the root CA in their configuration:

ETCD deployed as a cluster across multple servers:

needs an additional peer-cert for secure communication btw diff members in the cluster
-- peer.key:
-- peer-trusted-ca-file ca.crt:
-- etcdpeer1.crt:
-- trusted-ca-file ca.crt:

kubapi-server:

you need the name specified in creating the key

opnessl.cnf file:

openssl req -new -key apiserver.key -subj\ "/cn=KUBE=APISERVER" -OUT APISERVER.CSR --config openssl.cnf

To generate alternate names for apiserver, use an openssl.cnf file:

openssl.cnf file:

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

sign the certificate:
OPENSSL X509 -req -in apiserver.csr -CA ca.crt -CAkey ca.key -cacreateserial -out apiserver.crt -extensions v3_req -extfile openssl.cnf -days 1000

apiserver.crt:

pass the value to usr/local/bin/kube-apiserver:
```

## kubernetes- view certificate details

```yaml
The hard way - from scratch:

journalctl -u etcd.service -1


cat /etc/systemd/system/kube-apiserver.service

The automated way - kubeadm:

cat /etc/kubernetes/manifests/kube-apiserver.yaml

identify the file where it is stored

go deeper into the certificate to decode and check details:

lets start with the apiserver cert file:
openssl x509 -in /etc/kubernetes/pki/apiserver.crt  -text -noout


kubectl logs etcd-master

## can go down t docker

docker ps -a
docker logs containerid


grep additions:

 k describe pods -n kube-system kube-apiserver-controlplane | grep -E '\.ca$|\.crt$|'

kube-apiserver:
--tls-cert-file=/etc/kubernetes/pki/apiserver.crt

Identify the Certificate file used to authenticate kube-apiserver as a client to ETCD Server.:
--etcd-certfile=/etc/kubernetes/pki/apiserver-etcd-client.crt

Identify the ETCD Server Certificate used to host ETCD server.:
  --tls-cert-file=/etc/kubernetes/pki/apiserver.crt

What is the Common Name (CN) configured on the ETCD Server certificate?:
--cert-file=/etc/kubernetes/pki/etcd/server.crt


connection with kube-api server refused:
docker ps -a | grep etcd

use crtctl for crio environments:
crtctl ps -a
//used for envs using crio instead of docker

```

## Certificates API

```yaml
## TLS Certtificates - Certificates wotkflow and API
Kubernetes has a certificate buit-in API

once a new admin generates its key and sent to KA8Admin
He creates a certificate signing object

jane-scr.yaml:

apiVersion: certificates.k8s.io/v1
kind: CertificateSigninRequest

converts the admin key to base64:

cat jane.csr | base64

place the encoded object in the request field in the object:

check all siginin requests:
kubectl get csr

approve the request:

kubectl certifcate approve jane


get certifcate in yaml format:

kubectl get csr jane -o yaml

to decode it:

echo "a0qahqbqdqh0ndqd-qnasqwdnm" | base64 --decode

who does this for us - controller manager:

Anyone who needs to sign certifcate need the CA server root certificcate and private key:

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

Answer:

cat akshay.csr | base64 -w 0

cat <<EOF | kubectl apply -f -
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: akshay
spec:2
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

kubectl delete csr agent-smith -o yaml

k certificate deny agent-smith

```

## kube config

```yaml

Use a context with a different file name and location:

kubectl config use-context research --kubeconfig /root/my-kube-config

$HOME/.kube/config:
kubectl config view

change the context to access production cluster based on the configuration in the cofig file:

kubectl config use-context prod-user@production

To know the current context, run the command:
kubectl config --kubeconfig=/root/my-kube-config current-context

k config --kubeconfig=/root/my-kube-config use-context research


sample config file with users, context:
You leave the file as is:
You do not need to create any object:

k config view --kubeconfig my-kube-config

apiVersion: v1
kind: Config

clusters:
- name: production
  cluster:
    certificate-authority: /etc/kubernetes/pki/ca.crt
   ## certificate-authority-data: encoded base64
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
    namespace: finance

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

 k config use-context research --kubeconfig=/root/my-kube-config

 cp my-kube-config .kube/
source ~/.bashrc

```

## API Groups

```yaml
Core API and Named API Groups:

list available groups from your cluster:

curl http:/localhost:6443 -k

list groups on the named api group:

curl http://localhost:6443/apis -k | grep "name"

you need auth for more return from the api:

curl http"//localhost:6443 -k
      --key admin.key
      --cert admin.crt
      --cacert ca.crt

another option is to start a proxy client:
- kubectl proxy uses cred and certs from your kubeconfig file to access the cluster - port 8002
kubectl proxy

after the service has started:
curl http://locahost:8001 -k

kube proxy is not equal to kubectl proxy
```

## Authorization

```yaml
using namespaces to partition users and service account:

Auth mechanisms supported by kubernetes:
- Node Auth
- ABAC(Attribute Based Auth)
- RBAC (Role Based Authorization)
- Webhook

ABAC: Associate a user or a group of user with a set of permissions

Authorization Mode:

Always Allow

Always Deny

check the mode in the /usr/local/bin/kube-apiserver:
- By default
--authorization-mode=AlwaysAllow

you can set MUTLIPLE node Auth:
- It is processed in sequence
--authorization-mode=Node,RBAC,Webhook

RBAC:
kubectl create role developer --verb=list,create,delete --resource=pods

RBAC:
- Can also create a yaml file with rbac.authorization.k8s.io/v1

kind: Role
- Create a role with a yaml file


apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: default
  name: developer
rules:
- apiGroups: [""] # "" indicates the core API group
  resources: ["pods"]
  verbs: ["get", "watch", "list"]

- apiGroups: [""] # "" indicates the core API group
  resources: ["ConfigMap"]
  verbs: ["get", "watch", "list"]



kubectl create -f developer-group.yaml

link a user to the role object using ROLE BINDING object:
kubectl create rolebinding dev-user-binding --role=developer --user=dev-user


Kind: RoleBinding

kubectl create -f devuser-developer-binding.yaml


Get roles:
kubectl get roles
kubectl get roles -A

ps -aux | grep authorization

k get roles kube-proxy -n kube-system -o yaml

kubectl get rolebinding

Check your authorization as a user:
kubectl auth can-i create deployments

kubectl auth can-i delete nodes

Test users auth as an Admin without authenticating:
kubectl can-i create depolyments --as dev-user
kubectl can-i create depolyments --as dev-user -n test

kubectl edit role developer -n blue


Which account is the kube-proxy role assigned to?:

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


another example:

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
get resources in a namsepace:
kubectl api-resources --namespaced=true

cluster-scoped roles:

kubectl api-resources --namespaced=false

Get cluster role:
k get clusterroles --no-headers | wc -l

kubectl get clusterroles --no-headers  -o json | jq '.items | length'


Get cluster role binding:

 k get clusterrolebinding --no-headers | wc -l

A new user michelle joined the team. She will be focusing on the nodes in the cluster.:
Create the required ClusterRoles and ClusterRoleBindings so she gets access to the nodes.:


Use the command kubectl create to create a clusterrole and clusterrolebinding for user michelle to grant access to the nodes.
After that test the access using the command:

 kubectl auth can-i list nodes --as michelle.

answer:

k create clusterrole michelleuser --verb=list --resource=nodes

k create clusterrolebinding michellebind --clusterrole=michelleuser --user=michelle


michelle's responsibilities are growing and now she will be responsible for storage as well.:
Create the required ClusterRoles and ClusterRoleBindings to allow her access to Storage.:
Get the API groups and resource names from command kubectl api-resources. Use the given spec:


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

> Every namespace has a default service account

A service account in Kubernetes is a non-human identity that provides a way for applications to authenticate to a Kubernetes cluster's API server

```yaml
There are two kinds of accounts -:
- service account - used by machines like jenkins, prometheus
- user account - e.g admin user

create a service account:

kubectl create serviceaccount dashboard-sa

kubectl get serviceaccount

service account create token stored as a secret object:
The token is used by the app to authenticate to the k8 api:
The secret object is then linked to the service account:

kubectl describe secret <secret-name>

curl https:49u34u34/api -insecure --header "Authorization: Bearer sdssdmdsdmdmsdmsdm"

Default service account with secret token is automatically mounted as volume mount in a pod by default:
a vol is automatically created for the service acount:

kubectl exec -it my-dashboard -- ls /var/run/secrets/kubernetes.io/serviceaccount

The flow:
- create service account
kubectl create serviceaccounts logging-dash

- create a token for the service account
kubectl create token logging-dash


You shouldn't have to copy and paste the token each time. The Dashboard application is programmed to read token from the secret mount location.:
However currently, the default service account is mounted. Update the deployment to use the newly created ServiceAccount:


Edit the deployment to change ServiceAccount from default to dashboard-sa:

or edit the deployment and add serviceAccountName:

kubectl set serviceaccount deploy/web-dashboard dashboard-sa



make sure is inside the container spec:

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

use image on pods on the worker nodes from private registry:
- hOW DO WE IMPLEMENT THE AUTH

docker create secret docker-registry --help:
kubectl create secret docker-registry <secret-name>  \
--docker-server=  \
--docker-username=  \
--docker-email=    \


on the pod:
spec:
  imagePullSecrets:
  - name: <secret-name>
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
advisable to specify user to run processes in a container:

USER 1000

docker run --user=1001 ubuntu sleep 3600

Check what users can do in linux:

/usr/include/linux/capability.h

root user in container does not have has much capability as that of linux HOST

CONTROL CAPBILITY TO A USER:

docker run --cap-add MAC_ADMIN ubuntu
docker run --cap-drop KILL ubuntu

run with all priviledges:

docker run --privileged ubuntu
```

## Security Context

```yaml
security context on the spec/kubernetes level:
Applies to all container settings in a pod
spec:
 securityContext:
    runAsUser: 1000
 containers:
   - name: ubuntu
     image: ubuntu
     command: ["sleep", "3600"]


security context on the container level:
overrizes setings on the pod
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


check which user is running processes on a pod:

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


add external ip not part of the cluster , see above:


EGRESS: what if network egress from the DB to the backup server:

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
Networking contd:
kubectl get networkpolicies

Create a network policy to allow traffic from the Internal application only to the payroll-service and db-service.:


Use the spec given below. You might want to enable ingress traffic to the pod to test your rules in the UI.

Also, ensure that you allow egress traffic to DNS ports TCP and UDP (port 53) to enable DNS resolution from the internal pod.

My note:
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


   - ports:
    - port: 53
      protocol: UDP
    - port: 53
      protocol: TCP
```

## kubectx

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
Understand docker file system:
docker default location for file, images , volumes, containers:
/var/lib/docker

after writing dockerfile and building the file:
when u run docker run, docker creates a final writeable container layer:

The layer exist as long as the container exist, it dies if the container dies:
what if the want top persist data from a database:

docker volume create data_volume

mount the volume to the default location where mysql stores data:

docker run -v data_volume:/var/lib/mysql mysql

bind mounting - external host(docker host) has a data location  /data/mysql:

docker run -v /data/mysql:/var/libmysql mysql

new way under docker:
docker run \--mount type=bind,source=/data/mysql,target=/var/lib/mysql mysql

docker uses storage drivers to drive all these ops

Storage drivers help manage storage on images and containers

Volume drivers: Volumes are managed by volume driver pluggins : the default vol driver plugin is local


other examples:
Local| Azure File Storage | Convoy | DigitalOcean Block Storgae | Flocker | gce-docker

| Nteapp | Rexray | Portwoex | Vmarew vphere

storage drivers - Dependent on OS:
AUFS | ZFS | BTRFS | DEVICE MAPPER | OVERLAY

example of volumes on my local computer:
─ docker volume inspect buildx_buildkit_devops-builder0_state
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

using rexray volume driver to provision ebs volume from was in the cloud:
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
- while storage often refers to the broader, persistent, and external data storage mechanisms.

```yaml
CRI - Container Runtime Interface
CNI - Container Networking Interface
CSI - Container Storage Interface

With CSI, you can develop your driver for your own storage to work with k8
e.g Amazon EBS, DELL EMC, GlusterFS all have CSI drivers

Volumes in Kubernetes:
To persist data in kubernetes, attach volume to the pod

volume and mounts:
- volume is spec level
- A volume needs a storage
- Use a dir in the host location for example
- Every file created in the volume would be stored in the dir data on my node
- After specificing the vol and storage,  to access it from the container,mount it to  ..
- a dir inside the container
spec:
  containers:
  volumes:
  - name: data-volume
    hostPath:
       path: /data
       type: Directory

to access the volume from a container using volume mount:
- volumemount is spec.container level
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

Not recommeded on production level:

Support of diff types of strogae solutions:

- NFS,glusterFS, Flocker, ceph, scaleio, aws, Azure disk

  volumes:
  - name: data-volume
    awsElasticBlockStore:
       volumeID: <volume-id>
       fstype: ext4



Persistent volume:
- volumes stated above is only bound to pod definition file

- Need more centrally managed volume and user can carve out vols as needed

- PV is a cluster wide pool of storage volumes configured by an admin to be used by users deploying volume on the cluster using PVC

example:
kubectl create -f pvi-file.yaml

k get persistentvolume

Persistent volume:

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


Persistent Volume Claims:
Make a storage available to a node
user creates a set of PVCs to use for storage
- k8 binds PV to PVC - One-to-One
- The accessModes for pv and pvc must match:


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


persistent volume:
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
Let us claim some of that storage for our application. Create a Persistent Volume Claim with the given specification:

Volume Name: claim-log-1
Storage Request: 50Mi
Access Modes: ReadWriteOnce


pvc:

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



Update the Access Mode on the claim to bind it to the PV.:

apiVersion: v1
items:
  apiVersion: v1
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
Static provisioning volume:

gcloud beta compute disks create \
   --size 1GB
   --REGION US-EAST-1
   pd-disk


Dynamic provisioning:
- create a storage class object

 kubectl get storageclasses

STEPS:
- Create a storage class object
- storage class creates pv automatically
- pvc reference the storage class at the spec level
spec:
  storageClassName: google-storage
- reference the PVC in the volumes of pod at the spec level

notes:
info
- The Storage Class called local-storage makes use of VolumeBindingMode set to WaitForFirstConsumer:
- This will delay the binding and provisioning of a PersistentVolume until a Pod using the PersistentVolumeClaim is created:

step1:
 - create a google storage class for dynamic volume provisioning

storageclass.yaml:

apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: google-storage
provisioner: kubernetes.io/gce-pd
parameters:
  type: pd-standard
replication-type: none


step2:
- claim part of the storage dynamically
pvc-definition.yaml

- apiVersion: v1
  kind: PersistentVolumeClaim
  metadata:
    name: my-claim
    namespace: default
  spec:
    accessModes:
    - ReadWriteMany
    storageClassName: google-storage
    resources:
      requests:
        storage: 500Mi


step3:
- reference the claim in the pod volume section
apiVersion: v1
kind: Pod
metadata:
  name: task-pv-pod
spec:
  volumes:
    - name: task-pv-storage
      persistentVolumeClaim:
        claimName: my-claim
  containers:
    - name: task-pv-container
      image: nginx
      ports:
        - containerPort: 80
          name: "http-server"
```

## Networking in Linux

```yaml
In Linux:
list and modify interfaces on the host:
ip link

see the ip addrs assigned to those interfaces ip addr:
ip addr


set ip addrs to those interfaces:
ip addr add 192.168.1.10/24 dev eth0

persist this changes:
edit in the /etc/network/interfaces file.

view the routes/ routing table:
ip route

add entry into the routing table:
ip route add 192.168.1.0/24 via 192.168.2.1

check if ip forwarding is enabled, must be set to 1:
cat  /proc/sys/net/ipv4/ip_forward

```

## DNS configuration in Linux Host

```yaml
host A wanna ping system B with a host name db - name resolution:
- on host A
cat >> /etc/hosts
2323.232.2323.232  db

managing can be hard:
- move entries into a DNS server to manage the hosts
- every host has a `dns resolution file  `/etc/resolv.conf`
- add an entry into to it and specify the addr of the dns server
- namserver 192.168.1.100
- dont need entry anymore in /etc/hosts
- if both local and dns server have the same entry, it ist looks at the local
- order is configured at cat /etc/nsswitch.conf

shorthand for long Domain name such as web for web.mycompany.com:
/etc/resolv.conf
search     mycompany.com

ping web

test dns resolution:
ping

doesnt consider /ect/host file , only dns server:
nslookup www.google.com
dig www.google.com


can configure your computer as a DNS server using coredns solution:

https://coredns.io/plugins/kubernetes/
https://github.com/kubernetes/dns/blob/master/docs/specification.md
```

## Network Namspaces in Linux

```yaml
To create a network namespace on a linux host:
In general, containers too have a ns to isolate itself from the host:

ip netns add red
ip netns add blue

list the network namespaces:
ip netns

run inside the ns to check for interfaces, syou can run for host too:
this network ns do not have interface yet and no network connnectivity:
ip netns exec red ip link
ip -n red link
ip -n red arp


connect two namespaces using a virtual internet pair/cable:
- use a virtual ethernet pair

ip link add veth-red type veth peer name veth-blue

attach each virtual interface to ns respectively:
- so each ns get a networ interfce
ip link set veth-red netns red

ip link set veth-blue netns blue


can assign ip addr to each ns:
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

connect the ns to the bridge network:


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

any traffic coming on port 80 on the local host to be forwarded to port 80 of the ns:
iptables -t nat -A PREPOUTING --dport 80 --to-destination 192.168.15.2:80 -j DNAT





While testing the Network Namespaces, if you come across issues
where you can't ping one namespace from the other, make sure you set the NETMASK while setting IP Address. ie: 192.168.1.10/24

ip -n red addr add 192.168.1.10/24 dev veth-red Another thing to check is FirewallD/IP Table rules.

Either add rules to IP Tables to allow traffic from one namespace to another. Or disable IP Tables all together (Only in a learning environment).
```

## Docker Networking

```yaml
1 no network - docker cannot nreach the outisde world and vice-versa :
docker run --network none nginx


2 host network:
- container is attached to the host network
- if you deploy a web app on port 80, then the app is available on port 80 on the host

docker run --network host nginx

if you try and rerun because it wont work, two process cannot share the same port at the same time:


3. Bridge network - An internal private network which the docker host and container attach to:

docker network ls
bridge

// but on the host, same bridge network is referred to as docker0
ip link

et the ns of the container:
docker inspect <networkid>

on host:
ip link

ip -n <ns id/container network id> link

external users need ton access the docker container:
- use port mapping
- users can access port 80 of the container through the port 8080 on the host
docker run -p 8080:80 nginx

curl http://192.168.1.10:8080


iptables -nvL -t nat
```

## Cluster Networking

```yaml

Important commands:
- ip link
- ip addr
- ip addr add 192.168.1.0/24 dev eth0
- ip route
- ip route add 192.168.1.0/24 via 192.168.2.1
- cat /proc/sys/net/ipv4/ip_forward
- arp
- netstat -plnt
-netstat --help

K8 consist of master and worker nodes:
- Each nodes should have at least one interface connected to a network  with IP addr
- The host should have unique hostname set and a unique mac address

search for numeruc, programs, listening, -i - not case sensitive:

netstat -npl | grep -i scheduler

netstat -npa | grep -i etcd | grep -i 2379 | wc -1

An important tip about deploying Network Addons in a Kubernetes cluster:

In the upcoming labs, we will work with Network Addons. This includes installing a network plugin in the cluster. While we have used weave-net as an example, please bear in mind that you can use any of the plugins which are described here:

https://kubernetes.io/docs/concepts/cluster-administration/addons/

https://kubernetes.io/docs/concepts/cluster-administration/networking/#how-to-implement-the-kubernetes-networking-model

In the CKA exam, for a question that requires you to deploy a network addon, unless specifically directed, you may use any of the solutions described in the link above:

However, the documentation currently does not contain a direct reference to the exact command to be used to deploy a third-party network addon:

The links above redirect to third-party/ vendor sites or GitHub repositories, which cannot be used in the exam. This has been intentionally done to keep the content in the Kubernetes documentation vendor-neutral:

Note: In the official exam, all essential CNI deployment details will be provided


## exercise

## Question

- What is the network interface configured for cluster connectivity on the controlplane node?:

- node-to-node communication

ip a | grep -B2 192.23.97.3

- ip a lists all network interfaces and their IP addresses.
- grep -B2 searches for the string 192.23.97.3 and displays 2 lines before the match.

eth0@if25557: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1450 qdisc noqueue state UP group default
    link/ether 02:42:c0:17:61:03 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 192.23.97.3/24 brd 192.23.97.255 scope global eth0


- ip show route default
 What is the port the kube-scheduler is listening on in the controlplane node?:
netstat -nplt

netstat -npl | grep -i scheduler

Notice that ETCD is listening on two ports. Which of these have more client connections established?:

netstat -anp | grep etcd | grep 2380 | wc -l


show ip of an interface:
ip address show eth0

show all the bridge interface:

ip address show type bridge

Ques: We use Containerd as our container runtime. What is the interface/bridge created by Containerd on the controlplane node?:
- When using Containerd as the container runtime on a Kubernetes control plane node,
- the default interface/bridge created by Containerd is typically called cni0.
- This bridge is managed by the Container Network Interface (CNI) plugins, which Containerd relies on for network connectivity.

- The cni0 bridge connects the various containers running on the node,
- allowing them to communicate with each other and with external networks,
- based on the CNI plugin configuration you're using (e.g., Calico, Flannel).


Check for CNI bridge using network namespaces:
ip nets
```

## Pod Networking

<img src="https://github.com/sheyijojo/kubernetes_CKA_Exams/blob/main/pdfs/network-1.png?raw=true" alt="Description" width="800">

```yaml
k8 Networking Model:
  - Every pod should have an IP Address
  - Every pod should be able to talk with every other pod in the same node
  - Every pod should be able to talk with every other Pod on other nodes without NAT

CNI:
  - CNI helps run script on each pod created automatically
  - E.g a script that helps add IP addr and ns , and connects pods to the route network

Container Runtime:
  - A container runtime on each nodes is responbisible for  creating container
  - Container runtime then looks at the CNI configuration and looks for the script I created
  - /etc/cni/net.d/net-script.conflist
  - Then looks at the bin directory /opt/cni/bin/net-script.sh , and executes the script
```

## CNI in Kubernetes

```yaml
- In k8, the container plugins are installed  in :
ls /opt/cni/bin

- which plugin to be used is stored here:
/etc/cni/net.d/
```

## CNI Weave

- Solution based on CNI Weaveworks

```yaml
kubectl apply -f https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml


- so CNI plugin is deployed on the cluster
- It deploys an gent or service on each node
-They communicate with each other to exchange information.
- Waeve makes sure PODS have the correct route configured to reach the agent
- The agent takes of other PODS


DEPLOYING WEAVES ON A CLUSTER:

- WEAVE and weave peeers can be deployed as services or daemons on each node in d cluster mannaully or deploy as pods in cluster

kubectl get pods -n kube-system

kubectl logs weave-net-59cmb waeve -n kube-system

questions:

Inspect the kubelet service and identify the container runtime endpoint value is set for Kubernetes.:
ps aux | grep -i kubelet | grep containerd

ps aux | grep -i kubelet | grep container-runtime
```

## Plugin for IP Management - IPAM

```yaml
CNI outsourced IP management to DHCP and host-local:


questions:

What is the default gateway configured on the PODs scheduled on node01?:

- Try scheduling a pod on node01 and check ip route output:

ssh node01

ip route

- on control plane
- spec


nodeName: node01
kubectl run busybox --image=busybox --dry-run=client -o yaml -- sleep 1000 > busybox.yaml


apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  nodeName: node01
  containers:
  - name: nginx
    image: nginx:1.14.2
    ports:
    - containerPort: 80


What POD OR addr range configured on weave:

- check the pod logs of the weave agent:
- look for ipalloc:

kubctl logs -n kube-system weave-nt-mknr5

kubectl exec busybox -- ip route
```

## Service Networking

```YAML
- You will rarely configure pods to talk with each other, you will usually use a SERVICE.
When a service is created, it is accessible on all pods on the cluster:

- a service is hosted accross a cluster, not bound to a specific node:
- a service accesible ONLY within the cluster is known as clusterIp, gets an IP addr attached to it from a predefined range :

Nodeport service:
- can expose app on a pods externally on all nodes on the cluster, gets an IP Addr


 How is the service made available to external users through a port on each node:
- Generally, we know every node run a kubelet process which is responsible for creating PODS.
- Same kubelet invokes CNI plugging to configure networking for that POD.
- Each node also runs another component known as kube-proxy which gets into action whenever a service is created.
- services are not created on each node or assigned to each node, they are a cluster-wide concept.
- Service is just a virtual object
- kubeproxy gets the ip addr from the service and creates forwarding rules on each node in the cluster
- Saying any traffic to this IP to go the IP of the pod.

 set kube proxy mode - ways in which kube-proxy creates forwarding rules to forward requests from service to pods..:
defaults to iptables
kube-proxy --proxy-mode [userspace | iptables | ipvs] ...

kubectl get service


overlapping of IPS:

- Make sure a pod and a service IP should not overlap

get the service cluster ip range assigned to service when created.:

kube-api-server --service-cluster-ip-range ipNet
default - 10.0.0.0/24

ps aux | grep kube-api-server

 See the rules created by kube-proxy:

iptables -L -t nat | grep db-service

See these rules also in kube-proxy logs :
cat /var/log/kube-proxy.log

What network ranges are the nodes in the cluster part of?:
- one way to do this is to make use of the ipcalc utility. If it is not installed, you can install it by running:
- check the eth0
- apt update and the apt install ipcalc
-  ip a | grep eth0
- ipcalc -b 10.33.39.8



What is the range of IP addresses configured for PODs on this cluster?:


The network is configured with weave. Check the weave pods logs using the command
-  kubectl logs <weave-pod-name> weave -n kube-system and look for ipalloc-range.
-  k logs -n kube-system weave-net-lfq2s | ipalloc-range

What is the IP Range configured for the services within the cluster?:
cat /etc/kubernetes/manifests/kube-apiserver.yaml  | grep cluster-ip-range

What type of proxy is the kube-proxy configured to use?:

Check the logs of the kube-proxy pods.:

Run the command: kubectl logs <kube-proxy-pod-name> -n kube-system

k logs kube-proxy-ltbmp  -n kube-system | grep kube-proxy

General commands:

kubectl get all --all-namespaces

```

## DNS in Kubernetes

- k8 deploys a built-in DNS server by default when you set up the cluster
- If you set it up manually, then you have to build it yourself
- How DNS help Pods resolve each other
- Focus is purely on PODs and services within the cluster.
- Whenever the service is created, DNS creates a record and mapping its IP to the DNS

```yaml
can reach a webserver from a pod within the same namespace:
curl http://web-service

Different namespace for the service called apps(lets assume),:
curl http://web-service.apps

all services are further grouped together into another subdomain called svc created by DNS:
curl http://web-service.apps.svc


How services are resolved within the cluster:

FQDN for svc- all services and PODS are groupeed togther into a troot domain for the cluster, which is cluster.local by default:

curl http://web-service.apps.svc.cluster.local


for pods:
k8 replaces the ip with dashes:
curl http://10-244-2-5.apps.pod.cluster.local
```

## CORE DNS in Kubernetes

Every time a pod or service is created it adds a record for it in its database

```yaml
- Get Information on the root domain of the cluster in the ConfigMap object
DNS server maps IP address to services but not the same approach to PODs

- For pods it forms hostname by replacing the dots in IP with dashes. it maps ip with pp-dashes
10-244-2-5   10.244.2.5

Recommended DNS server is CoreDNS:
- The coreDNS server is deployed as a pod in the kube-system namespace in the k8 kluster - Deployed as two pods for redundancy,

as part of a replicaset.
- This POD runs the coredns EXECUTABLE.
- k8 uses a file called corefile  `cat /etc/coredns/corefile`, which has a number of plugins configured
- the corefile is passed into the pod has a configMap object.

How does pod point to the dns SERVER, what address does the pod use to point to:
- when the dns is deployed, it also creates a service to make it available to other components within a cluster
- The service is known as kube-dns by default. Ip addr of this service is configured as the nameserver on pods automatically by k8- kubelet

What is the name of the ConfigMap object created for Corefile?:

k get configmaps -n kube-system

ans - coredns

root domain - cluster.local


## What name can be used to access the hr web server from the test Application?
## You can execute a curl command on the test pod to test.
## Alternatively, the test Application also has a UI. Access it using the tab at the top of your terminal named test-app.

k get svc
k describe
- check for the Selector that indicates hr




Where is the configuration file located for configuring the CoreDNS service?:
 kubectl -n kube-system describe deployments.apps coredns | grep -A2 Args | grep Corefile


edit and deploy :
k edit deploy webapp


From the hr pod nslookup the mysql service and redirect the output to a file /root/CKA/nslookup.out:

 k exec -it hr -- nslookup mysql.payroll > /root/CKA/nslookup.out
```

## Ingress in Kubernetes

````yaml
You have load balancers provisioned on google cloud:
- load balancer is sitting in front of your servcies
- How do you direct traffic from different load balancers, manage ssl certs, firewall rules
- What service does that? A configuration in k8 that manages all the configurations mentioned and many more.
- INGRESS is the solution
- Ingress helps users access app using a single externaly url
- More like a layer7 Load Balancer that can be configured using k8 objects
- Need to publish ingress as a service such as nodeport. A one-time configuration

You could configure this withougt Ingress:
Could use reverse proxy such as NGINX, haproxy, TRAEFIK, GCP HTTP(S) Load balancer (GCE), Contour, Istio

They are also the Ingress controller:
- ingress does this in a similar way, with a supported solution like above
- solution deployed is known as ingress controller
- Set of Rules you configure  is known as INGRESS RESOURCES, done by using a definition file

- k8 cluster does not come with Ingress controller by default

Decouples configuration using config map when using example NGINX controller :

steps:
- create ingress controller
- create config map
- Createservice account role and rolebinding  to access all these objects
- create a service of e.g Nodeport


You need an Ingress Controller for Ingress Resource:
Apparently configured as a deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-ingress-controller
  namespace: kube-system
spec:
  replicas: 1
  selector:
    matchLabels:
      name: nginx-ingress
  template:
    metadata:
      labels:
        name: nginx-ingress
    spec:
      containers:
      - name: nginx-ingress-controller
        image: quay.io/kubernetes-ingress-controller/nginx-ingress-controller:0.30.0
        args:
        - /nginx-ingress-controller
        - --configmap=$(POD_NAMESPACE)/nginx-configuration
        #- --tcp-services-configmap=$(POD_NAMESPACE)/tcp-services
        #- --udp-services-configmap=$(POD_NAMESPACE)/udp-services
        env:
        - name: POD_NAME
          valueFrom:
            fieldRef:
              fieldPath: metadata.name
        - name: POD_NAMESPACE
          valueFrom:
            fieldRef:
              fieldPath: metadata.namespace
        ports:
        - name: http
          containerPort: 80
        - name: https
          containerPort: 443
---
apiVersion: v1
kind: Service
metadata:
  name: nginx-ingress
  namespace: kube-system
spec:
  type: NodePort
  ports:
  - port: 80
    targetPort: 80
    protocol: TCP
    name: http
  - port: 443
    targetPort: 443
    protocol: TCP
    name: https
  selector:
    app: nginx-ingress

---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: nginx-ingress-serviceaccount
  namespace: kube-system

---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: nginx-ingress-role
  namespace: kube-system
rules:
- apiGroups: [""]
  resources: ["configmaps", "endpoints", "nodes", "pods", "secrets", "services"]
  verbs: ["get", "list", "watch"]
- apiGroups: [""]
  resources: ["nodes"]
  verbs: ["get"]
- apiGroups: ["extensions", "networking.k8s.io"]
  resources: ["ingresses"]
  verbs: ["get", "list", "watch"]
- apiGroups: ["extensions", "networking.k8s.io"]
  resources: ["ingresses/status"]
  verbs: ["update"]
- apiGroups: [""]
  resources: ["events"]
  verbs: ["create", "patch"]

---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: nginx-ingress-rolebinding
  namespace: kube-system
subjects:
- kind: ServiceAccount
  name: nginx-ingress-serviceaccount
  namespace: kube-system
roleRef:
  kind: Role
  name: nginx-ingress-role
  apiGroup: rbac.authorization.k8s.io

---
apiVersion: v1
kind: ConfigMap
metadata:
  name: nginx-configuration
  namespace: kube-system
data:
  proxy-connect-timeout: "30"
  proxy-read-timeout: "120"
  use-proxy-protocol: "false"
  worker-processes: "2"


````

## create INGRESS resource:

```yaml
- More about routing traffic and whataview

Use rules when you wanna route traffic on diff conditions:
- host field diffentiates a yaml file with multiple domain names and a single domain name
So there are two paths:
1. Splitting traffic by urls with one rule, and split the traffic in two paths
2. Splitting traffic by hostname, use two rules and one path

```

## Ingress Resource

<img src="https://github.com/sheyijojo/kubernetes_CKA_Exams/blob/main/pdfs/ingress-resource.png?raw=true" alt="Description" width="800">

```yaml

Format:
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

- When user visits the url on /watch, /wear is request should be forwarded internally to the http://:/
- /watch and /wear path are what is configured on the ingress controller
- so that we can forward users to the appropriate app in the backend. The app doesnt  have this url/path configured on them.

  without the rewrite-target option, this is what happens:

- http://:/watch –> http://:/watch

- http://:/wear –> http://:/wear


- Notice watch and wear are at the end of the target URLs. The target applications are not configured with /watch or /wear paths.
- They are different applications built specifically for their purpose,
- so they don’t expect /watch or /wear in the URLs.
- And as such the requests would fail and throw a 404 not found error.

To fix that we want to “ReWrite” the URL when the request is passed on to the watch or wear applications.

 We don’t want to pass in the same path that user typed in.

 So we specify the rewrite-target option.

This rewrites the URL by replacing whatever is under rules->http->paths->path
which happens to be /pay in this case with the value in rewrite-target. This works just like a search and replace function.

example:

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




In another example given here, this could also be:
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

```yaml
Which namespace is the Ingress Resource deployed in?:


kubectl get ingress --all-namespaces

## Ingress resources documentation
https://kubernetes.github.io/ingress-nginx/examples/rewrite/


k get pods -A

create an ingress:
kubectl create ingress myingress -n critical-space --rule="/pay=pay-service:8282"

k get ingress -n critical-space

k logs <podname> -n <namespace-name>


namespace:
kubectl create namespace my-namespace

##
The NGINX Ingress Controller requires a ConfigMap object.

Create a ConfigMap object with name ingress-nginx-controller in the ingress-nginx namespace.:

k create configmap ingress-nginx-controller -n ingress-nginx

The NGINX Ingress Controller requires two ServiceAccounts.:
Create both ServiceAccount with name ingress-nginx and ingress-nginx-admission in the ingress-nginx namespace.:


k create serviceaccount ingress-nginx -n ingress-nginx

k create serviceaccount nginx-admission -n ingress-nginx

We have created the Roles, RoleBindings, ClusterRoles, and ClusterRoleBindings for the ServiceAccount. Check it out!!:

k get roles -n <namespacename>

## Create a service to make ingress available to external users

- Name: ingress
- Type: Nodeport
- Port: 80
- TargetPort: 30080
- Namespace: ingress-space
- Use the right selector

k expose deploy ingress-controller -n ingress-nginx --name ingress --port=80 --target-port=80 --type NodePort

k get svc -n ingress-nginx

k edit svc ingress -n ingress-nginx
- edit the NodePort port to 30080

create the ingress resource to make the applications vailable at /wear and /watch om the ingress service:

create the ingress in the app-space ns:
- configure correct backend service for /wear
- configure correct backend service for /watch
- configure backend port for /wear service
- configure backend port for /watch service

k create ingress ingress-wear-watch -n app-space --rule="/wear=wear-service:8080" --rule="/watch=video-service:8080"




```

Installing on Kubeadm

```yaml

set net.bridge.bridge-nf-call-iptables to 1:

cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

sudo sysctl --system

The container runtime has already been installed on both nodes, so you may skip this step.
Install kubeadm, kubectl and kubelet on all nodes:

sudo apt-get update

sudo apt-get install -y apt-transport-https ca-certificates curl

curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update

To see the new version labels:
sudo apt-cache madison kubeadm

sudo apt-get install -y kubelet=1.31.0-1.1 kubeadm=1.31.0-1.1 kubectl=1.31.0-1.1

sudo apt-mark hold kubelet kubeadm kubectl


Bootstrap the cluster with kubeadm:

kubeadm init --apiserver-advertise-address=192.4.83.6 --apiserver-cert-extra-sans=controlplane --
pod-network-cidr=10.244.0.0/16


mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config



Applying network:

To install a network plugin, we will go with Flannel as the default choice. For inter-host communication, we will utilize the eth0 interface.


Please ensure that the Flannel manifest includes the appropriate options for this configuration.


Refer to the official documentation for the procedure.

curl -LO https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml

  args:
  - --ip-masq
  - --kube-subnet-mgr

Add the additional argument - --iface=eth0 to the existing list of arguments.

Now apply the modified manifest kube-flannel.yml file using kubectl:

```

## Troubleshooting in kubernetes

- Application Failure
- Control Plane Failure
- Worker Node Failure
- Networking

> It is a good idea to write down the flow of your app and check every object in the map to find the root cause

```yaml
if users complain about accessing the app:
 steps:
1. Start with the webapp frontend: can you access it?
   -  curl http://web-service-ip:node-port
   -  curl http://10.43.224.12:8080
2. check the service:
   - kubectl describe service web-service
3. if the service endpoint is not discovered:
   -  kubectl describe service web-service
   -  check the Selector to Endpoints(which is ip) configured on the pod.
Notes: So in the web-service, there is a selector that references the Pod label name and they must match
4. check the pod itself and ensure it is in a running state
   - kubectl get pod
   - kubectl describe pod
   - kubectl logs web

Watch the container to fail if fails are not produced immediately:
kubectl logs web -f
watch logs of previous pod:
kubectl logs web -f --previous

5. check the status of the DB service
6. check the DB Pod
7. check the logs of the pod
```

## task

```yaml
create a service:
kubectl create service clusterip redis-service --tcp=6379:6379

k create service clusterip  mysql-service -n alpha --tcp=3306

```

## Question

```yaml
Troubleshooting Test 1: A simple 2 tier application is deployed in the alpha namespace. It must display a green web page on success. Click on the App tab at the top of your terminal to view your application. It is currently failed. Troubleshoot and fix the issue.


Stick to the given architecture. Use the same names and port numbers as given in the below architecture diagram. Feel free to edit, delete or recreate objects as necessary.

answer:
The service name used for the MySQL Pod is incorrect. According to the Architecture diagram, it should be mysql-service.

To fix this, first delete the current service: kubectl -n alpha delete svc mysql

Then create a new service with the following YAML file (or use imperative command):
---
apiVersion: v1
kind: Service
metadata:
  name: mysql-service
  namespace: alpha
spec:
    ports:
    - port: 3306
      targetPort: 3306
    selector:
      name: mysql

task questions:

use a particular namespace:
k config --help
kubectl config set-context --current --namespace=alpha

k descibe deploy webapp-mysql

k replace --force -f /tmp/kubectl-edit04287356731.yaml

note:
- a more complicated use case will have a config map associated to the service/pod
```

## control plane failures

```yaml
## steps
 1. Check status of the nodes:
kubectl get nodes

 2. check status of the pods running in the cluster:
kubectl get pods

 3. if deployed with kubeadm:
kubectl get pods -n kube-system

4. if deployed as a service, check the master node:

service kube-apiserver status

service kube-controller-manager status

service kube-scheduler status

on the worker nodes:

service kubelet status

service kube-proxy status

check the logs on the control plane if kubeadm:

kubectl logs kube-apiserver-master -n kube-system

for native service:

sudo journalctl -u kube-apiserver
```

## solution

```yaml
kubectl config set-context --current --namespace=alpha
```

## Dont forget this command

`kubectl replace --force -f /tmp/kubectl-edit-2623.yaml`

##

```yaml
trouble shooting the control plane components:

-you know is a static pod if it has controlplane appended at the end:

- Then look for the manifest file at /etc/kubernetes/manifest

kubectl scale deploy app --replicas=2

kubectl get pods -n kube-system --watch

The controller manager has its cert on the host and use vol mount to mount the dir to access it
```

## Worker Nodes Failure

```yaml
kubectl get nodes

kubectl describe node worker-1

unknown flag is when it is not communicating with master node

##
journalctl -u | grep fail

top

df -h

service kubelet status

check kubeket logs:
journalctl -u kubelet

check the certificate:

openssl x509 -in /var/lib/kubelet/worker-1.crt -text

condition types - Flags:

OutOfDisk - False
MemoryPressure - False
DiskPressure - False
PIDPressure - False (too many processes)
Ready - True

```

## json

- k get nodes -o json## json
- k get nodes -o json

## JSON PATH - Nice to Have

```yaml
kubectl get nodes -o wide

kubectl get nodes -o json

json path query:
- $ not neccessary with kubectl, it does it for you:
.items[0].spec.containers[0].image


kubectl get pods -o=jsonpath='{ .items[0].spec.containers[0].image  }'

kubectl get pods -o=jsonpath='{  .items[*].metadata.name   }'

kubectl get pods -o=jsonpath='{ .items[*].status.nodeInfo.architecture }'

kubectl get pods -o=jsonpath='{ .items[*].status.capacity.cpu }'

combine both commands:

kubectl get nodes -o=jsonpath='{ .tems[*].status.nodeInfo.architecture }{"\"}{ .tems[*].status.capacity.cpu }'


kubectl get nodes -o=jsonpath='{.items[*].metadata.name}{"\n"}{.items[*].status.capacity.cpu}'


using loops:

`{range .items[*]}

     {.metadata.name} {"\t"} {.status.capacity.cpu}{"\n"}

{end}'

kubectl get nodes -o=jsonpath='{range .items[*]}{.metadata.name} {"\t"} {.status.capacity.cpu}{"\n"} {end}'


Sudo code for this:

FOR EACH NODE
  PRINT NODE NAME \t PRINT CPU COUNT \n

END FOR
`

```

```yaml
using json path for printing custom columns: Option to using loop:

kubectl get nodes -o=custom-columns=<COLUMN NAME>:<JSON PATH>

kubectl get nodes -o=custom-columns=NODE:.metadata.name,CPU:.status.capactiy.cpu

kubectl get nodes --sort-by= .metadata.name

kubectl get nodes --sort-by= .status.capacity.cpu

execise:
Use JSON PATH query to fetch node names and store them in /opt/outputs/node_names.txt.
Remember the file should only have node names.

because nodes are in list:

k get nodes -o=jsonpath='{ .items[0, 1].metadata.name}'
kubectl get nodes -o=jsonpath='{.items[*].metadata.name}' > /opt/outputs/node_names.txt



kubectl config view --kubeconfig=/root/my-kube-config -o=json


 k config view --kubeconfig=/root/my-kube-config -o=jsonpath='{ .users[*].names  }'


Use JSON PATH query to retrieve the osImages of all the nodes and store it in a file /opt/outputs/nodes_os.txt.:

The osImage is under the nodeInfo section under status of each node.Use JSON PATH query to retrieve the osImages of all the nodes and store it in a file /opt/outputs/nodes_os.txt.:

The osImage is under the nodeInfo section under status of each node.:

kubectl get nodes -o=jsonpath='{.items[*].status.nodeInfo.osImage}'


A set of Persistent Volumes are available. Sort them based on their capacity and store the result in the file /opt/outputs/storage-capacity-sorted.txt.:

```

```yaml
That was good, but we don't need all the extra details. Retrieve just the first 2 columns of output and store it in /opt/outputs/pv-and-capacity-sorted.txt.:


The columns should be named NAME and CAPACITY. Use the custom-columns option and remember, it should still be sorted as in the previous question.:

kubectl get pv --sort-by=.spec.capacity.storage -o=custom-columns=NAME:.metadata.name,CAPACITY:.spec.capacity.storage > /opt/outputs/pv-and-capacity-sorted.txt


kubectl get pv --sort-by=.spec.capacity.storage > /opt/outputs/storage-capacity-sorted.txt


Use a JSON PATH query to identify the context configured for the aws-user in the my-kube-config context file and store the result in /opt/outputs/aws-context-name.:

kubectl config view --kubeconfig=my-kube-config -o jsonpath="{.contexts[?(@.context.user=='aws-user')].name}" > /opt/outputs/aws-context-name
```

## kubelet

```yaml
working with services:
journalct -u kubelet

service kubelet status

service kubelet start

static pod kubelet:

- ca location
ls /etc/kubernetes/pki/

ls /etc/kubernetes/manifest

- config file location
vim /var/lib/kubelet/config.yaml
```

## Network Trouble shooting

```yaml
Network Plugin in Kubernetes:
——————–

There are several plugins available, and these are some.

1. Weave Net:

To install,

kubectl apply -f
https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml

You can find details about the network plugins in the following documentation :

https://kubernetes.io/docs/concepts/cluster-administration/addons/#networking-and-network-policy


2. Flannel :

To install:

kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/2140ac876ef134e0ed5af15c65e414cf26827915/Documentation/kube-flannel.yml
Note: As of now, flannel does not support Kubernetes network policies.

3. Calico :

To install:

curl https://docs.projectcalico.org/manifests/calico.yaml -O

_Apply the manifest using the following command._

kubectl apply -f calico.yaml
Calico is said to have the most advanced cni network plugin.


DNS in Kubernetes:
—————–
Kubernetes uses CoreDNS. CoreDNS is a flexible, extensible DNS server that can serve as the Kubernetes cluster DNS.

Memory and Pods:

In large scale Kubernetes clusters, CoreDNS’s memory usage is predominantly affected by the number of Pods and Services in the cluster.
Other factors include the size of the filled DNS answer cache and the rate of queries received (QPS) per CoreDNS instance.

Kubernetes resources for coreDNS are:

1. a service account named coredns,
2. cluster-roles named coredns and kube-dns
3. clusterrolebindings named coredns and kube-dns,
4. a deployment named coredns,
5. a configmap named coredns and a
6. service named kube-dns.

While analyzing the coreDNS deployment, you can see that the Corefile plugin consists of an important configuration, which is defined as a configmap.

Port 53 is used for DNS resolution.
`
kubernetes cluster.local in-addr.arpa ip6.arpa {
   pods insecure
   fallthrough in-addr.arpa ip6.arpa
   ttl 30
}
`


This is the backend to k8s for cluster. local and reverse domains.:

`proxy . /etc/resolv.conf`

Forward out of cluster domains directly to right authoritative DNS server.

Troubleshooting issues related to coreDNS
1. If you find CoreDNS pods in a pending state first check that the network plugin is installed.

2. coredns pods have CrashLoopBackOff or Error state

If you have nodes that are running SELinux with an older version of Docker, you might experience a scenario where the coredns pods are not starting. To solve that, you can try one of the following options:

a)Upgrade to a newer version of Docker.

b)Disable SELinux.

c)Modify the coredns deployment to set allowPrivilegeEscalation to true:

kubectl -n kube-system get deployment coredns -o yaml | \ sed 's/allowPrivilegeEscalation: false/allowPrivilegeEscalation: true/g' | \ kubectl apply -f -

d)Another cause for CoreDNS to have CrashLoopBackOff is when a CoreDNS Pod deployed in Kubernetes detects a loop.

There are many ways to work around this issue; some are listed here:

Add the following to your kubelet config yaml: _resolvConf: _ This flag tells kubelet to pass an alternate resolv.conf to Pods. For systems using systemd-resolved, /run/systemd/resolve/resolv.conf is typically the location of the “real” resolv.conf, although this can be different depending on your distribution.

Disable the local DNS cache on host nodes, and restore /etc/resolv.conf to the original.

A quick fix is to edit your Corefile, replacing forward . /etc/resolv.conf with the IP address of your upstream DNS, for example forward . 8.8.8.8. But this only fixes the issue for CoreDNS, kubelet will continue to forward the invalid resolv.conf to all default dnsPolicy Pods, leaving them unable to resolve DNS.

3. If CoreDNS pods and the kube-dns service is working fine, check the kube-dns service has valid endpoints.:

kubectl -n kube-system get ep kube-dns

If there are no endpoints for the service, inspect the service and make sure it uses the correct selectors and ports.

Kube-Proxy
———
kube-proxy is a network proxy that runs on each node in the cluster. kube-proxy maintains network rules on nodes. These network rules allow network communication to the Pods from network sessions inside or outside of the cluster.

In a cluster configured with kubeadm, you can find kube-proxy as a daemonset.

kubeproxy is responsible for watching services and endpoint associated with each service. When the client is going to connect to the service using the virtual IP the kubeproxy is responsible for sending traffic to actual pods.

If you run a kubectl describe ds kube-proxy -n kube-system you can see that the kube-proxy binary runs with the following command inside the kube-proxy container.

Command:

  /usr/local/bin/kube-proxy
  --config=/var/lib/kube-proxy/config.conf
  --hostname-override=$(NODE\_NAME)


So it fetches the configuration from a configuration file i.e., /var/lib/kube-proxy/config.conf and we can override the hostname with the node name at which the pod is running.

In the config file, we define the clusterCIDR, kubeproxy mode, ipvs, iptables, bindaddress, kube-config etc.

Troubleshooting issues related to kube-proxy
1. Check kube-proxy pod in the kube-system namespace is running.

2. Check kube-proxy logs.

3. Check configmap is correctly defined and the config file for running kube-proxy binary is correct.

4. kube-config is defined in the config map.

5. check kube-proxy is running inside the container

 netstat -plan | grep kube-proxy tcp 0 0 0.0.0.0:30081 0.0.0.0:* LISTEN 1/kube-proxy tcp 0 0 127.0.0.1:10249 0.0.0.0:* LISTEN 1/kube-proxy tcp 0 0 172.17.0.12:33706 172.17.0.12:6443 ESTABLISHED 1/kube-proxy tcp6 0 0 :::10256 :::* LISTEN 1/kube-proxy:

References:

Debug Service issues:

https://kubernetes.io/docs/tasks/debug-application-cluster/debug-service/

DNS Troubleshooting:

https://kubernetes.io/docs/tasks/administer-cluster/dns-debugging-resolution/

```

## 2025 Updates

```yml

kubectl ---> Authentication -----> Authorization --------> Admission Controllers  -----> create pod
Admission Controllers:

check which admission controller plugins is enabled by default:

kube-apiserver -h | grep enable-admission-plugins

kubectl exec kube-apiserver-controlplane -n kube-system -- kube-apiserver -h | grep enable-admission-plugins


vi /etc/kubernetes/manifests/kube-apiserver.yaml

- --enable-admission-plugins=NodeRestriction


Since the kube-apiserver is running as pod you can check the process to see enabled and disabled plugins.:

ps -ef | grep kube-apiserver | grep admission-plugin
update this on the manifest or service:

- --enable-admission-plugins=NodeRestriction, NamespaceAutoProvision
- --disable-admission-plugins=NodeRestriction, NamespaceAutoProvision, DefaultStorageClass


NamespaceExists and NamespaceAutoProvision are both deprecated and replaced with NamespaceLifecycle Admission Controller.


Two types of Admission controllers:
- Mutation :
   Change/mutate the object before it is created. E.g When creating a pvc, a user do not specify a storage, but a default storage class is added before the pvc object is created.

Generally, mutating controllers are invoked first before the validating ones
- Validating:
   They validate the request and allow or deny it.

There are other that can do both.


Creating custom admission controllers:
- MutatingAdmissionWebhook
- ValidatingAdmissionWebhook

Can configure the webhook to point to a server that is hosted within k8 or externally:

Our own admission webhook server sends a request to all the built-in admission controllers, it hits the webhook that was configured on the k8 server, then makes a call to the admission webhook server by passing
an admission review object in a JSON format(See diagram):

Then the admission webhook responds with an admission review object:
with a result if the request is allowed or not

Create TLS secret webhook-server-tls for secure webhook communication in webhook-demo namespace.:
We have already created below cert and key for webhook server which should be used to create secret.:

 k create secret  tls webhook-server-tls --cert=/root/keys/webhook-server-tls.crt -
-key=/root/keys/webhook-server-tls.key


Create webhook service now so that admission controller can communicate with webhook.

apiVersion: v1
kind: Service
metadata:
  name: webhook-server
  namespace: webhook-demo
spec:
  selector:
    app: webhook-server
  ports:
    - port: 443
      targetPort: webhook-api


We have added MutatingWebhookConfiguration under /root/webhook-configuration.yaml.
If we apply this configuration which resource and actions it will affect?


apiVersion: admissionregistration.k8s.io/v1
kind: MutatingWebhookConfiguration
metadata:
  name: demo-webhook
webhooks:
  - name: webhook-server.webhook-demo.svc
    clientConfig:
      service:
        name: webhook-server
        namespace: webhook-demo
        path: "/mutate"
      caBundle: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURQekNDQWllZ0F3SUJBZ0lVSk8xWm9kUWVBTXEwUHZEM1ROeG1JTkhha3Vzd0RRWUpLb1pJaHZjTkFRRUwKQlFBd0x6RXRNQ3NHQTFVRUF3d2tRV1J0YVhOemFXOXVJRU52Ym5SeWIyeHNaWElnVjJWaWFHOXZheUJFWl
    rules:
      - operations: [ "CREATE" ]
        apiGroups: [""]
        apiVersions: ["v1"]
        resources: ["pods"]
    admissionReviewVersions: ["v1beta1"]
    sideEffects: None



In previous steps we have deployed demo webhook which does below:

- Denies all request for pod to run as root in container if no securityContext is provided.

- If no value is set for runAsNonRoot, a default of true is applied, and the user ID defaults to 1234

- Allow to run containers as root if runAsNonRoot set explicitly to false in the securityContext

In next steps we have added some pod definitions file for each scenario. Deploy those pods with existing definitions file and validate the behaviour of our webhook:


Deploy a pod with no securityContext specified.

apiVersion: v1
kind: Pod
metadata:
  name: pod-with-defaults
  labels:
    app: pod-with-defaults
spec:
  restartPolicy: OnFailure
  containers:
    - name: busybox
      image: busybox
      command: ["sh", "-c", "echo I am running as user $(id -u)"]

Deploy pod with a securityContext explicitly allowing it to run as root:

apiVersion: v1
kind: Pod
metadata:
  name: pod-with-override
  labels:
    app: pod-with-override
spec:
  restartPolicy: OnFailure
  securityContext:
    runAsNonRoot: false
  containers:
    - name: busybox
      image: busybox
      command: ["sh", "-c", "echo I am running as user $(id -u)"]


k get pods pod-with-override -o yaml  | grep -i -A2  "security:



Deploy a pod with a conflicting securityContext i.e. pod running with a user id of 0 (root)
Mutating webhook should reject the request as its asking to run as root user without setting runAsNonRoot: false

response:

 k create -f pod-with-conflict.yaml
Error from server: error when creating "pod-with-conflict.yaml": admission webhook "webhook-server.webhook-demo.svc" denied the request: runAsNonRoot specified, but runAsUser set to 0 (the root user)


apiVersion: v1
kind: Pod
metadata:
  name: pod-with-conflict
  labels:
    app: pod-with-conflict
spec:
  restartPolicy: OnFailure
  securityContext:
    runAsNonRoot: true
    runAsUser: 0
  containers:
    - name: busybox
      image: busybox
      command: ["sh", "-c", "echo I am running as user $(id -u)"]
```

<img src="https://github.com/sheyijojo/kubernetes_CKA_Exams/blob/main/pdfs/admission-controller-webhook.png?raw=true" alt="Description" width="800">

<img src="https://github.com/sheyijojo/kubernetes_CKA_Exams/blob/main/pdfs/admission-review-object.png?raw=true" alt="Description" width="800">

## webhook server sample Go, Python sudo

<img src="https://github.com/sheyijojo/kubernetes_CKA_Exams/blob/main/pdfs/web-hookserver-external.png?raw=true" alt="Description" width="500">

<img src="https://github.com/sheyijojo/kubernetes_CKA_Exams/blob/main/pdfs/webhook-server-sudocode-python.png?raw=true" alt="Description" width="500">

<img src="https://github.com/sheyijojo/kubernetes_CKA_Exams/blob/main/pdfs/webhook-server-sudo-2.png?raw=true" alt="Description" width="500">

## Updates 2025 - Helm

<img src="https://github.com/sheyijojo/kubernetes_CKA_Exams/blob/main/pdfs/helmchart.png?raw=true" alt="Description" width="500">

```yml
Helm Chart:
Helm work as a package manager and release manager. Also help us to treat kurbernetes as Apps:


sudo snap install --classic


helm install wordpress (rev1)

helm upgrade wordpress (rev2)

helm rollback wordpress (rev3)


Charts are a collection of files. They contain instructions that Helm needs to know to create the collection of objects needed in a k8 :cluster.

By using charts and objects, helm in a way intsalls application in my cluster.:

When a chart is applied to my cluster, a RELEASE is created. A release is single installation of an app using a Helm Chart.
On each release, you can have multiple revisions.Each rev is like a snapshot of the application.


We can find helm charts in public repos and use them. :

Helm produces metadata and needs somewhere to save it. It saves it as a k8 Secret.:

artifacthub.io:
- you see thousand of charts there



components of helm chart:
- templates(folder)
- values.yaml
- Chart.yaml
- LICENSE
- README.md
type - application or library

helm commands:

helm search hub wordpress

add bitnami hel chart repo to the cluster
helm repo add bitnami https://charts.bitnami.com/bitnami



helm install my-release bitnami/wordpress

helm search repo wordpress

helm list

helm unistall my-release


helm repo list

helm repo update


Customizing Helm Chart Parameters:

set before installing:
helm install --set wordpressBlogName="Helm Tutorials" my-release bitnami/wordpress

custom values:
helm install --values custom-values.yml my-release bitnami/wordpress

can pull:
helm pull bitnami/wordpress
helm pull --untar bitnami/wordpress

helm install my-release ./wordpress


Helm Lifescycle Management:

example:

helm install nginx-release bitnami/nginx --version 7.1.0

wanna make changes to config objs or objs:
k get pods

k describe pod and set bitnami image

wanna upgrade a release:
helm upgrade nginx-release bitnami/nginx

upgrade a release app version from 1.22.0 to 1.23.X:
- To get this, need to upgrade the chart from current version of nginx-12.0.4 to 13.
- 13 contains app version of 1.23. 0  :
- I upgraded mine to 18, which is the latest chart version, downloaded on my k8n portal:

helm upgrade dazzling-web bitnami/nginx --version 18

but the current andswer is --version 13 which gives app version of 1.23.4 specifically

rollback to version 3:

helm rollback dazzling-web 3

see current revision:
helm list


check all revisions:
helm history nginx-release


helm rollback nginx-release 1
 technically doesnt go back to revision 1, creates another revision 3 but same config with revision 1:

pvs, database, external data, rollback won't restore the data. There are options to do that using charthooks.



```

## Helm- Helloworld

<img src="https://github.com/sheyijojo/kubernetes_CKA_Exams/blob/main/pdfs/helm-helloworld.png?raw=true" alt="Description" width="500">

## Heml - wordpress

<img src="https://github.com/sheyijojo/kubernetes_CKA_Exams/blob/main/pdfs/helm-wordpress.png?raw=true" alt="Description" width="500">

## Kustomize

<img src="https://github.com/sheyijojo/kubernetes_CKA_Exams/blob/main/pdfs/kustomize.png?raw=true" alt="Description" width="500">

## Kustomize

```yml

Managing environment :

Same deployment but different config for each env :

dev/nginx.yml  stg/nginx.yml  prod/nginx.yml :

k apply of dev/nginx
This is just scaling the replicas. This is not a scalable solution:

Comes built in to kubctl, but still need to check for latest version , k doesnt come with latest version
Two concepts
Base config: Default accross your environment
Overlays: customize behaviors per env basis

overlays/dev  , overlays/stg, overlays/prod

Kustomize
Base + Overlay  ==  Final Manifests


Kustomize vs Helm :

Helm use of go templates to allow assinging var to properties
Helm is more than just a tool to customize configs on a per env basis. Helm is also a package manager for your app
Helm provides conditionals, loops, functions, amd hooks
Helm templates are not valid YAML as thet use go templating
Helm is complex templates become hard to read unlike Kustomize which is pure yaml.



Install Kustomize

curl gitbusocnten masster/hack-----

kustomize version --short :



structure  :

k8s folder
   nginx-depl.yaml
   nginx-service
   kustomization.yaml


kustomization.yaml
##kurbenetes resources that need to be managed by kustomize
resources:
  - nginx-deploy.yaml
  - nginx-service.yaml

##Customizations that need to be made
commonLabels:
  company: mycompany


kustomize build k8s/

output: service,  nginx
The Kustomize build command combines all the manifests and applies the defined transformations

The Kustomize build command does not apply/deploy the kubernetes resources to a cluster
  - The output needs to be redirected to the kubectl apply command


to run it:

kustomize build k8s/ | kubectl apply -f -

do it natively:
kubectl apply -k k8s/

to delete:
kustomize build k8s/ | kubectl delete -f -
kubectl delete -k k8s/


apiVersion: hard code it, even though it takes default

managing directories:
kubectl apply -f k8s/api/

kubectl apply -f k8s/db/

This becomes to get cubersome :
- go to k8s folder and and place Kustomization in the directory
- Because we get to add kustomizatin.yml in each dir
resources:
  - api/api-deply.yaml
  - api/api-service.yaml
  - db/db-deply.yaml
  - db/db-service.yaml
##Customizations that need to be made
commonLabels:
  company: mycompany

kustomize build k8s/ | kubectl apply -f -

Not still a perfect solution:

add a seperate kustomization.yaml in each sub-directories and still have root Kustomization.yaml

resources:
  - api/
  - db/
  - cache/
  - kafka/

kustomize build k8s/ | kubectl apply -f -


This becomes cumbersom:

kubectl apply -f k8s/ | kubectl apply -f k8s/cache -f k8s/api -f k8s/db

kubectl delete -f k8s/ | kubectl apply -f k8s/cache -f k8s/api -f k8s/db

using kustomize:
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
- api/api-deply.yaml
- cache/redis-deply.yaml



kustomize build k8s/

kustomize build k8s/ | kubectl apply -f -

kubectl apply -k k8s/


Best solution
Create a kustomization.yaml in each suub-directories and a root kustomization.yaml.:
Reference the sub-directory kustomization.yaml in in the root

Example:
sub directories:
api, cache, db

api subdirectory
k8s/api/
   api-deply.yaml
   api-service.yaml
   kustomization.yaml

Now the api kustomization.yaml file in the api folder

##kurbenetes resources that need to be managed by kustomize
resources:
  - api-deply.yaml
  - api-service.yaml

now do it for the rest of the subfolders, cache and db

in the root folder:
k8s/kustomization.yaml

apiVersion: Kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - api/
  - cache/
  - db/

kustomize build k8s/
kustomize build k8s/ | kubectl apply -f -



```

<img src="https://github.com/sheyijojo/kubernetes_CKA_Exams/blob/main/pdfs/managing-directories.png?raw=true" alt="Description" width="500">

## kustomization continues

```yml
common transformers:
commonLabel
namePrefix/Suffix
Namespace
commonAnnotations

kustomization.yaml
namePrefix: kodekloud-
nameSuffix: -dev
namespace: lab
commonAnnotations:
  branch: master


Image Transformers:
kustomization.yaml

images:
  - name: nginx
    newName: haproxy

can also do for tags:
images:
  - name: nginx
    newTag: 2.4

or combine both
images:
  - name: nginx
    newName: haproxy
    newTag: 2.4




```

<img src="https://github.com/sheyijojo/kubernetes_CKA_Exams/blob/main/pdfs/commonLabel-transformers.png?raw=true" alt="Description" width="500">

<img src="https://github.com/sheyijojo/kubernetes_CKA_Exams/blob/main/pdfs/image-transformation.png?raw=true" alt="Description" width="500">

<img src="https://github.com/sheyijojo/kubernetes_CKA_Exams/blob/main/pdfs/image-transformation-02.png?raw=true" alt="Description" width="500">

## Patches

<img src="https://github.com/sheyijojo/kubernetes_CKA_Exams/blob/main/pdfs/patches.png?raw=true" alt="Description" width="500">

<img src="https://github.com/sheyijojo/kubernetes_CKA_Exams/blob/main/pdfs/patches-02.png?raw=true" alt="Description" width="500">

### Json vs Strategic merge patach

<img src="https://github.com/sheyijojo/kubernetes_CKA_Exams/blob/main/pdfs/patches-03.png?raw=true" alt="Description" width="500">

```yaml
Patches is another method to modifying kubernetes configs

Two ways of working with patches

json 6902 Patch
Strategic merge Patch
```

### Inline vs seperate file

<img src="https://github.com/sheyijojo/kubernetes_CKA_Exams/blob/main/pdfs/patches-04.png?raw=true" alt="Description" width="500">

<img src="https://github.com/sheyijojo/kubernetes_CKA_Exams/blob/main/pdfs/patches-05.png?raw=true" alt="Description" width="500">

## Patches Dictionary

<img src="https://github.com/sheyijojo/kubernetes_CKA_Exams/blob/main/pdfs/patches-06.png?raw=true" alt="Description" width="500">

<img src="https://github.com/sheyijojo/kubernetes_CKA_Exams/blob/main/pdfs/patches-07.png?raw=true" alt="Description" width="500">

<img src="https://github.com/sheyijojo/kubernetes_CKA_Exams/blob/main/pdfs/patches-08.png?raw=true" alt="Description" width="500">

<img src="https://github.com/sheyijojo/kubernetes_CKA_Exams/blob/main/pdfs/patches-09.png?raw=true" alt="Description" width="500">

<img src="https://github.com/sheyijojo/kubernetes_CKA_Exams/blob/main/pdfs/patches-10.png?raw=true" alt="Description" width="500">

<img src="https://github.com/sheyijojo/kubernetes_CKA_Exams/blob/main/pdfs/patches-11.png?raw=true" alt="Description" width="500">

## patch list Operations

<img src="https://github.com/sheyijojo/kubernetes_CKA_Exams/blob/main/pdfs/patches-12.png?raw=true" alt="Description" width="500">

<img src="https://github.com/sheyijojo/kubernetes_CKA_Exams/blob/main/pdfs/patches-13.png?raw=true" alt="Description" width="500">

<img src="https://github.com/sheyijojo/kubernetes_CKA_Exams/blob/main/pdfs/patches-14.png?raw=true" alt="Description" width="500">

<img src="https://github.com/sheyijojo/kubernetes_CKA_Exams/blob/main/pdfs/patches-15.png?raw=true" alt="Description" width="500">

<img src="https://github.com/sheyijojo/kubernetes_CKA_Exams/blob/main/pdfs/patches-16.png?raw=true" alt="Description" width="500">

<img src="https://github.com/sheyijojo/kubernetes_CKA_Exams/blob/main/pdfs/patches-17.png?raw=true" alt="Description" width="500">

## Overlays

```yml
Putting everything together and understand use cases of using kustomize

Can add new config that is not present in the base folder. More like additional customization per overlays/
```

<img src="https://github.com/sheyijojo/kubernetes_CKA_Exams/blob/main/pdfs/patches-18.png?raw=true" alt="Description" width="500">

<img src="https://github.com/sheyijojo/kubernetes_CKA_Exams/blob/main/pdfs/patches-19.png?raw=true" alt="Description" width="500">

<img src="https://github.com/sheyijojo/kubernetes_CKA_Exams/blob/main/pdfs/patches-20.png?raw=true" alt="Description" width="500">

<img src="https://github.com/sheyijojo/kubernetes_CKA_Exams/blob/main/pdfs/patches-21.png?raw=true" alt="Description" width="500">

## Components

```yaml
Components provide the ability to define resuable pieces of configuration logic(resources + patches) that can be included in multiple overlays

Components are useful in situations where apps support mutliple optional features that need to be enabled only in a subset of overlays
```

<img src="https://github.com/sheyijojo/kubernetes_CKA_Exams/blob/main/pdfs/patches-22.png?raw=true" alt="Description" width="500">

<img src="https://github.com/sheyijojo/kubernetes_CKA_Exams/blob/main/pdfs/patches-23.png?raw=true" alt="Description" width="500">

<img src="https://github.com/sheyijojo/kubernetes_CKA_Exams/blob/main/pdfs/patches-24.png?raw=true" alt="Description" width="500">

<img src="https://github.com/sheyijojo/kubernetes_CKA_Exams/blob/main/pdfs/patches-25.png?raw=true" alt="Description" width="500">

## Examples - Patches

```yaml
resources:
  - mongo-depl.yaml
  - nginx-depl.yaml
  - mongo-service.yaml

patches:
  - target:
      kind: Deployment
      name: nginx-deployment
    patch: |-
      - op: replace
        path: /spec/replicas
        value: 3

  - target:
      kind: Deployment
      name: mongo-deployment
    path: mongo-label-patch.yaml

  - target:
      kind: Service
      name: mongo-cluster-ip-service
    patch: |-
      - op: replace
        path: /spec/ports/0/port
        value: 30000

      - op: replace
        path: /spec/ports/0/targetPort
        value: 30000


In api-patch.yaml create a strategic merge patch to remove the memcached container.:
api-depl.yaml:

apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      component: api
  template:
    metadata:
      labels:
        component: api
    spec:
      containers:
        - name: nginx
          image: nginx
        - name: memcached
          image: memcached


api-patch.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-deployment
spec:
  template:
    spec:
      containers:
        - $patch: delete
          name: memcached

kustomize build k8s/ | kubectl apply -f -


Create an inline json6902 patch in the kustomization.yaml file to remove the label org: KodeKloud from the mongo-deployment.:


mongo-deply.yaml:

apiVersion: apps/v1
kind: Deployment
metadata:
  name: mongo-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      component: mongo
  template:
    metadata:
      labels:
        component: mongo
        org: KodeKloud
    spec:
      containers:
        - name: mongo
          image: mongo

kustomization.yaml

resources:
  - mongo-depl.yaml
  - api-depl.yaml
  - mongo-service.yaml

patches:
  - target:
      kind: Deployment
      name: mongo-deployment
    patch: |-
      - op: remove
        path: /spec/template/metadata/labels/org


Question:
Update the api image in the api-deployment to use caddy docker image in the QA environment.:

Perform this using an inline JSON6902 patch.:
Note: Please ensure to apply the updated config for QA environment before validation.:


k8s/overlays/QA/kustomization.yaml :

bases:
  - ../../base
commonLabels:
  environment: QA

patches:
  - target:
      kind: Deployment
      name: api-deployment
    patch: |-
          - op: replace
            path: /spec/template/spec/containers/0/image
            value: caddy


k8s/base/api-deployment.yaml :

apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-deployment
spec:
  replicas: 2
  selector:
    matchLabels:
      component: api
  template:
    metadata:
      labels:
        component: api
    spec:
      containers:
        - name: api
          image: nginx
          env:
            - name: DB_CONNECTION
              value: db.kodekloud.com


kustomize build  k8s/overlays/QA/ | kubectl apply -f -
```

## Security (2025 Updates)

```yaml
Custom Resource Definition (CRD)

CRD needs a Custom Controller to create the CRD object
```

<img src="https://github.com/sheyijojo/kubernetes_CKA_Exams/blob/main/pdfs/sec01.png?raw=true" alt="Description" width="500">

<img src="https://github.com/sheyijojo/kubernetes_CKA_Exams/blob/main/pdfs/sec02.png?raw=true" alt="Description" width="500">

<img src="https://github.com/sheyijojo/kubernetes_CKA_Exams/blob/main/pdfs/sec03.png?raw=true" alt="Description" width="500">

## Exams

```yml
k expose pod messaging --name=messaging-service --port=6379 --type=ClusterIP --labels tier=msg

question

Create a static pod named static-busybox on the controlplane node that uses the busybox image and the command sleep 1000:
kubectl run --restart=Never --image=busybox static-busybox --dry-run=client -o yaml --command -- sleep 1000 > /etc/kubernetes/manifests/static-busybox.yaml


Expose the hr-web-app created in the previous task as a service named hr-web-app-service, accessible on port 30082 on the nodes of the cluster.:
The web application listens on port 8080.:

kubectl expose deployment hr-web-app --type=NodePort --port=8080 --name=hr-web-app-service --dry-run=client -o yaml > hr-web-app-service.yaml


Now, in generated service definition file add the nodePort field with the given port number under the ports section and create a service.:

my solution mistake:

 k expose deployment hr-web-app --type=NodePort --port=8080  --target-port=30082 --name=hr-web-app-service --labels app=hr-web-app



ques 11:
Task
Use JSON PATH query to retrieve the osImages of all the nodes and store it in a file /opt/outputs/nodes_os_x43kj56.txt.:
The osImage are under the nodeInfo section under status of each node. :

 kubectl get nodes -o jsonpath='{.items[*].status.nodeInfo.osImage}' > /opt/outputs/nodes_os_x43kj56.txt


ques12:
Create a Persistent Volume with the given specification: -

Volume name: pv-analytics

Storage: 100Mi

Access mode: ReadWriteMany
Host path: /pv/data-analytics

answer:
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-analytics
spec:
  capacity:
    storage: 100Mi
  volumeMode: Filesystem
  accessModes:
    - ReadWriteMany
  hostPath:
      path: /pv/data-analytics


my solution mistake:
apiVersion: v1
kind: PersistentVolume
metadata:
  name: foo-pv
spec:
  storageClassName: ""
  capacity:
    storage: 100Mi
  accessModes:
    - ReadWriteMany
  volumes:
  - name: pv-analytics
    # mount /data/foo, but only if that directory already exists
    hostPath:
      path: /pv/data-analytics # directory location on host
      type: Directory # this field is optional
```

exam 2

```yml

A pod definition file is created at /root/CKA/use-pv.yaml. Make use of this manifest file and mount the persistent volume called pv-1. Ensure the pod is running and the PV is bound.

mountPath: /data

persistentVolumeClaim Name: my-pvc

Solution
Add a persistentVolumeClaim definition to pod definition file.

Solution manifest file to create a pvc my-pvc as follows:
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-pvc
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
       storage: 10Mi

apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: use-pv
  name: use-pv
spec:
  containers:
  - image: nginx
    name: use-pv
    volumeMounts:
    - mountPath: "/data"
      name: mypd
  volumes:
    - name: mypd
      persistentVolumeClaim:
        claimName: my-pvc




Task
Create a new deployment called nginx-deploy, with image nginx:1.16 and 1 replica. Next upgrade the deployment to version 1.17 using rolling update.

Explore the --record option while creating the deployment while working with the deployment definition file. Then make use of the kubectl apply command to create or update the deployment.

To create a deployment definition file nginx-deploy:

$ kubectl create deployment nginx-deploy --image=nginx:1.16 --dry-run=client -o yaml > deploy.yaml

$ kubectl apply -f deploy.yaml --record

To create a resource from definition file and to record:

$ kubectl apply -f deploy.yaml --record

To view the history of deployment nginx-deploy:

$ kubectl rollout history deployment nginx-deploy

To upgrade the image to next given version:

$ kubectl set image deployment/nginx-deploy nginx=nginx:1.17 --record

To view the history of deployment nginx-deploy:

$ kubectl rollout history deployment nginx-deploy

Details




Create a new user called john. Grant him access to the cluster. John should have permission to create, list, get, update and delete pods in the development namespace . The private key exists in the location: /root/CKA/john.key and csr at /root/CKA/john.csr.

Important Note: As of kubernetes 1.19, the CertificateSigningRequest object expects a signerName.

Please refer the documentation to see an example. The documentation tab is available at the top right of terminal.


---
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: john-developer
spec:
  signerName: kubernetes.io/kube-apiserver-client
  request: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURSBSRVFVRVNULS0tLS0KTUlJQ1ZEQ0NBVHdDQVFBd0R6RU5NQXNHQTFVRUF3d0VhbTlvYmpDQ0FTSXdEUVlKS29aSWh2Y05BUUVCQlFBRApnZ0VQQURDQ0FRb0NnZ0VCQUt2Um1tQ0h2ZjBrTHNldlF3aWVKSzcrVVdRck04ZGtkdzkyYUJTdG1uUVNhMGFPCjV3c3cwbVZyNkNjcEJFRmVreHk5NUVydkgyTHhqQTNiSHVsTVVub2ZkUU9rbjYra1NNY2o3TzdWYlBld2k2OEIKa3JoM2prRFNuZGFvV1NPWXBKOFg1WUZ5c2ZvNUpxby82YU92czFGcEc3bm5SMG1JYWpySTlNVVFEdTVncGw4bgpjakY0TG4vQ3NEb3o3QXNadEgwcVpwc0dXYVpURTBKOWNrQmswZWhiV2tMeDJUK3pEYzlmaDVIMjZsSE4zbHM4CktiSlRuSnY3WDFsNndCeTN5WUFUSXRNclpUR28wZ2c1QS9uREZ4SXdHcXNlMTdLZDRaa1k3RDJIZ3R4UytkMEMKMTNBeHNVdzQyWVZ6ZzhkYXJzVGRMZzcxQ2NaanRxdS9YSmlyQmxVQ0F3RUFBYUFBTUEwR0NTcUdTSWIzRFFFQgpDd1VBQTRJQkFRQ1VKTnNMelBKczB2czlGTTVpUzJ0akMyaVYvdXptcmwxTGNUTStsbXpSODNsS09uL0NoMTZlClNLNHplRlFtbGF0c0hCOGZBU2ZhQnRaOUJ2UnVlMUZnbHk1b2VuTk5LaW9FMnc3TUx1a0oyODBWRWFxUjN2SSsKNzRiNnduNkhYclJsYVhaM25VMTFQVTlsT3RBSGxQeDNYVWpCVk5QaGhlUlBmR3p3TTRselZuQW5mNm96bEtxSgpvT3RORStlZ2FYWDdvc3BvZmdWZWVqc25Yd0RjZ05pSFFTbDgzSkljUCtjOVBHMDJtNyt0NmpJU3VoRllTVjZtCmlqblNucHBKZWhFUGxPMkFNcmJzU0VpaFB1N294Wm9iZDFtdWF4bWtVa0NoSzZLeGV0RjVEdWhRMi80NEMvSDIKOWk1bnpMMlRST3RndGRJZjAveUF5N05COHlOY3FPR0QKLS0tLS1FTkQgQ0VSVElGSUNBVEUgUkVRVUVTVC0tLS0tCg==
  usages:
  - digital signature
  - key encipherment
  - client auth



To approve this certificate, run: kubectl certificate approve john-developer

Next, create a role developer and rolebinding developer-role-binding, run the command:

$ kubectl create role developer --resource=pods --verb=create,list,get,update,delete --namespace=development

$ kubectl create rolebinding developer-role-binding --role=developer --user=john --namespace=development

To verify the permission from kubectl utility tool:

$ kubectl auth can-i update pods --as=john --namespace=development









Create a nginx pod called nginx-resolver using image nginx, expose it internally with a service called nginx-resolver-service. Test that you are able to look up the service and pod names from within the cluster. Use the image: busybox:1.28 for dns lookup. Record results in /root/CKA/nginx.svc and /root/CKA/nginx.pod

Use the command kubectl run and create a nginx pod and busybox pod. Resolve it, nginx service and its pod name from busybox pod.

To create a pod nginx-resolver and expose it internally:

kubectl run nginx-resolver --image=nginx
kubectl expose pod nginx-resolver --name=nginx-resolver-service --port=80 --target-port=80 --type=ClusterIP


To create a pod test-nslookup. Test that you are able to look up the service and pod names from within the cluster:
kubectl run test-nslookup --image=busybox:1.28 --rm -it --restart=Never -- nslookup nginx-resolver-service
kubectl run test-nslookup --image=busybox:1.28 --rm -it --restart=Never -- nslookup nginx-resolver-service > /root/CKA/nginx.svc


Get the IP of the nginx-resolver pod and replace the dots(.) with hyphon(-) which will be used below.

kubectl get pod nginx-resolver -o wide
kubectl run test-nslookup --image=busybox:1.28 --rm -it --restart=Never -- nslookup <P-O-D-I-P.default.pod> > /root/CKA/nginx.pod






Create a static pod on node01 called nginx-critical with image nginx and make sure that it is recreated/restarted automatically in case of a failure.:

Use /etc/kubernetes/manifests as the Static Pod path for example.

To create a static pod called nginx-critical by using below command:
kubectl run nginx-critical --image=nginx --dry-run=client -o yaml > static.yaml

Copy the contents of this file or use scp command to transfer this file from controlplane to node01 node.

scp static.yaml node01:/root/
 kubectl get nodes -o wide

Perform SSH:
root@controlplane:~# ssh node01
OR
root@controlplane:~# ssh <IP of node01>

On node01 node:

Check if static pod directory is present which is /etc/kubernetes/manifests, if it's not present then create it.

root@node01:~# mkdir -p /etc/kubernetes/manifests

Add that complete path to the staticPodPath field in the kubelet config.yaml file.

root@node01:~# vi /var/lib/kubelet/config.yaml


now, move/copy the static.yaml to path /etc/kubernetes/manifests/.

Go back to the controlplane node and check the status of static pod:

root@node01:~# exit
logout
root@controlplane:~# kubectl get pods
```

Exams practice

```yaml
Print the names of all deployments in the admin2406 namespace in the following format:

DEPLOYMENT   CONTAINER_IMAGE   READY_REPLICAS   NAMESPACE

<deployment name>   <container image used>   <ready replica count>   <Namespace>
. The data should be sorted by the increasing order of the deployment name.

Example:

DEPLOYMENT   CONTAINER_IMAGE   READY_REPLICAS   NAMESPACE
deploy0   nginx:alpine   1   admin2406
Write the result to the file /opt/admin2406_data.




kubectl -n admin2406 get deployment -o custom-columns=DEPLOYMENT:.metadata.name,CONTAINER_IMAGE:.spec.template.spec.containers[].image,READY_REPLICAS:.status.readyReplicas,NAMESPACE:.metadata.namespace --sort-by=.metadata.name > /opt/admin2406_data

my solution:
k get deployments.apps -n admin2406 -o=custom-columns=DEPLOYMENT:.metadata.name,CONTAINER_IMAGE:.spec.template.spec.containers[].image,READY_REPLICAS:.status.readyReplicas,NAMESPACE:.metadata.namespace --sort-by=.metadata.name


2. A kubeconfig file called admin.kubeconfig has been created in /root/CKA. There is something wrong with the configuration. Troubleshoot and fix it.

Solution
Make sure the port for the kube-apiserver is correct. So for this change port from 4380 to 6443.

Run the below command to know the cluster information:

kubectl cluster-info --kubeconfig /root/CKA/admin.kubeconfig


3.
A new deployment called alpha-mysql has been deployed in the alpha namespace. However, the pods are not running. Troubleshoot and fix the issue. The deployment should make use of the persistent volume alpha-pv to be mounted at /var/lib/mysql and should use the environment variable MYSQL_ALLOW_EMPTY_PASSWORD=1 to make use of an empty root password.

Important: Do not alter the persistent volume.

Use the command kubectl describe and try to fix the issue.

Solution manifest file to create a pvc called mysql-alpha-pvc as follows:

---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mysql-alpha-pvc
  namespace: alpha
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
  storageClassName: slow

4.
Create a pod called secret-1401 in the admin1401 namespace using the busybox image. The container within the pod should be called secret-admin and should sleep for 4800 seconds.

The container should mount a read-only secret volume called secret-volume at the path /etc/secret-volume. The secret being mounted has already been created for you and is called dotfile-secret.

Use the command kubectl run to create a pod definition file. Add secret volume and update container name in it.

Alternatively, run the following command:

kubectl run secret-1401 -n admin1401 --image=busybox --dry-run=client -o yaml --command -- sleep 4800 > admin.yaml


---
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: secret-1401
  name: secret-1401
  namespace: admin1401
spec:
  volumes:
  - name: secret-volume
    # secret volume
    secret:
      secretName: dotfile-secret
  containers:
  - command:
    - sleep
    - "4800"
    image: busybox
    name: secret-admin
    #volumes' mount path
    volumeMounts:
    - name: secret-volume
      readOnly: true
      mountPath: "/etc/secret-volume"

```

## exam part 3

```yml
kubectl get nodes -o json | jq -c 'paths'

kubectl get nodes -o json | jq -c 'paths | grep type | grep -v condition

kubectl get nodes -o jsonpath='{ .items}' | jq

kubectl get nodes -o jsonpath='{ .items[*].status.addresses[?(@.type=="InternalIP)].addresses}'


curl an ip using sample container:

k run sample --image=alpine/curl -rm -it -- sh

curl np-test-service


kubectl get nodes -o jsonpath='{.items[*].status.addresses[?(@.type=="InternalIP")].address}' > /root/CKA/node_ips

kubectl get pods -o jsonpath='{ .items[*].status.addresses[?(@type=="InternalIP")].address }'


apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: multi-pod
  name: multi-pod
spec:
  containers:
  - image: nginx
    name: alpha
    env:
      - name: name
        value: "alpha"

  - image: busybox
    name: beta
    command: ["sleep", "4800"]
    env:
    - name: name
      value: "beta"
    resources: {}
  dnsPolicy: ClusterFirst
  restartPolicy: Always
status: {}
```

## exam 2

```yaml

student-node ~ ➜  kubectl top node --context cluster1 --no-headers | sort -nr -k2 | head -1
cluster1-controlplane   127m   1%    703Mi   1%

student-node ~ ➜  kubectl top node --context cluster2 --no-headers | sort -nr -k2 | head -1
cluster2-controlplane   126m   1%    675Mi   1%

student-node ~ ➜  kubectl top node --context cluster3 --no-headers | sort -nr -k2 | head -1
cluster3-controlplane   577m   7%    1081Mi   1%

student-node ~ ➜  kubectl top node --context cluster4 --no-headers | sort -nr -k2 | head -1
cluster4-controlplane   130m   1%    679Mi   1%

helm install --generate-name ./new-version

helm uninstall webpage-server-01 -n default

Deploy a Vertical Pod Autoscaler (VPA) named analytics-vpa for a deployment named analytics-deployment in the cka24456 namespace. The VPA should automatically adjust the CPU and memory requests of the pods to optimize resource utilization. Ensure that the VPA operates in Auto mode, allowing it to evict and recreate pods with updated resource requests as needed.

apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: analytics-vpa
  namespace: cka24456
spec:
  targetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: analytics-deployment
  updatePolicy:
    updateMode: "Auto"

    student-node ~ ➜  kubectl -n beta-cka01-arch logs beta-pod-cka01-arch --context cluster1 | grep ERROR > /root/beta-pod-cka01-arch_errors


curl http://cluster3-controlplane:NODE-PORT

To make the application work, create a new secret called db-secret-wl05 with the following key values: -

1. DB_Host=mysql-svc-wl05
2. DB_User=root
3. DB_Password=password123

Next, configure the web application pod to load the new environment variables from the newly created secret.


Note: Check the web application again using the curl command, and the status of the application should be success.
kubectl create secret generic db-secret-wl05 -n canara-wl05 --from-literal=DB_Host=mysql-svc-wl05 --from-literal=DB_User=root --from-literal=DB_Password=password123

---
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: webapp-pod-wl05
  name: webapp-pod-wl05
  namespace: canara-wl05
spec:
  containers:
  - image: kodekloud/simple-webapp-mysql
    name: webapp-pod-wl05
    envFrom:
    - secretRef:
        name: db-secret-wl05


curl http://10.17.63.11:31020


curl http://kodekloud-ingress.app

kubectl get ingress
kubectl edit ingress nodeapp-ing-cka08-trb

Under rules: -> host: change example.com to kodekloud-ingress.app
Under backend: -> service: -> name: Change example-service to nodeapp-svc-cka08-trb
Change port: -> number: from 80 to 3000
You should be able to access the app using curl http://kodekloud-ingress.app command now.



Modify the existing web-gateway on cka5673 namespace to handle HTTPS traffic on port 443 for kodekloud.com, using a TLS certificate stored in a secret named kodekloud-tls.

apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: web-gateway
  namespace: cka5673
spec:
  gatewayClassName: kodekloud
  listeners:
    - name: https
      protocol: HTTPS
      port: 443
      hostname: kodekloud.com
      tls:
        certificateRefs:
          - name: kodekloud-tls



  Extend the web-route on cka7395 to direct traffic with the path prefix /api to a service named api-service on port 8080, while all other traffic continues to route to web-service.

  apiVersion: gateway.networking.k8s.io/v1
  kind: HTTPRoute
  metadata:
    name: web-route
    namespace: cka7395
  spec:
    parentRefs:
    - name: nginx-gateway
      namespace: nginx-gateway
    rules:
    - matches:
      - path:
          type: PathPrefix
          value: /api
      backendRefs:
      - name: api-service
        port: 8080
    - matches:
      - path:
          type: PathPrefix
          value: /
      backendRefs:
      - name: web-service
        port: 80


    journalctl -u kubelet -f

    journalctl -u kubelet -f | grep -v 'connect: connection refused'


    Search for etcd-cert, you will notice that the volume name is etcd-certs but the volume mount is trying to mount etcd-cert volume which is incorrect. Fix the volume mount name and save the changes. Let's restart kubelet service after that.

    systemctl restart kubelet

    ETCDCTL_API=3 etcdctl --endpoints=https://[127.0.0.1]:2379 --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/server.crt --key=/etc/kubernetes/pki/etcd/server.key snapshot save /opt/etcd-boot-cka18-trb.db


```

## exam 3

```

kubectl get deploy -n <NAMESPACE> <DEPLOYMENT-NAME> -o json | jq -r '.spec.template.spec.containers[].image'

kubectl get pods --show-labels -n spectra-1267

student-node ~ ➜  kubectl get pods -n spectra-1267 -o=custom-columns='POD_NAME:metadata.name,IP_ADDR:status.podIP' --sort-by=.status.podIP

POD_NAME   IP_ADDR
pod-12     10.42.0.18
pod-23     10.42.0.19
pod-34     10.42.0.20
pod-21     10.42.0.21
...

# store the output to /root/pod_ips
student-node ~ ➜  kubectl get pods -n spectra-1267 -o=custom-columns='POD_NAME:metadata.name,IP_ADDR:status.podIP' --sort-by=.status.podIP > /root/pod_ips_cka05_svcn



Next, create a Horizontal Pod Autoscaler (HPA) named web-ui-hpa to manage the scaling of the web-ui-deployment. This HPA should be configured to respond to CPU utilization, increasing the number of pods by 20% when CPU utilization exceeds 65%. Additionally, set the scale-up behavior to apply every 45 seconds, and configure the scale-down behavior to reduce the number of pods by 10% every 60 seconds. Use the following configuration:



apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: web-ui-hpa
  namespace: ck1967
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: web-ui-deployment
  minReplicas: 2
  maxReplicas: 12
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 65
  behavior:
    scaleUp:
      policies:
        - type: Percent
          value: 20
          periodSeconds: 45
    scaleDown:
      policies:
        - type: Percent
          value: 10
          periodSeconds: 60




student-node ~ ➜  echo cluster3,cluster3-controlplane > /opt/high_memory_node


apiVersion: v1
kind: Pod
metadata:
  name: looper-cka16-arch
spec:
  containers:
  - name: busybox
    image: busybox
    command: ["/bin/sh", "-c", "while true; do echo hello; sleep 10;done"]


A pod definition file is created at /root/peach-pod-cka05-str.yaml on the student-node. Update this manifest file to create a persistent volume claim called peach-pvc-cka05-str to claim a 100Mi of storage from peach-pv-cka05-str PV (this is already created). Use the access mode ReadWriteOnce.


Further add peach-pvc-cka05-str PVC to peach-pod-cka05-str POD and mount the volume at /var/www/html location. Ensure that the pod is running and the PV is bound.

apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: peach-pvc-cka05-str
spec:
  volumeName: peach-pv-cka05-str
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 100Mi
---
apiVersion: v1
kind: Pod
metadata:
  name: peach-pod-cka05-str
spec:
  containers:
  - image: nginx
    name: nginx
    volumeMounts:
      - mountPath: "/var/www/html"
        name: nginx-volume
  volumes:
    - name: nginx-volume
      persistentVolumeClaim:
        claimName: peach-pvc-cka05-str


Configure a web-portal-httproute within the cka3658 namespace to facilitate traffic distribution. Route 80% of the traffic to web-portal-service-v1 and 20% to the new version, web-portal-service-v2.

Note: Gateway has already been created in the nginx-gateway namespace.
To test the gateway, SH into the cluster2-controlplane and execute the following command:


curl http://cluster2-controlplane:30080



Switch to cluster2 by executing the following command:

kubectl config use-context cluster2

Next, check all the deployments and services in the cka3658 namespace with the command:

kubectl get deploy,svc -n cka3658

Review the gateway that has been created in the nginx-gateway namespace using the command:

kubectl get gateway -n nginx-gateway

You should see output similar to:

NAME            CLASS   ADDRESS   PROGRAMMED   AGE
nginx-gateway   nginx             True         36m

Now, create an HTTPRoute in the cka3658 namespace with the name web-portal-httproute to distribute traffic based on specified weights. Use the following YAML configuration:

apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: web-portal-httproute
  namespace: cka3658
spec:
  parentRefs:
    - name: nginx-gateway
      namespace: nginx-gateway
  rules:
    - matches:
        - path:
            type: PathPrefix
            value: /
      backendRefs:
        - name: web-portal-service-v1
          port: 80
          weight: 80
        - name: web-portal-service-v2
          port: 80
          weight: 20

For this question, please set the context to cluster1 by running:

kubectl config use-context cluster1

A service account called deploy-cka19-trb is created in cluster1 along with a cluster role called deploy-cka19-trb-role. This role should have the permissions to get all the deployments under the default namespace. However, at the moment, it is not able to.

Find out what is wrong and correct it so that the deploy-cka19-trb service account is able to get deployments under default namespace.



Let's see if deploy-cka19-trb service account is able to get the deployments.
kubectl auth can-i get deployments --as=system:serviceaccount:default:deploy-cka19-trb

We can see its not since we are getting no in the output.

Let's look into the cluster role:
kubectl get clusterrole deploy-cka19-trb-role -o yaml

The rules would be fine but we can see that there is no cluster role binding and service account associated with this. So let's create a cluster role binding.

kubectl create clusterrolebinding deploy-cka19-trb-role-binding --clusterrole=deploy-cka19-trb-role --serviceaccount=default:deploy-cka19-trb

Let's see if deploy-cka19-trb service account is able to get the deployments now.

kubectl auth can-i get deployments --as=system:serviceaccount:d






The demo-pod-cka29-trb pod is stuck in a Pending state. Look into the issue to fix it. Make sure the pod is in the Running state and stable






Look into the POD events
kubectl get event --field-selector involvedObject.name=demo-pod-cka29-trb

You will see some Warnings like:

Warning   FailedScheduling   pod/demo-pod-cka29-trb   0/3 nodes are available: 3 pod has unbound immediate PersistentVolumeClaims. preemption: 0/3 nodes are available: 3 Preemption is not helpful for scheduling.

This seems to be something related to PersistentVolumeClaims, Let's check that:

kubectl get pvc

You will notice that demo-pvc-cka29-trb is stuck in Pending state. Let's dig into it

kubectl get event --field-selector involvedObject.name=demo-pvc-cka29-trb

You will notice this error:

Warning   VolumeMismatch   persistentvolumeclaim/demo-pvc-cka29-trb   Cannot bind to requested volume "demo-pv-cka29-trb": incompatible accessMode

Which means the PVC is using incompatible accessMode, let's check the it out

kubectl get pvc demo-pvc-cka29-trb -o yaml
kubectl get pv demo-pv-cka29-trb -o yaml

Let's re-create the PVC with correct access mode i.e ReadWriteMany

kubectl get pvc demo-pvc-cka29-trb -o yaml > /tmp/pvc.yaml
vi /tmp/pvc.yaml

Under spec: change accessModes: from ReadWriteOnce to ReadWriteMany
Delete the old PVC and create new

kubectl delete pvc demo-pvc-cka29-trb
kubectl apply -f /tmp/pvc.yaml

Check the POD now

kubectl get pod demo-pod-cka29-trb

It should be good now.







For this question, please set the context to cluster1 by running:

kubectl config use-context cluster1

We want to deploy a python based application on the cluster using a template located at /root/olive-app-cka10-str.yaml on student-node. However, before you proceed we need to make some modifications to the YAML file as per details given below:

The YAML should also contain a persistent volume claim with name olive-pvc-cka10-str to claim a 100Mi of storage from olive-pv-cka10-str PV.

Update the deployment to add a sidecar container named busybox, which can use busybox image (you might need to add a sleep command for this container to keep it running.)

Share the python-data volume with this container and mount the same at path /usr/src. Make sure this container only has read permissions on this volume.

Finally, create a pod using this YAML and make sure the POD is in Running state.

Note: Additionally, you can expose a NodePort service for the application. The service should be named olive-svc-cka10-str and expose port 5000 with a nodePort value of 32006.
However, inclusion/exclusion of this service won't affect the validation for this task


Update olive-app-cka10-str.yaml template so that it looks like as below:

---
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: olive-pvc-cka10-str
spec:
  accessModes:
  - ReadWriteMany
  storageClassName: olive-stc-cka10-str
  volumeName: olive-pv-cka10-str
  resources:
    requests:
      storage: 100Mi

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: olive-app-cka10-str
spec:
  replicas: 1
  template:
    metadata:
      labels:
        app: olive-app-cka10-str
    spec:
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: kubernetes.io/hostname
                operator: In
                values:
                  - cluster1-node01
      containers:
      - name: python
        image: poroko/flask-demo-app
        ports:
        - containerPort: 5000
        volumeMounts:
        - name: python-data
          mountPath: /usr/share/
      - name: busybox
        image: busybox
        command:
          - "bin/sh"
          - "-c"
          - "sleep 10000"
        volumeMounts:
          - name: python-data
            mountPath: "/usr/src"
            readOnly: true
      volumes:
      - name: python-data
        persistentVolumeClaim:
          claimName: olive-pvc-cka10-str
  selector:
    matchLabels:
      app: olive-app-cka10-str

---
apiVersion: v1
kind: Service
metadata:
  name: olive-svc-cka10-str
spec:
  type: NodePort
  ports:
    - port: 5000
      nodePort: 32006
  selector:
    app: olive-app-cka10-str

Apply the template:

kubectl apply -f olive-app-cka10-str.yaml


A pod called elastic-app-cka02-arch is running in the default namespace. The YAML file for this pod is available at /root/elastic-app-cka02-arch.yaml on the student-node. The single application container in this pod writes logs to the file /var/log/elastic-app.log.


One of our logging mechanisms needs to read these logs to send them to an upstream logging server but we don't want to increase the read overhead for our main application container so recreate this POD with an additional sidecar container that will run along with the application container and print to the STDOUT by running the command tail -f /var/log/elastic-app.log. You can use busybox image for this sidecar container.




For this question, please set the context to cluster3 by running:


kubectl config use-context cluster3



We have an external webserver running on student-node which is exposed at port 9999. We have created a service called external-webserver-cka03-svcn that can connect to our local webserver from within the kubernetes cluster3 but at the moment it is not working as expected.



Fix the issue so that other pods within cluster3 can use external-webserver-cka03-svcn service to access the webserver.





Let's check if the webserver is working or not:

student-node ~ ➜  curl student-node:9999
...
<h1>Welcome to nginx!</h1>
...

Now we will check if service is correctly defined:

student-node ~ ➜  kubectl describe svc -n kube-public external-webserver-cka03-svcn
Name:              external-webserver-cka03-svcn
Namespace:         kube-public
.
.
Endpoints:         <none> # there are no endpoints for the service
...

As we can see there is no endpoints specified for the service, hence we won't be able to get any output. Since we can not destroy any k8s object, let's create the endpoint manually for this service as shown below:

student-node ~ ➜  export IP_ADDR=$(ifconfig eth0 | grep inet | head -n1 | awk '{print $2}')

student-node ~ ➜ kubectl --context cluster3 apply -f - <<EOF
apiVersion: v1
kind: Endpoints
metadata:
  # the name here should match the name of the Service
  name: external-webserver-cka03-svcn
  namespace: kube-public
subsets:
  - addresses:
      - ip: $IP_ADDR
    ports:
      - port: 9999
EOF

Finally check if the curl test works now:

student-node ~ ➜  kubectl --context cluster3 run -n kube-public --rm  -i test-curl-pod --image=curlimages/curl --restart=Never -- curl -m 2 external-webserver-cka03-svcn
...
<title>Welcome to nginx!</title>
...


student-node ~ ➜  kubectl create secret generic db-user-pass-cka17-arch --from-file=/opt/db-user-pass







Let's look into the network policy

kubectl edit networkpolicy cyan-np-cka28-trb -n cyan-ns-cka28-trb

Under spec: -> egress: you will notice there is not cidr: block has been added, since there is no restrcitions on egress traffic so we can update it as below. Further you will notice that the port used in the policy is 8080 but the app is running on default port which is 80 so let's update this as well (under egress and ingress):

Change port: 8080 to port: 80
- ports:
  - port: 80
    protocol: TCP
  to:
  - ipBlock:
      cidr: 0.0.0.0/0

Now, lastly notice that there is no POD selector has been used in ingress section but this app is supposed to be accessible from cyan-white-cka28-trb pod under default namespace. So let's edit it to look like as below:

ingress:
- from:
  - namespaceSelector:
      matchLabels:
        kubernetes.io/metadata.name: default
   podSelector:
      matchLabels:
        app: cyan-white-cka28-trb

Now, let's try to access the app from cyan-white-pod-cka28-trb

kubectl exec -it cyan-white-cka28-trb -- sh
curl cyan-svc-cka28-trb.cyan-ns-cka28-trb.svc.cluster.local

Also make sure its not accessible from the other pod(s)

kubectl exec -it cyan-black-cka28-trb -- sh
curl cyan-svc-cka28-trb.cyan-ns-cka28-trb.svc.cluster.local

It should not work from this pod. So its looking good now
```

## API Groups

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: pod-reader
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list", "watch"]
- apiGroups: ["apps"]
  resources: ["deployments", "statefulsets"]
  verbs: ["get", "list"]
- apiGroups: ["rbac.authorization.k8s.io"]
  resources: ["roles", "rolebindings"]
  verbs: ["get", "list"]



```
