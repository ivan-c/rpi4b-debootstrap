#! /bin/sh -eu


wget \
    https://gist.githubusercontent.com/ivan-c/35768f1ee268ce0a581f412bffa8a3dc/raw/bootstrap-ansible.sh \
    --output-document /tmp/bootstrap-ansible.sh
chmod +x /tmp/bootstrap-ansible.sh
/tmp/bootstrap-ansible.sh


wget \
    https://raw.githubusercontent.com/ivan-c/ansible-role-ansible-pull/master/files/ansible_pull_wrapper.sh \
    --output-document /usr/bin/ansible_pull_wrapper.sh
chmod +x /usr/bin/ansible_pull_wrapper.sh
/usr/bin/ansible_pull_wrapper.sh --tags boot --url https://github.com/ivan-c/ansible-bootstrap/
