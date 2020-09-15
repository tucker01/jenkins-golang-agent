#Docker file for jenkins agent image
FROM ubuntu:groovy

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

# Install JRE 8 
RUN apt-get -q update &&\
    DEBIAN_FRONTEND="noninteractive" apt-get -q install -y -o Dpkg::Options::="--force-confnew" --no-install-recommends software-properties-common &&\
    apt-get -q update &&\
    DEBIAN_FRONTEND="noninteractive" apt-get -q install -y -o Dpkg::Options::="--force-confnew" --no-install-recommends openjdk-8-jre-headless &&\
    apt-get -q clean -y && rm -rf /var/lib/apt/lists/* && rm -f /var/cache/apt/*.bin

# Install JDK 8
RUN apt-get -q update && apt-get install -y openjdk-8-jdk 

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
  sudo apt-get -y install python3.8 &&\
  sudo apt-get -y install python3-pip

# install golang
RUN cd ${HOME} && wget https://dl.google.com/go/go1.12.linux-amd64.tar.gz && tar -C /usr/local -xzf go1.12.linux-amd64.tar.gz

# switch to jenkins 
USER jenkins 

# setup user env for GO
ENV PATH="/usr/local/go/bin:${PATH}:/home/jenkins/bin"
ENV GOPATH="/home/jenkins/go"
ENV PATH="${PATH}:${GOPATH}/bin"

# JDK
ENV JAVA_HOME="/usr/lib/jvm/java-8-openjdk-amd64"

# install some python deps
RUN pip install fabric
RUN pip install mkdocs

# install golang tasks
RUN cd /home/jenkins && wget https://taskfile.dev/install.sh && chmod +x install.sh && ./install.sh && rm install.sh
RUN go get -u github.com/jstemmer/go-junit-report
