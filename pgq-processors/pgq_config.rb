# frozen_string_literal: true

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
    @config ||= YAML.safe_load(File.read(config_file), [Symbol])[section]
    if @config.blank?
      raise "Invalid configuration file #{config_file} or section #{section} is not exists."
    end

    dbkey = @config['mode'] || 'development'
    @dbconfig = YAML.safe_load(ERB.new(File.read('../config/database.yml')).result, aliases: true)
    raise 'Invalid db configuration file' if @dbconfig.blank?

    @config['source_database'] = @dbconfig['secondbase'][dbkey.to_s]
    @config['databases'] = @dbconfig
    @config
  end

  def [](k)
    config[k]
  end
end
