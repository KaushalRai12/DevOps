

```yml
# docker-compose.yml
version: '3'
services:
  genie-acs:
    image: drumsergio/genieacs:1.2.8
    restart: always
    #network_mode: host
    ports:
      - 80:7547
      - 3000:3000
    environment:
      GENIEACS_MONGODB_CONNECTION_URL: "mongodb://genieacs:3Vvrg3ty2F2dhbA4Rp3w@mongodb/genieacs?authSource=admin"
      GENIEACS_UI_JWT_SECRET: Th3resSomethingintheair
      GENIEACS_DEBUG_FILE: /var/log/genieacs/genieacs-debug.yaml
    #  GENIEACS_CWMP_PORT: 80
    #  GENIEACS_CWMP_INTERFACE: 0.0.0.0
  mongodb:
    image: mongo
    restart: always
    #network_mode: host
    environment:
      MONGO_INITDB_ROOT_USERNAME: genieacs
      MONGO_INITDB_ROOT_PASSWORD: 3Vvrg3ty2F2dhbA4Rp3w
      MONGO_INITDB_DATABASE: genieacs
    volumes:
      - ./data:/data/db
```

```bash
cd /tmp
sudo apt-get update
sudo apt-get -y install git binutils
git clone https://github.com/aws/efs-utils
cd efs-utils/
./build-deb.sh
sudo apt-get -y install ./build/amazon-efs-utils*deb
mkdir ~/genieacs/data
```

```fstab
fs-0a872451425d6244b:/ /home/ubuntu/genieacs/data/ efs _netdev,noresvport,tls,iam 0 0
```