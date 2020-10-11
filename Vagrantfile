# -*- mode: ruby -*-
# vi: set ft=ruby :
#

# Networks
# bond0.236 - br-mgmt (Container) 172.29.236.0/24
# bond1.240 - br-vxlan (Neutron VXLAN Tunnel network) 172.29.240.0/24
# bond0.244 - br-storage (Storage network) 172.29.244.0/24
# bond1 - br-vlan (Neutron VLAN network)
# openstack-sw - Public Network (192.168.15.0/24)

# Public Network
# 192.168.15.110 - deployment
# 192.168.15.120 - lb
# 192.168.15.130 - controller
# 192.168.15.140 - compute
# 192.168.15.150 - network
# 192.168.15.160 - ceph
# 192.168.15.170 - cinder
# 192.168.15.180 - swift

# ip_start for the diferent components:
# Deployment: 10
# Load Balancers: 20
# Controller: 30
# Compute: 40
# Network: 50
# Ceph: 60
# Cinder 70
# Swift 80

ENV['VAGRANT_NO_PARALLEL'] = 'yes'

# Node types
# DON'T FORGET TO UPDATE THE ANSIBLE INVENTORY FILE (inventory.txt)
deployment = { :count => 0, :start_ip => 10, :memory => 5120, cpus: 4 }
lb         = { :count => 1, :start_ip => 20, :memory => 2048, cpus: 1 }
controller = { :count => 3, :start_ip => 30, :memory => 4096, cpus: 2 }
compute    = { :count => 3, :start_ip => 40, :memory => 4096, cpus: 4 }
network    = { :count => 1, :start_ip => 50, :memory => 2048, cpus: 1 }
ceph       = { :count => 4, :start_ip => 60, :memory => 2048, cpus: 1 }
cinder     = { :count => 1, :start_ip => 70, :memory => 2048, cpus: 1 }
swift      = { :count => 0, :start_ip => 80, :memory => 2048, cpus: 1 }
logging    = { :count => 1, :start_ip => 90, :memory => 1024, cpus: 1 }
nfs        = { :count => 0, :start_ip =>100, :memory => 2048, cpus: 1 }

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
      box.vm.box = "ubuntu-bionic-bonding"
      box.vm.hostname = "#{hostname}"
      box.vm.synced_folder ".", "/vagrant", disabled: true
      box.vm.provision :shell, inline: "sudo update-alternatives --install /usr/bin/python python /usr/bin/python3 10"
      # Managment network
      box.vm.network :public_network, type: 'network', network_name: 'openstack-sw0', portgroup: "vlan-bond0", ovs: true, auto_config: false
      box.vm.network :public_network, type: 'network', network_name: 'openstack-sw1', portgroup: "vlan-bond0", ovs: true, auto_config: false
      # Public network 192.168.15.0/24
      # box.vm.network :public_network,
      #   type: 'bridge',
      #   dev: 'openstack-sw',
      #   mode: 'bridge',
      #   ovs: true,
      #   ip: "192.168.15.1#{ip}",
      #   netmask: "255.255.255.0"
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
      box.vm.box = "ubuntu-bionic-bonding"
      box.vm.hostname = "#{hostname}"
      box.vm.synced_folder ".", "/vagrant", disabled: true
      box.vm.provision :shell, inline: "sudo update-alternatives --install /usr/bin/python python /usr/bin/python3 10"
      # mgmt network
      box.vm.network :public_network, type: 'network', network_name: 'openstack-sw0', portgroup: "vlan-bond0", ovs: true, auto_config: false
      box.vm.network :public_network, type: 'network', network_name: 'openstack-sw1', portgroup: "vlan-bond0", ovs: true, auto_config: false
      # For public network access
      box.vm.network :public_network, type: 'network', network_name: 'openstack-sw0', portgroup: "vlan-bond1", ovs: true, auto_config: false
      box.vm.network :public_network, type: 'network', network_name: 'openstack-sw1', portgroup: "vlan-bond1", ovs: true, auto_config: false
      # Public network 192.168.15.0/24
      # box.vm.network :public_network,
      #   type: 'bridge',
      #   dev: 'openstack-sw',
      #   mode: 'bridge',
      #   ovs: true,
      #   ip: "192.168.15.1#{ip}",
      #   netmask: "255.255.255.0"
      box.vm.provider :libvirt do |domain|
        domain.memory = lb[:memory]
        domain.cpus = lb[:cpus]
      end
    end
  end

  # Creating the controller nodes
  controller[:count].times do |i|
    hostname = "controller%02d" % [i]
    config.vm.define "#{hostname}" do |box|
      box.vm.box = "ubuntu-bionic-bonding"
      box.vm.hostname = "#{hostname}"
      box.vm.synced_folder ".", "/vagrant", disabled: true
      box.vm.provision :shell, inline: "sudo update-alternatives --install /usr/bin/python python /usr/bin/python3 10"
      # Networking
      box.vm.network :public_network, type: 'network', network_name: 'openstack-sw0', portgroup: "vlan-bond0", ovs: true, auto_config: false
      box.vm.network :public_network, type: 'network', network_name: 'openstack-sw1', portgroup: "vlan-bond0", ovs: true, auto_config: false
      box.vm.network :public_network, type: 'network', network_name: 'openstack-sw0', portgroup: "vlan-bond1", ovs: true, auto_config: false
      box.vm.network :public_network, type: 'network', network_name: 'openstack-sw1', portgroup: "vlan-bond1", ovs: true, auto_config: false
      box.vm.provider :libvirt do |domain|
        domain.memory = controller[:memory]
        domain.cpus = controller[:cpus]
      end
    end
  end

  # Creating the compute nodes
  compute[:count].times do |i|
    hostname = "compute%02d" % [i]
    config.vm.define "#{hostname}" do |box|
      box.vm.box = "ubuntu-bionic-bonding"
      box.vm.hostname = "#{hostname}"
      box.vm.synced_folder ".", "/vagrant", disabled: true
      box.vm.provision :shell, inline: "sudo update-alternatives --install /usr/bin/python python /usr/bin/python3 10"
      # mgmt, storage and vxlan networks
      box.vm.network :public_network, type: 'network', network_name: 'openstack-sw0', portgroup: "vlan-bond0", ovs: true, auto_config: false
      box.vm.network :public_network, type: 'network', network_name: 'openstack-sw1', portgroup: "vlan-bond0", ovs: true, auto_config: false
      box.vm.network :public_network, type: 'network', network_name: 'openstack-sw0', portgroup: "vlan-bond1", ovs: true, auto_config: false
      box.vm.network :public_network, type: 'network', network_name: 'openstack-sw1', portgroup: "vlan-bond1", ovs: true, auto_config: false
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
    config.vm.define "#{hostname}" do |box|
      box.vm.box = "ubuntu-bionic-bonding"
      box.vm.hostname = "#{hostname}"
      box.vm.synced_folder ".", "/vagrant", disabled: true
      box.vm.provision :shell, inline: "sudo update-alternatives --install /usr/bin/python python /usr/bin/python3 10"
      # mgmt, storage, vxlan and vlan networks
      box.vm.network :public_network, type: 'network', network_name: 'openstack-sw0', portgroup: "vlan-bond0", ovs: true, auto_config: false
      box.vm.network :public_network, type: 'network', network_name: 'openstack-sw1', portgroup: "vlan-bond0", ovs: true, auto_config: false
      box.vm.network :public_network, type: 'network', network_name: 'openstack-sw0', portgroup: "vlan-bond1", ovs: true, auto_config: false
      box.vm.network :public_network, type: 'network', network_name: 'openstack-sw1', portgroup: "vlan-bond1", ovs: true, auto_config: false
      # provider network
      # box.vm.network :public_network,
      #   type: 'bridge',
      #   dev: 'openstack-sw',
      #   mode: 'bridge',
      #   ovs: true,
      #   auto_config: false
      box.vm.provider :libvirt do |domain|
        domain.memory = network[:memory]
        domain.cpus = network[:cpus]
      end
    end
  end

  # Creating the cinder nodes
  cinder[:count].times do |i|
    hostname = "cinder%02d" % [i]
    config.vm.define "#{hostname}" do |box|
      box.vm.box = "ubuntu-bionic-bonding"
      box.vm.hostname = "#{hostname}"
      box.vm.synced_folder ".", "/vagrant", disabled: true
      box.vm.provision :shell, inline: "sudo update-alternatives --install /usr/bin/python python /usr/bin/python3 10"
      # mgmt and storage network
      box.vm.network :public_network, type: 'network', network_name: 'openstack-sw0', portgroup: "vlan-bond0", ovs: true, auto_config: false
      box.vm.network :public_network, type: 'network', network_name: 'openstack-sw1', portgroup: "vlan-bond0", ovs: true, auto_config: false
      box.vm.provider :libvirt do |domain|
        domain.memory = cinder[:memory]
        domain.cpus = cinder[:cpus]
        domain.storage :file, :size => '60G'
      end
    end
  end

  # Creating the ceph nodes
  ceph[:count].times do |i|
    hostname = "ceph%02d" % [i]
    config.vm.define "#{hostname}" do |box|
      box.vm.box = "ubuntu-bionic-bonding"
      box.vm.hostname = "#{hostname}"
      box.vm.synced_folder ".", "/vagrant", disabled: true
      box.vm.provision :shell, inline: "sudo update-alternatives --install /usr/bin/python python /usr/bin/python3 10"
      # mgmt and storage network
      box.vm.network :public_network, type: 'network', network_name: 'openstack-sw0', portgroup: "vlan-bond0", ovs: true, auto_config: false
      box.vm.network :public_network, type: 'network', network_name: 'openstack-sw1', portgroup: "vlan-bond0", ovs: true, auto_config: false
      box.vm.provider :libvirt do |domain|
        domain.memory = ceph[:memory]
        domain.cpus = ceph[:cpus]
        domain.storage :file, :size => '60G'
        domain.storage :file, :size => '60G'
        domain.storage :file, :size => '60G'
      end
    end
  end

  # Creating the swift nodes
  swift[:count].times do |i|
    hostname = "swift%02d" % [i]
    config.vm.define "#{hostname}" do |box|
      box.vm.box = "ubuntu-bionic-bonding"
      box.vm.hostname = "#{hostname}"
      box.vm.synced_folder ".", "/vagrant", disabled: true
      box.vm.provision :shell, inline: "sudo update-alternatives --install /usr/bin/python python /usr/bin/python3 10"
      # mgmt and storage network
      box.vm.network :public_network, type: 'network', network_name: 'openstack-sw0', portgroup: "vlan-bond0", ovs: true, auto_config: false
      box.vm.network :public_network, type: 'network', network_name: 'openstack-sw1', portgroup: "vlan-bond0", ovs: true, auto_config: false
      box.vm.provider :libvirt do |domain|
        domain.memory = swift[:memory]
        domain.cpus = swift[:cpus]
        domain.storage :file, :size => '60G'
        domain.storage :file, :size => '60G'
        domain.storage :file, :size => '60G'
        domain.storage :file, :size => '60G'
        domain.storage :file, :size => '60G'
      end
    end
  end

