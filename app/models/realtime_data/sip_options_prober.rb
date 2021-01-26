# frozen_string_literal: true

class RealtimeData::SipOptionsProber < YetiResource
  include ActiveModel::Validations
  include WithQueryBuilder

  class << self
    def query_builder_find(id, includes:, **_)
      node_id, local_tag = id.split('*')
      record = Node.find(node_id).active_call(local_tag)
      RealtimeData::ActiveCall.load_associations([record], *includes)
      record
    end

    def query_builder_collection(includes:, filters:, **_)
      result = NodeRpcClient.perform_parallel(default: []) do |client, node|
        result = client.sip_options_probers
        result.map { |row| row.merge(node: node) }
      end
      records = result.map { |item| RealtimeData::SipOptionsProber.new(item) }
      records
    end
  end

  attribute :append_headers, :string
  attribute :contact, :string
  attribute :from, :string
  attribute :id, :integer
  attribute :interval, :integer
  attribute :last_reply_code, :integer
  attribute :last_reply_contact, :string
  attribute :last_reply_delay_ms, :integer
  attribute :last_reply_reason, :string
  attribute :local_tag, :string
  attribute :name, :string
  attribute :proxy, :string
  attribute :ruri, :string
  attribute :sip_interface_name, :string
  attribute :to, :string

  has_one :transport_protocol, class_name: 'Equipment::TransportProtocol', foreign_key: :transport_protocol_id
  has_one :proxy_transport_protocol, class_name: 'Equipment::TransportProtocol', foreign_key: :proxy_transport_protocol_id
  has_one :node, class_name: 'Node', foreign_key: :node_id
  has_one :pop, class_name: 'Pop', foreign_key: :pop_id
  has_one :sip_schema, class_name: 'System::SipSchema', foreign_key: :sip_schema_id
end
