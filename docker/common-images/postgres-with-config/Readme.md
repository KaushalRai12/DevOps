# Postgres with Config

This image can be used to customize the default Postgres image. Do NOT use this
container unless you specifically need to change configuration parameters that
cannot be done through a Helm chart.

## Methodology

The postgres config files in `/var/lib/postgresql/data/` cannot be modified using
`RUN` in the Dockerfile because that folder is declared as a volume in the
original image. You then have two options:

1. Mount the volume and overwrite the config file when creating the image
2. Modify the config file before startup by using a script in `/docker-entrypoint-initdb.d`

This repo uses the second option.

## Building the Image

```bash
docker build -t gitlab.vumaex.net:4567/internal/devops/postgres-with-config:0.1.0 .
docker push gitlab.vumaex.net:4567/internal/devops/postgres-with-config:0.1.0
```

## Running the Image

A default `.env` file has been provided, but it only contains the minimum values
needed to test this locally. These values MUST be changed in production.

```bash
docker run --env-file=.env --name postgres-with-config -t gitlab.automationexchange.co.za:4567/internal/devops/postgres-with-config:0.1.0
```