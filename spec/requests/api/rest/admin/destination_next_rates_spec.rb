# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Api::Rest::Admin::DestinationNextRatesController, type: :request do
  include_context :json_api_admin_helpers, type: :'destination-next-rates'
  let!(:rate_plan) { FactoryBot.create(:rateplan) }
  let!(:destination) { FactoryBot.create(:destination, rateplan: rate_plan) }

  describe 'GET /api/rest/admin/destination-next-rates' do
    subject do
      get json_api_request_path, params: nil, headers: json_api_request_headers
    end

    let!(:next_rates) do
      FactoryBot.create_list(:destination_next_rate, 3, destination: destination)
    end

    include_examples :returns_json_api_collection do
      let(:json_api_collection_ids) do
        next_rates.map { |r| r.id.to_s }
      end
    end
  end

  describe 'GET /api/rest/admin/destination-next-rates/{id}' do
    subject do
      get json_api_request_path, params: request_query, headers: json_api_request_headers
    end

    let(:json_api_request_path) { "#{super()}/#{record_id}" }
    let(:request_query) { nil }
    let(:record_id) { next_rate.id.to_s }

    let!(:next_rate) { FactoryBot.create(:destination_next_rate, next_rate_attrs) }
    let(:next_rate_attrs) { { destination: destination } }
    let(:next_rate_response_attributes) do
      {
        'next-rate': next_rate.next_rate.to_s,
        'initial-rate': next_rate.initial_rate.to_s,
        'initial-interval': next_rate.initial_interval,
        'next-interval': next_rate.next_interval,
        'connect-fee': next_rate.connect_fee.to_s,
        'apply-time': eq_time_string(next_rate.apply_time),
        'applied': next_rate.applied,
        'external-id': next_rate.external_id
      }
    end

    include_examples :returns_json_api_record, relationships: [:destination] do
      let(:json_api_record_id) { record_id }
      let(:json_api_record_attributes) { next_rate_response_attributes }
    end

    context 'with include destination' do
      let(:request_query) { { include: 'destination' } }

      include_examples :returns_json_api_record, relationships: [:destination] do
        let(:json_api_record_id) { record_id }
        let(:json_api_record_attributes) { next_rate_response_attributes }
      end

      include_examples :returns_json_api_record_relationship, :destination do
        let(:json_api_relationship_data) { { id: destination.id.to_s, type: 'destinations' } }
      end

      include_examples :returns_json_api_record_include, type: :destinations do
        let(:json_api_include_id) { destination.id.to_s }
        let(:json_api_include_attributes) { hash_including(prefix: destination.prefix) }
      end
    end
  end

  describe 'POST /api/rest/admin/destination-next-rates' do
    subject do
      post json_api_request_path, params: json_api_request_body.to_json, headers: json_api_request_headers
    end

    let(:json_api_request_body) do
      {
        data: {
          type: json_api_resource_type,
          attributes: json_api_request_attributes,
          relationships: json_api_request_relationships
        }
      }
    end
    let(:json_api_request_attributes) do
      {
        'next-rate': '0.01',
        'initial-rate': '0.01',
        'initial-interval': 60,
        'next-interval': 60,
        'connect-fee': '0.01',
        'apply-time': 1.month.from_now.to_s
      }
    end
    let(:json_api_request_relationships) do
      {
        destination: { data: { id: destination.id.to_s, type: 'destinations' } }
      }
    end
    let(:last_next_rate) { Routing::DestinationNextRate.last! }

    include_examples :returns_json_api_record, relationships: [:destination], status: 201 do
      let(:json_api_record_id) { last_next_rate.id.to_s }
      let(:json_api_record_attributes) do
        {
          'next-rate': json_api_request_attributes[:'next-rate'],
          'initial-rate': json_api_request_attributes[:'initial-rate'],
          'initial-interval': json_api_request_attributes[:'initial-interval'],
          'next-interval': json_api_request_attributes[:'next-interval'],
          'connect-fee': json_api_request_attributes[:'connect-fee'],
          'apply-time': eq_time_string(json_api_request_attributes[:'apply-time']),
          'applied': false,
          'external-id': nil
        }
      end
    end

    include_examples :changes_records_qty_of, Routing::DestinationNextRate, by: 1
  end

  describe 'PATCH /api/rest/admin/destination-next-rates/{id}' do
    subject do
      patch json_api_request_path, params: json_api_request_body.to_json, headers: json_api_request_headers
    end

    let(:json_api_request_path) { "#{super()}/#{record_id}" }
    let(:record_id) { next_rate.id.to_s }
    let(:json_api_request_body) do
      { data: { id: record_id, type: json_api_resource_type, attributes: json_api_request_attributes } }
    end
    let(:json_api_request_attributes) { { 'next-rate': '15.22' } }

    let!(:next_rate) { FactoryBot.create(:destination_next_rate, next_rate_attrs) }
    let(:next_rate_attrs) { { destination: destination } }

    include_examples :returns_json_api_record, relationships: [:destination] do
      let(:json_api_record_id) { next_rate.id.to_s }
      let(:json_api_record_attributes) do
        hash_including(json_api_request_attributes)
      end
    end
  end

  describe 'DELETE /api/rest/admin/destination-next-rates/{id}' do
    subject do
      delete json_api_request_path, headers: json_api_request_headers
    end

    let(:json_api_request_path) { "#{super()}/#{record_id}" }
    let(:request_query) { nil }
    let(:record_id) { next_rate.id.to_s }

    let!(:next_rate) { FactoryBot.create(:destination_next_rate, next_rate_attrs) }
    let(:next_rate_attrs) { { destination: destination } }

    include_examples :responds_with_status, 204
    include_examples :changes_records_qty_of, Routing::DestinationNextRate, by: -1
  end
end
