# Class: openstack_zeromq::config
#
# This module manages the openstack_zeromq configuration directories
#
# Parameters:
#
# [*debug*]
#   Whether to enable Debug or not. Default: false
#
# [*bind_address*]
#   Which address to bind zmq receiver. Default: '*' (all addresses)
#
# [*contexts*]
#   Number of Zeromq contexts. Default: 1
#
# [*ipc_dir*]
#   Directory for holding IPC sockets. These sockets are used to send the
#   messages to the applications - i.e. nova-scheduler will only listen
#   appropriate IPC socket, it will not listen the TCP socket.
#   It is zmq_receiver who listen on TCP port and send the messages to
#   appropriate IPC sockets.
#   Default: /var/run/openstack.
#
# [*matchmaker*]
#   Matchmaker driver. Currently only supported driver is MatchMakerRing.
#
# [*port*]
#   The port to listen zmq_receiver. Default: 9501
#
# [*backlog*]
#   Maximum number of ingress messages to locally buffer per topic.
#   Default: None (means unlimited)
#   Note: There was a bug in Havana code due to which setting this parameter
#   caused silently ignoring the messages. Not tested in icehouse yet.
#
# Actions:
#   Configure zmq_receiver.
#
# Requires: openstack_zeromq::install, openstack_zeromq
#
# Sample Usage: include openstack_zeromq::config
#
class openstack_zeromq::config(
  $debug        = false,
  $bind_address = '*',
  $contexts     = 1,
  $ipc_dir      = '/var/run/openstack',
  $matchmaker   = 'oslo.messaging._drivers.matchmaker_ring.MatchMakerRing',
  $port         = 9501,
  $backlog      = 'None',
) {

  require openstack_zeromq::install

  ##
  # /etc/oslo/zmq_receiver.conf is the zmq receiver configuration file.
  # /etc/oslo also holds matchmaker ring file - /etc/oslo/matchmaker_ring.json
  ##

  file { '/etc/oslo':
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
  }

  file { '/etc/oslo/zmq_receiver.conf':
    ensure => file,
    content => template("${module_name}/zmq_receiver.conf.erb"),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => File['/etc/oslo'],
    notify  => Class['openstack_zeromq::service'],
  }

  ##
  # MatchmakerRing will only work if and only if the unix sockets
  # for the topics (unix sockets under /var/run/openstack) to be writable
  # by all applications using zeromq.
  # In order to make that happen, There are three options
  #
  # 1. zeromq_receiver to be run as same user as the application which
  #   need separate zeromq_receiver for different
  #   projects (e.g one for cinder, another for nova etc) which runs as
  # different users
  # 2. run zmq_receiver with umask value of 000 - it create files with world
  # writable, which has a security issue.
  # 3.
  #   Create a group called "openstack"
  #   Add all users like cinder, nova to this group
  #   Handle below stuffs in upstart script
  #
  #   Make ipc_dir (/var/run/openstack) with group ownership of openstack
  #     and with sgid set, so that all files created under that directory
  #     will have group ownership of "openstack" group.
  #   Run zmq receiver with umask value of 0002, so that it will create files
  #     with group write flag.
  #
  #  Currently employed third option.
  ##

  ##
  # Create group with appropriate users
  ##

  group {'openstack':
    ensure  => present,
    system  => true,
    before  => [ Exec['add_cinder_to_openstack'],
                  Exec['add_nova_to_openstack']],
  }

  ##
  # Some modules (e.g nova) has user definition for nova user, So cannot use
  # user type to add these users to openstack group. So using exec for now as a
  # workaround.
  #
  # Note: Currently only cinder and nova need zmq.
  ##

  exec {'add_cinder_to_openstack':
    command => 'usermod -aG openstack cinder',
    onlyif  => 'id cinder',
    unless  => 'id cinder | grep "(openstack)"',
    path    => '/bin:/usr/bin:/usr/sbin:/sbin'
  }

  exec {'add_nova_to_openstack':
    command => 'usermod -aG openstack nova',
    onlyif  => 'id nova',
    unless  => 'id nova | grep "(openstack)"',
    path    => '/bin:/usr/bin:/usr/sbin:/sbin'
  }

}
