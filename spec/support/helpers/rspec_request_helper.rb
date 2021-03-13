# frozen_string_literal: true

module RspecRequestHelper
  def response_json
    data = JSON.parse(response.body)
    data.is_a?(Array) ? data.map(&:deep_symbolize_keys) : data.deep_symbolize_keys
  rescue StandardError => e
    Rails.logger.error { "response_json parsing failed with #{e.class}: #{e.message}" }
    nil
  end

  def pretty_response_json
    JSON.pretty_generate(response_json)
  end

  # Finds data item in jsonapi response data collection.
  # @param id [String,Integer] resource ID.
  # @param type [String,Symbol] resource type.
  # @return [Hash,nil] data object if found.
  def response_jsonapi_data_item(id, type)
    find_jsonapi_collection_item(response_json[:data], id, type)
  end

  # Finds data item in jsonapi response included collection.
  # @param id [String,Integer] resource ID.
  # @param type [String,Symbol] resource type.
  # @return [Hash,nil] data object if found.
  def response_jsonapi_included_item(id, type)
    find_jsonapi_collection_item(response_json[:included], id, type)
  end

  # Finds data item in jsonapi response array of data collections.
  # @param id [String,Integer] resource ID.
  # @param type [String,Symbol] resource type.
  # @return [Hash,nil] data object if found.
  def find_jsonapi_collection_item(data, id, type)
    return unless data.is_a?(Array)

    data.detect { |r| r[:id] == id.to_s && r[:type] == type.to_s }
  end

  # Returns jsonapi request relationship object for has one or has many.
  # @param id [String,Integer,Array<String,Integer>] resource ID or array of IDs.
  # @param type [String,Symbol] resource type.
  # @return [Hash] relationship object.
  # @example
  #   jsonapi_relationship(123, :nodes) # => { data: { id: '123', type: 'nodes' } }
  #   jsonapi_relationship([123, 124], :nodes) # => { data: [{ id: '123', type: 'nodes' }, { id: '124', type: 'nodes' }] }
  #   let(:request_body) do
  #     {
  #       data: {
  #         id: '456',
  #         type: 'registrations',
  #         relationships: {
  #           node: jsonapi_relationship(123, :nodes)
  #         }
  #       }
  #     }
  #   end
  def jsonapi_relationship(id, type)
    if id.is_a?(Array)
      { data: id.map { |id_item| { id: id_item.to_s, type: type.to_s } } }
    else
      { data: { id: id.to_s, type: type.to_s } }
    end
  end
end
