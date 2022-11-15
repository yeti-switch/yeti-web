# frozen_string_literal: true

RSpec.describe Api::Rest::Customer::V1::PaymentsController, type: :request do
  include_context :json_api_customer_v1_helpers, type: :payments

  describe 'GET /api/rest/customer/v1/payments' do
    subject do
      get json_api_request_path, params: json_api_request_query, headers: json_api_request_headers
    end

    shared_examples :responds_with_correct_records do
      it 'responds with correct records' do
        subject
        actual_ids = response_json[:data].pluck(:id)
        expect(actual_ids).to match_array expected_records.map(&:uuid)
      end
    end

    let(:json_api_request_query) { nil }
    let!(:accounts) { create_list(:account, 2, contractor: customer) }
    let!(:payments) do
      [
        create(:payment, amount: 100.25, account: accounts.first),
        create(:payment, notes: 'test', account: accounts.first),
        create(:payment, account: accounts.second)
      ]
    end
    before do
      other_customer = create(:customer)
      other_customer_account = create(:account, contractor: other_customer)
      # skip payments for the other customer
      create(:payment, account: other_customer_account)
    end

    it_behaves_like :json_api_customer_v1_check_authorization

    it_behaves_like :json_api_check_pagination do
      let(:payments) do
        Array.new(records_qty) { create(:payment, account: accounts.sample) }
      end
      let(:json_api_request_query) { { sort: 'created_at' } }
      let(:records_ids) { payments.sort_by(&:created_at).map(&:uuid) }
    end

    context 'when api_access.account_ids is empty' do
      let(:expected_records) { payments }

      include_examples :responds_with_correct_records
    end

    context 'when api_access.account_ids is filled' do
      let(:expected_records) { payments }
      before do
        # allowed accounts
        accounts.each { |acc| create(:customers_auth, customer: customer, account: acc) }
        api_access.update!(account_ids: accounts.map(&:id))

        # not allowed account and it's payments
        not_allowed_account = create(:account, contractor: customer)
        create(:payment, account: not_allowed_account)
      end

      include_examples :responds_with_correct_records
    end

    context 'with filter by uuid_in' do
      let(:json_api_request_query) do
        { filter: { uuid_in: "#{payments.first.uuid},#{payments.last.uuid}" } }
      end
      let(:expected_records) { [payments.first, payments.last] }

      include_examples :responds_with_correct_records
    end

    context 'with filter by account_id_eq' do
      let(:json_api_request_query) do
        { filter: { account_id_eq: another_account.uuid } }
      end
      let!(:another_account) { create(:account, contractor: customer) }
      let!(:expected_records) do
        create_list(:payment, 2, account: another_account)
      end

      include_examples :responds_with_correct_records
    end

    context 'with filter by account_id_not_eq' do
      let(:json_api_request_query) do
        { filter: { account_id_not_eq: accounts.first.reload.uuid } }
      end
      let!(:another_account) { create(:account, contractor: customer) }
      let(:payments) do
        create_list(:payment, 2, account: accounts.first)
      end
      let!(:expected_records) do
        create_list(:payment, 2, account: another_account)
      end

      include_examples :responds_with_correct_records
    end

    context 'with filter by account_id_in' do
      let(:json_api_request_query) do
        { filter: { account_id_in: "#{another_account.reload.uuid},#{another_account2.reload.uuid}" } }
      end
      let!(:another_account) { create(:account, contractor: customer) }
      let!(:another_account2) { create(:account, contractor: customer) }
      let!(:expected_records) do
        [
          create(:payment, account: another_account),
          create(:payment, account: another_account2)
        ]
      end

      include_examples :responds_with_correct_records
    end

    context 'with filter by account_id_not_in' do
      let(:json_api_request_query) do
        { filter: { account_id_not_in: "#{accounts.first.reload.uuid},#{accounts.second.reload.uuid}" } }
      end
      let!(:another_account) { create(:account, contractor: customer) }
      let!(:expected_records) do
        create_list(:payment, 2, account: another_account)
      end

      include_examples :responds_with_correct_records
    end

    context 'with filter by amount_eq' do
      let(:json_api_request_query) do
        { filter: { amount_eq: payments.first.amount.to_s } }
      end
      let(:expected_records) { [payments.first] }

      include_examples :responds_with_correct_records
    end

    context 'with filter by notes_eq' do
      let(:json_api_request_query) do
        { filter: { notes_eq: payments.second.notes } }
      end
      let(:expected_records) { [payments.second] }

      include_examples :responds_with_correct_records
    end

    context 'with include account' do
      let(:json_api_request_query) do
        { include: 'account' }
      end
      let(:expected_records) { payments }

      it 'responds with included accounts' do
        subject
        payments.each do |payment|
          data = response_json[:data].detect { |item| item[:id] == payment.uuid }
          expect(data[:relationships][:account][:data]).to eq(
                                                             id: payment.account.uuid,
                                                             type: 'accounts'
                                                           )
        end
        payments_accounts = payments.map(&:account).uniq
        expect(response_json[:included]).to match_array(
                                              payments_accounts.map do |account|
                                                hash_including(id: account.uuid, type: 'accounts')
                                              end
                                            )
      end

      include_examples :responds_with_correct_records
    end
  end

  describe 'GET /api/rest/customer/v1/payments/{id}' do
    subject do
      get json_api_request_path, params: nil, headers: json_api_request_headers
    end

    shared_examples :responds_with_correct_record do
      it 'responds with correct record' do
        subject
        expect(response_json[:data]).to match(
                                          id: payment.uuid,
                                          type: 'payments',
                                          links: anything,
                                          attributes: {
                                            amount: payment.amount.to_s,
                                            notes: payment.notes,
                                            'created-at': payment.created_at.iso8601(3)
                                          },
                                          relationships: {
                                            account: {
                                              links: anything
                                            }
                                          }
                                        )
      end
    end

    let(:json_api_request_path) { "#{super()}/#{record_id}" }
    let(:record_id) { payment.uuid }

    let!(:account) { create(:account, contractor: customer) }
    let!(:payment) { create(:payment, account: account) }

    it_behaves_like :json_api_customer_v1_check_authorization

    context 'when record exists' do
      include_examples :responds_with_correct_record
    end

    context 'when payment account listed in allowed_ids' do
      before do
        api_access.update!(account_ids: [account.id])
      end

      include_examples :responds_with_correct_record
    end

    context 'when payment account not listed in allowed_ids' do
      before do
        allowed_account = create(:account, contractor: customer)
        api_access.update!(account_ids: [allowed_account.id])
      end

      include_examples :responds_with_status, 404
    end

    context 'when payment account belongs to another customer' do
      let!(:another_customer) { create(:customer) }
      let!(:another_account) { create(:account, contractor: another_customer) }
      let(:payment) { create(:payment, account: another_account) }

      include_examples :responds_with_status, 404
    end
  end
end
