# frozen_string_literal: true

require 'json'

module SemanticLogger
  class VictoriaLogsFormatter < ::SemanticLogger::Formatters::Raw
    def message
      hash[:_msg] = log.cleansed_message if log.message
    end
  end
end
