Role Name
=========

This role basically helps to set up networking in Ubuntu based on the templates that are located under the directory templates.

Requirements
------------

The role requires netplan to be disabled in Ubuntu as it creates an interface configuration file under /etc/network/ and then restarts the networking service to bring up the interfaces in such file.

Role Variables
--------------

This role only accepts one variable:

- nodetype: The node type to set up networking for.
    Options: ceph, cinder, compute, controller, lb, logging, network, nfs, swift, etc. 

Example Playbook
----------------

    - name: Setting up networking in controller nodes
      hosts: controller_nodes
      become: yes
      roles:
      - networking
      vars:
        nodetype: controller
