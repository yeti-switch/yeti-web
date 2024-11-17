# frozen_string_literal: true

require 'rspec_api_documentation/dsl'

RSpec.resource 'Cdrs' do
  include_context :acceptance_admin_user
  let(:type) { 'cdrs' }

  get '/api/rest/admin/cdrs' do
    jsonapi_filters Api::Rest::Admin::CdrResource._allowed_filters

    before do
      create_list(:cdr, 2)
    end

    example_request 'get listing' do
      expect(status).to eq(200)
    end
  end

  get '/api/rest/admin/cdrs/:id' do
    let(:id) { create(:cdr).id }

    example_request 'get specific entry' do
      expect(status).to eq(200)
    end
  end

  get '/api/rest/admin/cdrs/:id/recording' do
    let(:id) { create(:cdr, audio_recorded: true).id }

    example_request 'get recording' do
      expect(status).to eq(200)
    end
  end

  patch '/api/rest/admin/cdrs/:id' do
    with_options scope: :data, with_example: true do
      parameter :type, 'Resource type (cdrs)', required: true
      parameter :id, 'CDR ID', required: true
      parameter :attributes, 'list of fields/values to update', required: true
    end

    jsonapi_attribute :metadata

    context '200' do
      let(:id) { create(:cdr).id }

      example 'Update an CDR' do
        request = {
          data: {
            id: id,
            type: 'cdrs',
            attributes: {
              metadata: { some_json: 'some value' }
            }
          }
        }

        do_request(request)

        expect(status).to eq(200)
        expect(JSON.parse(response_body).dig('data', 'attributes', 'metadata')).to eq 'some_json' => 'some value'
      end
    end
  end
end
