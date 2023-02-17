# frozen_string_literal: true

module RateManagement
  class PricelistItemsParser < ApplicationService
    parameter :file, required: true
    parameter :project, required: true

    Error = Class.new(StandardError)
    ALLOWED_HEADERS = %i[
      prefix
      initial_rate
      next_rate
      connect_fee
      dst_number_min_length
      dst_number_max_length
      initial_interval
      next_interval
      routing_tag_names
      routing_tag_mode
      enabled
      priority
      valid_from
    ].freeze
    MANDATORY_HEADERS = %i[
      prefix
      initial_rate
      next_rate
      connect_fee
    ].freeze

    def self.humanized_headers
      ALLOWED_HEADERS.map(&:to_s).map(&:humanize)
    end

    def call
      file_data = file.open.read
      table = CSV.parse(
        file_data,
        headers: true,
        header_converters: ->(header) { header.to_s.parameterize.underscore.to_sym },
        nil_value: nil
      )
      validate_headers!(table.headers)
      table.map(&:to_hash)
    rescue CSV::MalformedCSVError => e
      raise Error, e.message
    ensure
      file.close
    end

    private

    def validate_headers!(headers)
      raise Error, 'Headers required' unless headers.all?

      extra_headers = (headers - ALLOWED_HEADERS).map { |header| header.to_s.humanize }
      raise Error, "Unknown headers: #{extra_headers.join(', ')}. Valid headers are: #{self.class.humanized_headers.join(', ')}" if extra_headers.present?

      missing_headers = (mandatory_headers - headers).map { |header| header.to_s.humanize }
      raise Error, "Missing mandatory headers: #{missing_headers.join(', ')}." if missing_headers.present?
    end

    def mandatory_headers
      mandatory_headers = MANDATORY_HEADERS.dup
      mandatory_headers << :initial_interval if project.initial_interval.nil?
      mandatory_headers << :next_interval if project.next_interval.nil?
      mandatory_headers << :routing_tag_mode if project.routing_tag_mode_id.nil?
      mandatory_headers
    end
  end
end
