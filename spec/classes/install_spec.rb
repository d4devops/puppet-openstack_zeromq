require 'spec_helper'
describe 'openstack_zeromq::install' do
  let :facts do
    {
      :hostname => 'node1',
    }
  end
  context 'with defaults parameters' do
    it do
      should contain_package('python-oslo.messaging')
      should contain_package('python-zmq')
   end
  end
end
