# frozen_string_literal: true

module Scheduler
  module Middleware
    class Base
      attr_reader :app, :opts

      # @param app [#call] handler class or previous middleware.
      # @param opts [Hash] middleware options.
      def initialize(app, opts = {})
        @app = app
        @opts = opts
      end

      # @param options [Scheduler::Base::RunOptions]
      def call(options)
        @app.call(options)
      end
    end
  end
end
