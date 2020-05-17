# -*- mode: ruby -*-
# vi: set ft=ruby :
#

# Networks
# eth0 - NAT Used by Libvirt 
# eth1 - br-mgmt (Container) 172.29.236.0/24
# eth2 - br-vxlan (Neutron VXLAN Tunnel network) 172.29.240.0/24
# eth3 - br-storage (Storage network) 172.29.244.0/24
# eth4 - br-vlan (Neutron VLAN network) 0.0.0.0/0

# ip_start for the diferent components:
# Deployment: 10
# Load Balancers: 20
# Controller: 30
# Compute: 40
# Network: 50
# Ceph: 60

ENV['VAGRANT_NO_PARALLEL'] = 'yes'

# Node types
# DON'T FORGET TO UPDATE THE ANSIBLE INVENTORY FILE (inventory.txt)
deployment = { :count => 0, :start_ip => 10, :memory => 5120, cpus: 4 }
lb         = { :count => 1, :start_ip => 20, :memory => 2048, cpus: 2 }
controller = { :count => 2, :start_ip => 30, :memory => 4096, cpus: 2 }
compute    = { :count => 1, :start_ip => 40, :memory => 4096, cpus: 2 }
network    = { :count => 1, :start_ip => 50, :memory => 2048, cpus: 2 }
ceph       = { :count => 3, :start_ip => 60, :memory => 1024, cpus: 4 }


