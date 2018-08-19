require 'spec_helper'

RSpec::Matchers.define :return_404_with_empty_body do
  match do |actual|
    actual.status == 404 && actual.body.blank?
  end
end

describe Api::Rest::Customer::V1::AuthController, type: :controller do

  let!(:user) { create :api_access }
  let(:remote_ip) { '127.0.0.1' }

  before { request.accept = 'application/json' }
  before { request.remote_addr = remote_ip }

  describe 'POST create' do
    let(:attributes) { { login: user.login, password: user.password } }

    before { post :create, params: { auth: attributes } }

    context 'when attributes are valid' do
      it { expect(response.status).to eq(201) }
      it { expect(response_body).to include(:jwt) }
    end

    context 'when password is invalid' do
      let(:attributes) { { login: user.login, password: 'wrong.password' } }

      it { expect(response).to return_404_with_empty_body }
    end

    context 'when customer not exists' do
      let(:attributes) { { login: 'fake.login', password: user.password } }

      it { expect(response).to return_404_with_empty_body }
    end

    context 'when IP is not allowed' do
      let(:remote_ip) { '127.0.0.2' }

      it { expect(response).to return_404_with_empty_body }
    end

    context 'Issue#338: 0.0.0.0/0 allows requests from any IP' do
      let!(:user) { create :api_access, allowed_ips: ['0.0.0.0/0'] }
      let(:remote_ip) { '104.81.225.117' }

      it { expect(response.status).to eq(201) }
    end

    context 'Issue#338: request from IP not matches the mask' do
      let!(:user) { create :api_access, allowed_ips: ['192.168.0.0/24'] }
      let(:remote_ip) { '192.169.1.1' }

      it { expect(response).to return_404_with_empty_body }
    end
  end

end
