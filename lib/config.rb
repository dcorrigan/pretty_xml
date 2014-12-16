require 'yaml'

module PrettyXML
  def self.root
    File.expand_path '../..', __FILE__
  end

  def self.etc
    File.join(root, 'etc')
  end

  def self.load_config(config)
    YAML.load(File.read(File.join(PrettyXML.etc, config)))
  end
end
