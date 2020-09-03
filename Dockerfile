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
  iputils-ping \
  file
ADD bin /usr/local/bin
ADD --chown=root:users . /var/local/humacs
ENV EMACSLOADPATH=/var/local/humacs: \
  HUMACS_PROFILE=ii
COPY homedir/.tmate.conf /etc/skel
COPY homedir/.tmux.conf /etc/skel
RUN mkdir -p /etc/sudoers.d && \
  echo "%sudo    ALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers.d/sudo && \
  useradd -m -G users,sudo -u 1000 -s /bin/bash humacs
RUN su humacs -c 'curl -L https://github.com/humacs/humacs/releases/download/0.0.1-alpha/spacemacs-elpa-cache-2020.08.28.tgz | tar xvzC /var/local/humacs/spacemacs'
RUN su humacs -c 'cd && emacs -batch -l /var/local/humacs/default.el'

WORKDIR /home/humacs
