# Docker-UrNetwork Releases v2025.12.11-806642720
A minimal Docker setup that automatically fetches and runs the latest urNetwork Provider. The container is built on **Alpine Linux**, ensuring a minimal footprint. Includes built-in authentication handling and network diagnostics.

## Links
| DockerHub | GitHub | Invite |
|----------|----------|----------|
| [![Docker Hub](https://img.shields.io/badge/ㅤ-View%20on%20Docker%20Hub-blue?logo=docker&style=for-the-badge)](https://hub.docker.com/r/kingofmmo/docker-urnetwork) | [![GitHub Repo](https://img.shields.io/badge/ㅤ-View%20on%20GitHub-black?logo=github&style=for-the-badge)](https://github.com/trungdungalpha/Docker-UrNetwork) | [![Invite Link](https://img.shields.io/badge/ㅤ-Join%20UrNetwork%20Now-brightgreen?logo=linktree&style=for-the-badge)](https://ur.io/app?bonus=7H3U4C) |

## Features
- Automated retrieval of the latest urNetwork Provider binary on startup
- Secure credential management via environment variables
- Alpine-based image for minimal footprint
- Persistent storage of authentication tokens and version metadata
- Built-in network diagnostic script (ipinfo.sh)
- **GUI auto-close feature** to reduce CPU lag (requires xdotool and DISPLAY)
- **Disabled vnstatd** to reduce CPU usage

## Environment variables
| Variable | Requirement | Description |
|----------|-------------|-------------|
| `USER_AUTH`  | Required    | Your Email. Container exits if not provided. |
| `PASSWORD`  | Required    | Your Password. Container exits if not provided. |
| `ENABLE_IP_CHECKER` | Optional | Boolean true/false : Checks and prints your public IPv4 address to stdout visible directly in Docker logs for easy monitoring. |
| `ENABLE_GUI_CLOSE` | Optional | Boolean true/false : Enable GUI auto-close feature to reduce CPU lag. Requires xdotool and DISPLAY environment. Default: `false` |
| `GUI_WINDOW_NAME` | Optional | Name of the GUI window to close. Default: `UrNetwork` |
| `-v /path/to/your/proxy.txt:/app/proxy.txt`  | Optional | Mount a proxy configuration file from host to container.<br>Omit this line entirely if you don't want to use a proxy.<br>The proxy inside the proxy.txt should have this format ip:port:username:password.<br>See the sample below. one proxy per line. |
| | Optional | `123.456.789.012:55555:myproxyusername:myproxypassword`<br>`234.567.890.123:44444:myproxyusername:myproxypassword`<br>`345.678.901.234:33333:myproxyusername:myproxypassword`<br>`456.789.012.345:22222:myproxyusername:myproxypassword`<br>`567.890.123.456:11111:myproxyusername:myproxypassword` |

## Run

### From GitHub Packages (Recommended)
```sh
# Login to GitHub Container Registry
echo $GITHUB_TOKEN | docker login ghcr.io -u YOUR_GITHUB_USERNAME --password-stdin

# Pull and run
docker run -d --platform linux/amd64 \
  --name="urnetwork" \
  --restart="always" \
  --privileged \
  --log-driver=json-file \
  --log-opt max-size=5m \
  --log-opt max-file=3 \
  -e USER_AUTH="example@gmail.com" \
  -e PASSWORD="mYv3rYsEcUr3dP@sSw0rD" \
  -e ENABLE_IP_CHECKER=false \                #optional
  -e ENABLE_GUI_CLOSE=true \                  #optional: Enable GUI auto-close
  -e GUI_WINDOW_NAME="UrNetwork" \            #optional: GUI window name
  -v /path/to/your/proxy.txt:/app/proxy.txt \ #optional
  ghcr.io/trungdungalpha/docker-urnetwork:latest
```

### From Docker Hub
```sh
# Login to Docker Hub (optional, for private images)
docker login -u kingofmmo

# Pull and run
docker run -d --platform linux/amd64 \
  --name="urnetwork" \
  --restart="always" \
  --privileged \
  --log-driver=json-file \
  --log-opt max-size=5m \
  --log-opt max-file=3 \
  -e USER_AUTH="example@gmail.com" \
  -e PASSWORD="mYv3rYsEcUr3dP@sSw0rD" \
  -e ENABLE_IP_CHECKER=false \                #optional
  -e ENABLE_GUI_CLOSE=true \                  #optional: Enable GUI auto-close
  -e GUI_WINDOW_NAME="UrNetwork" \            #optional: GUI window name
  -v /path/to/your/proxy.txt:/app/proxy.txt \ #optional
  kingofmmo/docker-urnetwork:latest
```

### From Docker Hub (Original)
```sh
# Option 1 : amd64 build
docker run -d --platform linux/amd64 \
  --name="urnetwork" \
  --restart="always" \
  --pull="always" \
  --privileged \
  --log-driver=json-file \
  --log-opt max-size=5m \
  --log-opt max-file=3 \
  -e USER_AUTH="example@gmail.com" \
  -e PASSWORD="mYv3rYsEcUr3dP@sSw0rD" \
  -e ENABLE_IP_CHECKER=false \                #optional
  -v /path/to/your/proxy.txt:/app/proxy.txt \ #optional
  techroy23/docker-urnetwork:latest

# Option 2 : arm64 build
docker run -d --platform linux/arm64 \
  --name="urnetwork" \
  --restart="always" \
  --pull="always" \
  --privileged \
  --log-driver=json-file \
  --log-opt max-size=5m \
  --log-opt max-file=3 \
  -e USER_AUTH="example@gmail.com" \
  -e PASSWORD="mYv3rYsEcUr3dP@sSw0rD" \
  -e ENABLE_IP_CHECKER=false \                #optional
  -v /path/to/your/proxy.txt:/app/proxy.txt \ #optional
  techroy23/docker-urnetwork:latest
```


## Promo Video
<div align="center">
  <a href="https://www.youtube.com/watch?v=E1tXbiLSU2I">
    <img src="https://img.youtube.com/vi/E1tXbiLSU2I/0.jpg" alt="Watch the Video">
  </a>
</div>

## Promo
<ul><li><a href="https://ur.io/app?bonus=7H3U4C"> [ REGISTER HERE ] </a></li></ul>
<div align="center">
  <a href="https://ur.io/app?bonus=7H3U4C">
    <img src="screenshot/img0.png" alt="Alt text">
  </a>
</div>
