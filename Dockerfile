FROM centos7

# There's no cmake available for ubi7 yet
# FROM registry.access.redhat.com/ubi7

MAINTAINER Anthony Green <anthony@atgreen.org>

ARG GOGS_VERSION="0.11.86"

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

RUN rpm -hiv http://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm && \
    yum -y update && yum -y install git nss_wrapper gettext jq openssl && yum -y clean all 
RUN curl -L -o /tmp/gogs.tar.gz https://github.com/gogs/gogs/releases/download/v0.11.86/linux_amd64.tar.gz && \
    (cd /opt; tar xvf /tmp/gogs.tar.gz; rm /tmp/gogs.tar.gz)

RUN (for D in /var/log/gogs /etc/gogs /var/lib/gogs; do mkdir -p $D; done) && \
    adduser gogs && \
    /usr/bin/fix-permissions /var/lib/gogs && \
    /usr/bin/fix-permissions /home/gogs && \
    /usr/bin/fix-permissions /opt/gogs && \
    /usr/bin/fix-permissions /etc/gogs && \
    /usr/bin/fix-permissions /var/log/gogs

ENV USERNAME=gogs

EXPOSE 3000

CMD ["/usr/bin/rungogs"]
