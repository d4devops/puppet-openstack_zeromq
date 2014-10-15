#
# Class: openstack_zeromq::service
#   To install and manage zmq receiver service.
#

class openstack_zeromq::service {

  require openstack_zeromq::config

  ##
  # Oslo package dont have an init script, so adding an upstart script.
  ##

  file {'/etc/init/oslo-messaging-zmq-receiver.conf':
    ensure  => file,
    source  => "puppet:///modules/${module_name}/oslo-messaging-zmq-receiver.conf",
  }

  file {'/etc/init.d/oslo-messaging-zmq-receiver':
    ensure  => link,
    target  => '/lib/init/upstart-job',
  }

  ##
  # Start service
  ##
  service { 'oslo-messaging-zmq-receiver':
    ensure     => 'running',
    enable     => true,
    require    => [
      Package['python-oslo.messaging'],
      File['/etc/init/oslo-messaging-zmq-receiver.conf'],
      File['/etc/init.d/oslo-messaging-zmq-receiver']
    ]
  }
}
