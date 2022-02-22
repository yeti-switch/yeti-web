# frozen_string_literal: true

require 'delayed/command'

# @usage
#   $ RAILS_LOG_TO_STDOUT=true DELAYED_JOB_NO_DAEMON=true NO_FILE_WATCHER=true bundle exec bin/delayed_job start
module Delayed::DevNoDaemon
  def daemonize
    if ENV['DELAYED_JOB_NO_DAEMON'].present?
      # run_process("delayed_job.#{@options[:identifier]}", @options)
      Delayed::Worker.before_fork
      Delayed::Worker.logger = Rails.logger
      run("delayed_job.#{@options[:identifier]}", @options)
    else
      super
    end
  end
end

Delayed::Command.prepend Delayed::DevNoDaemon
