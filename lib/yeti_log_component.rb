# frozen_string_literal: true

# Identifies the process that emitted a log record, so that the logs of all
# yeti-web components (puma, delayed_job, scheduler, ...) collected into a single
# storage can be told apart.
#
# Entry points assign the name before booting Rails, so that even the logs written
# during the boot have it, see config.ru, bin/delayed_job, bin/scheduler.
# Detection is a fallback for the processes that are not started by them.
#
# This file is loaded before Bundler.require, so it must not depend on gems.
module YetiLogComponent
  class << self
    # @return [String]
    def name
      @name ||= normalize(detect)
    end

    # @param name [String] assigned by an entry point before Rails is booted.
    def name=(name)
      @name = normalize(name)
    end

    # Resets the name, for specs.
    def reset!
      @name = nil
    end

    private

    # A frozen copy, so that the component of the process cannot be changed by
    # mutating the string that was assigned.
    #
    # @return [String]
    def normalize(name)
      -name.to_s
    end

    # @return [String]
    def detect
      return 'console' if defined?(::Rails::Console)
      # `defined?(::Rake)` alone is unreliable, Rake is loaded into any process by
      # Bundler.require. top_level_tasks are only filled when it executes tasks.
      return 'rake' if defined?(::Rake) && ::Rake.application.top_level_tasks.any?
      return 'rspec' if defined?(::RSpec)

      File.basename($PROGRAM_NAME)
    end
  end
end
