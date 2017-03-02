require 'active_record'
require 'http_logger'
require 'pgq'
require 'active_resource'
require 'active_support/core_ext/string'
require 'active_resource/persistent'
require 'syslog-logger'
require_relative 'lib/json_coder'
require_relative 'lib/shutdown'
require_relative 'models/routing_base.rb'

class PgqEnv

  attr_reader :config, :logger

  def initialize(config)
    # read configuration from configuration file
    @config = config
    rack_env = ENV['RACK_ENV'] || 'development'
    ActiveRecord::Base.establish_connection @config["#{rack_env}_cdr"]
    ::RoutingBase.establish_connection  @config["#{rack_env}"]
    ENV['ROOT_PATH'] = Dir.getwd
    @logger = Logger::Syslog.new(@config['syslog_program_name'], Syslog::LOG_LOCAL7)
    HttpLogger.logger = @logger
    Pgq::Worker.logger = @logger

# set up pony options
    Pony.options = {
        to: @config['mail_to'],
        from: @config['mail_from'],
        subject: @config['mail_subject']
    }


  end

end



