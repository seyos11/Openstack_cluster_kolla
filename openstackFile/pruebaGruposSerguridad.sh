#!/bin/bash

source ~/vnx-kolla-openstack/conf/admin-openrc.sh

# Create security group rules to allow ICMP, SSH and WWW access
admin_project_id=$(openstack project show admin -c id -f value)
default_secgroup_id=$(openstack security group list -f value | grep $admin_project_id | cut -d " " -f1)
openstack security group rule create --proto icmp --dst-port 0  $default_secgroup_id
openstack security group rule create --proto tcp  --dst-port 80 $default_secgroup_id
openstack security group rule create --proto tcp  --dst-port 22 $default_secgroup_id

   # Create flavors if not created
        openstack flavor show m1.nano >/dev/null 2>&amp;1    || openstack flavor create --id 0 --vcpus 1 --ram 64 --disk 1 m1.nano
        openstack flavor show m1.tiny >/dev/null 2>&amp;1    || openstack flavor create --id 1 --vcpus 1 --ram 512 --disk 1 m1.tiny
        openstack flavor show m1.smaller >/dev/null 2>&amp;1 || openstack flavor create --id 6 --vcpus 1 --ram 512 --disk 3 m1.smaller

        # Create virtual machine
        mkdir -p tmp
        openstack keypair create vmA1 > tmp/vmA1
        openstack server create --flavor m1.tiny --image Ubuntu-18.04 vmA1 --nic net-id=vlan1000 --key-name vmA1
        openstack keypair create vmB1 > tmp/vmB1
        openstack server create --flavor m1.tiny --image Ubuntu-18.04 vmB1 --nic net-id=vlan500 --key-name vmB1
