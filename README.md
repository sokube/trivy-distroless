# trivy-distroless
- v1.0.0
- 9a1ac998567d
- 26.5MB

## Remote image scan
docker run -it distroless-trivy:v0.0.4 image nginx:latest

## Client / Server scenario

```shell
docker network create trivy
```

Run the server
```shell
docker run \
  -d \
  --name trivy-server \
  --network trivy \
  -p 8080:8080 \
  distroless-trivy:v0.0.4 \
  server --listen 0.0.0.0:8080
```

Run the client
```shell
docker run \
  --network trivy \
  distroless-trivy:v0.0.4 \
  client --remote http://trivy-server:8080 nginx:1.17
```