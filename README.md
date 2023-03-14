# Custom Boomi Docker Images v3
This repository contains the sources for the publicly available custom docker images on Docker Hub.

The version 4 images are in the [main branch](https://bitbucket.org/officialboomi/docker-images/src/main/).

## Custom Gateway images
https://hub.docker.com/repository/docker/anthonyrabiaza/docker-boomi-gateway

## Sources
https://github.com/anthonyrabiaza/boomigatewaydockerv3


## Use of Custom Docker Image

Docker
```
docker run -d -t -i \
-e BOOMI_USERNAME=atomsphereuser@email.com \
-e BOOMI_PASSWORD=thepassword \
-e BOOMI_ACCOUNTID=theboomiaccountid-ABCDEF \
-e BOOMI_ATOMNAME=GatewayDocker \
-e ATOM_LOCALHOSTID='localhost' \
-v /mnt/boomi/:/tmp/boomigateway/:Z \
boomigateway/3.1.23
```

Kubernetes
```
kind: StatefulSet
apiVersion: apps/v1
metadata:
  name: gateway-statefulset-k3s
  namespace: default
  labels:
    app: gateway
spec:
  replicas: 1
  selector:
    matchLabels:
      app: gateway
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: gateway
        env: test
    spec:
      volumes:
        - name: boomi-shared-folder
          persistentVolumeClaim:
            claimName: nfs-volume
        - name: tmpfs
          emptyDir: {}
        - name: cgroup
          hostPath:
            path: /sys/fs/cgroup
            type: Directory
      containers:
        - name: gateway-container
          image: anthonyrabiaza/docker-boomi-gateway:3.2.13
          ports:
            - containerPort: 8077
              protocol: TCP
          ports:
            - containerPort: 18077
              protocol: TCP
          env:
            - name: URL
              value: https://platform.boomi.com
            - name: BOOMI_USERNAME
              valueFrom:
                secretKeyRef:
                  name: boomi-secret
                  key: username
                  ...
```

# Building the Custom Docker Image
From the root of this project.

#### Build base 
    ./build.sh boomibase
#### Build Gateway    
    ./build.sh boomigateway
#### Test the Gateway
    # Update build.properties then run
    ./build.sh run
    # Connect to AtomSphere UI>API Management>Gateway
#### Push (optional)
    ./build.sh tag
    ./build.sh push
    
# Reference Architectures
https://bitbucket.org/officialboomi/runtime-containers/src/master/

