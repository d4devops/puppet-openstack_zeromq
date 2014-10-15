require 'spec_helper'
describe 'openstack_zeromq::config' do
  let :facts do
    {
      :hostname => 'node1',
    }
  end
  context 'with defaults parameters' do
    it do
      should contain_file('/etc/oslo').with_ensure('directory')
      should contain_file('/etc/oslo/zmq_receiver.conf').with_content(<<-CTRL.gsub(/^ {8}/, '')
        [DEFAULT]
        debug= False
        rpc_zmq_bind_address = *
        rpc_zmq_contexts = 1
        rpc_zmq_host = node1
        rpc_zmq_ipc_dir = /var/run/openstack
        rpc_zmq_matchmaker = oslo.messaging._drivers.matchmaker_ring.MatchMakerRing
        rpc_zmq_port = 9501
        ringfile = /etc/oslo/matchmaker_ring.json
      CTRL
      )
      should contain_group('openstack').with({
        'ensure'  => 'present',
        'system'  => true,
        'before'  => [ 'Exec[add_cinder_to_openstack]',
                  'Exec[add_nova_to_openstack]'],
      })
      should contain_exec('add_cinder_to_openstack').with({
        'command' => 'usermod -aG openstack cinder',
        'onlyif'  => 'id cinder',
        'unless'  => 'id cinder | grep "(openstack)"',
        'path'    => '/bin:/usr/bin:/usr/sbin:/sbin'
      })
      should contain_exec('add_nova_to_openstack').with({
        'command' => 'usermod -aG openstack nova',
        'onlyif'  => 'id nova',
        'unless'  => 'id nova | grep "(openstack)"',
        'path'    => '/bin:/usr/bin:/usr/sbin:/sbin'
      })
   end
  end
end
