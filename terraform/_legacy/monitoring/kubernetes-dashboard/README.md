**Not Currently Used**
_This dashboard is not used, there is enough info in the grafana dashboards_


### Dashboard URL's

**prod**: https://k8s-api.prod.aex-sys.net:6443/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:443/proxy/#/login
**dev**: https://k8s-api.dev.aex-sys.net:6443/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:443/proxy


### Get login token
Get a token for a service account you can use to log in; e.g.
`kubectl describe secret -n aex-devops cluster-admin-token-twsnv`
