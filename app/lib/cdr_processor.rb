# frozen_string_literal: true

module CdrProcessor
  ActiveRecord::Base.extend(CdrProcessor::Api)
end
