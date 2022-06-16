#!/bin/bash

source ../conf/admin-openrc.sh

# Create security group rules to allow ICMP, SSH and WWW access
admin_project_id=$(openstack project show admin -c id -f value)
default_secgroup_id=$(openstack security group list -f value | grep $admin_project_id | cut -d " " -f1)
openstack security group rule create --proto icmp --dst-port 0  $default_secgroup_id
openstack security group rule create --proto tcp  --dst-port 80 $default_secgroup_id
openstack security group rule create --proto tcp  --dst-port 22 $default_secgroup_id

# Create vlan based networks and subnetworks
openstack network create --share --provider-physical-network physnet1 --provider-network-type vlan --provider-segment 10 vlan10
openstack network create --share --provider-physical-network physnet1 --provider-network-type vlan --provider-segment 20 vlan20
openstack subnet create --network vlan10 --gateway 10.1.2.1 --dns-nameserver 8.8.8.8 --subnet-range 10.1.2.0/24 --allocation-pool start=10.1.2.2,end=10.1.2.99 subvlan10
openstack subnet create --network vlan20 --gateway 10.1.3.1 --dns-nameserver 8.8.8.8 --subnet-range 10.1.3.0/24 --allocation-pool start=10.1.3.2,end=10.1.3.99 subvlan20

# Create virtual machine
mkdir -p tmp
openstack keypair create vmA1 > tmp/vmA1
openstack server create --flavor m1.small --image Ubuntu-Xenial vmA1 --nic net-id=vlan10 --key-name vmA1
openstack keypair create vmB1 > tmp/vmB1
openstack server create --flavor m1.small --image Ubuntu-Xenial vmB1 --nic net-id=vlan20 --key-name vmB1
