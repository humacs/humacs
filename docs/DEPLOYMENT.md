- [Host system](#orgb06d881)
- [Notes](#orgba1503d)
- [Kubernetes (Helm)](#orgd6fe92d)
  - [Installation](#orga76f064)
- [Docker](#org0b59ef7)
  - [Simple](#orgcaf2fb2)
  - [Configuring](#orgf3dd97a)
  - [Simple-Init.sh](#org74ae6ba)

Deploying Humacs in several environments.

For configuration, please refer to the [configuration](./CONFIGURATION.md) docs.


<a id="orgb06d881"></a>

# Host system

Setting up on your host system can be done with the following three commands

```shell
git clone --recursive https://github.com/humacs/humacs
export EMACSLOADPATH=$(pwd)/humacs:
emacs -nw
```

Setting up on your host system with doom profile just means adding env vars for doom.

```shell
git clone --recursive https://github.com/humacs/humacs
export EMACSLOADPATH=$(pwd)/humacs:
export DOOMDIR=$(pwd)/humacs/doom-config
export HUMACS_PROFILE=doom
emacs -nw
```


<a id="orgba1503d"></a>

# Notes

-   the environment variable EMACSLOADPATH must be set on your system for the Humacs configuration to load correctly


<a id="orgd6fe92d"></a>

# Kubernetes (Helm)


<a id="orga76f064"></a>

## Installation

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


<a id="org0b59ef7"></a>

# Docker


<a id="orgcaf2fb2"></a>

## Simple

Spin up a quick and default environment

```shell
docker run -ti --rm registry.gitlab.com/humacs/humacs/ii:2020.09.09 emacs
```


<a id="orgf3dd97a"></a>

## Configuring

The following command shows configuring:

-   the Humacs profile to Doom; and
-   mounting in the current directory into the /home/ii/workspace folder of the humacs container

```shell
docker run -ti --rm \
  -e HUMACS_PROFILE=doom \
  -v $(pwd):/home/ii/workspace registry.gitlab.com/humacs/humacs/ii:2020.09.09 emacs /home/ii/workspace
```


<a id="org74ae6ba"></a>

## Simple-Init.sh

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
