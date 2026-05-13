## 👋 Welcome to deno 🚀  

deno README  
  
  
## Install my system scripts  

```shell
 sudo bash -c "$(curl -q -LSsf "https://github.com/systemmgr/installer/raw/main/install.sh")"
 sudo systemmgr --config && sudo systemmgr install scripts  
```
  
## Automatic install/update  
  
```shell
dockermgr update deno
```
  
## Install and run container
  
```shell
dockerHome="/var/lib/srv/$USER/docker/casjaysdevdocker/deno/deno/latest/rootfs"
mkdir -p "/var/lib/srv/$USER/docker/deno/rootfs"
git clone "https://github.com/dockermgr/deno" "$HOME/.local/share/CasjaysDev/dockermgr/deno"
cp -Rfva "$HOME/.local/share/CasjaysDev/dockermgr/deno/rootfs/." "$dockerHome/"
docker run -d \
--restart always \
--privileged \
--name casjaysdevdocker-deno-latest \
--hostname deno \
-e TZ=${TIMEZONE:-America/New_York} \
-v "$dockerHome/data:/data:z" \
-v "$dockerHome/config:/config:z" \
-p 80:80 \
casjaysdevdocker/deno:latest
```
  
## via docker-compose  
  
```yaml
version: "2"
services:
  ProjectName:
    image: casjaysdevdocker/deno
    container_name: casjaysdevdocker-deno
    environment:
      - TZ=America/New_York
      - HOSTNAME=deno
    volumes:
      - "/var/lib/srv/$USER/docker/casjaysdevdocker/deno/deno/latest/rootfs/data:/data:z"
      - "/var/lib/srv/$USER/docker/casjaysdevdocker/deno/deno/latest/rootfs/config:/config:z"
    ports:
      - 80:80
    restart: always
```
  
## Get source files  
  
```shell
dockermgr download src casjaysdevdocker/deno
```
  
OR
  
```shell
git clone "https://github.com/casjaysdevdocker/deno" "$HOME/Projects/github/casjaysdevdocker/deno"
```
  
## Build container  
  
```shell
cd "$HOME/Projects/github/casjaysdevdocker/deno"
buildx 
```
  
## Authors  
  
🤖 casjay: [Github](https://github.com/casjay) 🤖  
⛵ casjaysdevdocker: [Github](https://github.com/casjaysdevdocker) [Docker](https://hub.docker.com/u/casjaysdevdocker) ⛵  
