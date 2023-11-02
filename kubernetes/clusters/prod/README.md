## Bootstrap root cluster artefacts
* Copy boot.yml to you cluster master
* run `kubectl apply -f boot.yml`


## Label nodes
```
kubectl label nodes k8s-worker-01 aex/component=app
kubectl label nodes app05 aex/component=app
kubectl label nodes app05 aex/has-native=true
```
