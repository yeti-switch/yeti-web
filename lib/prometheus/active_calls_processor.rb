# frozen_string_literal: true

require_relative './base_processor'

class ActiveCallsProcessor < BaseProcessor
  self.logger = Rails.logger
  self.type = 'yeti_ac'

  def collect(data)
    format_metric(data)
  end
end
