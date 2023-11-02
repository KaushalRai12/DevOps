# Vumatel Radius Failover

## Deploy K8s freeRADIUS
From the _helm_ folder
`helm upgrade --install vumatel-freeradius . -n aex-prod --kube-context aex-prod`


## Build load balancer
From the _load-balancer_ folder
```bash
docker build -t gitlab.automationexchange.co.za:4567/fnms/radius-2/freeradius-vumatel-load-balancer:1.19.8 .
docker push gitlab.automationexchange.co.za:4567/fnms/radius-2/freeradius-vumatel-load-balancer:1.19.8
```
