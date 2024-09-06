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
`helm repo search bitnami`

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


- customiize installation using --set on the cli

## overides the value set at values.yaml file 

`helm install --set wordpressBlogName="Sheyi Blog Tutorial" my-release bitnami/wordpress --set wordpresseMAIL="john@gmail.com"`

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

