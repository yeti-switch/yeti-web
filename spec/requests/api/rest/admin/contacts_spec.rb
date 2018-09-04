require 'spec_helper'

RSpec.describe Api::Rest::Admin::ContactsController, type: :request do
  include_context :json_api_admin_helpers, type: :'contacts'

  describe 'GET /api/rest/admin/contacts' do
    subject do
      puts json_api_request_path
      get json_api_request_path, params: nil, headers: json_api_request_headers
    end

    let!(:contacts) do
      FactoryGirl.create_list(:contact, 2) # only Contact with contractor
    end

    include_examples :returns_json_api_collection do
      let(:json_api_collection_ids) do
        contacts.map { |r| r.id.to_s }
      end
    end
  end


  describe 'GET /api/rest/admin/contacts/{id}' do
    subject do
      get json_api_request_path, params: request_query, headers: json_api_request_headers
    end

    let(:json_api_request_path) { "#{super()}/#{record_id}" }
    let(:request_query) { nil }
    let(:record_id) { contact.id.to_s }

    let!(:contact) { FactoryGirl.create(:contact, contact_attrs) }
    let(:contractor) { contact.contractor }
    let(:contact_attrs) { { email: 'some@mail.com', notes: 'Text here...' } }
    let(:contact_response_attributes) do
      {
          'email': contact.email,
          'notes': contact.notes
      }
    end

    include_examples :returns_json_api_record, relationships: [:contractor] do
      let(:json_api_record_id) { record_id }
      let(:json_api_record_attributes) { contact_response_attributes }
    end

    context 'with include destination' do
      let(:request_query) { { include: 'contractor' } }

      include_examples :returns_json_api_record_relationship, :contractor do
        let(:json_api_relationship_data) { { id: contractor.id.to_s, type: 'contractors' } }
      end

      include_examples :returns_json_api_record_include, type: :contractors do
        let(:json_api_include_id) { contractor.id.to_s }
        let(:json_api_include_attributes) { hash_including(name: contractor.name) }
      end
    end
  end


  describe 'POST /api/rest/admin/contacts' do
    subject do
      post json_api_request_path, params: json_api_request_body.to_json, headers: json_api_request_headers
    end

    let(:contractor) { FactoryGirl.create(:customer) }

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
        'email': 'some@mail.com',
        'notes': 'Text here...'
      }
    end
    let(:json_api_request_relationships) do
      {
          contractor: { data: { id: contractor.id.to_s, type: 'contractors' } }
      }
    end
    let(:last_contact) { Billing::Contact.last! }

    include_examples :returns_json_api_record, relationships: [:contractor], status: 201 do
      let(:json_api_record_id) { last_contact.id.to_s }
      let(:json_api_record_attributes) do
        {
            'email': json_api_request_attributes[:'email'],
            'notes': json_api_request_attributes[:'notes']
        }
      end
    end

    include_examples :changes_records_qty_of, Billing::Contact, by: 1
  end



  describe 'PATCH /api/rest/admin/contacts/{id}' do
    subject do
      patch json_api_request_path, params: json_api_request_body.to_json, headers: json_api_request_headers
    end

    let(:json_api_request_path) { "#{super()}/#{record_id}" }
    let(:record_id) { contact.id.to_s }
    let(:json_api_request_body) do
      { data: { id: record_id, type: json_api_resource_type, attributes: json_api_request_attributes } }
    end
    let(:json_api_request_attributes) { { 'email': 'another@mail,com' } }

    let!(:contact) { FactoryGirl.create(:contact) }

    include_examples :returns_json_api_record, relationships: [:contractor] do
      let(:json_api_record_id) { contact.id.to_s }
      let(:json_api_record_attributes) do
        hash_including(json_api_request_attributes)
      end
    end
  end


  describe 'DELETE /api/rest/admin/contacts/{id}' do
    subject do
      delete json_api_request_path, headers: json_api_request_headers
    end

    let(:json_api_request_path) { "#{super()}/#{record_id}" }
    let(:request_query) { nil }
    let(:record_id) { contact.id.to_s }

    let!(:contact) { FactoryGirl.create(:contact) }

    include_examples :responds_with_status, 204
    include_examples :changes_records_qty_of, Billing::Contact, by: -1
  end
end