Vagrant.configure("2") do |config|

  # For vagrant hostmanager plugin
  config.hostmanager.enabled = true
  config.hostmanager.manage_host = true
  config.hostmanager.ignore_private_ip = true

  # Define the pool from which the 
  config.vm.provider :libvirt do |libvirt|
    libvirt.storage_pool_name = "virsh-ssd-pool"
  end

  # Creating the deployment node
  deployment[:count].times do |i|
    hostname = "deployment%02d" % [i]
    ip = "#{deployment[:start_ip]+i}"
    config.vm.define "#{hostname}" do |box|
      box.vm.box = "ubuntu-bionic-openstack"
      box.vm.hostname = "#{hostname}"
      box.vm.synced_folder ".", "/vagrant", disabled: true
      box.vm.provision :shell, inline: "sudo update-alternatives --install /usr/bin/python python /usr/bin/python3 10"
      # Managment network
      box.vm.network :private_network, ip: "172.29.236.#{ip}", :netmask => "255.255.255.0"
      # Network for accessing the public IP address of the API
      box.vm.network :private_network, libvirt__network_name: "openstack-public", ip: "192.168.100.#{ip}", netmask: "255.255.255.0"
      box.vm.provider :libvirt do |domain|
        domain.memory = deployment[:memory]
        domain.cpus = deployment[:cpus]
      end
    end
  end

 # Creating the LB nodes
 lb[:count].times do |i|
    hostname = "lb%02d" % [i]
    ip = "#{lb[:start_ip]+i}"
    config.vm.define "#{hostname}" do |box|
      box.vm.box = "ubuntu-bionic-openstack"
      box.vm.hostname = "#{hostname}"
      box.vm.synced_folder ".", "/vagrant", disabled: true
      box.vm.provision :shell, inline: "sudo update-alternatives --install /usr/bin/python python /usr/bin/python3 10"
      # mgmt network
      box.vm.network :public_network, type: 'network', network_name: 'openstack-sw', portgroup: "vlan-bond0", ovs: true, auto_config: false
      box.vm.network :public_network, type: 'network', network_name: 'openstack-sw', portgroup: "vlan-bond0", ovs: true, auto_config: false
      # Public network 192.168.15.0/24
      box.vm.network :public_network,
        type: 'bridge',
        dev: 'openstack-sw',
        mode: 'bridge',
        ovs: true,
        ip: "192.168.15.2#{ip}",
        netmask: "255.255.255.0"
      box.vm.provider :libvirt do |domain|
        domain.memory = lb[:memory]
        domain.cpus = lb[:cpus]
      end
    end
  end

  # Creating the controller nodes
  controller[:count].times do |i|
    hostname = "controller%02d" % [i]
    ip = "#{controller[:start_ip]+i}"
    config.vm.define "#{hostname}" do |box|
      box.vm.box = "ubuntu-bionic-openstack"
      box.vm.hostname = "#{hostname}"
      box.vm.synced_folder ".", "/vagrant", disabled: true
      box.vm.provision :shell, inline: "sudo update-alternatives --install /usr/bin/python python /usr/bin/python3 10"
      # mgmt and storage network
      box.vm.network :public_network, type: 'network', network_name: 'openstack-sw', portgroup: "vlan-bond0", ovs: true, auto_config: false
      box.vm.network :public_network, type: 'network', network_name: 'openstack-sw', portgroup: "vlan-bond0", ovs: true, auto_config: false
      box.vm.provider :libvirt do |domain|
        domain.memory = controller[:memory]
        domain.cpus = controller[:cpus]
      end
    end
  end

  # Creating the compute nodes
  compute[:count].times do |i|
    hostname = "compute%02d" % [i]
    ip = "#{compute[:start_ip]+i}"
    config.vm.define "#{hostname}" do |box|
      box.vm.box = "ubuntu-bionic-openstack"
      box.vm.hostname = "#{hostname}"
      box.vm.synced_folder ".", "/vagrant", disabled: true
      box.vm.provision :shell, inline: "sudo update-alternatives --install /usr/bin/python python /usr/bin/python3 10"
      # mgmt, storage and vxlan networks
      box.vm.network :public_network, type: 'network', network_name: 'openstack-sw', portgroup: "vlan-bond0", ovs: true, auto_config: false
      box.vm.network :public_network, type: 'network', network_name: 'openstack-sw', portgroup: "vlan-bond0", ovs: true, auto_config: false
      box.vm.network :public_network, type: 'network', network_name: 'openstack-sw', portgroup: "vlan-bond1", ovs: true, auto_config: false
      box.vm.network :public_network, type: 'network', network_name: 'openstack-sw', portgroup: "vlan-bond1", ovs: true, auto_config: false
      box.vm.provider :libvirt do |domain|
        domain.memory = compute[:memory]
        domain.cpus = compute[:cpus]
        # Nested virtualization
        domain.nested = true
      end
    end
  end

  # Creating the network nodes
  network[:count].times do |i|
    hostname = "network%02d" % [i]
    ip = "#{network[:start_ip]+i}"
    config.vm.define "#{hostname}" do |box|
      box.vm.box = "ubuntu-bionic-openstack"
      box.vm.hostname = "#{hostname}"
      box.vm.synced_folder ".", "/vagrant", disabled: true
      box.vm.provision :shell, inline: "sudo update-alternatives --install /usr/bin/python python /usr/bin/python3 10"
      # mgmt, storage, vxlan and vlan networks
      box.vm.network :public_network, type: 'network', network_name: 'openstack-sw', portgroup: "vlan-bond0", ovs: true, auto_config: false
      box.vm.network :public_network, type: 'network', network_name: 'openstack-sw', portgroup: "vlan-bond0", ovs: true, auto_config: false
      box.vm.network :public_network, type: 'network', network_name: 'openstack-sw', portgroup: "vlan-bond1", ovs: true, auto_config: false
      box.vm.network :public_network, type: 'network', network_name: 'openstack-sw', portgroup: "vlan-bond1", ovs: true, auto_config: false
      # provider network
      box.vm.network :public_network,
        type: 'bridge',
        dev: 'openstack-sw',
        mode: 'bridge',
        ovs: true,
        auto_config: false
      box.vm.provider :libvirt do |domain|
        domain.memory = network[:memory]
        domain.cpus = network[:cpus]
      end
    end
  end

  # Creating the ceph nodes
#  compute[:count].times do |i|
#    hostname = "compute-%02d" % [i]
#    ip = "#{lb[:start_ip]+i}"
#    config.vm.define "#{hostname}" do |box|
#      box.vm.box = "ubuntu-bionic-openstack"
#      box.vm.hostname = "#{hostname}"
#      box.vm.synced_folder ".", "/vagrant", disabled: true
#      box.vm.provision :shell, inline: "sudo update-alternatives --install /usr/bin/python python /usr/bin/python3 10"
#      box.vm.network :private_network, ip: "172.29.236.#{ip}", :netmask => "255.255.255.0"
#      box.vm.network :private_network, ip: "172.29.240.#{ip}", :netmask => "255.255.255.0"
#      box.vm.network :private_network, ip: "172.29.244.#{ip}", :netmask => "255.255.255.0"
#      box.vm.network :private_network, ip: "172.16.0.#{ip}", :netmask => "255.255.255.0"
#      box.vm.network :private_network, libvirt__network_name: "openstack-public", ip: "192.168.100.#{ip}", netmask: "255.255.255.0"
#      box.vm.provider :libvirt do |domain|
#        domain.memory = compute[:memory]
#        domain.cpus = compute[:cpus]
#      end
#    end
#  end
end
