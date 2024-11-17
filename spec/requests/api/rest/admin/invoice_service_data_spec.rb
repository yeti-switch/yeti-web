# frozen_string_literal: true

RSpec.describe Api::Rest::Admin::InvoiceServiceDataController, type: :request, bullet: [:n] do
  include_context :json_api_admin_helpers, type: :'invoice-service-data'

  describe 'GET /api/rest/admin/invoice-service-data' do
    subject do
      get json_api_request_path, params: json_api_request_query, headers: json_api_request_headers
    end

    let(:json_api_request_query) { nil }

    let!(:customer) { create(:customer) }
    let!(:accounts) { create_list(:account, 2, contractor: customer) }
    let!(:another_customer) { create(:customer) }
    let!(:another_account) { create(:account, contractor: another_customer) }
    let!(:invoices) do
      [
        create(:invoice, account: accounts.first),
        create(:invoice, account: accounts.second)
      ]
    end
    let!(:another_invoice) { create(:invoice, account: another_account) }
    let!(:records) do
      [
        *create_list(:invoice_service_data, 2, :filled, invoice: invoices.first),
        *create_list(:invoice_service_data, 2, :filled, invoice: invoices.second),
        *create_list(:invoice_service_data, 2, :filled, invoice: another_invoice)
      ]
    end

    include_examples :returns_json_api_collection do
      let(:json_api_collection_ids) { records.map { |r| r.id.to_s } }
    end

    it_behaves_like :json_api_admin_check_authorization

    it_behaves_like :json_api_check_pagination do
      let(:records) do
        invoices = create_list(:invoice, records_qty, :manual, :approved, account: accounts.first)
        Array.new(records_qty) do |i|
          create(:invoice_service_data, :filled, invoice: invoices[i])
        end
      end
      let(:records_ids) { records.sort_by(&:id).map { |r| r.id.to_s } }
    end

    context 'with filters' do
      let!(:records) { nil }

      # it_behaves_like :jsonapi_filters_by_foreign_key, :invoice_id do
      #   let(:foreign_keys_to_ids) do
      #     {
      #       invoices.first.id => create_list(:invoice_terminated_network, 2, invoice: invoices.first).map(&:id),
      #       invoices.second.id => create_list(:invoice_terminated_network, 2, invoice: invoices.second).map(&:id),
      #       another_invoice.id => create_list(:invoice_terminated_network, 2, invoice: another_invoice).map(&:id)
      #     }
      #   end
      # end

      it_behaves_like :jsonapi_filters_by_foreign_key, :invoice_account_id do
        let(:foreign_keys_to_ids) do
          {
            accounts.first.id => create_list(:invoice_service_data, 2, :filled, invoice: invoices.first).map(&:id),
            accounts.second.id => create_list(:invoice_service_data, 2, :filled, invoice: invoices.second).map(&:id),
            another_account.id => create_list(:invoice_service_data, 2, :filled, invoice: another_invoice).map(&:id)
          }
        end
      end
    end

    context 'with include invoice' do
      let(:json_api_request_query) do
        { include: 'invoice' }
      end

      it 'responds with included accounts' do
        subject
        records.each do |record|
          data = response_json[:data].detect { |item| item[:id] == record.id.to_s }
          expect(data[:relationships][:invoice][:data]).to eq(
                                                             id: record.invoice.id.to_s,
                                                             type: 'invoices'
                                                           )
        end
        invoices = records.map(&:invoice).uniq
        expect(response_json[:included]).to match_array(
                                              invoices.map do |invoice|
                                                hash_including(id: invoice.id.to_s, type: 'invoices')
                                              end
                                            )
      end

      include_examples :returns_json_api_collection do
        let(:json_api_collection_ids) { records.map { |r| r.id.to_s } }
      end
    end
  end

  describe 'GET /api/rest/admin/invoice-service-data/{id}' do
    subject do
      get json_api_request_path, params: json_api_request_query, headers: json_api_request_headers
    end

    let(:json_api_request_path) { "#{super()}/#{record_id}" }
    let(:record_id) { record.id.to_s }
    let(:json_api_request_query) { nil }

    let!(:contractor) { create(:customer) }
    let!(:account) { create(:account, contractor:) }
    let!(:invoice) { create(:invoice, account:) }
    let!(:record) do
      create(:invoice_service_data, :filled, invoice:)
    end
    let(:expected_attributes) do
      {
        amount: record.amount&.to_s,
        'transactions-count': record.transactions_count,
        spent: record.spent
      }
    end

    relationships = %i[invoice service]
    include_examples :returns_json_api_record, relationships: do
      let(:json_api_record_id) { record_id }
      let(:json_api_record_attributes) { expected_attributes }
    end

    it_behaves_like :json_api_admin_check_authorization

    context 'with include=service' do
      let(:json_api_request_query) do
        { include: 'service' }
      end

      it 'responds with correct included records' do
        subject
        expect(response_json[:included]).to match(
                                              [
                                                hash_including(id: record.service.id.to_s, type: 'services')
                                              ]
                                            )
      end

      include_examples :returns_json_api_record, relationships: do
        let(:json_api_record_id) { record_id }
        let(:json_api_record_attributes) { expected_attributes }
      end

      include_examples :returns_json_api_record_relationship, :service do
        let(:json_api_relationship_data) { { id: record.service.id.to_s, type: 'services' } }
      end
    end

    context 'with non-existed id' do
      let(:record_id) { (record.id + 1_000).to_s }

      include_examples :responds_with_status, 404
    end
  end
end
