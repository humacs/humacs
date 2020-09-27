# Humacs docs
## Prerequisites
- existing cluster (can be anywhere, will use to boostrap)
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- [clusterctl](https://cluster-api.sigs.k8s.io/user/quick-start.html)
- [Docker](https://docs.docker.com/engine/install/ubuntu/)
- [Checkout humacs](https://github.com/humacs/humacs)
- Create an account at [packet](https://app.packet.net/) make sure you have an api key with permissions to create resources 

**Installing kind If you need it as your bootstrap cluster**
For OSX:
```shell=
curl -Lo fit./kind https://kind.sigs.k8s.io/dl/v0.8.1/kind-darwin-amd64
```
for linux
``` shell
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.8.1/kind-linux-amd64
```

```shell
chmod +x kind
```

```shell
mv kind /usr/local/bin/kind
```

**Install kubectl**
for linux
``` shell
curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl"
```

```shell
chmod +x kubectl
```

```shell
mv kubectl /usr/local/bin/kubectl
```


## Get Clusterctl 0.3.8
We don't want to use the latest version on clusterctl's quickstart page.
For linux
```shell
curl -L https://github.com/kubernetes-sigs/cluster-api/releases/download/v0.3.8/clusterctl-linux-amd64 -o clusterctl
```
For osx
``` shell 
curl -L https://github.com/kubernetes-sigs/cluster-api/releases/download/v0.3.8/clusterctl-darwin-amd64 -o clusterctl
```

```shell
chmod +x clusterctl
```

```shell
mv clusterctl /usr/local/bin/clusterctl
```


## Steps
1) get kind or minikube cluster up
2) git clone https://github.com/humacs/humacs
3) cd humacs/infra/cluster-api
4) cp the secrect.env.example to make your own
5) update the secrets.env you created in line 5 to give it a distinct  `CLUSTER_NAME`
TODO: We need to generate a string to add to the name 
7) run `./cluster-setup.sh`
8) After the script hits  `[  OK  ] Reached target Cloud-init target.` type the following keys in sequence: "enter ~ ."
9) we have to rebuild the apisnoop image to include that kubeconfig
10) To open Mock test ticket `spc spc apisnoop/insert-mock-template`

Setting up SSH keys
In a new terminal on local machine:
1. ssh-add
2. ssh -A root@{Packetbox IP}
3. On the Packetbox open a Bash terminal
4. run . /usr/local/bin/ssh-agent-export.sh



## Re-attach to a session:
1. `export KUBECONFIG=/home/user/.kube/packet-{cluster name} i.e. testbox-humacs`
2. `kubectl exec -n r{cluster name}  -ti statefulset/{cluster name}  -- attach`
3. Type `Ctl + c` to dismiss the warning when you reattach 

## Add https certificates so we can use the https ingress
You will need to use the org files inside the cluster for this part. apisnoop references navigating to those files where they are checked out on disk. So this is all done inside emacs, to run a piece of required code move your cursor inside the code block and hit `,,`

1) navigate to apisnoop/README.org
2) Setup -> Ingress configuration -> Custom domains and input in NEW_HOST the sharing.io domain to assign (bb.sharing.io)
3) Setup -> Bringing up with kubectl
4) navigate to apisnoop/apps/certs/README.org and run through the docs to set it up, make sure that you change the NEW_HOST var too
5) add/update AWS Route53 rule , pointing an A record (bb.sharing.io) to the controlPlaneAddress of the server


# Daily Run: Start-up steps

`~$ ssh-add -l`

The agent has no identities.

`~$ ssh-add`

Identity added: /home/foo/.ssh/id_rsa (foo[@ii.coop](mailto:riaan@ii.coop))

`~$ Kind Delete cluster` - To ensure you have no Kind instance running yet

`~$ Kind create cluster`

`~$ cd .kube`

`~$ ls`  + Delete old config files ie. Packet-"cluster name"

`~$  cd humacs/infra/cluster-api/`

`~$ ls` + Delete old "cluster name".yaml files

`~$ vim secrets.env` - Ensure Unique CLUSTER_NAME="name-humacs" 

(the name a must be all smallcaps and end in "-humacs"

`~$ ./cluster-setup.sh`

When the setup stop with: `[ OK ] Reached target Cloud-init target.`

Type: `ENTER`

user-humacs-control-plane-tzslt login:  `~.`

**In Packet machine:**

Alt b, c

`~$ kubectl get svc -A | grep ingre`

Copy IP 

**In local terminal:**

~$ ssh -A [ii@{output IP from grep}](mailto:ii@139.178.89.28) 

 IF IT FAIL, TAKE THE IP FROM [PACKET.COM](http://packet.COM) (SSH Info)

**In Packet Machine:**

`~$ . /usr/local/bin/ssh-agent-export.sh`

`~$ ssh-add`

`~$ ssh -T git@github.com`

`yes` & Enter

`You've successfully authenticated, but GitHub does not provide shell access.`

DONE!!

**For good measure in Emacs:**
`spc spc` then the command `ssh-find-agent`



