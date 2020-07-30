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
ADD . /etc/skel/humacs
ADD bin /usr/local/bin
RUN mkdir -p /etc/sudoers.d && \
  echo "%sudo    ALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers.d/sudo && \
  cd /etc/skel/humacs && \
  ln -sf /etc/skel/humacs/.emacs-profiles.el ../ && \
  ln -sf /etc/skel/humacs/.emacs-profile ../ && \
  ln -sf /etc/skel/humacs/chemacs/.emacs ../ && \
  useradd -m -G users,sudo -u 2000 -s /bin/bash humacs
WORKDIR /home/humacs
