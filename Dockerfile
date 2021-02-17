FROM centos:latest

LABEL "maintainer"="L3D <l3d@c3woc.de>"
LABEL "repository"="https://github.com/roles-ansible/check-ansible-centos-latest-action.git"
LABEL "homepage"="https://github.com/roles-ansible/check-ansible-centos-latest-action"

LABEL "com.github.actions.name"="check-ansible-centos-latest"
LABEL "com.github.actions.description"="Check ansible role or playbook with CentOS latest"
LABEL "com.github.actions.icon"="aperture"
LABEL "com.github.actions.color"="green"

RUN dnf update --assumeyes && dnf install --assumeyes epel-release

RUN dnf update --assumeyes && dnf install --assumeyes \
    ansible \
    git

RUN ansible --version

ADD ansible-docker.sh /ansible-docker.sh
ENTRYPOINT ["/ansible-docker.sh"]
