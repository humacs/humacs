- [Host system](#sec-1)
  - [Notes](#sec-1-1)
- [Kubernetes (Helm)](#sec-2)
  - [Installation](#sec-2-1)
- [Docker](#sec-3)
  - [Simple](#sec-3-1)
  - [Configuring](#sec-3-2)
  - [Simple-Init.sh](#sec-3-3)

Deploying Humacs in several environments.

For configuration, please refer to the [configuration](./CONFIGURATION.md) docs.

# Host system<a id="sec-1"></a>

Setting up on your host system can be done with the following three commands

```shell
git clone --recursive https://github.com/humacs/humacs
export EMACSLOADPATH=$(pwd)/humacs:
emacs -nw
```

## Notes<a id="sec-1-1"></a>

-   the environment variable EMACSLOADPATH must be set on your system for the Humacs configuration to load correctly

# Kubernetes (Helm)<a id="sec-2"></a>

## Installation<a id="sec-2-1"></a>

Create namespace:

```sh
kubectl create namespace humacs
```

Install Humacs:

```sh
helm install humacs --namespace humacs chart/humacs
```

Values are found in the [configuration](./CONFIGURATION.md) docs.

Once up and running, connect via kubectl:

```shell
kubectl -n humacs exec statefulset/humacs -- attach
```

# Docker<a id="sec-3"></a>

## Simple<a id="sec-3-1"></a>

Spin up a quick and default environment

```shell
docker run -ti --rm registry.gitlab.com/humacs/humacs/ii:2020.09.09 emacs
```

## Configuring<a id="sec-3-2"></a>

The following command shows configuring:

-   the Humacs profile to Doom; and
-   mounting in the current directory into the /home/ii/workspace folder of the humacs container

```shell
docker run -ti --rm \
  -e HUMACS_PROFILE=doom \
  -v $(pwd):/home/ii/workspace registry.gitlab.com/humacs/humacs/ii:2020.09.09 emacs /home/ii/workspace
```

## Simple-Init.sh<a id="sec-3-3"></a>

Simple init allows the environment to be set up with:

-   tmate
-   repos
-   git name and email env

```shell
docker run -ti --rm \
  --user ii \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /tmp:/tmp \
  -e HUMACS_DEBUG=true \
  -e GIT_AUTHOR_NAME="ii" \
  -e GIT_AUTHOR_EMAIL="myemail@example.com" \
  -e INIT_ORG_FILE="" \
  -e INIT_DEFAULT_DIR="/home/ii" \
  -e INIT_DEFAULT_REPOS="https://github.com/kubernetes/kubernetes https://github.com/cncf/apisnoop" \
  -e INIT_DEFAULT_REPOS_FOLDER="workspace" \
  registry.gitlab.com/humacs/humacs/ii:2020.09.09 simple-init.sh
```
