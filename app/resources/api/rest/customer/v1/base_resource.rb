# frozen_string_literal: true

class Api::Rest::Customer::V1::BaseResource < ::BaseResource
  abstract
  immutable

  # https://github.com/cerebris/jsonapi-resources/issues/460#issuecomment-257581275
  def self.ransack_filter(name, opts = {})
    opts[:apply] = lambda { |records, value, _options|
      records.ransack(name => value[0]).result
    }
    filter name, opts
  end
end
