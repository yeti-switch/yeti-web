# frozen_string_literal: true

module Helpers
  module ResponseData
    def response_data
      JSON.parse(response.body)['data']
    end

    def response_body
      # TODO: replace with: response_body[:data]
      JSON.parse(response.body).deep_symbolize_keys
    end
  end
end

RSpec.configure do |config|
  config.include Helpers::ResponseData
end
