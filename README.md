# openstack_zeromq

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with openstack_zeromq](#setup)
    * [What openstack_zeromq affects](#what-openstack_zeromq-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with openstack_zeromq](#beginning-with-openstack_zeromq)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Overview

This module is to configure openstack zmq receiver to use zeromq as message
queue for openstack services.

This module is tested with Ubuntu trusty with icehouse.

## Module Description
This module install, configure oslo zeromq receiver and matchmaker and manage
zmq_receiver service.

* Configure zmq receiver by setting up /etc/oslo/zmq_receiver.conf
* Configure matchmaker by adding appropriate server entries in /etc/oslo/matchmaker_ring.json

Note: Currently only supported driver is MatchmakerRing which use a json ring file for matchmaking.

### Reference
http://docs.openstack.org/icehouse/config-reference/content/database-configuring-rpc.html#database-configure-zeromq
http://ewindisch.github.io/nova/

## Setup

### What openstack_zeromq affects

* install python-oslo-messaging, and python-zmq packages.
* Configure /etc/oslo/zmq_receiver.conf and /etc/oslo/matchmaker_ring.json
* Install upstart script for service oslo-messaging-zmq-receiver. This is
    because python-oslo-messaging dont have an upstart job for zmq receiver.
* Manage service oslo-messaging-zmq-receiver.

Note: This module only work with icehouse and later releases.

### Setup Requirements

Host resolution is mandatory for matchmaker to work. So either /etc/hosts
entries or DNS resolution is required for all hosts added in matchmaker.

### Beginning with openstack_zeromq

To begin, call openstack_zeromq class with parameters.


The very basic steps needed for a user to get the module up and running.

If your most recent release breaks compatibility or requires particular steps
for upgrading, you may wish to include an additional section here: Upgrading
(For an example, see http://forge.puppetlabs.com/puppetlabs/firewall).

## Usage

Put the classes, types, and resources for customizing, configuring, and doing
the fancy stuff with your module here.

## Reference

Here, list the classes, types, providers, facts, etc contained in your module.
This section should include all of the under-the-hood workings of your module so
people know what the module is touching on their system but don't need to mess
with things. (We are working on automating this section!)

## Limitations

This is where you list OS compatibility, version compatibility, etc.

## Development

Since your module is awesome, other users will want to play with it. Let them
know what the ground rules for contributing are.

## Release Notes/Contributors/Etc **Optional**

If you aren't using changelog, put your release notes here (though you should
consider using changelog). You may also add any additional sections you feel are
necessary or important to include here. Please use the `## ` header.
