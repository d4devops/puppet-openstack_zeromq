require 'spec_helper'
describe 'openstack_zeromq::service' do
  let :facts do
    {
      :hostname => 'node1',
    }
  end
  context 'with defaults parameters' do
    it do
      should contain_file('/etc/init/oslo-messaging-zmq-receiver.conf')
      should contain_file('/etc/init.d/oslo-messaging-zmq-receiver').with({
        'ensure'  => 'link',
        'target'  => '/lib/init/upstart-job',
      })
      should contain_service('oslo-messaging-zmq-receiver').with({
        'ensure'     => 'running',
        'enable'     => true,
        'require'    => [ 'Package[python-oslo.messaging]',
                        'File[/etc/init/oslo-messaging-zmq-receiver.conf]',
                        'File[/etc/init.d/oslo-messaging-zmq-receiver]'
                      ]
      })
    end
  end
end
