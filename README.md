
# openstack-libvirt
OpenStack environment using Libvirt, Ansible and Vagrant

# Steps to create an OpenStack project

1. In the host machine, create an Open vSwitch bridge called openstack-sw and also define a network in libvirt using the XML file vlan-trunking.xml
1. Define the number of nodes: deployment, load balancer, controller, compute, network, ceph, swift, cinder, etc. in the Vagrantfile
2. Execute vagrant up
1. Update the file inventory.txt (this is an Ansible inventory file).
1. Modify the networking configuration files inside networking/templates based on the environment defined in openstack_user_config.yml
    1. The file interfaces.j2 can be used as a template for every node defined
1. Execute: ansible-playbook -i inventory.txt site.yaml. This will set up the virtual machines and it'll get them ready for OpenStack.
1. Modify the file openstack_user_config.yml in the deployment node.
    1. The used_ips.txt file can be used to update the variable used_ips in openstack_user_config.yml
1. Log into the OpenStack deployment node and execute.
    1. cd /opt/openstack-ansible/playbooks
    1. openstack-ansible setup-hosts.yml
    1. openstack-ansible haproxy-install.yml # If using Load Balancer nodes
    1. openstack-ansible setup-infrastructure.yml
    1. openstack-ansible setup-openstack.yml
  
# Currently the project supports the following:

1. Creating a dynamic multinode enviroment (number of nodes can be specified in the Vagrantfile). Currently, only the following nodes can be created: lb, deployment, controller, compute and network.
1. Network interface bonding in the virtual machines that made up the OpenStack environment.
1. VLAN's support for the storage, container and tenant networks.
1. Flat network support for provider networks.
