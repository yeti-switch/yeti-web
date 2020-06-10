# frozen_string_literal: true

require 'spec_helper'

describe Api::Rest::Admin::Cdr::AuthLogsController, type: :controller do
  include_context :jsonapi_admin_headers

  after { Cdr::AuthLog.destroy_all }

  describe 'GET index' do
    let!(:auth_logs) do
      create_list :auth_log, 12, :with_id, request_time: 20.minutes.ago.utc
    end
    subject { get :index, params: { filter: filters, page: { number: page_number, size: 10 }, sort: 'id' } }
    let(:filters) do
      {}
    end
    let(:page_number) do
      1
    end

    it 'http status should eq 200' do
      subject
      expect(response.status).to eq(200)
    end

    it 'response should contain valid count of items respects pagination' do
      subject
      expect(response_data.size).to eq(10)
    end

    it 'total-count should be present in meta info' do
      subject
      expect(JSON.parse(response.body)['meta']).to eq(
        'total-count' => auth_logs.size
      )
    end

    context 'get second page' do
      let(:page_number) do
        2
      end

      it 'response should contain valid count of items respects pagination' do
        subject
        expect(response_data.size).to eq(2)
        expect(response_data.map { |auth_log| auth_log['id'].to_i }).to match_array(auth_logs[-2..-1].map(&:id))
      end
    end

    context 'filtering' do
      context 'by request_time_gteq' do
        let(:filters) do
          { 'request-time-gteq' => Time.now.utc.beginning_of_minute }
        end

        let!(:auth_log) do
          create :auth_log, :with_id, request_time: Time.now.utc
        end

        it 'only desired logs should be present' do
          subject
          expect(response_data).to match_array(
            hash_including(
              'id' => auth_log.id.to_s
            )
          )
        end
      end

      context 'by request_time_lteq' do
        let(:filters) do
          { 'request-time-lteq' => 21.minute.ago.utc }
        end

        let!(:auth_log) do
          create :auth_log, :with_id, request_time: 22.minutes.ago.utc
        end

        it 'only desired logs should be present' do
          subject
          expect(response_data).to match_array(
            hash_including(
              'id' => auth_log.id.to_s
            )
          )
        end
      end
    end
  end

  describe 'GET index with ransack filters' do
    let(:factory) { :auth_log }
    let(:trait) { :with_id }

    it_behaves_like :jsonapi_filters_by_datetime_field, :request_time
    it_behaves_like :jsonapi_filters_by_boolean_field, :success, type: :boolean
    it_behaves_like :jsonapi_filters_by_number_field, :code, type: :number
    it_behaves_like :jsonapi_filters_by_string_field, :reason
    it_behaves_like :jsonapi_filters_by_string_field, :internal_reason
    it_behaves_like :jsonapi_filters_by_string_field, :origination_ip
    it_behaves_like :jsonapi_filters_by_number_field, :origination_port, type: :number
    it_behaves_like :jsonapi_filters_by_number_field, :origination_proto_id, type: :number
    it_behaves_like :jsonapi_filters_by_number_field, :transport_proto_id, type: :number
    it_behaves_like :jsonapi_filters_by_string_field, :transport_remote_ip
    it_behaves_like :jsonapi_filters_by_number_field, :transport_remote_port, type: :number
    it_behaves_like :jsonapi_filters_by_string_field, :transport_local_ip
    it_behaves_like :jsonapi_filters_by_number_field, :transport_local_port, type: :number
    it_behaves_like :jsonapi_filters_by_number_field, :pop_id, type: :number
    it_behaves_like :jsonapi_filters_by_number_field, :node_id, type: :number
    it_behaves_like :jsonapi_filters_by_number_field, :gateway_id, type: :number
    it_behaves_like :jsonapi_filters_by_string_field, :username
    it_behaves_like :jsonapi_filters_by_string_field, :realm
    it_behaves_like :jsonapi_filters_by_string_field, :request_method
    it_behaves_like :jsonapi_filters_by_string_field, :ruri
    it_behaves_like :jsonapi_filters_by_string_field, :from_uri
    it_behaves_like :jsonapi_filters_by_string_field, :to_uri
    it_behaves_like :jsonapi_filters_by_string_field, :call_id
    it_behaves_like :jsonapi_filters_by_string_field, :nonce
    it_behaves_like :jsonapi_filters_by_string_field, :response
    it_behaves_like :jsonapi_filters_by_string_field, :x_yeti_auth
    it_behaves_like :jsonapi_filters_by_string_field, :diversion
    it_behaves_like :jsonapi_filters_by_string_field, :pai
    it_behaves_like :jsonapi_filters_by_string_field, :ppi
    it_behaves_like :jsonapi_filters_by_string_field, :privacy
    it_behaves_like :jsonapi_filters_by_string_field, :rpid
    it_behaves_like :jsonapi_filters_by_string_field, :rpid_privacy
  end

  describe 'GET show' do
    let!(:auth_log) do
      create :auth_log, :with_id
    end

    subject do
      get :show, params: {
        id: auth_log.id, include: includes.join(',')
      }
    end
    let(:includes) do
      %w[pop gateway node origination-protocol transport-protocol]
    end

    it 'http status should eq 200' do
      subject
      expect(response.status).to eq(200)
    end

    it 'response body should be valid' do
      subject
      expect(response_data).to match(
        hash_including(
          'id' => auth_log.id.to_s,
          'type' => 'auth-logs',
          'attributes' => {
            'request-time' => auth_log.request_time.iso8601(3),
            'success' => auth_log.success,
            'code' => auth_log.code,
            'reason' => auth_log.reason,
            'internal-reason' => auth_log.internal_reason,
            'origination-ip' => auth_log.origination_ip,
            'origination-port' => auth_log.origination_port,
            'origination-proto-id' => auth_log.origination_proto_id,

            'transport-proto-id' => auth_log.transport_proto_id,
            'transport-remote-ip' => auth_log.transport_remote_ip,
            'transport-remote-port' => auth_log.transport_remote_port,
            'transport-local-ip' => auth_log.transport_local_ip,
            'transport-local-port' => auth_log.transport_local_port,

            'pop-id' => auth_log.pop_id,
            'node-id' => auth_log.node_id,
            'gateway-id' => auth_log.gateway_id,
            'username' => auth_log.username,
            'realm' => auth_log.realm,
            'request-method' => auth_log.request_method,
            'ruri' => auth_log.ruri,
            'from-uri' => auth_log.from_uri,
            'to-uri' => auth_log.to_uri,
            'call-id' => auth_log.call_id,
            'nonce' => auth_log.nonce,
            'response' => auth_log.response,
            'x-yeti-auth' => auth_log.x_yeti_auth,
            'diversion' => auth_log.diversion,
            'pai' => auth_log.pai,
            'ppi' => auth_log.ppi,
            'privacy' => auth_log.privacy,
            'rpid' => auth_log.rpid,
            'rpid-privacy' => auth_log.rpid_privacy
          },
          'relationships' => hash_including(
            'pop' => hash_including(
              'data' => {
                'type' => 'pops',
                'id' => auth_log.pop.id.to_s
              }
            ),
            'gateway' => hash_including(
              'data' => {
                'type' => 'gateways',
                'id' => auth_log.gateway.id.to_s
              }
            ),
            'node' => hash_including(
              'data' => {
                'type' => 'nodes',
                'id' => auth_log.node.id.to_s
              }
            ),
            'origination-protocol' => hash_including(
              'data' => {
                'type' => 'transport-protocols',
                'id' => auth_log.origination_protocol.id.to_s
              }
            ),
            'transport-protocol' => hash_including(
              'data' => {
                'type' => 'transport-protocols',
                'id' => auth_log.transport_protocol.id.to_s
              }
            )
          )
        )
      )
    end
  end

  describe 'POST create' do
    it 'POST should not be routable', type: :routing do
      expect(post: '/api/rest/admin/cdr/auth_logs').to_not be_routable
    end
  end

  describe 'PATCH create' do
    it 'PATCH should not be routable', type: :routing do
      expect(patch: '/api/rest/admin/cdr/auth_logs/123').to_not be_routable
    end
  end

  describe 'DELETE create' do
    it 'DELETE should not be routable', type: :routing do
      expect(delete: '/api/rest/admin/cdr/auth_logs/123').to_not be_routable
    end
  end
end
