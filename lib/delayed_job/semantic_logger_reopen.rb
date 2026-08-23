# frozen_string_literal: true

require 'delayed_job'
require 'semantic_logger'

# Reopens SemanticLogger in the daemonized worker.
#
# Threads do not survive a fork: the worker inherits the SemanticLogger processor
# with a dead thread, so everything it logs stays in the queue forever and is never
# written to any appender. Puma does the same in the before_worker_boot hook.
module Delayed::SemanticLoggerReopen
  def after_fork
    super
    SemanticLogger.reopen
  end
end

Delayed::Worker.singleton_class.prepend Delayed::SemanticLoggerReopen
