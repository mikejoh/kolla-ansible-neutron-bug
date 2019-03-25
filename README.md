# Demo of the Neutron rolling upgrade bug

### Info

Bug report - read for more info:
https://bugs.launchpad.net/kolla-ansible/+bug/1821086

Commits related to this bug:
* https://github.com/openstack/kolla/commit/4f4de70594d3d9060c262438ddd87f768b4dda00
* https://github.com/openstack/kolla-ansible/commit/ac5d5217fc7b40bdd2371f7f0f2caa4d734568bb

In this demo i've tried to isolate the problematic code and logic into two playbooks (one for Ubuntu and one for CentOS). The Docker containers will have the same entrypoint script based of the original `extend_start.sh` script used, it have been shortened a bit to only include the for-loop and surrounding logic that makes up this bug.

### Notes
* The variables are configured as `vars` in the playbooks instead of external files.
* The tasks are delegated to `localhost` to fire off the container(s) and exit.
* The `kolla_docker` module are bundled.

### Testing locally on Ubuntu and CentOS containers:
1. Build image:
```
docker build . -f Dockerfile.ubuntu -t fake-neutron:ubuntu
docker build . -f Dockerfile.centos -t fake-neutron:centos
```
2. Run ansible playbook (run once per operating system):
```
export ANSIBLE_STDOUT_CALLBACK=debug
ansible-playbook rolling_upgrade-ubuntu.yml
ansible-playbook rolling_upgrade-centos.yml
```


