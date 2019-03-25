# Demo of the Neutron rolling upgrade bug

### Info

Bug report - read for more info:
https://bugs.launchpad.net/kolla-ansible/+bug/1821086

Commits related to this bug:
* https://github.com/openstack/kolla/commit/4f4de70594d3d9060c262438ddd87f768b4dda00
* https://github.com/openstack/kolla-ansible/commit/ac5d5217fc7b40bdd2371f7f0f2caa4d734568bb

In this demo i've tried to isolate the problematic code and logic into two playbooks (one for Ubuntu and one for CentOS). The Docker containers will have the same entrypoint script based of the original `extend_start.sh` script used, it's shortened a bit to only include the for-loop and surrounding logic that makes up this bug.

The point i want to make here is that the variable containing a valid YAML list:

`neutron_rolling_upgrade_services: ["neutron", "neutron-fwaas", "neutron-vpnaas"]`

will be interated through correctly in `bash` and that `extended_start.sh` script _but_ with the squarebrackets and commas as parts of the array elements:

```
neutron-db-manage --subproject ['neutron', upgrade --contract
neutron-db-manage --subproject 'neutron-fwaas', upgrade --contract
neutron-db-manage --subproject 'neutron-vpnaas'] upgrade --contract
```

Which fails with the following error(s):

```
argument --subproject: Invalid String(choices=['vmware-nsx', 'networking-infoblox', 'neutron-lbaas', 'networking-sfc', 'neutron-vpnaas', 'networking-l2gw', 'neutron-fwaas', 'neutron', 'neutron-dynamic-routing']) value: [neutron,
```

As i've mentioned in the comments of this bug report the above error falls through silently, it never propagates outside of the Docker container which means that the upgrade of the database failed but the user have no clue about it. We got other errors later on (in the upgrade phase) where access to specific columns in the database failed since they were never created as they should've been during the database upgrade.

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


