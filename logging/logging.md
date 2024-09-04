## Logging

`https://speakerdeck.com/thockin/illustrated-guide-to-kubernetes-networking?slide=13`


**component for metrics in kubelet is the cAdvisor**

## if using minikube for setup

`minikube addons enable metrics-server

## Metrics Server 
- **Do not use this for PROD, use official documentation**
`git clone https://github.com/kodekloudhub/kubernetes-metrics-server.git`
`kubectl create -f deploy/1.8+/`

**running `kubectl create -f .**
- The follwing output will be generated
```md
clusterrole.rbac.authorization.k8s.io/system:aggregated-metrics-reader created
clusterrolebinding.rbac.authorization.k8s.io/metrics-server:system:auth-delegator created
rolebinding.rbac.authorization.k8s.io/metrics-server-auth-reader created
apiservice.apiregistration.k8s.io/v1beta1.metrics.k8s.io created
serviceaccount/metrics-server created
deployment.apps/metrics-server created
service/metrics-server created
clusterrole.rbac.authorization.k8s.io/system:metrics-server created
clusterrolebinding.rbac.authorization.k8s.io/system:metrics-server created

```

## view performance metrics
`kubectl top node`

`kubectl top pod`

## Application logs 

**view logs life in pods**
- `kubectl logs -f event-simulator-pod`
- `kubectl logs -f event-simulator-pod container-name`
  
