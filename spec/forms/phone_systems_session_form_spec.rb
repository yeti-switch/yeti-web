# frozen_string_literal: true

RSpec.describe PhoneSystemsSessionForm do
  subject { form.save }

  include_context :stub_request_to_create_phone_systems_session

  let(:customer) { create(:customer) }
  let(:account) { create(:account, contractor: customer) }
  let(:service_type_attrs) { { variables: { endpoint: phone_systems_base_url } } }
  let(:service_type) { FactoryBot.create(:service_type, service_type_attrs) }
  let(:service_attrs) { { type: service_type, account: } }
  let(:service) { FactoryBot.create(:service, service_attrs) }
  let(:api_access_attrs) { { account_ids: [account.id], customer: } }
  let(:api_access) { create :api_access, api_access_attrs }
  let(:form_attributes) { { service: service.uuid } }
  let(:auth_context) { CustomerV1Auth::AuthContext.from_api_access(api_access) }
  let(:form) do
    f = described_class.new(form_attributes)
    f.auth_context = auth_context
    f
  end

  context 'when valid data' do
    before { stub_request_to_create_phone_systems_session }

    it 'should create session on the phone.systems side and URL should be received' do
      subject

      expect(form.errors.messages).to eq({})
      expect(form.phone_systems_url).to eq phone_systems_redirect_url
      expect(stub_request_to_create_phone_systems_session).to have_been_requested
    end
  end

  context 'when service not found' do
    let(:form_attributes) { { service: SecureRandom.uuid } }

    it 'should return validation error message' do
      subject

      expect(form.errors.messages).to eq base: ['service not found']
    end
  end

  context 'when service from another Customer' do
    let!(:another_customer) { create(:customer) }
    let!(:another_account) { create(:account, contractor: another_customer) }
    let(:api_access_attrs) { { account_ids: [another_account.id], customer: another_customer } }

    it 'should return validation error message' do
      subject

      expect(form.errors.messages).to match_array(
                                        base: ['service not found'],
                                        service: ['Account of current Service is not related to current API Access']
                                      )
    end
  end

  context 'when current API Access with account_ids = []' do
    let(:api_access_attrs) { super().merge account_ids: [] }

    before { stub_request_to_create_phone_systems_session }

    it 'should create session on the phone.systems side and URL should be received' do
      subject

      expect(form.errors.messages).to eq({})
      expect(form.phone_systems_url).to eq phone_systems_redirect_url
      expect(stub_request_to_create_phone_systems_session).to have_been_requested
    end
  end

  context 'when Account of Service is NOT included in list of allowed account IDs ' do
    let(:second_account) { create(:account, contractor: customer, name: 'Second Account') }
    let(:api_access_attrs) { super().merge account_ids: [account.id] }
    let(:service_attrs) { super().merge account: second_account }

    it 'should return validation error' do
      subject

      expect(form.errors.messages).to eq service: ['Account of current Service is not related to current API Access']
    end
  end
end
