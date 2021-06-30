# frozen_string_literal: true

module Scheduler
  module Job
    class Base
      class_attribute :cron_line, instance_accessor: false
      class_attribute :logger, instance_writer: false

      class << self
        def inherited(subclass)
          subclass.cron_line = nil
          super
        end

        def scheduler_options
          {
            overlap: false,
            name: name
          }
        end

        # @param options [Scheduler::Base::RunOptions]
        def call(options)
          new(options).call
        end
      end

      delegate :type, to: :class

      # @param options [Scheduler::Base::RunOptions]
      def initialize(options)
        @options = options
      end

      def call
        raise NotImplementedError
      end
    end
  end
end
