# frozen_string_literal: true

module WithLogger
  extend ActiveSupport::Concern

  included do
    class_attribute :logger, instance_writer: false, default: Rails.logger
  end
end
