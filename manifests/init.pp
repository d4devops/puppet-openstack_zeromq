# Class: openstack_zeromq
#
# This module manages openstack oslo zeromq
#
# Note: At present, only matchmaker driver supported is MathMakerRing.
#
# Parameters:
#
# [*debug*]
# Whether to enable debug messages, Default: false,
#
# [*bind_address*]
#   ZeroMQ bind address. Should be a wildcard (*),
#     an ethernet interface, or IP. Default: '*'
#
# [*port*]
#   Zmq receiver port. Default: 9501
#
# [*contexts*]
#   Number of ZeroMQ contexts, Default: 1.
#
# [*matchmaker*]
#   Matchmaker driver.
#
# [*topic_backlog*]
#   Maximum number of ingress messages to locally buffer
#      per topic. Default is unlimited.
#
# [*ipc_dir*]
#   Directory for holding IPC sockets. Default: /var/run/openstack
#
# [*cinder_nodes*]
#   Array of cinder nodes where all cinder services (cinder-scheduler,
#   cinder-api, and cinder-volume are running. This is used as default
#   for cinder_scheduler_nodes, and cinder_volume_nodes
#
# [*cinder_scheduler_nodes*]
#   Array of cinder-scheduler nodes. This is to add to matchmaker ring.
#   Default: $cinder_nodes
#
# [*cinder_volume_nodes*]
#   Array of cinder-volume nodes to add into matchmaker ring.
#   Default: $cinder_nodes
#
# [*nova_nodes*]
#   Array of nova nodes where all nova controller services (nova-scheduler,
#   nova-api, nova-consoleauth, nova-cert, etc are running. This is used
#   default for nova_scheduler_nodes, nova_consoleauth_nodes,
#   nova_conductor_nodes, nova_cert_nodes, unless they are overridden.
#
# [*nova_scheduler_nodes*]
#   Nova scheduler nodes to add in matchmaker ring.
#   Default: $nova_nodes
#
# [*nova_consoleauth_nodes*]
#   Nova consoleauth nodes to add in matchmaker ring.
#   Default: $nova_nodes
#
# [*nova_conductor_nodes*]
#   Nova conductor nodes to add in matchmaker ring.
#   Default: $nova_nodes
#
# [*nova_cert_nodes*]
#   Nova cert nodes to add in matchmaker ring. Default: $nova_nodes,
#   Default: $nova_nodes
#
# Sample Usage:
#
#   include 'openstack_zeromq':
#
#

