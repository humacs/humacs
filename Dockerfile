FROM ubuntu:20.04
ARG HUMACS_IMAGE=""
ENV TERM=screen-256color \
  HUMACS_IMAGE="$HUMACS_IMAGE" \
  HUMACS_CONTAINER=yes \
  HUMACS_DISTRO=humacs \
  HUMACS_PROFILE=doom \
  HUMACS_DOOM_CONFIG_REF=108f9877fecd199455a62816f7162f77020f5f7f \
  DOOMDIR=/home/ii/.doom.d \
  EMACSLOADPATH=/var/local/humacs: \
  PATH=$PATH:/var/local/humacs/doom-emacs/bin
RUN DEBIAN_FRONTEND=noninteractive \
  apt update \
  && apt upgrade -y \
  && DEBIAN_FRONTEND=noninteractive apt install --no-install-recommends -y \
    software-properties-common \
  && yes '\n' | add-apt-repository ppa:git-core/ppa \
  && yes '\n' | add-apt-repository ppa:kelleyk/emacs \
  && apt update \
  && DEBIAN_FRONTEND=noninteractive apt install --no-install-recommends -y \
    emacs27-nox \
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
    psmisc \
  && rm -rf /var/lib/apt/lists/*
COPY homedir/.tmate.conf /etc/skel
COPY homedir/.tmux.conf /etc/skel
COPY homedir/.bashrc /etc/skel/.bashrc
COPY homedir/.bash_profile /etc/skel/.bash_profile
COPY homedir/.gitconfig /etc/skel/.gitconfig
COPY etc/ /etc/
RUN mkdir -p /etc/sudoers.d && \
  echo "%sudo    ALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers.d/sudo && \
  useradd -m -G users,sudo -u 1000 -s /bin/bash ii && \
  chmod 0775 /usr/local/lib && chgrp users /usr/local/lib && \
  chmod 0770 -R /etc/service/ && \
  chgrp -R users /etc/service/ && \
  chown -R ii:ii /usr/local/lib/node_modules
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
COPY --chown=ii:users spacemacs/ /var/local/humacs/spacemacs/
COPY --chown=ii:users vagrant/ /var/local/humacs/vagrant/
COPY --chown=ii:users snippets/ /var/local/humacs/snippets/
COPY --chown=ii:users config.org /var/local/humacs/
RUN cd /var/local/humacs && git remote remove origin && chown -R ii:users .
RUN su ii -c 'curl -L https://github.com/humacs/humacs/releases/download/0.0.1-alpha/spacemacs-elpa-cache-2020.08.28.tgz | tar xvzC /var/local/humacs/spacemacs'
# spacemacs cache
RUN su ii -c 'cd && HUMACS_PROFILE=ii emacs -batch -l /var/local/humacs/default.el'
# doom install/sync
RUN su ii -c "cd /home/ii && git clone https://github.com/humacs/.doom.d && \
  cd .doom.d && \
  git checkout $HUMACS_DOOM_CONFIG_REF && \
  /var/local/humacs/doom-emacs/bin/org-tangle ii.org"
RUN su ii -c 'cd && yes | /var/local/humacs/doom-emacs/bin/doom install --no-env'
RUN su ii -c 'cd && yes | /var/local/humacs/doom-emacs/bin/doom sync -e'
ADD bin /usr/local/bin
# copy final files from the repo to make it feel more like a repo
COPY --chown=ii:users Dockerfile .gitignore .gitlab-ci.yml .gitmodules ii.Dockerfile LICENSE README.org /var/local/humacs/

WORKDIR /home/ii
