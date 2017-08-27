class PgqConfig

  attr_accessor :section, :config_file

  def initialize(config_file, section)
    self.config_file = config_file
    self.section = section

    # validate configuration
    if config.blank?
      raise "Invalid configuration file #{config_file} or section #{section} is not exists."
    end

  end

  def config
    @config ||= YAML.load(File.read(config_file))[section]
    if @config.blank?
      raise "Invalid configuration file #{config_file} or section #{section} is not exists."
    end

    dbkey = @config['mode'] || 'development'
    @dbconfig = YAML.load(File.read("../config/database.yml"))
    if @dbconfig.blank?
      raise "Invalid db configuration file"
    end

    @config['source_database'] = @dbconfig["secondbase"]["#{dbkey}"]
    @config['databases'] = @dbconfig
    @config
  end

  def [](k)
    config[k]
  end

end
