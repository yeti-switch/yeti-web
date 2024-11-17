# frozen_string_literal: true

RSpec.describe Api::Rest::Admin::CdrsController, type: :request do
  include_context :json_api_admin_helpers, type: :cdrs

  describe 'GET /api/rest/admin/cdrs' do
    subject do
      get json_api_request_path, params: json_api_request_params, headers: json_api_request_headers
    end

    let(:json_api_request_params) { nil }

    let!(:cdrs) do
      FactoryBot.create_list(:cdr, 2)
    end

    include_examples :jsonapi_responds_with_pagination_links
    include_examples :returns_json_api_collection do
      let(:json_api_collection_ids) do
        cdrs.map { |r| r.id.to_s }
      end
    end

    it_behaves_like :json_api_admin_check_authorization

    context 'with filters' do
      let(:json_api_request_params) do
        { filter: filter }
      end

      context 'by src_prefix_in_eq' do
        let(:filter) { { src_prefix_in_eq: '111111111111' } }
        let!(:record) { FactoryBot.create(:cdr, src_prefix_in: '111111111111') }

        include_examples :returns_json_api_collection do
          let(:json_api_collection_ids) { [record.id.to_s] }
        end
      end

      context 'by src_prefix_in_contains' do
        let(:filter) { { src_prefix_in_contains: '11111' } }
        let!(:record) { FactoryBot.create(:cdr, src_prefix_in: '111111111111') }

        include_examples :returns_json_api_collection do
          let(:json_api_collection_ids) { [record.id.to_s] }
        end
      end

      context 'by src_prefix_routing_eq' do
        let(:filter) { { src_prefix_routing_eq: '111111111111' } }
        let!(:record) { FactoryBot.create(:cdr, src_prefix_routing: '111111111111') }

        include_examples :returns_json_api_collection do
          let(:json_api_collection_ids) { [record.id.to_s] }
        end
      end

      context 'by src_prefix_routing_contains' do
        let(:filter) { { src_prefix_routing_contains: '111111' } }
        let!(:record) { FactoryBot.create(:cdr, src_prefix_routing: '111111111111') }

        include_examples :returns_json_api_collection do
          let(:json_api_collection_ids) { [record.id.to_s] }
        end
      end

      context 'by dst_prefix_routing_eq' do
        let(:filter) { { dst_prefix_routing_eq: '111111111111' } }
        let!(:record) { FactoryBot.create(:cdr, dst_prefix_routing: '111111111111') }

        include_examples :returns_json_api_collection do
          let(:json_api_collection_ids) { [record.id.to_s] }
        end
      end

      context 'by dst_prefix_routing_contains' do
        let(:filter) { { dst_prefix_routing_contains: '11111' } }
        let!(:record) { FactoryBot.create(:cdr, dst_prefix_routing: '111111111111') }

        include_examples :returns_json_api_collection do
          let(:json_api_collection_ids) { [record.id.to_s] }
        end
      end
    end
  end

  describe 'GET /api/rest/admin/:id/recording' do
    subject do
      get json_api_request_path, params: nil, headers: { 'Authorization' => json_api_auth_token }
    end

    let(:json_api_request_path) { "#{super()}/#{record_id}/recording" }
    let(:record_id) { cdr.id.to_s }

    let!(:cdr) { create(:cdr, audio_recorded: true) }

    it 'responds with X-Accel-Redirect' do
      subject
      expect(response.status).to eq 200
      expect(response.body).to be_blank
      expect(response.headers['X-Accel-Redirect']).to eq "/record/#{cdr.local_tag}.mp3"
      expect(response.headers['Content-Type']).to eq 'audio/mpeg'
    end

    context 'when audio not recorded' do
      let!(:cdr) { create(:cdr, audio_recorded: false) }

      it 'responds 404' do
        subject
        expect(response.status).to eq 404
        expect(response.body).to be_blank
        expect(response.headers['X-Accel-Redirect']).to be_nil
        expect(response.headers['Content-Disposition']).to be_nil
      end
    end
  end

  describe 'GET /api/rest/admin/cdrs/:id/vendor' do
    subject do
      get json_api_request_path, params: json_api_request_params, headers: json_api_request_headers
    end

    let(:json_api_request_path) { "#{super()}/#{record_id}/vendor" }
    let(:record_id) { cdr.id.to_s }
    let(:json_api_request_params) { nil }

    let!(:cdr) do
      create :cdr, :with_id
    end

    it 'responds correctly', :aggregate_failures do
      subject
      expect(response).to have_http_status(200)
      expect(response_json).to match(
                                 data: hash_including(
                                   id: cdr.vendor.id.to_s,
                                   type: 'contractors',
                                   attributes: be_present,
                                   relationships: be_present
                                 )
                               )
    end
  end
end
