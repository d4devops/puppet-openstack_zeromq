# Class: openstack_zeromq::install
#
# This module manages Openstack zeromq installation
#
# Parameters:
#
# [*package_ensure*]
#
# Actions:
#   Install packages for zmq receiver to work (python-oslo-messaging and
#   python-zmq).
#
# Sample Usage:
#   include openstack_zeromq::install
#
class openstack_zeromq::install(
  $package_ensure    = present,
) {

##
# Install python-oslo-messaging. This include zmq receiver code and oslo driver.
##
  package { 'python-oslo.messaging':
    ensure  => $package_ensure,
  }

##
# install python-zmq which is depenancy for zeromq
##

  package {'python-zmq':
    ensure  => present,
  }
}

