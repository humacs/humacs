
# Table of Contents

1.  [Host system](#orgc1877b3)
2.  [Notes](#org189a71e)
3.  [Kubernetes (Helm)](#org2176ad9)
    1.  [Installation](#orgcc52741)
4.  [Docker](#org4f88944)
    1.  [Simple](#org63a92e1)
    2.  [Configuring](#orgf061113)
    3.  [Simple-Init.sh](#org6724c71)

Deploying Humacs in several environments.

For configuration, please refer to the [configuration](./CONFIGURATION.md) docs.


<a id="orgc1877b3"></a>

# Host system

Setting up on your host system can be done with the following three commands

    git clone --recursive https://github.com/humacs/humacs
    export EMACSLOADPATH=$(pwd)/humacs:
    emacs -nw

Setting up on your host system with doom profile just means adding env vars for doom.

    git clone --recursive https://github.com/humacs/humacs
    export EMACSLOADPATH=$(pwd)/humacs:
    export DOOMDIR=$(pwd)/humacs/doom-config
    export HUMACS_PROFILE=doom
    emacs -nw


<a id="org189a71e"></a>

# Notes

-   the environment variable EMACSLOADPATH must be set on your system for the Humacs configuration to load correctly


<a id="org2176ad9"></a>

# Kubernetes (Helm)


<a id="orgcc52741"></a>

## Installation

Create namespace:

    kubectl create namespace humacs

Install Humacs:

    helm install humacs --namespace humacs chart/humacs

Values are found in the [configuration](./CONFIGURATION.md) docs.

Once up and running, connect via kubectl:

    kubectl -n humacs exec statefulset/humacs -- attach


<a id="org4f88944"></a>

# Docker


<a id="org63a92e1"></a>

## Simple

Spin up a quick and default environment

    docker run -ti --rm registry.gitlab.com/humacs/humacs/ii:2020.09.09 emacs


<a id="orgf061113"></a>

## Configuring

The following command shows configuring:

-   the Humacs profile to Doom; and
-   mounting in the current directory into the /home/ii/workspace folder of the humacs container

    docker run -ti --rm \
      -e HUMACS_PROFILE=doom \
      -v $(pwd):/home/ii/workspace registry.gitlab.com/humacs/humacs/ii:2020.09.09 emacs /home/ii/workspace


<a id="org6724c71"></a>

## Simple-Init.sh

Simple init allows the environment to be set up with:

-   tmate
-   repos
-   git name and email env

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

