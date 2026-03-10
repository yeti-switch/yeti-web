# frozen_string_literal: true

require 'json'

module CdrProcessor
  module JsonCoder
    class << self
      def dump(obj)
        JSON.dump obj
      end
      alias encode dump

      def load(str)
        JSON.parse str
      end
      alias decode load
    end
  end
end