# Creating the NFS storage nodes
  nfs[:count].times do |i|
    hostname = "nfs%02d" % [i]
    config.vm.define "#{hostname}" do |box|
      box.vm.box = "ubuntu-bionic-bonding"
      box.vm.hostname = "#{hostname}"
      box.vm.synced_folder ".", "/vagrant", disabled: true
      box.vm.provision :shell, inline: "sudo update-alternatives --install /usr/bin/python python /usr/bin/python3 10"
      # mgmt and storage network
      box.vm.network :public_network, type: 'network', network_name: 'openstack-sw0', portgroup: "vlan-bond0", ovs: true, auto_config: false
      box.vm.network :public_network, type: 'network', network_name: 'openstack-sw1', portgroup: "vlan-bond0", ovs: true, auto_config: false
      box.vm.provider :libvirt do |domain|
        domain.memory = nfs[:memory]
        domain.cpus = nfs[:cpus]
        domain.storage :file, :size => '60G'
      end
    end
  end

  # Creating the logging nodes
  logging[:count].times do |i|
    hostname = "logging%02d" % [i]
    config.vm.define "#{hostname}" do |box|
      box.vm.box = "ubuntu-bionic-bonding"
      box.vm.hostname = "#{hostname}"
      box.vm.synced_folder ".", "/vagrant", disabled: true
      box.vm.provision :shell, inline: "sudo update-alternatives --install /usr/bin/python python /usr/bin/python3 10"
      # mgmt and storage network
      box.vm.network :public_network, type: 'network', network_name: 'openstack-sw0', portgroup: "vlan-bond0", ovs: true, auto_config: false
      box.vm.network :public_network, type: 'network', network_name: 'openstack-sw1', portgroup: "vlan-bond0", ovs: true, auto_config: false
      box.vm.provider :libvirt do |domain|
        domain.memory = logging[:memory]
        domain.cpus = logging[:cpus]
      end
    end
  end

end
