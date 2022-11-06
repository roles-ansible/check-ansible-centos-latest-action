# hadolint ignore=DL3007
FROM quay.io/centos/centos:latest

LABEL "maintainer"="L3D <l3d@c3woc.de>"
LABEL "repository"="https://github.com/roles-ansible/check-ansible-centos-latest-action.git"
LABEL "homepage"="https://github.com/roles-ansible/check-ansible-centos-latest-action"

LABEL "com.github.actions.name"="check-ansible-centos-latest"
LABEL "com.github.actions.description"="Check ansible role or playbook with CentOS latest"
LABEL "com.github.actions.icon"="aperture"
LABEL "com.github.actions.color"="green"

# hadolint ignore=DL3041,DL3013
RUN sed -i -e "s|mirrorlist=|#mirrorlist=|g" /etc/yum.repos.d/CentOS-* \
  && sed -i -e "s|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g" /etc/yum.repos.d/CentOS-* \
  && dnf update --assumeyes \
  && dnf install -y epel-release \
  && dnf install --assumeyes \
         python3 python3-pip git \
  && pip install --no-cache-dir ansible \
  && dnf clean all \
  && ansible --version

COPY ansible-docker.sh /ansible-docker.sh
ENTRYPOINT ["/ansible-docker.sh"]
