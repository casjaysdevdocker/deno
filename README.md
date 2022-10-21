# 👋 deno Readme 👋



## Run container

```shell
dockermgr install deno
```

### via command line

```shell
docker run -d \
--restart always \
--name deno \
--hostname casjaysdev-deno \
--publish-all \
-e TZ=${TIMEZONE:-America/New_York} \
-v $PWD/deno/data:/data \
-v $PWD/deno/config:/config \
casjaysdev/deno:latest
```

### via docker-compose

```yaml
version: "2"
services:
  deno:
    image: casjaysdev/deno
    container_name: deno
    environment:
      - TZ=America/New_York
      - HOSTNAME=casjaysdev-deno
    volumes:
      - $HOME/.local/share/docker/storage/deno/data:/data
      - $HOME/.local/share/docker/storage/deno/config:/config
    ports:
      - 1-65535
    restart: always
```

## Authors  

🤖 Jason Hempstead: [Github](<https://github.com/Jason> Hempstead) [Docker](<https://hub.docker.com/Jason> Hempstead) 🤖  
⛵ CasjaysDev: [Github](https://github.com/casjaysdev) [Docker](https://hub.docker.com/casjaysdev) ⛵  
