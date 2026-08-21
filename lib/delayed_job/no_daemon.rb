# frozen_string_literal: true

require 'delayed/command'

# Runs the worker in the foreground instead of daemonizing it, so that its logs go
# to stdout. The daemons gem reopens stdout to /dev/null on the daemonized path,
# which would silently discard every log record of the worker.
#
# Enabled by the DELAYED_JOB_NO_DAEMON env variable, see config/initializers/delayed_job.rb.
# One process runs one worker, identified by `-i`: `-n` is ignored here. In production
# the systemd template unit(yeti-delayed-job@.service) starts one instance per worker.
#
# @usage
#   $ RAILS_LOG_TO_STDOUT=true DELAYED_JOB_NO_DAEMON=true NO_FILE_WATCHER=true bundle exec bin/delayed_job start
module Delayed::NoDaemon
  def daemonize
    # `run` calls Delayed::Worker.after_fork, that iterates the list this fills in.
    Delayed::Worker.before_fork
    Delayed::Worker.logger = Rails.logger
    run("delayed_job.#{@options[:identifier]}", @options)
  end
end

Delayed::Command.prepend Delayed::NoDaemon
