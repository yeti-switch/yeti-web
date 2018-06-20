class Api::Rest::Admin::Cdr::AuthLogResource < ::BaseResource
  immutable
  model_name 'Cdr::AuthLog'
  paginator :paged

  module CONST
    ROOT_NAMESPACE_RELATIONS = %w(
      Gateway Pop Node
    ).freeze

    freeze
  end

  def self.default_sort
    [{field: 'request_time', direction: :desc}]
  end

  attributes :request_time,
             :success,
             :code,
             :reason,
             :internal_reason,
             :origination_ip, :origination_port,
             :transport_remote_ip, :transport_remote_port,
             :transport_local_ip, :transport_local_port,
             :pop_id,
             :node_id,
             :gateway_id,
             :username, :realm,
             :method, :ruri,
             :from_uri, :to_uri,
             :call_id,
             :nonce, :responce,
             :x_yeti_auth,
             :diversion, :pai, :ppi, :privacy, :rpid, :rpid_privacy

  has_one :gateway
  has_one :pop
  has_one :node


  filter :request_time_gteq, apply: ->(records, values, _options) do
    records.where('request_time >= ?', values[0])
  end
  filter :request_time_lteq, apply: ->(records, values, _options) do
    records.where('request_time <= ?', values[0])
  end

  # add supporting associations from non cdr namespaces
  def self.resource_for(type)
    if type.in?(CONST::ROOT_NAMESPACE_RELATIONS)
      "Api::Rest::Admin::#{type}Resource".safe_constantize
    else
      super
    end
  end
end