class openstack_zeromq(
  $package_ensure         = 'present',
  $debug                  = false,
  $bind_address           = '*',
  $contexts               = 1,
  $ipc_dir                = '/var/run/openstack',
  $matchmaker             = 'oslo.messaging._drivers.matchmaker_ring.MatchMakerRing',
  $port                   = 9501,
  $topic_backlog          = undef,
  $cinder_nodes           = [],
  $cinder_scheduler_nodes = [],
  $cinder_volume_nodes    = [],
  $nova_nodes             = [],
  $nova_scheduler_nodes   = [],
  $nova_consoleauth_nodes = [],
  $nova_conductor_nodes   = [],
  $nova_cert_nodes        = [],
) {

  ##
  #  Validate the parameters
  ##

  validate_absolute_path($ipc_dir)
  validate_bool($debug)
  validate_re($contexts,'\d+')
  validate_re($package_ensure,['^present$','^absent$'])
  validate_re($port,'\d+')
  validate_string($bind_address)
  validate_string($matchmaker)
  validate_array($cinder_nodes)
  validate_array($nova_nodes)
  validate_array($cinder_scheduler_nodes)
  validate_array($cinder_volume_nodes)
  validate_array($nova_scheduler_nodes)
  validate_array($nova_consoleauth_nodes)
  validate_array($nova_conductor_nodes)
  validate_array($nova_cert_nodes)

  ##
  # Anchors
  ##

  anchor { 'openstack_zeromq::start': }
  anchor { 'openstack_zeromq::end': }

  ##
  # Define ordering
  ##
  Anchor['openstack_zeromq::start'] ->
  Class['openstack_zeromq::install'] ->
  Class['openstack_zeromq::config'] ->
  Class['openstack_zeromq::service'] ->
  Anchor['openstack_zeromq::end']

  ##
  # Matchmakerring_config to be run after openstack_zeromq::config
  ##

  Class['openstack_zeromq::config'] -> Matchmakerring_config<||>

  ##
  # Install packages
  ##

  class { 'openstack_zeromq::install':
    package_ensure  => $package_ensure,
  }

  ##
  # Configure zeromq receiver
  ##

  class { 'openstack_zeromq::config':
    debug         => $debug,
    bind_address  => $bind_address,
    contexts      => $contexts,
    ipc_dir       => $ipc_dir,
    matchmaker    => $matchmaker,
    port          => $port,
  }

  ##
  # Set defaults for matchmaker node definition.
  ##
  if ! empty($cinder_nodes) {
    if empty($cinder_scheduler_nodes) {
      $cinder_scheduler_nodes_orig = $cinder_nodes
    } else {
      $cinder_scheduler_nodes_orig = $cinder_scheduler_nodes
    }
    if empty($cinder_volume_nodes) {
      $cinder_volume_nodes_orig = $cinder_nodes
    } else {
      $cinder_volume_nodes_orig = $cinder_volume_nodes
    }
  } else {
    $cinder_scheduler_nodes_orig  = $cinder_scheduler_nodes
    $cinder_volume_nodes_orig     = $cinder_volume_nodes
  }

  if ! empty($nova_nodes) {
    if empty($nova_scheduler_nodes) {
      $nova_scheduler_nodes_orig  = $nova_nodes
    } else {
      $nova_scheduler_nodes_orig  = $nova_scheduler_nodes
    }

    if empty($nova_consoleauth_nodes) {
      $nova_consoleauth_nodes_orig = $nova_nodes
    } else {
      $nova_consoleauth_nodes_orig = $nova_consoleauth_nodes
    }

    if empty($nova_conductor_nodes) {
      $nova_conductor_nodes_orig = $nova_nodes
    } else {
      $nova_conductor_nodes_orig = $nova_conductor_nodes
    }

    if empty($nova_cert_nodes) {
      $nova_cert_nodes_orig = $nova_nodes
    } else {
      $nova_cert_nodes_orig = $nova_cert_nodes
    }
  } else {
    $nova_scheduler_nodes_orig  = $nova_scheduler_nodes
    $nova_consoleauth_nodes_orig= $nova_consoleauth_nodes
    $nova_conductor_nodes_orig  = $nova_conductor_nodes
    $nova_cert_nodes_orig       = $nova_cert_nodes
  }

  ##
  # Add matchmaker entries
  ##
  if ! empty($cinder_scheduler_nodes_orig) {
    matchmakerring_config { 'cinder-scheduler':
      value => $cinder_scheduler_nodes_orig
    }
  }

  if ! empty($cinder_volume_nodes_orig) {
    matchmakerring_config { 'cinder-volume': value => $cinder_volume_nodes_orig }
  }

  if ! empty($nova_scheduler_nodes_orig) {
    matchmakerring_config { 'scheduler': value => $nova_scheduler_nodes_orig  }
  }

  if ! empty($nova_conductor_nodes_orig) {
    matchmakerring_config { 'conductor': value => $nova_conductor_nodes_orig  }
  }

  if ! empty($nova_consoleauth_nodes_orig) {
    matchmakerring_config { 'consoleauth': value => $nova_consoleauth_nodes_orig  }
  }

  if ! empty($nova_cert_nodes_orig) {
    matchmakerring_config { 'cert': value => $nova_cert_nodes_orig }
  }

  ##
  # Service management
  ##

  include openstack_zeromq::service
}
