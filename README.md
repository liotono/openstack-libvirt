# openstack-libvirt
OpenStack environment using Libvirt, Ansible and Vagrant

# Steps to create an OpenStack environment:

1. In the host machine, create two Open vSwitch bridges and name them openstack-sw0 and openstack-sw1 and also define two networks in libvirt using the XML files openstack-sw0.xml and openstack-sw1.xml. These two switches are created to simulate some redudancy because hosts are connected to either of them and then a bond is created in the OpenStack nodes. Creating the bridges and the networks can be acomplished through the following commands:

    ```
    # ovs-vsctl add-br openstack-sw0
    # ovs-vsctl add-br openstack-sw1

    virsh # net-define openstack-sw0.xml
    virsh # net-autostart openstack-sw0
    virsh # net-start openstack-sw0

    virsh # net-define openstack-sw1.xml
    virsh # net-autostart openstack-sw1
    virsh # net-start openstack-sw1
    ```

1. Connect the two bridges using patch ports:

    ```
    ovs-vsctl add-port openstack-sw0 trunk-sw0
    ovs-vsctl add-port openstack-sw1 trunk-sw1
    ovs-vsctl set interface trunk-sw0 type=patch
    ovs-vsctl set interface trunk-sw1 type=patch
    ovs-vsctl set interface trunk-sw0 options=peer=trunk-sw1
    ovs-vsctl set interface trunk-sw1 options=peer=trunk-sw0
    ```

1. If possible, add one of your server's physical network interface to one of the bridges to provide external access to VM's:

    ```
    ovs-vsctl add-port openstack-sw0 enp7s0f1
    ```

1. Set the native VLAN and also the VLANS that are going to be trunked between bridges:

    ```
    ovs-vsctl set port trunk-sw0 trunks=100,101,102,103,104,105,236,240,244
    ovs-vsctl set port trunk-sw1 trunks=100,101,102,103,104,105,236,240,244
    ovs-vsctl set port trunk-sw0 vlan_mode=native-untagged tag=99
    ovs-vsctl set port trunk-sw1 vlan_mode=native-untagged tag=99
    ovs-vsctl set port enp7s0f1 vlan_mode=native-untagged tag=99 (Allow traffic to reach the physical network)
    ```

1. Define the number of nodes: deployment, load balancer, controller, compute, network, ceph, swift, cinder, etc. in Vagrantfile
1. Execute vagrant up
1. Update the file inventory.txt (this is an Ansible inventory file).
1. Modify the networking configuration files inside networking/templates based on your environment.
    1. The file interfaces.j2 can be used as a template for every node defined.
1. Modify or add the OpenStack configuration files in openstack-ansible/files/openstack_deploy. These files define your OpenStack deployment and will be copied to /etc/openstack_deploy in the deployment node.
1. Modify the variable openstack_version (version to be deployed) in the task 'Cloning, preparing and bootstrapping OpenStack-Ansible'. This in site.yaml
1. Execute: ansible-playbook -i inventory.txt site.yaml
    1. This will set up the virtual machines and it'll get them ready for OpenStack.
1. Log into the OpenStack deployment node and execute.
    1. cd /opt/openstack-ansible/playbooks
    1. openstack-ansible setup-hosts.yml
    1. openstack-ansible haproxy-install.yml # If using Load Balancer nodes
    1. openstack-ansible setup-infrastructure.yml
    1. openstack-ansible setup-openstack.yml
  
# Currently the project supports the following:

1. Creating a dynamic multinode enviroment (number of nodes can be specified in the Vagrantfile). Currently, only the following nodes can be created: lb, deployment, controller, compute, network, cinder, ceph and logging.
1. Network interface bonding in the virtual machines that make up the OpenStack environment.
1. VLAN's support for the storage, container and tenant networks.
1. Flat network support for provider networks.
