class Api::Rest::Customer::V1::BaseResource < ::BaseResource
  abstract
  immutable

  # https://github.com/cerebris/jsonapi-resources/issues/460#issuecomment-257581275
  def self.ransack_filter(name, opts = {})
    opts[:apply] = ->(records, value, _options) do
      records.ransack({ name => value[0] }).result
    end
    filter name, opts
  end
end
