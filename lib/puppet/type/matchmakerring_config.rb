Puppet::Type.newtype(:matchmakerring_config) do
  @doc = "This type is to make matchmaker ring json entries
it accept following parameters
ringfile: Matchmaker ring file (json file) which keeps all matchmaker entries
name: Name of the service, like cinder-scheduler, nova-consoleauth, cinder-volume etc
value: array of host names which would be running appropriate service.

Note: the hostnames in value must be resolved. Also they must match the hostname (result of hostname -s)
	e.g for machines nova1.example.com,nova2.example.com which run nova-consoleauth, you will run as below.
	matchmakerring_config('nova-consoleauth': value => ['nova1','nova2'])

Note that I just used nova1 and not nova1.example.com - the name specified there must be matched to
the hostname of the machines.
Also nova1 and nova2 must be resolved to thier IP addresses.
"


  ensurable

  newparam(:name, :namevar => true) do
    newvalues(/\S+/)
  end

  newparam(:ringfile) do
    desc 'File path of the ring file'
    newvalues(/[\/\S]+/)
    defaultto '/etc/oslo/matchmaker_ring.json'
    validate do |val|
      unless Pathname.new(val).absolute?
        fail("Invalid ring file path #{val}")
      end
    end
  end

  newproperty(:value, :array_matching => :all) do
    desc 'The value of the setting to be defined.'
    def insync?(is)
      is.sort == should.sort
    end
    newvalues(/^[\S ]*$/)
  end
end
