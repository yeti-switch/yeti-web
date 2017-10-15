require 'securerandom'

module JsonapiModel
  class Base
    include ActiveModel::Model
    attr_reader :id

    class << self
      def inherited(_subclass)
      end

      def call(args = {})
        new(args).call
      end
    end

    def initialize(**_args)
      @id = SecureRandom.uuid
    end

    def call
      fail NotImplementedError.new('call needs to be implemented in subclasses and return self')
    end

    def self.all
      new
    end

    def order(*_args)
      [self]
    end

    def count(*_args)
      1
    end
  end
end
