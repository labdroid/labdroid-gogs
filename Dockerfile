FROM centos:7

MAINTAINER Anthony Green <anthony@atgreen.org>

ARG GOGS_VERSION="0.11.79"

LABEL name="Gogs - Go Git Service" \
      vendor="Gogs" \
      io.k8s.display-name="Gogs - Go Git Service" \
      io.k8s.description="The goal of this project is to make the easiest, fastest, and most painless way of setting up a self-hosted Git service." \
      summary="The goal of this project is to make the easiest, fastest, and most painless way of setting up a self-hosted Git service." \
      io.openshift.expose-services="3000,gogs" \
      io.openshift.tags="gogs" \
      build-date="2018-12-29" \
      version="${GOGS_VERSION}" \
      release="1"

ENV HOME=/var/lib/gogs

COPY ./root /

RUN yum -y install epel-release &&\ 
    yum -y --setopt=tsflags=nodocs install nss_wrapper gettext && \
    yum install epel-release -y && yum install -y --setopt=tsflags=nodocs jq && \
    yum -y clean all && \
    curl -L -o /tmp/gogs.tar.gz https://github.com/gogs/gogs/releases/download/v${GOGS_VERSION}/linux_amd64.tar.gz && \
    (cd /opt; tar xvf /tmp/gogs.tar.gz; rm /tmp/gogs.tar.gz) && \
    mkdir -p /var/lib/gogs

RUN /usr/bin/fix-permissions /var/lib/gogs && \
    /usr/bin/fix-permissions /home/gogs && \
    /usr/bin/fix-permissions /opt/gogs && \
    /usr/bin/fix-permissions /etc/gogs && \
    /usr/bin/fix-permissions /var/log/gogs

EXPOSE 3000
USER 997

CMD ["/usr/bin/rungogs"]
