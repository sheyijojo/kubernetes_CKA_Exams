## filter a json

```yml
$[ check if each item in the array > 40 ]

## ? filer, @ check the array
$[? ( @ > 40 )]

$[? ( @ in [40, 44, 46] ) ]

```

```yml
kubectl set env deployment/cm-webapp -n cm-namespace \
  --from=configmap/app-config

apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: low-priority
value: 50000
globalDefault: false
description: "Low priority class"

```


```yml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: api-hpa
  namespace: api
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: api-deployment
  minReplicas: 1
  maxReplicas: 20
  metrics:
  - type: Pods
    pods:
      metric:
        name: requests_per_second
      target:
        type: AverageValue
        averageValue: "1000"

```

```yml
You are an administrator preparing your environment to deploy a Kubernetes cluster using kubeadm. Adjust the following network parameters on the system to the following values, and make sure your changes persist reboots:

net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-iptables = 1

echo 'net.ipv4.ip_forward = 1' >> /etc/sysctl.conf
echo 'net.bridge.bridge-nf-call-iptables = 1' >> /etc/sysctl.conf
sysctl -p

verify
sysctl net.ipv4.ip_forward
sysctl net.bridge.bridge-nf-call-iptables


```

## splitting traffic 

```yml

kubectl create -n default -f - <<EOF
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: web-route
  namespace: default
spec:
  parentRefs:
    - name: web-gateway
      namespace: default
  rules:
    - matches:
        - path:
            type: PathPrefix
            value: /
      backendRefs:
        - name: web-service
          port: 80
          weight: 80
        - name: web-service-v2
          port: 80
          weight: 20
EOF

```
helm ls -n default
helm lint ./new-version

helm install --generate-name ./new-version

helm uninstall webpage-server-01 -n default


```yml
Identify the pod CIDR network of the Kubernetes cluster. This information is crucial for configuring the CNI plugin during installation. Output the pod CIDR network to a file at /root/pod-cidr.txt.

Solution
Use kubectl cluster-info to find details about the cluster and check the network range for pods.

To identify the Pod CIDR network of the Kubernetes cluster, use the following command:
kubectl get node -o jsonpath='{.items[0].spec.podCIDR}' > /root/pod-cidr.txt

cat /root/pod-cidr.txt
```
