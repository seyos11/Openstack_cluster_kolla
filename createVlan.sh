#!/bin/bash

source ~/vnx-kolla-openstack/conf/admin-openrc.sh

# Create security group rules to allow ICMP, SSH and WWW access
admin_project_id=$(openstack project show admin -c id -f value)
default_secgroup_id=$(openstack security group list -f value | grep $admin_project_id | cut -d " " -f1)
openstack security group rule create --proto icmp --dst-port 0  $default_secgroup_id
openstack security group rule create --proto tcp  --dst-port 80 $default_secgroup_id
openstack security group rule create --proto tcp  --dst-port 22 $default_secgroup_id

# Create vlan based networks and subnetworks
openstack network create --share --provider-physical-network vlan --provider-network-type vlan --provider-segment 1000 vlan1000
openstack network create --share --provider-physical-network vlan --provider-network-type vlan --provider-segment 1001 vlan1001
openstack subnet create --network vlan1000 --gateway 10.1.2.1 --dns-nameserver 8.8.8.8 --subnet-range 10.1.2.0/24 --allocation-pool start=10.1.2.2,end=10.1.2.99 subvlan1000
openstack subnet create --network vlan1001 --gateway 10.1.3.1 --dns-nameserver 8.8.8.8 --subnet-range 10.1.3.0/24 --allocation-pool start=10.1.3.2,end=10.1.3.99 subvlan1001

# Create virtual machine
mkdir -p tmp
openstack keypair create vmA1 > tmp/vmA1
openstack server create --flavor m1.tiny --image cirros vmA1 --nic net-id=vlan1000 --key-name vmA1
openstack keypair create vmB1 > tmp/vmB1
openstack server create --flavor m1.tiny --image cirros vmB1 --nic net-id=vlan1001 --key-name vmB1
