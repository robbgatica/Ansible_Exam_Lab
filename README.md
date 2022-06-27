# Ansible Exam Lab

---

## Introduction

This is the lab environment I used to prepare for the Red Hat Certified Engineer exam (EX294). There is one control node and four managed nodes:

- ansible-control
- ansible1
- ansible2
- ansible3
- ansible4

To start, these hosts were manually created from RHEL8 and CentOS8 iso files in VMWare Fusion/Workstation and configured to a minimal baseline specification:

- 1GB RAM
- 20GB primary disk
- 5GB secondary disk on ansible1 and ansible2
- root user account configured with a password of "password"
- Control node (ansible-control) configured with an "ansible" user
- Local name resolution configured in `/etc/hosts` on control node for all managed hosts

## Initial config

After the base configuration was established, snapshots were created for all hosts. At this point, I created a couple of simple shell scripts that use `vmrun` commands: vmstart.sh and vmstop.sh. `vmstart` reverts the hosts to their snapshot, runs them in the background, and automatically ssh into the control node. `vmstop` simply shuts the machines down gracefully.

> FYI, I used the `rhce_hostname` naming convention for all of the hosts in this lab for the sake of easy globbing (`rhce*`) in these scripts.

The idea here is to start with a fresh snapshot of the hosts for each lab session.

---

## Ansible setup

### control node

For each new session, I start with adding the ansible user to `/etc/sudoers.d` on the control node. The `priv.sh` script is a one-liner that accomplishes the task:

- `echo 'ansible ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/ansible`

Next, the Ansible repo is enabled and the engine is installed:

- `sudo subscription-manager repos --enable=ansible-2-for-rhel-8-x86_64-rpms`
- `sudo yum install -y ansible`

### inventory and config files

Now, an inventory file can be set up in the ansible user's home directory. The managed hosts will be added to groups 'test', 'dev', 'prod', and 'servers'. An `.ansible.cfg` file will also created in /home/ansible with my lab defaults. This should be all that is needed to set up the control node.

### managed node setup

To finish the lab configuration, I used a shell script containing Ansible ad-hoc commands to complete the setup of the managed hosts - `host_setup.sh`. This addresses the remaining tasks:

- generate SSH keys
- create the ansible user on managed hosts
- grant sudo privileges to the ansible user
- distribute SSH keys
- verify the configuration (ping)

### Repo setup - `repos.yml`

Now that the lab has been successfully set up, the final task is to create a playbook that disables all current repos, loop mounts the iso file, and creates a local BaseOS and AppStream repos on each managed node.

---

## Practice Exam Tasks

- **`lvm_config.yml`**
  - Create a playbook that configures an 2GB LVM volume with the name `web_files` in the volume group `web_group`
  - Configure the LVM as an XFS volume
  - This should only execute on servers that have a secondary disk available. If no second disk is found, a message should be displayed indicating 'no secondary disk available' with no further action taken
  - Ensure that the LVM is mounted persitently to /mnt/web
- **`ftp_server.yml`**
  - Create a playbook that configures servers in the 'dev' group for FTP
  - Ensure that the latest version of vsftp is installed
  - The service should be started and enabled
  - Anonymous access to the ftp server should be enabled
  - Ensure the firewall is configured for the service
  - Create a welcome message file (welcome.txt) in the ftp root directory
- **`hostfile.yml`**
  - Write a playbook that generates a file with the name /tmp/hosts, based on discovered inventory information. The file must have the same format as the /etc/hosts file
  - Use a template file to accomplish this task (hosts.j2)
- **`web_server.yml`**
  - Write a playbook that installs, starts, and enables the httpd service on host ansible4
  - Ensure the httpd service is listening on port 88 and is accessible through the firewall
  - In the same playbook, write a play that tests access to the service and prints an error message if the service could not be accessed
- **`device_list.yml`**
  - Write a playbook that detects storage devices and writes a report with device names to the file /tmp/devices.txt.
  - For each host, the file should have the line “primary device DEVICENAME found on HOSTNAME,” where DEVICENAME is replaced with the actual name of the device and HOSTNAME is replaced with the actual name of the host
  - If a second disk device is found, the file should have the line “second device DEVICENAME found on HOSTNAME". If no second disk device is found, the file should have the line “no second device found on HOSTNAME
- **`set_selinux_mode.yml`**
  - Create a playbook that changes SELinux mode to 'permissive' on host ansible3
  - If the mode is changed successfully, the target host should be rebooted after waiting 30 seconds
  - If no change is made, the playbook should print the message "no changes made"
- **`custom_facts.yml`**
  - Create a facts file that sets the following facts: package1=httpd, package2=mariadb-server
  - Write a playbook to push these custom facts to ansible2
- **`install_packages.yml`**
  - Write a playbook that installs and enables the packages listed in the custom facts file from the previous task
- **`ntp_server.yml`**
  - Use a RHEL system role that manages time in a playbook
  - Ensure that the control node is used as the time server
  - Ensure that the appropriate parameter that allows changing time even if a large difference exists between time on the managed machine and the time on the NTP server
  - Verify that time is synchronized at the end of the playbook. If not, the playbook should prin the message "time could not be synchronized"
