## secrets in kubernetes 

Remember that secrets encode data in base64 format. Anyone with the base64 encoded secret can easily decode it. As such the secrets can be considered not very safe.

The concept of safety of the Secrets is a bit confusing in Kubernetes. The Kubernetes documentation page and a lot of blogs out there refer to secrets as a “safer option” to store sensitive data. They are safer than storing in plain text as they reduce the risk of accidentally exposing passwords and other sensitive data. In my opinion, it’s not the secret itself that is safe, it is the practices around it.

Secrets are not encrypted, so it is not safer in that sense. However, some best practices around using secrets make it safer. As in best practices like:

Not checking in secret object definition files to source code repositories.
Enabling Encryption at Rest for Secrets so they are stored encrypted in ETCD.
Also, the way Kubernetes handles secrets. Such as:

A secret is only sent to a node if a pod on that node requires it.

Kubelet stores the secret into a tmpfs so that the secret is not written to disk storage.

Once the Pod that depends on the secret is deleted, kubelet will delete its local copy of the secret data as well.

Read about the protections and risks of using secrets here.

Having said that, there are other better ways of handling sensitive data like passwords in Kubernetes, such as using tools like Helm Secrets, and HashiCorp Vault.

## Encrypting secret data at Rest 

This is a kubeadm setup

The focus here is the secret data stored inside the etcd in the control plane.

How is this data stored in the etcd


## On the control plane
**Generate certificate manually**

https://kubernetes.io/docs/tasks/administer-cluster/encrypt-data/

`etcdctl`

`apt-get install etcd-client`

**check for the etcd control plane**

`kubectl get pods -n kube-system`


- check if you have the cert files on the control plane 

ls /etc/kubernetes/pki/etcd/ca.crt

## change the secret1 to your created secret
```yaml
ETCDCTL_API=3 etcdctl \
   --cacert=/etc/kubernetes/pki/etcd/ca.crt   \
   --cert=/etc/kubernetes/pki/etcd/server.crt \
   --key=/etc/kubernetes/pki/etcd/server.key  \
   get /registry/secrets/default/secret1 | hexdump -C

```

- With this you can get your secret from the etcd server, so not save in an uncrypted format 

**We need encryption at rest**

- check if encyrption is enabled alreadt 

`ps -aux | grep kube-api`


`ps -aux | grep kube-api | grep "encryption-provider-config"`

**check for the encrytpion in kube-apiserver.yaml 

`ls /etc/kubernetes/manifests/`

- checking it shows it does not have encryptoon at rest 

## create a config file to store your secrets encrytpted

```yaml
---
apiVersion: apiserver.config.k8s.io/v1
kind: EncryptionConfiguration
resources:
  - resources:
      - secrets
    providers:
      - aescbc:
          keys:
            - name: key1
              secret: <BASE 64 ENCODED SECRET>
      - identity: {} # REMOVE THIS LINE

```

## To create a new secret, generate a random jey and base64 encode it 

`head -c 32 /dev/urandom | base64`

```yaml

enc.yaml
---
apiVersion: apiserver.config.k8s.io/v1
kind: EncryptionConfiguration
resources:
  - resources:
      - secrets
    providers:
      - aescbc:
          keys:
            - name: key1
              secret: fbfodfnmrwer3094u34mnms;dmdd>
      - identity: {} # REMOVE THIS LINE

```

`mkdir /etc/kubernetes/enc`

`mv enc.yaml /etc/kubernetes/enc`

## edit the kuberapi manifest file and make changes


`vi /etc/kubernetes/manifests/kube-apiserver.yaml`


add path to the encryption file 

`--encryption-provider-config=/etc/kubernetes/enc/enc.yaml`



`speficy the mount too and local directory`

`done, api server will restart auto`

