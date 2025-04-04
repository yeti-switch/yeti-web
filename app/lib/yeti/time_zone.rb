# frozen_string_literal: true

module Yeti
  class TimeZone
    def initialize(name)
      @name = name.downcase
    end

    attr_reader :name
  end
end
