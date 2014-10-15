require 'json'
Puppet::Type.type(:matchmakerring_config).provide(:json) do

  def conf
    begin
      @conf ||= JSON.parse(File.read(config_file))
    rescue
      @conf ||= {}
    end
  end

  def config_file
    resource[:ringfile]
  end

  def create
    conf[resource[:name]] = resource[:value]
    if resource[:name]  =~ /cinder-volume/
      resource[:value].each { |node| conf[resource[:name] + ':' + node] = [ node ] }
    end
  end

  def destroy
    conf.delete(resource[:name])
  end

  def flush
    File.open(config_file, 'w') do |f|
      f.puts JSON.pretty_generate(conf)
    end
  end

  ##
  # Cinder volume need extra json entries for individual cinder volume node. e.g
  # if cinder1 and cinder2 are hosting cinder-volume, it need following json entries
  #  "cinder-volume": [
  #    "cinder1",
  #    "cinder2"
  #  ],
  # "cinder-volume:cinder1": [
  #  	"cinder1"
  #  ],
  # "cinder-volume:cinder2": [
  #  	"cinder2"
  #   ],
  #
  ##

  def value
    res = conf[resource[:name]]
    if resource[:name]  =~ /cinder-volume/
      res1 = resource[:value].map { |node| nd = conf[resource[:name] + ':' + node]; nd.nil? ? nil : nd.join }
      return res & res1
    end
    return res
  end

  def value=(value)
    conf[resource[:name]] = resource[:value]
    if resource[:name]  =~ /cinder-volume/
      resource[:value].each { |node| conf[resource[:name] + ':' + node] = [ node ] }
    end
  end

  def exists?
    begin
      conf.has_key?(resource[:name]) ? true : false
    end
  end
end
