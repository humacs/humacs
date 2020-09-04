FROM ubuntu:20.04
ENV TERM=screen-256color
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
  file
ADD bin /usr/local/bin
ENV EMACSLOADPATH=/var/local/humacs: \
  HUMACS_PROFILE=ii \
  DOOMDIR=/var/local/humacs/zz-config
COPY homedir/.tmate.conf /etc/skel
COPY homedir/.tmux.conf /etc/skel
RUN mkdir -p /etc/sudoers.d && \
  echo "%sudo    ALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers.d/sudo && \
  useradd -m -G users,sudo -u 1000 -s /bin/bash ii
ADD --chown=ii:users . /var/local/humacs
RUN su ii -c 'curl -L https://github.com/humacs/humacs/releases/download/0.0.1-alpha/spacemacs-elpa-cache-2020.08.28.tgz | tar xvzC /var/local/humacs/spacemacs'
# spacemacs cache
RUN su ii -c 'cd && emacs -batch -l /var/local/humacs/default.el'
# doom install/sync
RUN su ii -c 'cd && yes | /var/local/humacs/doom-emacs/bin/doom install --no-env'
RUN su ii -c 'cd && yes | /var/local/humacs/doom-emacs/bin/doom sync -e'

WORKDIR /home/ii
