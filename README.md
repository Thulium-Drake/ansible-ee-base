# Ansible Base Execution Environment
This Ansible Execution Environment (EE) contains all tools required for running Ansible code.

It contains tools/libraries for:

* ARA (https://ara.recordsansible.org)
* ASSH (https://github.com/moul/assh)
* Git
* Python dependencies commonly used in Ansible Collections
* Jq
* VMWare vSphere 8 (https://github.com/vmware/vsphere-automation-sdk-python)

You can use this EE as a base for your own projects and add all required collections to it

# Building
In order to build the EE you can use the 'build_ee.sh' script, before running it, ensure you have:

* Credentials for the destination registry with write privileges
* If required, credentials for password-protected source registries
* Configure the script using the ~/.build_ee.conf file, you can find the default values in the script

# Ansible Navigator usage
When running this with Ansible Navigator, you should create a `ansible-navigator.yml` file
in your project, which looks like this:

```
---
ansible-navigator:
  execution-environment:
    image: git.element-networks.nl/ansible/ee-base:latest
    environment-variables:
      pass:
        - ANSIBLE_VAULT_PASSWORD
        - SSH_AUTH_SOCK
      set:
        ANSIBLE_VAULT_PASSWORD_FILE: ./.ansible-vault-ee
    volume-mounts:
      - src: $SSH_AUTH_SOCK
        dest: $SSH_AUTH_SOCK
  mode: stdout
  logging:
    file: /dev/null
  playbook-artifact:
    enable: false
```

This configuration will reuse the SSH agent on the host and pass the ANSIBLE_VAULT_PASSWORD
via the environment.

## Passing Ansible Vault passphrase to the EE
In order to use secrets to the EE, you need to set up the following:

* On the host: make sure you have a means of retrieving the Ansible Vault passphrase, this document
  assumes you have this set up (for example using ansible-utils)
* In your project: create a new script with the following content:

```
#!/bin/bash
echo ${ANSIBLE_VAULT_PASSWORD}
```

* On the host: before running ansible-navigator, put your Ansible Vault passphrase in the
  ANSIBLE_VAULT_PASSWORD environment variable. If you're using ansible-utils, you can do:

```
cd <my_project>
export ANSIBLE_VAULT_PASSWORD=$(./.ansible-vault)
```

* This will retrieve the passphrase from the GPG encrypted file and pass it to the container
  with the ansible-navigator configuration shown above.
