# frozen_string_literal: true

RSpec.describe Api::Rest::Admin::ActiveCallsController, type: :request do
  include_context :json_api_admin_helpers, type: :'active-calls'
  let!(:node) { FactoryBot.create(:node) }

  describe 'GET /api/rest/admin/active-calls' do
    subject do
      get json_api_request_path, params: json_api_request_params, headers: json_api_request_headers
    end

    let(:json_api_request_params) { nil }

    let!(:stub_jrpc_req) do
      cdrs_filter_stub = instance_double(Yeti::CdrsFilter)
      expect(Yeti::CdrsFilter).to receive(:new).with(Node.all, {}).and_return(cdrs_filter_stub)
      expect(cdrs_filter_stub).to receive(:search).with(only: nil, empty_on_error: true)
                                                  .and_return(active_calls.map(&:stringify_keys))
    end

    it_behaves_like :json_api_admin_check_authorization do
      let!(:stub_jrpc_req) { nil }
      let(:when_valid_auth) do
        cdrs_filter_stub = instance_double(Yeti::CdrsFilter)
        expect(Yeti::CdrsFilter).to receive(:new).with(Node.all, {}).and_return(cdrs_filter_stub)
        active_calls = [FactoryBot.attributes_for(:active_call, :filled, node_id: node.id)]
        expect(cdrs_filter_stub).to receive(:search).with(only: nil, empty_on_error: true)
                                                    .and_return(active_calls.map(&:stringify_keys))
      end
    end

    context 'with 2 calls' do
      let(:active_calls) do
        [
          FactoryBot.attributes_for(:active_call, :filled, node_id: node.id),
          FactoryBot.attributes_for(:active_call, :filled, node_id: node.id)
        ]
      end
      let(:active_calls_ids) { active_calls.map { |r| "#{node.id}*#{r[:local_tag]}" } }

      include_examples :responds_with_status, 200

      it 'has not pagination' do
        subject
        expect(response_json[:links]).to be_nil
      end

      include_examples :returns_json_api_collection do
        let(:json_api_collection_ids) { active_calls_ids }
      end

      context 'include node' do
        let(:json_api_request_params) { { include: 'node' } }

        include_examples :responds_with_status, 200
        include_examples :returns_json_api_collection do
          let(:json_api_collection_ids) { active_calls_ids }
        end

        context 'check node' do
          include_examples :returns_json_api_record_relationship, :node do
            let(:json_api_record_data) { response_json[:data].first }
            let(:json_api_relationship_data) { { id: node.id.to_s, type: 'nodes' } }
          end
          include_examples :returns_json_api_record_include, type: :nodes do
            let(:json_api_include_id) { node.id.to_s }
            let(:json_api_include_attributes) { hash_including(name: node.name) }
            let(:json_api_include_relationships_names) { nil }
          end
        end
      end

      context 'with include node,customer.smtp-connection' do
        let(:json_api_request_params) { { include: 'node,customer.smtp-connection' } }
        let(:active_calls) do
          result = super()
          result.first[:customer_id] = customer.id
          result
        end

        let!(:smtp_connection) { FactoryBot.create(:smtp_connection) }
        let!(:customer) { FactoryBot.create(:customer, smtp_connection: smtp_connection) }

        include_examples :responds_with_status, 200
        include_examples :returns_json_api_collection do
          let(:json_api_collection_ids) { active_calls_ids }
        end

        context 'check node' do
          include_examples :returns_json_api_record_relationship, :node do
            let(:json_api_record_data) { response_json[:data].first }
            let(:json_api_relationship_data) { { id: node.id.to_s, type: 'nodes' } }
          end
          include_examples :returns_json_api_record_include, type: :nodes do
            let(:json_api_include_id) { node.id.to_s }
            let(:json_api_include_attributes) { hash_including(name: node.name) }
            let(:json_api_include_relationships_names) { nil }
          end
        end

        context 'check customer' do
          include_examples :returns_json_api_record_relationship, :customer do
            let(:json_api_record_data) { response_json[:data].first }
            let(:json_api_relationship_data) { { id: customer.id.to_s, type: 'contractors' } }
          end
          include_examples :returns_json_api_record_include, type: :contractors do
            let(:json_api_include_id) { customer.id.to_s }
            let(:json_api_include_attributes) { hash_including(name: customer.name) }
            let(:json_api_include_relationships_names) { [:'smtp-connection'] }
          end
        end

        context 'check smtp_connection' do
          include_examples :returns_json_api_record_relationship, :'smtp-connection' do
            let(:json_api_record_data) { response_json[:included].detect { |r| r[:type] == 'contractors' } }
            let(:json_api_relationship_data) { { id: smtp_connection.id.to_s, type: 'smtp-connections' } }
          end
          include_examples :returns_json_api_record_include, type: :'smtp-connections' do
            let(:json_api_include_id) { smtp_connection.id.to_s }
            let(:json_api_include_attributes) { hash_including(name: smtp_connection.name) }
            let(:json_api_include_relationships_names) { nil }
          end
        end
      end

      context 'with include customer-acc' do
        let(:json_api_request_params) { { include: 'customer-acc' } }
        let(:active_calls) do
          result = super()
          result.first[:customer_acc_id] = account.id
          result
        end

        let!(:account) { FactoryBot.create(:account) }

        include_examples :responds_with_status, 200
        include_examples :returns_json_api_collection do
          let(:json_api_collection_ids) { active_calls_ids }
        end
        include_examples :returns_json_api_record_relationship, :'customer-acc' do
          let(:json_api_record_data) { response_json[:data].first }
          let(:json_api_relationship_data) { { id: account.id.to_s, type: 'accounts' } }
        end
        include_examples :returns_json_api_record_include, type: :accounts do
          let(:json_api_include_id) { account.id.to_s }
          let(:json_api_include_attributes) { hash_including(name: account.name) }
        end
      end

      context 'with include vendor-acc.contractor' do
        let(:json_api_request_params) { { include: 'vendor-acc.contractor' } }
        let(:active_calls) do
          result = super()
          result.first[:vendor_acc_id] = account.id
          result
        end

        let!(:vendor) { FactoryBot.create(:vendor) }
        let!(:account) { FactoryBot.create(:account, contractor: vendor) }

        include_examples :responds_with_status, 200
        include_examples :returns_json_api_collection do
          let(:json_api_collection_ids) { active_calls_ids }
        end
        it_behaves_like :returns_json_api_record_relationship, :'vendor-acc' do
          let(:json_api_record_data) { response_json[:data].first }
          let(:json_api_relationship_data) { { id: account.id.to_s, type: 'accounts' } }
        end
        it_behaves_like :returns_json_api_record_include, type: :accounts do
          let(:json_api_include_id) { account.id.to_s }
          let(:json_api_include_attributes) { hash_including(name: account.name) }
        end
        it_behaves_like :returns_json_api_record_relationship, :contractor do
          let(:json_api_record_data) { response_json[:included].detect { |r| r[:type] == 'accounts' } }
          let(:json_api_relationship_data) { { id: vendor.id.to_s, type: 'contractors' } }
        end
        it_behaves_like :returns_json_api_record_include, type: :contractors do
          let(:json_api_include_id) { vendor.id.to_s }
          let(:json_api_include_attributes) { hash_including(name: vendor.name) }
        end
      end
    end

    context 'without active calls' do
      let(:active_calls) { [] }

      include_examples :responds_with_status, 200
      it 'responds with empty collection' do
        subject
        expect(response_json[:data]).to eq []
      end
    end
  end

  describe 'GET /api/rest/admin/active-calls/{id}' do
    subject do
      get json_api_request_path, params: json_api_request_params, headers: json_api_request_headers
    end

    let(:json_api_request_path) { "#{super()}/#{record_id}" }
    let(:json_api_request_params) { nil }
    let(:record_id) { "#{node.id}*#{local_tag}" }
    let(:local_tag) { active_call[:local_tag] }

    let!(:stub_jrpc_req) do
      stub_jrpc_connect(node.rpc_endpoint)
      expect_any_instance_of(NodeApi).to receive(:calls).with(local_tag).once.and_return(active_call)
    end

    let(:active_call) { FactoryBot.attributes_for(:active_call, :filled, node_id: node.id) }

    rels = %i[
      customer vendor customer-acc vendor-acc customer-auth destination dialpeer
      orig-gw term-gw routing-group rateplan destination-rate-policy node
    ]

    it_behaves_like :json_api_admin_check_authorization do
      let!(:stub_jrpc_req) { nil }
      let(:when_valid_auth) do
        stub_jrpc_connect(node.rpc_endpoint)
        expect_any_instance_of(NodeApi).to receive(:calls).with(local_tag).once.and_return(active_call)
      end
    end

    context 'without includes' do
      include_examples :responds_with_status, 200
      include_examples :returns_json_api_record, relationships: rels do
        let(:json_api_record_id) { record_id }
        let(:json_api_record_attributes) do
          hash_including(
            'local-tag': local_tag,
            duration: active_call[:duration].to_i,
            'start-time': Time.at(active_call[:start_time].to_i).in_time_zone.as_json,
            'connect-time': Time.at(active_call[:connect_time].to_i).in_time_zone.as_json
          )
        end
      end
    end

    context 'with include node' do
      let(:json_api_request_params) { { include: 'node' } }

      include_examples :responds_with_status, 200
      include_examples :returns_json_api_record, relationships: rels do
        let(:json_api_record_id) { record_id }
        let(:json_api_record_attributes) { hash_including('local-tag': local_tag) }
      end

      context 'check node' do
        include_examples :returns_json_api_record_relationship, :node do
          let(:json_api_relationship_data) { { id: node.id.to_s, type: 'nodes' } }
        end
        include_examples :returns_json_api_record_include, type: :nodes do
          let(:json_api_include_id) { node.id.to_s }
          let(:json_api_include_attributes) { hash_including(name: node.name) }
          let(:json_api_include_relationships_names) { nil }
        end
      end
    end

    context 'with include node,customer.smtp-connection' do
      let(:json_api_request_params) { { include: 'node,customer.smtp-connection' } }
      let(:active_call) { super().merge(customer_id: customer.id) }

      let!(:smtp_connection) { FactoryBot.create(:smtp_connection) }
      let!(:customer) { FactoryBot.create(:customer, smtp_connection: smtp_connection) }

      include_examples :responds_with_status, 200
      include_examples :returns_json_api_record, relationships: rels do
        let(:json_api_record_id) { record_id }
        let(:json_api_record_attributes) { hash_including('local-tag': local_tag) }
      end

      context 'check node' do
        include_examples :returns_json_api_record_relationship, :node do
          let(:json_api_relationship_data) { { id: node.id.to_s, type: 'nodes' } }
        end
        include_examples :returns_json_api_record_include, type: :nodes do
          let(:json_api_include_id) { node.id.to_s }
          let(:json_api_include_attributes) { hash_including(name: node.name) }
          let(:json_api_include_relationships_names) { nil }
        end
      end

      context 'check customer' do
        include_examples :returns_json_api_record_relationship, :customer do
          let(:json_api_relationship_data) { { id: customer.id.to_s, type: 'contractors' } }
        end
        include_examples :returns_json_api_record_include, type: :contractors do
          let(:json_api_include_id) { customer.id.to_s }
          let(:json_api_include_attributes) { hash_including(name: customer.name) }
          let(:json_api_include_relationships_names) { [:'smtp-connection'] }
        end
      end

      context 'check smtp_connection' do
        include_examples :returns_json_api_record_relationship, :'smtp-connection' do
          let(:json_api_record_data) { response_json[:included].detect { |r| r[:type] == 'contractors' } }
          let(:json_api_relationship_data) { { id: smtp_connection.id.to_s, type: 'smtp-connections' } }
        end
        include_examples :returns_json_api_record_include, type: :'smtp-connections' do
          let(:json_api_include_id) { smtp_connection.id.to_s }
          let(:json_api_include_attributes) { hash_including(name: smtp_connection.name) }
          let(:json_api_include_relationships_names) { nil }
        end
      end
    end
  end

  describe 'DELETE /api/rest/admin/active-calls/{id}' do
    subject do
      delete json_api_request_path, headers: json_api_request_headers
    end

    let(:json_api_request_path) { "#{super()}/#{record_id}" }
    let(:json_api_request_params) { nil }
    let(:record_id) { "#{node.id}*#{local_tag}" }
    let(:local_tag) { active_call[:local_tag] }
    let(:active_call) { FactoryBot.attributes_for(:active_call, :filled, node_id: node.id) }

    before do
      stub_jrpc_connect(node.rpc_endpoint)
      expect_any_instance_of(NodeApi).to receive(:calls).with(local_tag).once.and_return(active_call)
      expect_any_instance_of(NodeApi).to receive(:call_disconnect).with(local_tag).once
    end

    include_examples :responds_with_status, 204
  end
end
