## Here’s a tip!

As you might have seen already, creating and editing YAML files is a bit difficult, especially in the CLI. During the exam, you might find it difficult to copy and paste YAML files from the browser to the terminal. Using the kubectl run command can help in generating a YAML template. And sometimes, you can even get away with just the kubectl run command without having to create a YAML file at all. For example, if you were asked to create a pod or deployment with a specific name and image, you can simply run the kubectl run command.

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


Generate Deployment YAML file (-o yaml). Don’t create it(–dry-run) and save it to a file.

`kubectl create deployment --image=nginx nginx --dry-run=client -o yaml > nginx-deployment.yaml`


## Make necessary changes to the file (for example, adding more replicas) and then create the deployment.

`kubectl create -f nginx-deployment.yaml`


`kubectl create deployment httpd-frontend --image=httpd:2.4-alpine --replicas=3`
OR

In k8s version 1.19+, we can specify the –replicas option to create a deployment with 4 replicas.

kubectl create deployment --image=nginx nginx --replicas=4 --dry-run=client -o yaml > nginx-deployment.yaml

## Create a service 

`kubectl create service nodeport <service-name> --tcp=<port>:<target-port> -o yaml > service-definition-1.yaml`


`kubectl create service nodeport my-service --tcp=80:80 -o yaml > service-definition-1.yaml`

kubectl create service nodeport webapp-service --tcp=30080:8080 -o yaml > service-definition-1.yaml


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

