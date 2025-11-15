# frozen_string_literal: true

RSpec.shared_examples :json_api_customer_v1_check_authorization do |success_status: 200|
  let(:extra_auth_config) { {} }

  context 'with valid Authorization header' do
    include_examples :responds_with_status, success_status

    it 'responds without set-cookie header' do
      subject
      expect(response.headers['set-cookie']).to be_blank
    end

    context 'when Authorization header has no expiration' do
      let(:json_api_auth_token) { build_customer_token(api_access.id, expiration: nil) }

      include_examples :responds_with_status, success_status

      it 'responds without set-cookie header' do
        subject
        expect(response.headers['set-cookie']).to be_blank
      end
    end

    context 'with dynamic auth' do
      let(:api_access) { nil }
      let(:auth_config) { { customer_id: customer.id, **extra_auth_config } }
      let(:json_api_auth_token) do
        build_customer_token_from_config(auth_config, expiration: 1.minute.from_now)
      end

      include_examples :responds_with_status, success_status

      it 'responds without set-cookie header' do
        subject
        expect(response.headers['set-cookie']).to be_blank
      end
    end
  end

  context 'with invalid Authorization header' do
    let(:json_api_auth_token) { 'invalid' }

    include_examples :responds_with_status, 401
  end

  context 'without Authorization header' do
    let(:json_api_request_headers) { super().except('Authorization') }

    include_examples :responds_with_status, 401
  end

  context 'with expired Authorization header' do
    let(:json_api_auth_token) do
      build_customer_token(api_access.id, expiration: 1.minute.ago)
    end

    include_examples :responds_with_status, 401
  end

  context 'with Authorization header for non-existed customer' do
    let(:json_api_auth_token) do
      build_customer_token(999_999, expiration: 1.minute.ago)
    end

    include_examples :responds_with_status, 401
  end

  context 'with valid Cookie header' do
    let(:json_api_request_headers) do
      super().except('Authorization').merge('Cookie' => json_api_auth_cookie)
    end
    let(:json_api_auth_token) { nil }
    let(:json_api_auth_cookie) do
      build_customer_cookie(api_access.id, expiration: 1.minute.from_now)
    end

    include_examples :responds_with_status, success_status

    it 'responds with set-cookie header', freeze_time: true do
      subject
      expiration = CustomerV1Auth::Authenticator::EXPIRATION_INTERVAL.from_now
      expected_cookie = build_customer_cookie(api_access.id, expiration: expiration)
      expect(response.headers['set-cookie']).to eq(expected_cookie)
    end

    context 'when cookie header has no expiration' do
      let(:json_api_auth_cookie) do
        build_customer_cookie(api_access.id, expiration: nil)
      end

      it 'responds with set-cookie header', freeze_time: true do
        subject
        expiration = CustomerV1Auth::Authenticator::EXPIRATION_INTERVAL.from_now
        expected_cookie = build_customer_cookie(api_access.id, expiration: expiration)
        expect(response.headers['set-cookie']).to eq(expected_cookie)
      end
    end

    context 'when expiration interval is blank' do
      before do
        stub_const('CustomerV1Auth::Authenticator::EXPIRATION_INTERVAL', nil)
      end

      include_examples :responds_with_status, success_status

      it 'responds with set-cookie header' do
        subject
        expected_cookie = build_customer_cookie(api_access.id, expiration: nil)
        expect(response.headers['set-cookie']).to eq(expected_cookie)
      end
    end

    context 'with dynamic auth' do
      let(:api_access) { nil }
      let(:auth_config) { { customer_id: customer.id, **extra_auth_config } }
      let(:json_api_auth_cookie) do
        build_customer_cookie_from_config(auth_config, expiration: 1.minute.from_now)
      end

      include_examples :responds_with_status, success_status

      it 'responds with set-cookie header', freeze_time: true do
        subject
        expiration = CustomerV1Auth::Authenticator::EXPIRATION_INTERVAL.from_now
        expected_cookie = build_customer_cookie_from_config(auth_config, expiration: expiration)
        expect(response.headers['set-cookie']).to eq(expected_cookie)
      end

      context 'when expiration interval is blank' do
        before do
          stub_const('CustomerV1Auth::Authenticator::EXPIRATION_INTERVAL', nil)
        end

        include_examples :responds_with_status, success_status

        it 'responds with set-cookie header' do
          subject
          expected_cookie = build_customer_cookie_from_config(auth_config, expiration: nil)
          expect(response.headers['set-cookie']).to eq(expected_cookie)
        end
      end
    end
  end

  context 'with invalid token in Cookie header' do
    let(:json_api_request_headers) do
      super().except('Authorization').merge('Cookie' => json_api_auth_cookie)
    end
    let(:json_api_auth_cookie) do
      build_raw_cookie('test', expiration: 1.minute.from_now)
    end

    include_examples :responds_with_status, 401
  end

  context 'with expired Cookie header' do
    let(:json_api_request_headers) do
      super().except('Authorization').merge('Cookie' => json_api_auth_cookie)
    end
    let(:json_api_auth_cookie) do
      build_customer_cookie(api_access.id, expiration: 1.minute.ago)
    end

    include_examples :responds_with_status, 401
  end

  context 'with Cookie header for non-existed customer' do
    let(:json_api_request_headers) do
      super().except('Authorization').merge('Cookie' => json_api_auth_cookie)
    end
    let(:json_api_auth_cookie) do
      build_customer_cookie(999_999, expiration: 1.minute.from_now)
    end

    include_examples :responds_with_status, 401
  end

  context 'when valid Cookie header passed along with invalid Authorization header' do
    let(:json_api_auth_token) { 'invalid' }
    let(:json_api_request_headers) do
      super().merge('Cookie' => json_api_auth_cookie)
    end
    let(:json_api_auth_cookie) do
      build_customer_cookie(api_access.id, expiration: 1.minute.from_now)
    end

    # When Authorization header is passed system will not check Cookie header.
    include_examples :responds_with_status, 401
  end

  context 'with logout Cookie header' do
    let(:json_api_request_headers) do
      super().except('Authorization').merge('Cookie' => json_api_auth_cookie)
    end
    let(:json_api_auth_cookie) do
      expiration = Time.parse('1970-01-01 00:00:00 UTC')
      build_raw_cookie('logout', expiration: expiration)
    end

    include_examples :responds_with_status, 401
  end
end
