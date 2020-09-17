- [Emacs](#sec-1)
- [Humacs](#sec-2)
- [Humacs in Docker](#sec-3)
    - [Simple-Init.sh](#sec-3-0-1)
- [Kubernetes (Helm)](#sec-4)

Environment variables to configure environments

# Emacs<a id="sec-1"></a>

| Variables       | Description                                                  | Default |
|--------------- |------------------------------------------------------------ |------- |
| `EMACSLOADPATH` | colon string array path for Emacs to load configuration from | `""`    |

# Humacs<a id="sec-2"></a>

| Variables        | Description               | Default |
|---------------- |------------------------- |------- |
| `HUMACS_PROFILE` | the Humacs profile to use | `ii`    |

# Humacs in Docker<a id="sec-3"></a>

### Simple-Init.sh<a id="sec-3-0-1"></a>

| Variables                   | Description                                            | Default                           |
|--------------------------- |------------------------------------------------------ |--------------------------------- |
| `DEBUG`                     | `set -x` debug on shell blocks                         | `false`                           |
| `GIT_AUTHOR_EMAIL`          | (required) the default email to use for commits        | `""`                              |
| `GIT_AUTHOR_NAME`           | (required) the default name to use for commits         | `""`                              |
| `GIT_COMMITER_EMAIL`        | (required) the default email to use for commits        | `""`                              |
| `GIT_COMMITER_NAME`         | (required) the default name to use for commits         | `""`                              |
| `TMATE_SOCKET`              | the default tmate socket to use for creating sessions  | `/tmp/ii.default.target.iisocket` |
| `TMATE_SOCKET_NAME`         | the name of the socket file                            | `ii.default.target.iisocket`      |
| `INIT_ORG_FILE`             | the initial file/folder to load when bringing up Emacs | `~/`                              |
| `INIT_DEFAULT_DIR`          | the default directory to open shells in                | `~/`                              |
| `INIT_DEFAULT_REPOS`        | spaced string array of default repos to clone          | `""`                              |
| `INIT_DEFAULT_REPOS_FOLDER` | the location of where to clone repos                   | `"/home/ii"`                      |
| `INIT_PREFINISH_BLOCK`      | a shell block to execute (after repos are clone)       | `""`                              |

# Kubernetes (Helm)<a id="sec-4"></a>

| Parameter                   | Description                                                     | Default                                  |
|--------------------------- |--------------------------------------------------------------- |---------------------------------------- |
| options.profile             | Humacs profile to use                                           | `ii`                                     |
| options.hostDockerSocket    | mount in the Docker socket from the host system                 | `false`                                  |
| options.hostTmp             | mount in the tmp dir of the host system                         | `false`                                  |
| options.gitName             | set the git name for the user account                           | `""`                                     |
| options.gitEmail            | set the git email for the user account                          | `""`                                     |
| options.repos               | array of repo URLs                                              | `[]`                                     |
| options.workingDirectory    | the default directory for new shells                            | `/home/ii`                               |
| options.workingFile         | the initial file or folder to load in Emacs                     | `/home/ii`                               |
| options.preinitScript       | a shell block to execute after cloning repos                    | `(echo 'Welcome to Humacs')`             |
| extraEnvVars                | declare extra environment variables                             |                                          |
| image.repository            | the repo where the image lives                                  | registry.gitlab.com/humacs/humacs/humacs |
| image.tag                   | specifies a tag of from the image to use                        | 2020.09.09                               |
| image.pullPolicy            | Humacs container pull policy                                    | IfNotPresent                             |
| imagePullSecrets            | references for the registry secrets to pull Humacs from         | `[]`                                     |
| nameOverride                | expand the name of the chart                                    | `""`                                     |
| fullNameOverride            | create a FQDN for the app name                                  | `""`                                     |
| serviceAccount.create       | whether a serviceAccount should be created for the Pod to use   | `true`                                   |
| serviceAccount.name         | a name to give the servce account                               | `nil`                                    |
| clusterRoleBinding.create   | where a clusterRoleBinding should be created for the Pod to use | `true`                                   |
| clusterRoleBinding.roleName | a name to give the clusterRoleBinding                           | `cluster-admin`                          |
| podSecurityContext          | Set a security context for the Pod                              | `{}`                                     |
| labels                      | declare labels for all resources                                | `{}`                                     |
| annotations                 | declare annotations for all resources                           | `{}`                                     |
| resources                   | limits and requests for the Pods                                | `{}`                                     |
| nodeSelector                | delcare the node labels for Pod scheduling                      | `{}`                                     |
| tolerations                 | declare the toleration labels for Pod scheduling                | `[]`                                     |
| affinity                    | declare the affinity settings for the Pod scheduling            | `{}`                                     |
| extraVolumes                | declare the extra volumes to use within the Pod                 | `{}`                                     |
| extraVolumesMounts          | declare the extra volume mounts for the Pod                     | `{}`                                     |
