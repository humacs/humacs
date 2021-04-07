FROM ubuntu:20.04
ENV TERM=screen-256color \
  HUMACS_CONTAINER=yes \
  HUMACS_DISTRO=humacs
RUN DEBIAN_FRONTEND=noninteractive \
  apt update \
  && apt upgrade -y \
  && DEBIAN_FRONTEND=noninteractive apt install --no-install-recommends -y \
  emacs-nox \
  tmate \
  bash-completion \
  less \
  xz-utils \
  sudo \
  curl \
  ca-certificates \
  libcap2-bin \
  git \
  kitty \
  openssh-client \
  postgresql-client-12 \
  jq \
  inotify-tools \
  xtermcontrol \
  nodejs \
  gnupg2 \
  tzdata \
  wget \
  python3-dev \
  xz-utils \
  apache2-utils \
  sqlite3 \
  silversearcher-ag \
  build-essential \
  vim \
  rsync \
  unzip \
  direnv \
  iputils-ping \
  file \
  && rm -rf /var/lib/apt/lists/*
ENV EMACSLOADPATH=/var/local/humacs: \
  HUMACS_PROFILE=ii \
  DOOMDIR=/var/local/humacs/doom-config
COPY homedir/.tmate.conf /etc/skel
COPY homedir/.tmux.conf /etc/skel
COPY homedir/.bashrc /etc/skel/.bashrc
COPY homedir/.bash_profile /etc/skel/.bash_profile
COPY homedir/.gitconfig /etc/skel/.gitconfig
COPY homedir/kubeconfig /etc/skel/.kube/config
RUN mkdir -p /etc/sudoers.d && \
  echo "%sudo    ALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers.d/sudo && \
  useradd -m -G users,sudo -u 1000 -s /bin/bash ii && \
  chmod 0600 /etc/skel/.kube/config
# required for emacs initialization
COPY --chown=ii:users default.el /var/local/humacs/
# copy each needed directory so it is placed in correctly
COPY --chown=ii:users chart/ /var/local/humacs/chart/
COPY --chown=ii:users docs/ /var/local/humacs/docs/
COPY --chown=ii:users .git/ /var/local/humacs/.git/
COPY --chown=ii:users homedir/ /var/local/humacs/homedir/
COPY --chown=ii:users infra/ /var/local/humacs/infra/
COPY --chown=ii:users kind-configs/ /var/local/humacs/kind-configs/
COPY --chown=ii:users spacemacs-config/ /var/local/humacs/spacemacs-config/
COPY --chown=ii:users wilinux-config/ /var/local/humacs/wilinux-config/
COPY --chown=ii:users doom-emacs/ /var/local/humacs/doom-emacs/
COPY --chown=ii:users doom-config/ /var/local/humacs/doom-config/
COPY --chown=ii:users spacemacs/ /var/local/humacs/spacemacs/
COPY --chown=ii:users vagrant/ /var/local/humacs/vagrant/
RUN cd /var/local/humacs && git remote remove origin
RUN su ii -c 'curl -L https://github.com/humacs/humacs/releases/download/0.0.1-alpha/spacemacs-elpa-cache-2020.08.28.tgz | tar xvzC /var/local/humacs/spacemacs'
# spacemacs cache
RUN su ii -c 'cd && emacs -batch -l /var/local/humacs/default.el'
# doom install/sync
RUN su ii -c 'cd && yes | /var/local/humacs/doom-emacs/bin/doom install --no-env'
RUN su ii -c 'cd && yes | /var/local/humacs/doom-emacs/bin/doom sync -e'
ADD bin /usr/local/bin
# copy final files from the repo to make it feel more like a repo
COPY --chown=ii:users Dockerfile .gitignore .gitlab-ci.yml .gitmodules ii.Dockerfile LICENSE Readme.md Readme.org /var/local/humacs/

WORKDIR /home/ii
