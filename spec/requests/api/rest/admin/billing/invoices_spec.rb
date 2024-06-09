# frozen_string_literal: true

RSpec.describe Api::Rest::Admin::Billing::InvoicesController, type: :request, bullet: [:n] do
  include_context :json_api_admin_helpers, type: :invoices, prefix: 'billing'

  describe 'GET /api/rest/admin/invoices' do
    subject do
      get json_api_request_path, params: json_api_request_query, headers: json_api_request_headers
    end

    let(:json_api_request_query) { nil }

    before { Billing::Invoice.delete_all }
    let!(:customer) { create(:customer) }
    let!(:accounts) { create_list(:account, 2, contractor: customer) }
    let!(:another_customer) { create(:customer) }
    let!(:another_account) { create(:account, contractor: another_customer) }
    let!(:records) do
      [
        create(:invoice, :manual, :approved, account: another_account),
        create(:invoice, :manual, :new, account: accounts.first),
        create(:invoice, :manual, :new, account: accounts.second),
        create(
          :invoice,
          :manual,
          :approved,
          account: accounts.first,
          start_date: 30.days.ago.utc,
          end_date: 25.days.ago.utc
        ),
        create(:invoice, :auto_full, :approved, account: accounts.first),
        create(:invoice, :manual, :approved, account: accounts.second),
        create(
          :invoice,
          :auto_partial,
          :approved,
          account: accounts.second,
          start_date: 25.days.ago.utc,
          end_date: 21.days.ago.utc
        )
      ]
    end

    include_examples :returns_json_api_collection do
      let(:json_api_collection_ids) { records.map { |r| r.id.to_s } }
    end

    it_behaves_like :json_api_admin_check_authorization

    it_behaves_like :json_api_check_pagination do
      let(:records) do
        accounts = create_list(:account, records_qty)
        Array.new(records_qty) do |i|
          create(:invoice, :manual, :approved, account: accounts[i])
        end
      end
      let(:records_ids) { records.sort_by(&:id).map { |r| r.id.to_s } }
    end

    context 'with filters' do
      let!(:records) { nil }

      it_behaves_like :jsonapi_filters_by_foreign_key, :account_id do
        let(:foreign_keys_to_ids) do
          {
            accounts.first.id => create_list(:invoice, 2, :approved, account: accounts.first).map(&:id),
            accounts.second.id => create_list(:invoice, 2, :approved, account: accounts.second).map(&:id),
            another_account.id => create_list(:invoice, 2, :approved, account: another_account).map(&:id)
          }
        end
      end

      it_behaves_like :jsonapi_filters_by_enum, :state do
        let(:enum_values_to_ids) do
          {
            Billing::InvoiceState.find(Billing::InvoiceState::PENDING).name => create_list(:invoice, 2, :pending, account: accounts.first).map(&:id),
            Billing::InvoiceState.find(Billing::InvoiceState::APPROVED).name => create_list(:invoice, 2, :approved, account: accounts.second).map(&:id),
            Billing::InvoiceState.find(Billing::InvoiceState::NEW).name => create_list(:invoice, 2, :new, account: accounts.first).map(&:id)
          }
        end
      end

      it_behaves_like :jsonapi_filters_by_enum, :invoice_type do
        let(:enum_values_to_ids) do
          {
            Billing::InvoiceType.find(Billing::InvoiceType::MANUAL).name => create_list(:invoice, 2, :manual, account: accounts.first).map(&:id),
            Billing::InvoiceType.find(Billing::InvoiceType::AUTO_FULL).name => create_list(:invoice, 2, :auto_full, account: accounts.first).map(&:id),
            Billing::InvoiceType.find(Billing::InvoiceType::AUTO_PARTIAL).name => create_list(:invoice, 2, :auto_partial, account: accounts.second).map(&:id)
          }
        end
      end
    end

    context 'with include account' do
      let(:json_api_request_query) do
        { include: 'account' }
      end

      it 'responds with included accounts' do
        subject
        records.each do |invoice|
          data = response_json[:data].detect { |item| item[:id] == invoice.id.to_s }
          expect(data[:relationships][:account][:data]).to eq(
                                                             id: invoice.account.id.to_s,
                                                             type: 'accounts'
                                                           )
        end
        invoices_accounts = records.map(&:account).uniq
        expect(response_json[:included]).to match_array(
                                              invoices_accounts.map do |account|
                                                hash_including(id: account.id.to_s, type: 'accounts')
                                              end
                                            )
      end

      include_examples :returns_json_api_collection do
        let(:json_api_collection_ids) { records.map { |r| r.id.to_s } }
      end
    end
  end

  describe 'GET /api/rest/admin/invoices/{id}' do
    subject do
      get json_api_request_path, params: json_api_request_query, headers: json_api_request_headers
    end

    let(:json_api_request_path) { "#{super()}/#{record_id}" }
    let(:record_id) { invoice.id.to_s }
    let(:json_api_request_query) { nil }

    let!(:contractor) { create(:customer) }
    let!(:account) { create(:account, contractor:) }
    let!(:invoice) do
      create(:invoice, :auto_full, :approved, account:)
    end
    let(:expected_attributes) do
      {
        'pdf-path': nil,
        'odt-path': nil,
        reference: invoice.reference,
        'start-date': invoice.start_date.iso8601(3),
        'end-date': invoice.end_date.iso8601(3),
        state: invoice.state.name,
        'invoice-type': invoice.type.name,
        'amount-spent': invoice.amount_spent.to_s,
        'amount-earned': invoice.amount_earned.to_s,
        'originated-amount-spent': invoice.originated_amount_spent.to_s,
        'originated-amount-earned': invoice.originated_amount_earned.to_s,
        'originated-calls-count': invoice.originated_calls_count,
        'originated-successful-calls-count': invoice.originated_successful_calls_count,
        'originated-calls-duration': invoice.originated_calls_duration,
        'originated-billing-duration': invoice.originated_billing_duration,
        'originated-first-call-at': invoice.first_originated_call_at&.iso8601(3),
        'originated-last-call-at': invoice.last_originated_call_at&.iso8601(3),
        'terminated-amount-spent': invoice.terminated_amount_spent.to_s,
        'terminated-amount-earned': invoice.terminated_amount_earned.to_s,
        'terminated-calls-count': invoice.terminated_calls_count,
        'terminated-successful-calls-count': invoice.terminated_successful_calls_count,
        'terminated-calls-duration': invoice.terminated_calls_duration,
        'terminated-billing-duration': invoice.terminated_billing_duration,
        'terminated-first-call-at': invoice.first_terminated_call_at&.iso8601(3),
        'terminated-last-call-at': invoice.last_terminated_call_at&.iso8601(3),
        'services-amount-spent': invoice.services_amount_spent.to_s,
        'services-amount-earned': invoice.services_amount_earned.to_s,
        'service-transactions-count': invoice.service_transactions_count
      }
    end

    relationships = %i[
      account
      originated-destinations
      originated-networks
      terminated-destinations
      terminated-networks
      service-data
    ]
    include_examples :returns_json_api_record, relationships: do
      let(:json_api_record_id) { record_id }
      let(:json_api_record_attributes) { expected_attributes }
    end

    it_behaves_like :json_api_admin_check_authorization

    context 'when invoice has document without files' do
      let!(:invoice_document) { create(:invoice_document, invoice: invoice) }

      include_examples :returns_json_api_record, relationships: do
        let(:json_api_record_id) { record_id }
        let(:json_api_record_attributes) { expected_attributes }
      end
    end

    context 'when invoice has document with pdf file' do
      let!(:invoice_document) { create(:invoice_document, invoice: invoice, pdf_data: 'foobar') }
      let(:expected_attributes) do
        super().merge 'pdf-path': "/api/rest/admin/files/invoice-#{invoice.id}.pdf"
      end

      include_examples :returns_json_api_record, relationships: do
        let(:json_api_record_id) { record_id }
        let(:json_api_record_attributes) { expected_attributes }
      end
    end

    context 'when invoice has document with odt file' do
      let!(:invoice_document) { create(:invoice_document, invoice: invoice, data: 'foobar') }
      let(:expected_attributes) do
        super().merge 'odt-path': "/api/rest/admin/files/invoice-#{invoice.id}.odt"
      end

      include_examples :returns_json_api_record, relationships: do
        let(:json_api_record_id) { record_id }
        let(:json_api_record_attributes) { expected_attributes }
      end
    end

    context 'with include=originated-destinations' do
      let(:json_api_request_query) do
        { include: 'originated-destinations' }
      end

      let!(:originated_destinations) do
        create_list(:invoice_originated_destination, 2, :success, invoice: invoice)
      end

      include_examples :returns_json_api_record, relationships: do
        let(:json_api_record_id) { record_id }
        let(:json_api_record_attributes) { expected_attributes }
      end

      include_examples :returns_json_api_record_relationship, :'originated-destinations' do
        let(:json_api_relationship_data) do
          match_array(
            originated_destinations.map { |r| { id: r.id.to_s, type: 'invoice-originated-destinations' } }
          )
        end
      end

      it 'responds with correct included records' do
        subject
        originated_destinations_data = originated_destinations.map do |record|
          hash_including(
            id: record.id.to_s,
            type: 'invoice-originated-destinations',
            attributes: {
              amount: record.amount&.to_s,
              'billing-duration': record.billing_duration,
              'calls-count': record.calls_count,
              'calls-duration': record.calls_duration,
              'dst-prefix': record.dst_prefix,
              'first-call-at': record.first_call_at&.iso8601(3),
              'last-call-at': record.last_call_at&.iso8601(3),
              rate: record.rate&.to_s,
              spent: record.spent,
              'successful-calls-count': record.successful_calls_count
            },
            relationships: {
              invoice: { links: anything },
              country: { links: anything },
              network: { links: anything }
            }
          )
        end
        expect(response_json[:included]).to match_array(originated_destinations_data)
      end

      context 'with nested include country and network' do
        let(:json_api_request_query) do
          { include: 'originated-destinations.country,originated-destinations.network' }
        end

        include_examples :returns_json_api_record, relationships: do
          let(:json_api_record_id) { record_id }
          let(:json_api_record_attributes) { expected_attributes }
        end

        include_examples :returns_json_api_record_relationship, :'originated-destinations' do
          let(:json_api_relationship_data) do
            match_array(
              originated_destinations.map { |r| { id: r.id.to_s, type: 'invoice-originated-destinations' } }
            )
          end
        end

        it 'responds with correct included records' do
          subject
          originated_destinations_data = originated_destinations.map do |record|
            hash_including(
              id: record.id.to_s,
              type: 'invoice-originated-destinations',
              attributes: {
                amount: record.amount&.to_s,
                'billing-duration': record.billing_duration,
                'calls-count': record.calls_count,
                'calls-duration': record.calls_duration,
                'dst-prefix': record.dst_prefix,
                'first-call-at': record.first_call_at&.iso8601(3),
                'last-call-at': record.last_call_at&.iso8601(3),
                rate: record.rate&.to_s,
                spent: record.spent,
                'successful-calls-count': record.successful_calls_count
              },
              relationships: {
                invoice: { links: anything },
                country: {
                  data: { id: record.country_id.to_s, type: 'countries' },
                  links: anything
                },
                network: {
                  data: { id: record.network_id.to_s, type: 'networks' },
                  links: anything
                }
              }
            )
          end
          countries_data = originated_destinations.map(&:country).uniq.map do |record|
            hash_including(
              id: record.id.to_s,
              type: 'countries'
            )
          end
          networks_data = originated_destinations.map(&:network).uniq.map do |record|
            hash_including(
              id: record.id.to_s,
              type: 'networks'
            )
          end

          expect(response_json[:included]).to contain_exactly(
                                                *originated_destinations_data,
                                                *countries_data,
                                                *networks_data
                                              )
        end

        context 'when originated destination has no country nor network' do
          let!(:originated_destinations) do
            create_list(:invoice_originated_destination, 2, invoice: invoice)
          end

          include_examples :returns_json_api_record, relationships: do
            let(:json_api_record_id) { record_id }
            let(:json_api_record_attributes) { expected_attributes }
          end

          include_examples :returns_json_api_record_relationship, :'originated-destinations' do
            let(:json_api_relationship_data) do
              match_array(
                originated_destinations.map { |r| { id: r.id.to_s, type: 'invoice-originated-destinations' } }
              )
            end
          end

          it 'responds with correct included records' do
            subject
            originated_destinations_data = originated_destinations.map do |record|
              hash_including(
                id: record.id.to_s,
                type: 'invoice-originated-destinations',
                attributes: {
                  amount: record.amount&.to_s,
                  'billing-duration': record.billing_duration,
                  'calls-count': record.calls_count,
                  'calls-duration': record.calls_duration,
                  'dst-prefix': record.dst_prefix,
                  'first-call-at': record.first_call_at&.iso8601(3),
                  'last-call-at': record.last_call_at&.iso8601(3),
                  rate: record.rate&.to_s,
                  spent: record.spent,
                  'successful-calls-count': record.successful_calls_count
                },
                relationships: {
                  invoice: { links: anything },
                  country: { data: nil, links: anything },
                  network: { data: nil, links: anything }
                }
              )
            end
            expect(response_json[:included]).to match_array(originated_destinations_data)
          end
        end
      end
    end

    context 'with include=originated-networks' do
      let(:json_api_request_query) do
        { include: 'originated-networks' }
      end

      let!(:originated_networks) do
        create_list(:invoice_originated_network, 2, :success, invoice: invoice)
      end

      include_examples :returns_json_api_record, relationships: do
        let(:json_api_record_id) { record_id }
        let(:json_api_record_attributes) { expected_attributes }
      end

      include_examples :returns_json_api_record_relationship, :'originated-networks' do
        let(:json_api_relationship_data) do
          match_array(
            originated_networks.map { |r| { id: r.id.to_s, type: 'invoice-originated-networks' } }
          )
        end
      end

      it 'responds with correct included records' do
        subject
        originated_networks_data = originated_networks.map do |record|
          hash_including(
            id: record.id.to_s,
            type: 'invoice-originated-networks',
            attributes: {
              amount: record.amount&.to_s,
              'billing-duration': record.billing_duration,
              'calls-count': record.calls_count,
              'calls-duration': record.calls_duration,
              'first-call-at': record.first_call_at&.iso8601(3),
              'last-call-at': record.last_call_at&.iso8601(3),
              rate: record.rate&.to_s,
              spent: record.spent,
              'successful-calls-count': record.successful_calls_count
            },
            relationships: {
              invoice: { links: anything },
              country: { links: anything },
              network: { links: anything }
            }
          )
        end
        expect(response_json[:included]).to match_array(originated_networks_data)
      end

      context 'with nested include country and network' do
        let(:json_api_request_query) do
          { include: 'originated-networks.country,originated-networks.network' }
        end

        include_examples :returns_json_api_record, relationships: do
          let(:json_api_record_id) { record_id }
          let(:json_api_record_attributes) { expected_attributes }
        end

        include_examples :returns_json_api_record_relationship, :'originated-networks' do
          let(:json_api_relationship_data) do
            match_array(
              originated_networks.map { |r| { id: r.id.to_s, type: 'invoice-originated-networks' } }
            )
          end
        end

        it 'responds with correct included records' do
          subject
          originated_networks_data = originated_networks.map do |record|
            hash_including(
              id: record.id.to_s,
              type: 'invoice-originated-networks',
              attributes: {
                amount: record.amount&.to_s,
                'billing-duration': record.billing_duration,
                'calls-count': record.calls_count,
                'calls-duration': record.calls_duration,
                'first-call-at': record.first_call_at&.iso8601(3),
                'last-call-at': record.last_call_at&.iso8601(3),
                rate: record.rate&.to_s,
                spent: record.spent,
                'successful-calls-count': record.successful_calls_count
              },
              relationships: {
                invoice: { links: anything },
                country: {
                  data: { id: record.country_id.to_s, type: 'countries' },
                  links: anything
                },
                network: {
                  data: { id: record.network_id.to_s, type: 'networks' },
                  links: anything
                }
              }
            )
          end
          countries_data = originated_networks.map(&:country).uniq.map do |record|
            hash_including(
              id: record.id.to_s,
              type: 'countries'
            )
          end
          networks_data = originated_networks.map(&:network).uniq.map do |record|
            hash_including(
              id: record.id.to_s,
              type: 'networks'
            )
          end

          expect(response_json[:included]).to contain_exactly(
                                                *originated_networks_data,
                                                *countries_data,
                                                *networks_data
                                              )
        end

        context 'when originated network has no country nor network' do
          let(:originated_networks) do
            create_list(:invoice_originated_network, 2, invoice: invoice)
          end

          include_examples :returns_json_api_record, relationships: do
            let(:json_api_record_id) { record_id }
            let(:json_api_record_attributes) { expected_attributes }
          end

          include_examples :returns_json_api_record_relationship, :'originated-networks' do
            let(:json_api_relationship_data) do
              match_array(
                originated_networks.map { |r| { id: r.id.to_s, type: 'invoice-originated-networks' } }
              )
            end
          end

          it 'responds with correct included records' do
            subject
            originated_networks_data = originated_networks.map do |record|
              hash_including(
                id: record.id.to_s,
                type: 'invoice-originated-networks',
                attributes: {
                  amount: record.amount&.to_s,
                  'billing-duration': record.billing_duration,
                  'calls-count': record.calls_count,
                  'calls-duration': record.calls_duration,
                  'first-call-at': record.first_call_at&.iso8601(3),
                  'last-call-at': record.last_call_at&.iso8601(3),
                  rate: record.rate&.to_s,
                  spent: record.spent,
                  'successful-calls-count': record.successful_calls_count
                },
                relationships: {
                  invoice: { links: anything },
                  country: { data: nil, links: anything },
                  network: { data: nil, links: anything }
                }
              )
            end
            expect(response_json[:included]).to match_array(originated_networks_data)
          end
        end
      end
    end

    context 'with include=terminated-destinations' do
      let(:json_api_request_query) do
        { include: 'terminated-destinations' }
      end

      let!(:terminated_destinations) do
        create_list(:invoice_terminated_destination, 2, :success, invoice: invoice)
      end

      include_examples :returns_json_api_record, relationships: do
        let(:json_api_record_id) { record_id }
        let(:json_api_record_attributes) { expected_attributes }
      end

      include_examples :returns_json_api_record_relationship, :'terminated-destinations' do
        let(:json_api_relationship_data) do
          match_array(
            terminated_destinations.map { |r| { id: r.id.to_s, type: 'invoice-terminated-destinations' } }
          )
        end
      end

      it 'responds with correct included records' do
        subject
        terminated_destinations_data = terminated_destinations.map do |record|
          hash_including(
            id: record.id.to_s,
            type: 'invoice-terminated-destinations',
            attributes: {
              amount: record.amount&.to_s,
              'billing-duration': record.billing_duration,
              'calls-count': record.calls_count,
              'calls-duration': record.calls_duration,
              'dst-prefix': record.dst_prefix,
              'first-call-at': record.first_call_at&.iso8601(3),
              'last-call-at': record.last_call_at&.iso8601(3),
              rate: record.rate&.to_s,
              spent: record.spent,
              'successful-calls-count': record.successful_calls_count
            },
            relationships: {
              invoice: { links: anything },
              country: { links: anything },
              network: { links: anything }
            }
          )
        end
        expect(response_json[:included]).to match_array(terminated_destinations_data)
      end

      context 'with nested include country and network' do
        let(:json_api_request_query) do
          { include: 'terminated-destinations.country,terminated-destinations.network' }
        end

        include_examples :returns_json_api_record, relationships: do
          let(:json_api_record_id) { record_id }
          let(:json_api_record_attributes) { expected_attributes }
        end

        include_examples :returns_json_api_record_relationship, :'terminated-destinations' do
          let(:json_api_relationship_data) do
            match_array(
              terminated_destinations.map { |r| { id: r.id.to_s, type: 'invoice-terminated-destinations' } }
            )
          end
        end

        it 'responds with correct included records' do
          subject
          terminated_destinations_data = terminated_destinations.map do |record|
            hash_including(
              id: record.id.to_s,
              type: 'invoice-terminated-destinations',
              attributes: {
                amount: record.amount&.to_s,
                'billing-duration': record.billing_duration,
                'calls-count': record.calls_count,
                'calls-duration': record.calls_duration,
                'dst-prefix': record.dst_prefix,
                'first-call-at': record.first_call_at&.iso8601(3),
                'last-call-at': record.last_call_at&.iso8601(3),
                rate: record.rate&.to_s,
                spent: record.spent,
                'successful-calls-count': record.successful_calls_count
              },
              relationships: {
                invoice: { links: anything },
                country: {
                  data: { id: record.country_id.to_s, type: 'countries' },
                  links: anything
                },
                network: {
                  data: { id: record.network_id.to_s, type: 'networks' },
                  links: anything
                }
              }
            )
          end
          countries_data = terminated_destinations.map(&:country).uniq.map do |record|
            hash_including(
              id: record.id.to_s,
              type: 'countries'
            )
          end
          networks_data = terminated_destinations.map(&:network).uniq.map do |record|
            hash_including(
              id: record.id.to_s,
              type: 'networks'
            )
          end

          expect(response_json[:included]).to contain_exactly(
                                                *terminated_destinations_data,
                                                *countries_data,
                                                *networks_data
                                              )
        end

        context 'when terminated destination has no country nor network' do
          let!(:terminated_destinations) do
            create_list(:invoice_terminated_destination, 2, invoice: invoice)
          end

          include_examples :returns_json_api_record, relationships: do
            let(:json_api_record_id) { record_id }
            let(:json_api_record_attributes) { expected_attributes }
          end

          include_examples :returns_json_api_record_relationship, :'terminated-destinations' do
            let(:json_api_relationship_data) do
              match_array(
                terminated_destinations.map { |r| { id: r.id.to_s, type: 'invoice-terminated-destinations' } }
              )
            end
          end

          it 'responds with correct included records' do
            subject
            terminated_destinations_data = terminated_destinations.map do |record|
              hash_including(
                id: record.id.to_s,
                type: 'invoice-terminated-destinations',
                attributes: {
                  amount: record.amount&.to_s,
                  'billing-duration': record.billing_duration,
                  'calls-count': record.calls_count,
                  'calls-duration': record.calls_duration,
                  'dst-prefix': record.dst_prefix,
                  'first-call-at': record.first_call_at&.iso8601(3),
                  'last-call-at': record.last_call_at&.iso8601(3),
                  rate: record.rate&.to_s,
                  spent: record.spent,
                  'successful-calls-count': record.successful_calls_count
                },
                relationships: {
                  invoice: { links: anything },
                  country: { data: nil, links: anything },
                  network: { data: nil, links: anything }
                }
              )
            end
            expect(response_json[:included]).to match_array(terminated_destinations_data)
          end
        end
      end
    end

    context 'with include=terminated-networks' do
      let(:json_api_request_query) do
        { include: 'terminated-networks' }
      end

      let!(:terminated_networks) do
        create_list(:invoice_terminated_network, 2, :success, invoice: invoice)
      end

      include_examples :returns_json_api_record, relationships: do
        let(:json_api_record_id) { record_id }
        let(:json_api_record_attributes) { expected_attributes }
      end

      include_examples :returns_json_api_record_relationship, :'terminated-networks' do
        let(:json_api_relationship_data) do
          match_array(
            terminated_networks.map { |r| { id: r.id.to_s, type: 'invoice-terminated-networks' } }
          )
        end
      end

      it 'responds with correct included records' do
        subject
        terminated_networks_data = terminated_networks.map do |record|
          hash_including(
            id: record.id.to_s,
            type: 'invoice-terminated-networks',
            attributes: {
              amount: record.amount&.to_s,
              'billing-duration': record.billing_duration,
              'calls-count': record.calls_count,
              'calls-duration': record.calls_duration,
              'first-call-at': record.first_call_at&.iso8601(3),
              'last-call-at': record.last_call_at&.iso8601(3),
              rate: record.rate&.to_s,
              spent: record.spent,
              'successful-calls-count': record.successful_calls_count
            },
            relationships: {
              invoice: { links: anything },
              country: { links: anything },
              network: { links: anything }
            }
          )
        end
        expect(response_json[:included]).to match_array(terminated_networks_data)
      end

      context 'with nested include country and network' do
        let(:json_api_request_query) do
          { include: 'terminated-networks.country,terminated-networks.network' }
        end

        include_examples :returns_json_api_record, relationships: do
          let(:json_api_record_id) { record_id }
          let(:json_api_record_attributes) { expected_attributes }
        end

        include_examples :returns_json_api_record_relationship, :'terminated-networks' do
          let(:json_api_relationship_data) do
            match_array(
              terminated_networks.map { |r| { id: r.id.to_s, type: 'invoice-terminated-networks' } }
            )
          end
        end

        it 'responds with correct included records' do
          subject
          terminated_networks_data = terminated_networks.map do |record|
            hash_including(
              id: record.id.to_s,
              type: 'invoice-terminated-networks',
              attributes: {
                amount: record.amount&.to_s,
                'billing-duration': record.billing_duration,
                'calls-count': record.calls_count,
                'calls-duration': record.calls_duration,
                'first-call-at': record.first_call_at&.iso8601(3),
                'last-call-at': record.last_call_at&.iso8601(3),
                rate: record.rate&.to_s,
                spent: record.spent,
                'successful-calls-count': record.successful_calls_count
              },
              relationships: {
                invoice: { links: anything },
                country: {
                  data: { id: record.country_id.to_s, type: 'countries' },
                  links: anything
                },
                network: {
                  data: { id: record.network_id.to_s, type: 'networks' },
                  links: anything
                }
              }
            )
          end
          countries_data = terminated_networks.map(&:country).uniq.map do |record|
            hash_including(
              id: record.id.to_s,
              type: 'countries'
            )
          end
          networks_data = terminated_networks.map(&:network).uniq.map do |record|
            hash_including(
              id: record.id.to_s,
              type: 'networks'
            )
          end

          expect(response_json[:included]).to contain_exactly(
                                                *terminated_networks_data,
                                                *countries_data,
                                                *networks_data
                                              )
        end

        context 'when terminated network has no country nor network' do
          let(:terminated_networks) do
            create_list(:invoice_terminated_network, 2, invoice: invoice)
          end

          include_examples :returns_json_api_record, relationships: do
            let(:json_api_record_id) { record_id }
            let(:json_api_record_attributes) { expected_attributes }
          end

          include_examples :returns_json_api_record_relationship, :'terminated-networks' do
            let(:json_api_relationship_data) do
              match_array(
                terminated_networks.map { |r| { id: r.id.to_s, type: 'invoice-terminated-networks' } }
              )
            end
          end

          it 'responds with correct included records' do
            subject
            terminated_networks_data = terminated_networks.map do |record|
              hash_including(
                id: record.id.to_s,
                type: 'invoice-terminated-networks',
                attributes: {
                  amount: record.amount&.to_s,
                  'billing-duration': record.billing_duration,
                  'calls-count': record.calls_count,
                  'calls-duration': record.calls_duration,
                  'first-call-at': record.first_call_at&.iso8601(3),
                  'last-call-at': record.last_call_at&.iso8601(3),
                  rate: record.rate&.to_s,
                  spent: record.spent,
                  'successful-calls-count': record.successful_calls_count
                },
                relationships: {
                  invoice: { links: anything },
                  country: { data: nil, links: anything },
                  network: { data: nil, links: anything }
                }
              )
            end
            expect(response_json[:included]).to match_array(terminated_networks_data)
          end
        end
      end
    end

    context 'with non-existed id' do
      let(:record_id) { (invoice.id + 1_000).to_s }

      include_examples :responds_with_status, 404
    end
  end

  describe 'GET /api/rest/admin/invoices/{id}/pdf' do
    subject do
      get json_api_request_path, params: nil, headers: json_api_request_headers
    end

    let(:json_api_request_headers) { super().except('Content-Type', 'Accept') }
    let(:json_api_request_path) { "#{super()}/#{record_id}/pdf" }
    let(:record_id) { invoice.id.to_s }

    let!(:contractor) { create(:customer) }
    let!(:account) { create(:account, contractor:) }
    let!(:invoice) { create(:invoice, account:) }
    let!(:invoice_document) { create(:invoice_document, :filled, invoice:) }

    it 'responds with pdf file' do
      subject
      expect(response.status).to eq(200)
      expect(response.headers['Content-Transfer-Encoding']).to eq('binary')
      expect(response.headers['Content-Type']).to eq('application/pdf')
      expect(response.headers['Content-Disposition']).to include("attachment; filename=\"invoice-#{invoice.id}.pdf\"")
      expect(response.body).to match(invoice_document.pdf_data)
    end

    it_behaves_like :json_api_admin_check_authorization

    context 'when invoice_document does not have pdf_data' do
      let(:invoice_document) { create(:invoice_document, :filled, invoice:, pdf_data: nil) }

      include_examples :responds_with_status, 404
    end

    context 'when invoice does not have invoice_document' do
      let(:invoice_document) { nil }

      include_examples :responds_with_status, 404
    end

    context 'with non-existed id' do
      let(:record_id) { (invoice.id + 1_000).to_s }

      include_examples :responds_with_status, 404
    end
  end

  describe 'GET /api/rest/admin/invoices/{id}/odt' do
    subject do
      get json_api_request_path, params: nil, headers: json_api_request_headers
    end

    let(:json_api_request_headers) { super().except('Content-Type', 'Accept') }
    let(:json_api_request_path) { "#{super()}/#{record_id}/odt" }
    let(:record_id) { invoice.id.to_s }

    let!(:contractor) { create(:customer) }
    let!(:account) { create(:account, contractor:) }
    let!(:invoice) { create(:invoice, account:) }
    let!(:invoice_document) { create(:invoice_document, :filled, invoice:) }

    it 'responds with pdf file' do
      subject
      expect(response.status).to eq(200)
      expect(response.headers['Content-Transfer-Encoding']).to eq('binary')
      expect(response.headers['Content-Type']).to eq('application/octet-stream')
      expect(response.headers['Content-Disposition']).to include("attachment; filename=\"invoice-#{invoice.id}.odt\"")
      expect(response.body).to match(invoice_document.data)
    end

    it_behaves_like :json_api_admin_check_authorization

    context 'when invoice_document does not have pdf_data' do
      let(:invoice_document) { create(:invoice_document, :filled, invoice:, data: nil) }

      include_examples :responds_with_status, 404
    end

    context 'when invoice does not have invoice_document' do
      let(:invoice_document) { nil }

      include_examples :responds_with_status, 404
    end

    context 'with non-existed id' do
      let(:record_id) { (invoice.id + 1_000).to_s }

      include_examples :responds_with_status, 404
    end
  end

  describe 'POST /api/rest/admin/invoices' do
    subject do
      post json_api_request_path, params: json_api_request_body.to_json, headers: json_api_request_headers
    end

    shared_examples :creates_invoice do
      # let(:expected_start_time) { ... }
      # let(:expected_end_time) { ... }

      it 'creates invoice' do
        expect(BillingInvoice::Create).to receive(:call).with(
          account: account,
          start_time: expected_start_time,
          end_time: expected_end_time,
          type_id: Billing::InvoiceType::MANUAL
        ).once.and_call_original

        expect { subject }.to change { Billing::Invoice.count }.by(1)
      end

      include_examples :responds_with_status, 201
    end

    include_context :timezone_helpers

    let(:json_api_request_body) do
      {
        data: {
          type: 'invoices',
          attributes: json_api_request_attributes,
          relationships: json_api_request_relationships
        }
      }
    end
    let(:json_api_request_attributes) do
      {
        'start-date': '2023-11-01',
        'end-date': '2023-12-01'
      }
    end
    let(:json_api_request_relationships) do
      {
        account: {
          data: { id: account.id.to_s, type: 'accounts' }
        }
      }
    end

    let!(:contractor) { create(:customer) }
    let!(:account) { create(:account, account_attrs) }
    let(:account_attrs) { { contractor: } }

    include_examples :creates_invoice do
      let(:expected_start_time) { utc_timezone.time_zone.parse('2023-11-01') }
      let(:expected_end_time) { utc_timezone.time_zone.parse('2023-12-01') }
    end

    context 'when account in LA timezone' do
      let(:account_attrs) { super().merge timezone: la_timezone }

      include_examples :creates_invoice do
        let(:expected_start_time) { la_timezone.time_zone.parse('2023-11-01') }
        let(:expected_end_time) { la_timezone.time_zone.parse('2023-12-01') }
      end
    end

    context 'without account relationship' do
      let(:json_api_request_relationships) { {} }

      include_examples :returns_json_api_errors, status: 422, errors: {
        detail: "account - can't be blank",
        source: { pointer: '/data/relationships/account' }
      }
    end

    context 'without attributes' do
      let(:json_api_request_attributes) { {} }

      include_examples :returns_json_api_errors, status: 422, errors: [
        { detail: "start-date - can't be blank", source: { pointer: '/data/attributes/start-date' } },
        { detail: "end-date - can't be blank", source: { pointer: '/data/attributes/end-date' } }
      ]
    end

    context 'with start-date later than end-date' do
      let(:json_api_request_attributes) do
        {
          'start-date': '2023-11-01',
          'end-date': '2023-10-01'
        }
      end

      include_examples :returns_json_api_errors, status: 422, errors: {
        detail: 'end-date - must be greater than start date',
        source: { pointer: '/data/attributes/end-date' }
      }
    end

    context 'with invalid start-date and end-date' do
      let(:json_api_request_attributes) do
        {
          'start-date': 'foo',
          'end-date': 'bar'
        }
      end

      include_examples :returns_json_api_errors, status: 422, errors: [
        { detail: 'start-date - is invalid', source: { pointer: '/data/attributes/start-date' } },
        { detail: 'end-date - is invalid', source: { pointer: '/data/attributes/end-date' } }
      ]
    end
  end

  describe 'DELETE /api/rest/admin/invoices/{id}' do
    subject do
      delete json_api_request_path, headers: json_api_request_headers
    end

    shared_examples :destroys_invoice do
      it 'destroys invoice' do
        expect { subject }.to change { Billing::Invoice.count }.by(-1)
        expect(Billing::Invoice).not_to be_exists(id: invoice.id)
      end

      include_examples :responds_with_status, 204, without_body: true
    end

    let(:json_api_request_path) { "#{super()}/#{record_id}" }
    let(:record_id) { invoice.id.to_s }

    let!(:contractor) { create(:customer) }
    let!(:account) { create(:account, contractor:) }
    let!(:invoice) { create(:invoice, account:) }

    include_examples :destroys_invoice

    it_behaves_like :json_api_admin_check_authorization, status: 204

    context 'with non-existed id' do
      let(:record_id) { (invoice.id + 1_000).to_s }

      include_examples :responds_with_status, 404
    end

    context 'when invoice has document' do
      let!(:invoice_document) { create(:invoice_document, invoice: invoice) }

      it 'destroys invoice document' do
        expect { subject }.to change { Billing::InvoiceDocument.count }.by(-1)
        expect(Billing::InvoiceDocument).not_to be_exists(id: invoice_document.id)
      end

      include_examples :destroys_invoice
    end

    context 'when invoice has originated destinations' do
      let!(:originated_destinations) do
        create_list(:invoice_originated_destination, 2, :success, invoice: invoice)
      end

      it 'destroys originated destinations' do
        expect { subject }.to change { Billing::InvoiceOriginatedDestination.count }.by(-originated_destinations.size)
        expect(Billing::InvoiceOriginatedDestination).not_to be_exists id: originated_destinations.pluck(:id)
      end

      include_examples :destroys_invoice
    end

    context 'when invoice has originated networks' do
      let!(:originated_networks) do
        create_list(:invoice_originated_network, 2, :success, invoice: invoice)
      end

      it 'destroys originated networks' do
        expect { subject }.to change { Billing::InvoiceOriginatedNetwork.count }.by(-originated_networks.size)
        expect(Billing::InvoiceOriginatedNetwork).not_to be_exists id: originated_networks.pluck(:id)
      end

      include_examples :destroys_invoice
    end

    context 'when invoice has terminated destinations' do
      let!(:terminated_destinations) do
        create_list(:invoice_terminated_destination, 2, :success, invoice: invoice)
      end

      it 'destroys terminated destinations' do
        expect { subject }.to change { Billing::InvoiceTerminatedDestination.count }.by(-terminated_destinations.size)
        expect(Billing::InvoiceTerminatedDestination).not_to be_exists id: terminated_destinations.pluck(:id)
      end

      include_examples :destroys_invoice
    end

    context 'when invoice has terminated networks' do
      let!(:terminated_networks) do
        create_list(:invoice_terminated_network, 2, :success, invoice: invoice)
      end

      it 'destroys terminated networks' do
        expect { subject }.to change { Billing::InvoiceTerminatedNetwork.count }.by(-terminated_networks.size)
        expect(Billing::InvoiceTerminatedNetwork).not_to be_exists id: terminated_networks.pluck(:id)
      end

      include_examples :destroys_invoice
    end
  end
end
