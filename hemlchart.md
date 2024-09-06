## All Helm Chart

https://artifacthub.io/

## list environment variables in Helm 
`helm env`

## enable bverbose option
`helm --debug`

## search for wordpress repo
`helm search wordpress`

`helm search hub wordpress`

## add the repo
`helm repo add bitnami https://charts.bitnami.com/bitnami`

## search
`helm search repo bitnami`

## remove repo 
`helm repo remove hashicorp`
## install the app
`helm install my-release bitnami/wordpress`

## tracing releases
`helm list`

## Delete app

`helm unistall my-relase`

## check repos

`helm repo`

`helm repo list`

`help repo update`




## overides the value set at values.yaml file 
- customiize installation using --set on the cli

`helm install --set wordpressBlogName="Sheyi Blog Tutorial" my-release bitnami/wordpress --set wordpresseMAIL="john@gmail.com"`
## Install example
```md
Deploy the Apache application on the cluster using the apache from the bitnami repository.


Set the release Name to: amaze-surf
```

`helm install amaze-surf bitnami/apache`

- After installation is where we found chart releases. Search for releases(charts) using `helm list`
## if values are too mnay
**create a custom-values.yaml**

wordpressBlogName: Sheyi Blog

wordpressRmail: john@gmail.com

## run the values flag to pick up the value
`helm install --values custom-values.yaml my-release bitnami/wordpress`


## other way of dediting direcctly
`helm pull bitnami/wordpress`

`helm pull --untar bitnami/wordpress`

`ls`

`helm install my-release ./wordpress`


## Helm Lifecycle management 

```yaml
## Install a version of a chart
helm install nginx-release bitnami/nginx --version 7.1.0

## check the pods from the release
kubectl get pods

## check the lrelease
helm list

## more details
helm history

## return to revision 1
helm rollback nginx-release 1
//This takes back to revision 3 with the conf of revision1

## upgrade a the release

Usage:  helm upgrade [RELEASE] [CHART] [flags]

helm upgrade nginx-release bitnami/nginx

## Rollback does not restore persistent volume rollbacks, you will use chart hooks
```


## Installation nginx chart version

```yaml
## You can install any nginx helm chart version above 13 for installing 1.23.

## Run the command:

helm upgrade dazzling-web bitnami/nginx --version 13

##which will install the current latest nginx helm chart.

```

## Writing helm charts

- Check the pdfs

```yaml
## first create a chart structure
helm create nginx-chart

ls nginx-chart

## check the templaes directory

## we don not want a static names on the files . e.g deployment name 


## can specify release name for uniqueness
metada:
  name: {{  .Release.Name }}-nginx
```


