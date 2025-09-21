# frozen_string_literal: true

require 'active_record'
require 'http_logger'
require 'pgq'
require 'active_resource'
require 'active_support/core_ext/string'
require 'active_resource/persistent'
require 'syslog-logger'
require_relative 'pgq_config'
require_relative 'lib/json_coder'
require_relative 'lib/json_each_row_coder'
require_relative 'lib/shutdown'
require_relative 'lib/amqp_factory'
require_relative 'lib/event_filter'

ENV['ROOT_PATH'] ||= Dir.getwd

raise 'processor is mandatory option!' if ENV['processor'].blank?

raise 'config_file is mandatory option!' if ENV['config_file'].blank?

unless File.exist?(ENV['config_file'])
  raise "Configuration file #{ENV['config_file']} does not exist."
end

class PgqEnv
  attr_reader :config, :logger

  def initialize
    # set proc title
    Process.setproctitle(ENV['processor'])

    @config = ::PgqConfig.new(ENV['config_file'], ENV['processor'])
    ActiveRecord::Base.establish_connection(@config['source_database'])
    @logger = build_logger
    ActiveRecord::Base.logger = @logger
    HttpLogger.logger = @logger
    Pgq::Worker.logger = @logger

    # set up pony options
    Pony.options = {
      to: @config['mail_to'],
      from: @config['mail_from'],
      subject: @config['mail_subject']
    }
  end

  private

  def build_logger
    if ENV['LOG_TO_STDOUT'].present?
      stdout_logger
    else
      syslog_logger
    end
  end

  def stdout_logger
    STDOUT.sync = true
    logger = Logger.new(STDOUT)
    logger.level = Logger::INFO
    logger
  end

  def syslog_logger
    logger = Logger::Syslog.new(@config['syslog_program_name'], Syslog::LOG_LOCAL7)
    logger.level = Logger::INFO
    logger
  end
end
