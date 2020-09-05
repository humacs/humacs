- [Humacs](#sec-1)
  - [Usage](#sec-1-1)
    - [Locally](#sec-1-1-1)
    - [docker](#sec-1-1-2)
    - [k8s/helm](#sec-1-1-3)


# Humacs<a id="sec-1"></a>

## Usage<a id="sec-1-1"></a>

### Locally<a id="sec-1-1-1"></a>

```shell
git clone --recursive https://github.com/humacs/humacs
export EMACSLOADPATH=$(pwd)/humacs:
emacs -nw
```

### docker<a id="sec-1-1-2"></a>

Simple:

```shell
docker run -ti --rm humacs/ii:2020.09.04 emacs
```

With doom and mounted files:

```shell
docker run -ti --rm \
  -e HUMACS_PROFILE=doom \
  -v $(pwd):/workspace humacs/ii:2020.09.04 emacs /workspace
```

### k8s/helm<a id="sec-1-1-3"></a>

```shell
NAME=humacs
HUMACS_PROFILE=ii # doom, or others
HUMACS_TZ="Pacific/Auckland"
HUMACS_GIT_NAME="Hippie Hacker"
HUMACS_GIT_EMAIL="hh@ii.coop"
git clone https://github.com/humacs/humacs
cd humacs
kubectl create ns "${NAME}"
helm install "${NAME}" -n "${NAME}" \
  -f chart/humacs/values/apisnoop.yaml \
  --set options.timezone="${HUMACS_TZ}" \
  --set options.gitName="${HUMACS_GIT_NAME}" \
  --set options.gitEmail="${HUMACS_GIT_EMAIL}" \
  --set options.profile="${HUMACS_PROFILE}" \
  chart/humacs
```

Once up and running, connect via kubectl:

```shell
kubectl -n $NAME exec $NAME-humacs-0 -- attach
```
