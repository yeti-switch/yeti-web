# frozen_string_literal: true

RSpec.describe Api::Rest::Customer::V1::InvoicesController, type: :request do
  include_context :json_api_customer_v1_helpers, type: :invoices

  describe 'GET /api/rest/customer/v1/invoices' do
    subject do
      get json_api_request_path, params: json_api_request_query, headers: json_api_request_headers
    end

    let(:json_api_request_query) { nil }

    before { Billing::Invoice.delete_all }
    let!(:accounts) { create_list(:account, 2, contractor: customer) }
    let!(:other_customer) { create(:customer) }
    let!(:other_customer_account) { create(:account, contractor: other_customer) }
    before do
      # skip invoices for the other customer
      create(:invoice, :manual, :approved, account: other_customer_account)

      # skip not approved invoices
      create(:invoice, :manual, :new, account: accounts.first)
      create(:invoice, :manual, :pending, account: accounts.second)
    end
    let!(:invoices) do
      [
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

    it_behaves_like :json_api_customer_v1_check_authorization

    it_behaves_like :json_api_check_pagination do
      let!(:accounts) do
        create_list(:account, records_qty, contractor: customer)
      end
      let!(:invoices) do
        (0...records_qty).map do |i|
          create(:invoice, :manual, :approved, account: accounts[i])
        end
      end

      let(:json_api_request_query) { { sort: 'start_date' } }
      let(:records_ids) { invoices.sort_by(&:start_date).map(&:uuid) }
    end

    context 'account_ids is empty' do
      it 'returns records of this customer' do
        subject
        expect(response.status).to eq(200)
        actual_ids = response_json[:data].map { |data| data[:id] }
        expect(actual_ids).to match_array invoices.map(&:uuid)
      end
    end

    context 'with account_ids' do
      before do
        # allowed accounts
        create(:customers_auth, customer: customer, account: accounts.first)
        create(:customers_auth, customer: customer, account: accounts.second)
        api_access.update!(account_ids: accounts.map(&:id))

        # not allowed account and it's invoice
        not_allowed_account = create(:account, contractor: customer)
        create(:invoice, :auto_full, :approved, account: not_allowed_account)
      end

      it 'returns records of this customer' do
        subject
        expect(response.status).to eq(200)
        actual_ids = response_json[:data].map { |data| data[:id] }
        expect(actual_ids).to match_array invoices.map(&:uuid)
      end
    end

    context 'with filters' do
      let(:json_api_request_query) do
        { filter: request_filters }
      end

      shared_examples :responds_with_filtered_records do
        it 'response contains only filtered records' do
          subject
          actual_ids = response_json[:data].pluck(:id)
          expect(actual_ids).to match_array expected_records.map(&:uuid)
        end
      end

      context 'account_id_eq' do
        let(:request_filters) { { account_id_eq: another_account.reload.uuid } }
        let!(:another_account) { create(:account, contractor: customer) }
        let!(:expected_records) do
          create_list(:invoice, 2, :approved, account: another_account)
        end

        include_examples :responds_with_filtered_records
      end

      context 'account_id_not_eq' do
        let(:request_filters) { { account_id_not_eq: accounts.first.reload.uuid } }
        let!(:another_account) { create(:account, contractor: customer) }
        let!(:invoices) do
          create_list(:invoice, 2, :approved, account: accounts.first)
        end
        let!(:expected_records) do
          create_list(:invoice, 2, :approved, account: another_account)
        end

        include_examples :responds_with_filtered_records
      end

      context 'account_id_in' do
        let(:request_filters) { { account_id_in: "#{another_account.reload.uuid},#{another_account2.reload.uuid}" } }
        let!(:another_account) { create(:account, contractor: customer) }
        let!(:another_account2) { create(:account, contractor: customer) }
        let!(:expected_records) do
          [
            create(:invoice, :approved, account: another_account),
            create(:invoice, :approved, account: another_account2)
          ]
        end

        include_examples :responds_with_filtered_records
      end

      context 'account_id_not_in' do
        let(:request_filters) { { account_id_not_in: "#{accounts.first.reload.uuid},#{accounts.second.reload.uuid}" } }
        let!(:another_account) { create(:account, contractor: customer) }
        let!(:expected_records) do
          create_list(:invoice, 2, :approved, account: another_account)
        end

        include_examples :responds_with_filtered_records
      end
    end

    context 'with include account' do
      let(:json_api_request_query) do
        { include: 'account' }
      end

      it 'responds with included accounts' do
        subject
        invoices.each do |invoice|
          data = response_json[:data].detect { |item| item[:id] == invoice.uuid }
          expect(data[:relationships][:account][:data]).to eq(
                                                             id: invoice.account.uuid,
                                                             type: 'accounts'
                                                           )
        end
        invoices_accounts = invoices.map(&:account).uniq
        expect(response_json[:included]).to match_array(
                                              invoices_accounts.map do |account|
                                                hash_including(id: account.uuid, type: 'accounts')
                                              end
                                            )
      end

      it 'returns records of this customer' do
        subject
        expect(response.status).to eq(200)
        actual_ids = response_json[:data].map { |data| data[:id] }
        expect(actual_ids).to match_array invoices.map(&:uuid)
      end
    end
  end

  describe 'GET /api/rest/customer/v1/invoices/{id}' do
    subject do
      get json_api_request_path, params: nil, headers: json_api_request_headers
    end

    let(:json_api_request_path) { "#{super()}/#{record_id}" }
    let(:record_id) { invoice.uuid }

    let!(:account) { create(:account, contractor: customer) }
    let!(:invoice) do
      create(:invoice, :auto_full, :approved, account: account)
    end

    it_behaves_like :json_api_customer_v1_check_authorization

    context 'when record exists' do
      it 'returns record with expected attributes' do
        subject
        expect(response_json[:data]).to match(
          id: invoice.uuid,
          type: 'invoices',
          links: anything,
          attributes: {
            reference: invoice.reference,
            'start-date': invoice.start_date.iso8601(3),
            'end-date': invoice.end_date.iso8601(3),
            'amount-spent': invoice.amount_spent.to_s,
            'originated-amount-spent': invoice.originated_amount_spent.to_s,
            'originated-calls-count': invoice.originated_calls_count,
            'originated-successful-calls-count': invoice.originated_successful_calls_count,
            'originated-calls-duration': invoice.originated_calls_duration,
            'originated-billing-duration': invoice.originated_billing_duration,
            'originated-first-call-at': invoice.first_originated_call_at&.iso8601(3),
            'originated-last-call-at': invoice.last_originated_call_at&.iso8601(3),
            'terminated-amount-spent': invoice.terminated_amount_spent.to_s,
            'terminated-calls-count': invoice.terminated_calls_count,
            'terminated-successful-calls-count': invoice.terminated_successful_calls_count,
            'terminated-calls-duration': invoice.terminated_calls_duration,
            'terminated-billing-duration': invoice.terminated_billing_duration,
            'terminated-first-call-at': invoice.first_terminated_call_at&.iso8601(3),
            'terminated-last-call-at': invoice.last_terminated_call_at&.iso8601(3),
            'has-pdf': invoice.invoice_document&.pdf_data.present?
          },
          relationships: {
            account: {
              links: anything
            }
          }
        )
      end
    end

    context 'when invoice account not listed in allowed_ids' do
      before do
        allowed_account = create(:account, contractor: customer)
        api_access.update!(account_ids: [allowed_account.id])
      end

      include_examples :responds_with_status, 404
    end
  end
end
