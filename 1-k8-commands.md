## Here’s a tip!

As you might have seen already, creating and editing YAML files is a bit difficult, especially in the CLI. 
During the exam, you might find it difficult to copy and paste YAML files from the browser to the terminal.

Using the kubectl run command can help in generating a YAML template. And sometimes, you can even get away with just the kubectl run command without having to create a YAML file at all. 

For example, if you were asked to create a pod or deployment with a specific name and image, you can simply run the kubectl run command.

Use the below set of commands and try the previous practice tests again, but this time, try to use the below commands instead of YAML files. Try to use these as much as you can going forward in all exercises.

Reference (Bookmark this page for the exam. It will be very handy):

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

`kubectl create service nodeport <service-name> --tcp=<port>:<target-port> -o yaml > service-definition-1.yaml`


`kubectl create service nodeport my-service --tcp=80:80 -o yaml > service-definition-1.yaml`

`kubectl create service nodeport webapp-service --tcp=30080:8080 -o yaml > service-definition-1.yaml`


## notice there is no labels in this configuration. Labels is what is used to assicuate a specific template. 
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

## Namespace
`kubectl run redis --image=redis --namespace=finance`

`kubectl get pods --namespace=research`

`kubectl get pods -n=researchnamespace`

`kubectl get pods --all-namespaces`
`kubectl get pods -A`


`kubectl run redis --image=redis:alpine --labels=tier=db`

`kubectl create service clusterip redis-service --tcp=6379:6379`



`kubectl create service clusterip redis-service --tcp=6379`



`kubectl run custom-nginx --image=nginx --port=8080`


`kubectl create ns dev-ns`


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

## Another options for cpmmand 

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
