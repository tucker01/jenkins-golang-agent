# Docker file for jenkins agent image
FROM ubuntu:bionic

USER root

RUN apt-get update -qqy \
  && apt-get -qqy install \
    locales \
    sudo

# Upgrade packages on image
# Preparations for sshd
RUN locale-gen en_US.UTF-8 &&\
    apt-get -q update &&\
    DEBIAN_FRONTEND="noninteractive" apt-get -q upgrade -y -o Dpkg::Options::="--force-confnew" --no-install-recommends &&\
    DEBIAN_FRONTEND="noninteractive" apt-get -q install -y -o Dpkg::Options::="--force-confnew" --no-install-recommends openssh-server &&\
    apt-get -q autoremove &&\
    apt-get -q clean -y && rm -rf /var/lib/apt/lists/* && rm -f /var/cache/apt/*.bin &&\
    sed -i 's|session    required     pam_loginuid.so|session    optional     pam_loginuid.so|g' /etc/pam.d/sshd &&\
    mkdir -p /var/run/sshd


ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Install JDK 11
RUN apt-get -q update && apt-get install -y openjdk-11-jdk-headless 

# Create jenkins user
RUN sudo useradd jenkins --shell /bin/bash --create-home \
  && sudo usermod -a -G sudo jenkins \
  && echo 'ALL ALL = (ALL) NOPASSWD: ALL' >> /etc/sudoers \
  && echo 'jenkins:jenkins' | chpasswd

# install some basic utilities
RUN apt-get -y update &&\
  sudo apt-get -y install wget &&\
  sudo apt-get -y install curl &&\
  sudo apt-get -y install git &&\
  sudo apt-get -y install python3-pip &&\
  sudo apt-get -y install python3.8 &&\
  sudo apt-get -y install python3-venv &&\
  sudo apt-get -y install python3.8-venv &&\
  sudo apt-get -y install python3-dev &&\
  sudo apt-get -y install python3.8-dev &&\
  sudo apt-get -y install unzip &&\
  sudo apt-get -y install zip &&\
  sudo apt-get -y install libcurl4-openssl-dev &&\
  sudo apt-get -y install libssl-dev

# install golang
RUN cd ${HOME} && wget https://golang.org/dl/go1.12.linux-amd64.tar.gz &&\
  echo "750a07fef8579ae4839458701f4df690e0b20b8bcce33b437e4df89c451b6f13 go1.12.linux-amd64.tar.gz" | sha256sum -c &&\
  tar -C /usr/local -xzf go1.12.linux-amd64.tar.gz

RUN cp /usr/bin/python3.8 /usr/bin/python
RUN cp /usr/bin/python3.8 /usr/bin/python3
RUN cp /usr/bin/pip3 /usr/bin/pip

# install nodejs
# https://nodejs.org/en/download/package-manager/#debian-and-ubuntu-based-linux-distributions
# https://github.com/nodesource/distributions/blob/master/README.md#debinstall
RUN curl -fsSL https://deb.nodesource.com/setup_14.x | bash - &&\
  sudo apt-get install -y nodejs

# install golang tasks
RUN cd ${HOME} &&\
  wget https://github.com/go-task/task/releases/download/v2.8.1/task_linux_amd64.tar.gz &&\
  echo "c7ca69ef85a6db25b04f90d417ec7e9c537518d7023c2a563ae4d1e34b841aba task_linux_amd64.tar.gz" | sha256sum -c &&\
  tar -xzf task_linux_amd64.tar.gz &&\
  cp task /usr/bin/task &&\
  chmod +x /usr/bin/task

# switch to jenkins 
USER jenkins 

# setup user env for GO
ENV PATH="/usr/local/go/bin:${PATH}:/home/jenkins/bin"
ENV GOPATH="/home/jenkins/go"
ENV PATH="${PATH}:${GOPATH}/bin"

# JDK
ENV JAVA_HOME="/usr/lib/jvm/java-11-openjdk-amd64"

# Setup PATH for python scripts
ENV PATH="${PATH}:/home/jenkins/.local/bin"

# install some python deps - the upgrade is necessary because fabric installs, the python/pip
# guidance is to upgrade pip ...
RUN pip3 install --upgrade pip
RUN pip3 install mkdocs==1.1.2
RUN pip3 install mkdocs-material==6.2.6
RUN pip3 install PyGithub==1.54.1
RUN pip3 install fabric==2.6.0
RUN pip3 install blackduck==1.0.4

# install junit report
RUN go get -u github.com/jstemmer/go-junit-report
