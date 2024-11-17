# frozen_string_literal: true

require 'rspec_api_documentation/dsl'

RSpec.resource 'Invoices' do
  include_context :acceptance_admin_user
  let(:type) { 'invoices' }

  get '/api/rest/admin/invoices' do
    jsonapi_filters Api::Rest::Admin::InvoiceResource._allowed_filters

    before do
      create_list(:invoice, 2, :approved, :auto_full, :with_vendor_account)
    end

    example_request 'get listing' do
      expect(status).to eq(200)
    end
  end

  get '/api/rest/admin/invoices/:id' do
    let(:id) { create(:invoice, :approved, :auto_full, :with_vendor_account).id }

    example_request 'get specific entry' do
      expect(status).to eq(200)
    end
  end

  post '/api/rest/admin/invoices' do
    parameter :type, 'Resource type (invoices)', scope: :data, required: true

    jsonapi_attributes(%i[start-date end-date], [])
    jsonapi_relationships([:account], [])

    let(:'start-date') { 1.month.ago.strftime('%F') }
    let(:'end-date') { Time.current.strftime('%F') }
    let(:account) { wrap_relationship('accounts', account_record.id.to_s) }
    let!(:account_record) { create(:account) }

    example_request 'create new entry' do
      expect(status).to eq(201)
    end
  end

  delete '/api/rest/admin/invoices/:id' do
    let(:id) { create(:invoice, :approved, :auto_full, :with_vendor_account).id }

    example_request 'delete entry' do
      expect(status).to eq(204)
    end
  end
end
