## Test the docker container
```
docker run -it --entrypoint=/bin/sh gitlab.vumaex.net:4567/internal/devops/helm-deployer:4.2.5
```

When in the container shell:
`helm list --kube-context aex-prod -A`
