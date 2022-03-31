#! /usr/bin/env bash

set -Eeuo pipefail
set -x

# Generates client.
# env:
#   [required] TARGETS : Path to your ansible role or to a playbook .yml file you want to be tested.
#                       (e.g, './' or 'roles/my_role/' for roles or 'site.yml' for playbooks)

ansible::prepare() {
  : "${TARGETS?No targets to check. Nothing to do.}"
  : "${GITHUB_WORKSPACE?GITHUB_WORKSPACE has to be set. Did you use the actions/checkout action?}"
  pushd "${GITHUB_WORKSPACE}"

  # generate ansible.cfg
  cat <<EOF | tee ansible.cfg
[defaults]
inventory = hosts.ini
nocows = true
host_key_checking = false
forks = 20
fact_caching = jsonfile
fact_caching_connection = $HOME/facts
fact_caching_timeout = 7200
ansible_python_interpreter=/usr/bin/python3
ansible_connection=local
EOF

  # create host list
  cat <<EOF | tee hosts.ini
[local]
localhost ansible_python_interpreter=/usr/bin/python3 ansible_connection=local
EOF
}

ansible::test::role() {
  : "${TARGETS?No targets to check. Nothing to do.}"
  : "${GITHUB_WORKSPACE?GITHUB_WORKSPACE has to be set. Did you use the actions/checkout action?}"
  pushd "${GITHUB_WORKSPACE}"

  # generate playbook to be executed
  cat <<EOF | tee -a deploy.yml
---
- name: test a ansible role
  hosts: localhost
  tags: default
  roles:
    - "${TARGETS}"
EOF

  # execute playbook
  ansible-playbook  --connection=local --limit localhost deploy.yml --tags "${TAGS}" --skip-tags "${SKIPTAGS}"
}
ansible::test::playbook() {
  : "${TARGETS?No targets to check. Nothing to do.}"
  : "${GITHUB_WORKSPACE?GITHUB_WORKSPACE has to be set. Did you use the actions/checkout action?}"
  : "${HOSTS?at least one valid host is required to check your playbook!}"
  : "${GROUP?Please define the group your playbook is written for!}"
  pushd "${GITHUB_WORKSPACE}"

  cat <<EOF | tee hosts.ini
[${GROUP}]
${HOSTS} ansible_python_interpreter=/usr/bin/python3 ansible_connection=local ansible_host=127.0.0.1
EOF

  # execute playbook
  # shellcheck disable=SC2086
  ansible-playbook --connection=local --inventory host.ini ${TARGETS}
}

# make sure git is up to date
git submodule update --init --recursive
if [[ "${REQUIREMENTS}" == *.yml ]]
then
  ansible-galaxy install -r "${REQUIREMENTS}"
else
  [ -n "${REQUIREMENTS}" ] && ansible-galaxy install "${REQUIREMENTS}"
fi
if [ "$0" = "${BASH_SOURCE[*]}" ] ; then
  >&2 printf "Running Ansible debian check...\n"
  ansible::prepare
  if [[ "${TARGETS}" == *.yml ]]
  then
      echo -e "\nansible playbook detected\ninitialize playbook testing...\n"
      ansible::test::playbook
  else
      echo -e "\nno playbook detected\ninitialize role testing...\n"
      ansible::test::role
  fi
fi
