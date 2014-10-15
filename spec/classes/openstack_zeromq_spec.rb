require 'spec_helper'
describe 'openstack_zeromq' do

  context 'with defaults parameters' do
    it do
      should contain_class('openstack_zeromq::install')
      should contain_class('openstack_zeromq::config').with({
        'debug'         => false,
        'bind_address'  => '*',
        'contexts'      => 1,
        'ipc_dir'       => '/var/run/openstack',
        'matchmaker'    => 'oslo.messaging._drivers.matchmaker_ring.MatchMakerRing',
        'port'          => 9501,
      })
      should contain_class('openstack_zeromq::service')
      should_not contain_matchmakerring_config()
    end
  end
  context 'with inappropriate parameter types' do
    context 'with wrong path for ipc_dir' do
      let :params do
        {
          :ipc_dir => 'tmp',
        }
      end
      it 'should require absolute path' do
        expect { should compile }.to raise_error(Puppet::Error, /"tmp" is not an absolute path./)
      end
    end
    context 'with wrong parameter for debug' do
      let :params do
        {
          :debug => 'hi',
        }
      end
      it 'should require' do
        expect { should compile }.to raise_error(Puppet::Error, /"hi" is not a boolean/)
      end
    end
    context 'with wrong parameter for contexts' do
      let :params do
        {
          :contexts => 'test',
        }
      end
      it 'should require' do
        expect { should compile }.to raise_error(Puppet::Error, /"test" does not match/)
      end
    end
    context 'with wrong parameter for package_ensure' do
      let :params do
        {
          :package_ensure => 'anything',
        }
      end
      it 'should require' do
        expect { should compile }.to raise_error(Puppet::Error, /"anything" does not match/)
      end
    end
    context 'with wrong parameter for port' do
      let :params do
        {
          :port => 'hey',
        }
      end
      it 'should require' do
        expect { should compile }.to raise_error(Puppet::Error, /"hey" does not match/)
      end
    end
    context 'with wrong parameter for cinder_nodes' do
      let :params do
        {
          :cinder_nodes => 'string',
        }
      end
      it 'should require' do
        expect { should compile }.to raise_error(Puppet::Error, /"string" is not an Array/)
      end
    end
    context 'with wrong parameter for nova_nodes' do
      let :params do
        {
          :nova_nodes => 'string',
        }
      end
      it 'should require' do
        expect { should compile }.to raise_error(Puppet::Error, /"string" is not an Array/)
      end
    end
    context 'with wrong parameter for cinder_scheduler_nodes' do
      let :params do
        {
          :cinder_scheduler_nodes => 'string',
        }
      end
      it 'should require' do
        expect { should compile }.to raise_error(Puppet::Error, /"string" is not an Array/)
      end
    end
    context 'with wrong parameter for cinder_volume_nodes' do
      let :params do
        {
          :cinder_volume_nodes => 'string',
        }
      end
      it 'should require' do
        expect { should compile }.to raise_error(Puppet::Error, /"string" is not an Array/)
      end
    end
    context 'with wrong parameter for nova_scheduler_nodes' do
      let :params do
        {
          :nova_scheduler_nodes => 'string',
        }
      end
      it 'should require' do
        expect { should compile }.to raise_error(Puppet::Error, /"string" is not an Array/)
      end
    end
    context 'with wrong parameter for nova_consoleauth_nodes' do
      let :params do
        {
          :nova_consoleauth_nodes => 'string',
        }
      end
      it 'should require' do
        expect { should compile }.to raise_error(Puppet::Error, /"string" is not an Array/)
      end
    end
    context 'with wrong parameter for nova_conductor_nodes' do
      let :params do
        {
          :nova_conductor_nodes => 'string',
        }
      end
      it 'should require' do
        expect { should compile }.to raise_error(Puppet::Error, /"string" is not an Array/)
      end
    end
    context 'with wrong parameter for nova_cert_nodes' do
      let :params do
        {
          :nova_cert_nodes => 'string',
        }
      end
      it 'should require' do
        expect { should compile }.to raise_error(Puppet::Error, /"string" is not an Array/)
      end
    end
  end
  context 'with nodes parameters' do
    let :params do
      {
        :cinder_scheduler_nodes => ['cinder_scheduler1','cinder_scheduler2','cinder_scheduler3'],
        :cinder_volume_nodes    => ['cinder_volume1','cinder_volume2','cinder_volume3'],
        :nova_scheduler_nodes   => ['scheduler1','scheduler2','scheduler3'],
        :nova_consoleauth_nodes => ['consoleauth1','consoleauth2','consoleauth3'],
        :nova_conductor_nodes   => ['conductor1','conductor2','conductor3'],
        :nova_cert_nodes        => ['cert1','cert2','cert3'],
      }
    end
    it do
      should contain_matchmakerring_config('cinder-scheduler').with({
        'value' => ['cinder_scheduler1','cinder_scheduler2','cinder_scheduler3']
      })
      should contain_matchmakerring_config('cinder-volume').with({
        'value' => ['cinder_volume1','cinder_volume2','cinder_volume3'],
      })
      should contain_matchmakerring_config('scheduler').with({
        'value' => ['scheduler1','scheduler2','scheduler3'],
      })
      should contain_matchmakerring_config('consoleauth').with({
        'value' => ['consoleauth1','consoleauth2','consoleauth3'],
      })
      should contain_matchmakerring_config('conductor').with({
        'value' => ['conductor1','conductor2','conductor3']
      })
      should contain_matchmakerring_config('cert').with({
        'value' => ['cert1','cert2','cert3'],
      })
    end
  end
end
