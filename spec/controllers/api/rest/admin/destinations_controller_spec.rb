# frozen_string_literal: true

RSpec.describe Api::Rest::Admin::DestinationsController, type: :controller do
  let(:rate_group) { create :rate_group }

  include_context :jsonapi_admin_headers

  describe 'GET index' do
    subject { get :index, params: index_params }

    let(:index_params) { {} }
    let!(:destinations) { create_list :destination, 2, rate_group: rate_group }

    context 'without query params' do
      it 'should return valid response with all destinations' do
        subject
        expect(response.status).to eq(200)
        expect(response_data.size).to eq(destinations.size)
      end
    end

    describe 'sort' do
      context 'by country, network & prefix' do
        let(:destinations) { nil }
        let(:net_type_landline) { System::NetworkType.find_by!(name: 'Landline') }
        let(:net_type_mobile) { System::NetworkType.find_by!(name: 'Mobile') }
        let(:net_type_sp) { System::NetworkType.find_by!(name: 'Supplementary services') }
        let(:net_type_unknown) { System::NetworkType.find_by!(name: 'Unknown') }

        let!(:network_ua_abc) { FactoryBot.create(:network, name: 'ABCUkraineNet', network_type: net_type_mobile) }
        let!(:network_ua_cba) { FactoryBot.create(:network, name: 'UkraineNetCBA', network_type: net_type_landline) }
        let!(:network_ua_wxy) { FactoryBot.create(:network, name: 'UkraineNetWXY', network_type: net_type_unknown) }

        let!(:destination_afghanistan_111_mobile) do
          afghanistan = System::Country.find_by!(name: 'Afghanistan')
          network = FactoryBot.create(:network, name: 'AfghanistanNet', network_type: net_type_mobile)
          network_prefix = FactoryBot.create(:network_prefix, country: afghanistan, network:)
          record = FactoryBot.create(:destination, rate_group: rate_group, prefix: '111')
          record.update!(network_prefix_id: network_prefix.id)
          record
        end

        let!(:destination_ukraine_999_mobile) do
          ukraine = System::Country.find_by!(name: 'Ukraine')
          network = FactoryBot.create(:network, name: 'UkraineNetABC', network_type: net_type_mobile)
          network_prefix = FactoryBot.create(:network_prefix, country: ukraine, network:)
          record = FactoryBot.create(:destination, rate_group: rate_group, prefix: '999')
          record.update!(network_prefix_id: network_prefix.id)
          record
        end

        context 'by name of the country in ascending order' do
          let(:index_params) { { sort: 'country.name' } }

          it 'returns ordered records' do
            subject

            expect(response_body[:errors]).to be_nil
            expect(response_body[:data].pluck(:id)).to eq [destination_afghanistan_111_mobile.id.to_s, destination_ukraine_999_mobile.id.to_s]
          end
        end

        context 'by name of the country in descending order' do
          let(:index_params) { { sort: '-country.name' } }

          it 'returns ordered records' do
            subject

            expect(response_body[:errors]).to be_nil
            expect(response_body[:data].pluck(:id)).to eq [destination_ukraine_999_mobile.id.to_s, destination_afghanistan_111_mobile.id.to_s]
          end
        end

        context 'by country and prefix' do
          let!(:destination_ukraine_555_mobile) do
            ukraine = System::Country.find_by!(name: 'Ukraine')
            network = FactoryBot.create(:network, name: 'UkraineNetBAC', network_type: net_type_mobile)
            network_prefix = FactoryBot.create(:network_prefix, country: ukraine, network:)
            record = FactoryBot.create(:destination, rate_group: rate_group, prefix: '555')
            record.update!(network_prefix_id: network_prefix.id)
            record
          end

          context 'when sort by country name and then by prefix in ASC order' do
            let(:index_params) { { sort: 'country.name,prefix' } }

            it 'returns ordered records' do
              subject

              expect(response_body[:errors]).to be_nil
              expect(response_body[:data].pluck(:id)).to eq [destination_afghanistan_111_mobile.id.to_s, destination_ukraine_555_mobile.id.to_s, destination_ukraine_999_mobile.id.to_s]
              expect(response_body[:data].pluck(:attributes).pluck(:prefix)).to eq %w[111 555 999]
            end
          end

          context 'when sort by prefix in ASC order and then by country name' do
            let(:index_params) { { sort: 'prefix,country.name' } }

            it 'returns ordered records' do
              subject

              expect(response_body[:errors]).to be_nil
              expect(response_body[:data].pluck(:id)).to eq [destination_afghanistan_111_mobile.id.to_s, destination_ukraine_555_mobile.id.to_s, destination_ukraine_999_mobile.id.to_s]
              expect(response_body[:data].pluck(:attributes).pluck(:prefix)).to eq %w[111 555 999]
            end
          end

          context 'when sort by country name in ASC order and then by prefix in DESC order' do
            let(:index_params) { { sort: 'country.name,-prefix' } }

            it 'returns ordered records' do
              subject

              expect(response_body[:errors]).to be_nil
              expect(response_body[:data].pluck(:id)).to eq [destination_afghanistan_111_mobile.id.to_s, destination_ukraine_999_mobile.id.to_s, destination_ukraine_555_mobile.id.to_s]
              expect(response_body[:data].pluck(:attributes).pluck(:prefix)).to eq %w[111 999 555]
            end
          end

          context 'when sort by prefix in DESC order and then by country name' do
            let(:index_params) { { sort: '-prefix,country.name' } }

            it 'returns ordered records' do
              subject

              expect(response_body[:errors]).to be_nil
              expect(response_body[:data].pluck(:id)).to eq [destination_ukraine_999_mobile.id.to_s, destination_ukraine_555_mobile.id.to_s, destination_afghanistan_111_mobile.id.to_s]
              expect(response_body[:data].pluck(:attributes).pluck(:prefix)).to eq %w[999 555 111]
            end
          end
        end

        context 'by country, network and prefix' do
          let!(:destination_ukraine_777_landline) do
            ukraine = System::Country.find_by!(name: 'Ukraine')
            network_prefix = FactoryBot.create(:network_prefix, country: ukraine, network: network_ua_cba)
            record = FactoryBot.create(:destination, rate_group: rate_group, prefix: '777')
            record.update!(network_prefix_id: network_prefix.id)
            record
          end

          let!(:destination_ukraine_444_landline) do
            ukraine = System::Country.find_by!(name: 'Ukraine')
            network_prefix = FactoryBot.create(:network_prefix, country: ukraine, network: network_ua_cba)
            record = FactoryBot.create(:destination, rate_group: rate_group, prefix: '444')
            record.update!(network_prefix_id: network_prefix.id)
            record
          end

          let!(:destination_ukraine_333_mobile) do
            ukraine = System::Country.find_by!(name: 'Ukraine')
            network_prefix = FactoryBot.create(:network_prefix, country: ukraine, network: network_ua_abc)
            record = FactoryBot.create(:destination, rate_group: rate_group, prefix: '333')
            record.update!(network_prefix_id: network_prefix.id)
            record
          end

          context 'when sort by country name and then by prefix in ASC order' do
            let(:index_params) { { sort: 'country.name,network.name,prefix' } }

            it 'returns ordered records' do
              subject

              expect(response_body[:errors]).to be_nil
              expect(response_body[:data].pluck(:id)).to eq([
                                                              destination_afghanistan_111_mobile.id.to_s,
                                                              destination_ukraine_333_mobile.id.to_s,
                                                              destination_ukraine_999_mobile.id.to_s,
                                                              destination_ukraine_444_landline.id.to_s,
                                                              destination_ukraine_777_landline.id.to_s
                                                            ])
              expect(response_body[:data].pluck(:attributes).pluck(:prefix)).to eq(%w[111 333 999 444 777])
            end
          end

          context 'when sort by country name and then by prefix in DESC order' do
            let(:index_params) { { sort: 'country.name,network.name,-prefix' } }

            it 'returns ordered records' do
              subject

              expect(response_body[:errors]).to be_nil
              expect(response_body[:data].pluck(:id)).to eq([
                                                              destination_afghanistan_111_mobile.id.to_s,
                                                              destination_ukraine_333_mobile.id.to_s,
                                                              destination_ukraine_999_mobile.id.to_s,
                                                              destination_ukraine_777_landline.id.to_s,
                                                              destination_ukraine_444_landline.id.to_s
                                                            ])
              expect(response_body[:data].pluck(:attributes).pluck(:prefix)).to eq(%w[111 333 999 777 444])
            end
          end
        end

        context 'by country, network_type and prefix' do
          let!(:destination_ukraine_777_landline) do
            ukraine = System::Country.find_by!(name: 'Ukraine')
            network_prefix = FactoryBot.create(:network_prefix, country: ukraine, network: network_ua_cba)
            record = FactoryBot.create(:destination, rate_group: rate_group, prefix: '777')
            record.update!(network_prefix_id: network_prefix.id)
            record
          end

          let!(:destination_ukraine_444_landline) do
            ukraine = System::Country.find_by!(name: 'Ukraine')
            network_prefix = FactoryBot.create(:network_prefix, country: ukraine, network: network_ua_cba)
            record = FactoryBot.create(:destination, rate_group: rate_group, prefix: '444')
            record.update!(network_prefix_id: network_prefix.id)
            record
          end

          let!(:destination_ukraine_333_mobile) do
            ukraine = System::Country.find_by!(name: 'Ukraine')
            network_prefix = FactoryBot.create(:network_prefix, country: ukraine, network: network_ua_abc)
            record = FactoryBot.create(:destination, rate_group: rate_group, prefix: '333')
            record.update!(network_prefix_id: network_prefix.id)
            record
          end

          let!(:destination_ukraine_33345_mobile) do
            ukraine = System::Country.find_by!(name: 'Ukraine')
            network_prefix = FactoryBot.create(:network_prefix, country: ukraine, network: network_ua_abc)
            record = FactoryBot.create(:destination, rate_group: rate_group, prefix: '33345')
            record.update!(network_prefix_id: network_prefix.id)
            record
          end

          let!(:destination_ukraine_333625_landline) do
            ukraine = System::Country.find_by!(name: 'Ukraine')
            network_prefix = FactoryBot.create(:network_prefix, country: ukraine, network: network_ua_cba)
            record = FactoryBot.create(:destination, rate_group: rate_group, prefix: '333625')
            record.update!(network_prefix_id: network_prefix.id)
            record
          end

          let!(:destination_ukraine_1112_unknown) do
            ukraine = System::Country.find_by!(name: 'Ukraine')
            network_prefix = FactoryBot.create(:network_prefix, country: ukraine, network: network_ua_wxy)
            record = FactoryBot.create(:destination, rate_group: rate_group, prefix: '1112')
            record.update!(network_prefix_id: network_prefix.id)
            record
          end

          context 'when sort by country name, network type and then by prefix in ASC order' do
            let(:index_params) { { sort: 'country.name,network_type.sorting_priority,prefix' } }

            it 'returns ordered records' do
              subject

              expect(response_body[:errors]).to be_nil
              expect(response_body[:data].pluck(:id)).to eq([
                                                              destination_afghanistan_111_mobile.id.to_s,
                                                              destination_ukraine_333625_landline.id.to_s,
                                                              destination_ukraine_444_landline.id.to_s,
                                                              destination_ukraine_777_landline.id.to_s,
                                                              destination_ukraine_333_mobile.id.to_s,
                                                              destination_ukraine_33345_mobile.id.to_s,
                                                              destination_ukraine_999_mobile.id.to_s,
                                                              destination_ukraine_1112_unknown.id.to_s
                                                            ])
              expect(response_body[:data].pluck(:attributes).pluck(:prefix)).to eq(%w[111 333625 444 777 333 33345 999 1112])
            end
          end

          context 'when sort by country name, network type and then by prefix in DESC order' do
            let(:index_params) { { sort: 'country.name,network_type.sorting_priority,-prefix' } }

            it 'returns ordered records' do
              subject

              expect(response_body[:errors]).to be_nil
              expect(response_body[:data].pluck(:id)).to eq([
                                                              destination_afghanistan_111_mobile.id.to_s,
                                                              destination_ukraine_777_landline.id.to_s,
                                                              destination_ukraine_444_landline.id.to_s,
                                                              destination_ukraine_333625_landline.id.to_s,
                                                              destination_ukraine_999_mobile.id.to_s,
                                                              destination_ukraine_33345_mobile.id.to_s,
                                                              destination_ukraine_333_mobile.id.to_s,
                                                              destination_ukraine_1112_unknown.id.to_s
                                                            ])
              expect(response_body[:data].pluck(:attributes).pluck(:prefix)).to eq(%w[111 777 444 333625 999 33345 333 1112])
            end
          end
        end
      end
    end
  end

  describe 'GET index with filters' do
    subject do
      get :index, params: json_api_request_query
    end
    before { create_list :destination, 2 }
    let(:json_api_request_query) { nil }

    it_behaves_like :jsonapi_filter_by_external_id do
      let(:subject_record) { create(:destination) }
    end

    it_behaves_like :jsonapi_filter_by, :prefix do
      include_context :ransack_filter_setup
      let(:filter_key) { :prefix }
      let(:filter_value) { subject_record.prefix }
      let(:subject_record) { create :destination, prefix: attr_value }
      let(:attr_value) { '987' }
    end

    it_behaves_like :jsonapi_filter_by, :rate_group_id do
      include_context :ransack_filter_setup
      let(:filter_key) { :rate_group_id }
      let(:filter_value) { subject_record.rate_group_id }
      let(:subject_record) { create :destination, rate_group: rate_group }
      let(:attr_value) { subject_record.rate_group_id }
    end

    it_behaves_like :jsonapi_filter_by, :rateplan_id_eq do
      include_context :ransack_filter_setup
      let(:filter_key) { :rateplan_id_eq }
      let(:filter_value) { rateplan.id }
      let!(:rateplan) { FactoryBot.create(:rateplan, rate_groups: [rate_group]) }
      let!(:subject_record) { FactoryBot.create(:destination, rate_group: rate_group) }
      let(:attr_value) { rateplan.id }
    end

    it_behaves_like :jsonapi_filter_by, :country_id_eq do
      include_context :ransack_filter_setup
      let(:filter_key) { :country_id_eq }
      let(:filter_value) { country.id }
      let!(:network) { FactoryBot.create(:network_uniq) }
      let!(:network_prefix) { FactoryBot.create(:network_prefix, network:) }
      let!(:country) { network_prefix.country }
      let!(:subject_record) { FactoryBot.create(:destination, prefix: network_prefix.prefix) }
      let(:attr_value) { country.id }
    end
  end

  describe 'GET index with ransack filters' do
    subject do
      get :index, params: json_api_request_query
    end
    let(:factory) { :destination }
    let(:json_api_request_query) { nil }

    it_behaves_like :jsonapi_filters_by_boolean_field, :enabled
    it_behaves_like :jsonapi_filters_by_string_field, :prefix
    it_behaves_like :jsonapi_filters_by_number_field, :next_rate
    it_behaves_like :jsonapi_filters_by_number_field, :connect_fee
    it_behaves_like :jsonapi_filters_by_number_field, :initial_interval
    it_behaves_like :jsonapi_filters_by_number_field, :next_interval
    it_behaves_like :jsonapi_filters_by_number_field, :dp_margin_fixed
    it_behaves_like :jsonapi_filters_by_number_field, :dp_margin_percent
    it_behaves_like :jsonapi_filters_by_number_field, :initial_rate
    it_behaves_like :jsonapi_filters_by_boolean_field, :reject_calls
    it_behaves_like :jsonapi_filters_by_boolean_field, :use_dp_intervals
    it_behaves_like :jsonapi_filters_by_datetime_field, :valid_from
    it_behaves_like :jsonapi_filters_by_datetime_field, :valid_till
    it_behaves_like :jsonapi_filters_by_number_field, :external_id
    it_behaves_like :jsonapi_filters_by_number_field, :asr_limit
    it_behaves_like :jsonapi_filters_by_number_field, :acd_limit
    it_behaves_like :jsonapi_filters_by_number_field, :short_calls_limit
    it_behaves_like :jsonapi_filters_by_boolean_field, :quality_alarm
    it_behaves_like :jsonapi_filters_by_uuid_field, :uuid
    it_behaves_like :jsonapi_filters_by_number_field, :dst_number_min_length
    it_behaves_like :jsonapi_filters_by_number_field, :dst_number_max_length
    it_behaves_like :jsonapi_filters_by_boolean_field, :reverse_billing
  end

  describe 'GET show' do
    let!(:destination) { create :destination }

    context 'when destination exists' do
      before { get :show, params: { id: destination.to_param } }

      it { expect(response.status).to eq(200) }
      it { expect(response_data['id']).to eq(destination.id.to_s) }
    end

    context 'when destination does not exist' do
      before { get :show, params: { id: destination.id + 10 } }

      it { expect(response.status).to eq(404) }
      it { expect(response_data).to eq(nil) }
    end

    context 'include Country' do
      let!(:network) { FactoryBot.create(:network_uniq) }
      let!(:network_prefix) { FactoryBot.create(:network_prefix, network:) }
      let!(:country) { network_prefix.country }
      let!(:destination) { FactoryBot.create(:destination, prefix: network_prefix.prefix) }

      before { get :show, params: { id: destination.to_param, include: 'country' } }

      include_examples :responds_with_status, 200
      include_examples :returns_json_api_record, type: 'destinations', relationships: %i[country network destination-next-rates rate-group routing-tag-mode] do
        let(:json_api_record_id) { destination.id.to_s }
        let(:json_api_record_attributes) do
          hash_including(
            prefix: network_prefix.prefix,
            enabled: true
          )
        end
      end

      include_examples :returns_json_api_record_relationship, :country do
        let(:json_api_relationship_data) { { id: country.id.to_s, type: 'countries' } }
      end

      include_examples :returns_json_api_record_include, type: :countries do
        let(:json_api_include_id) { country.id.to_s }
        let(:json_api_include_attributes) { hash_including(name: country.name, iso2: country.iso2) }
      end
    end
  end

  describe 'POST create' do
    before do
      post :create, params: {
        data: { type: 'destinations',
                attributes: attributes,
                relationships: relationships }
      }
    end

    context 'when attributes are valid' do
      let(:attributes) do
        { prefix: 'test',
          enabled: true,
          'reverse-billing': true,
          'initial-interval': 60,
          'next-interval': 60,
          'initial-rate': 0,
          'next-rate': 0,
          'connect-fee': 0,
          'dp-margin-fixed': 0,
          'dp-margin-percent': 0,
          'profit-control-mode-id': Routing::RateProfitControlMode::MODE_PER_CALL,
          'rate-policy-id': Routing::DestinationRatePolicy::POLICY_MIN }
      end

      let(:relationships) do
        { 'rate-group': wrap_relationship(:'rate-groups', create(:rate_group).id),
          'routing-tag-mode': wrap_relationship(:'routing-tag-modes', 1) }
      end

      it { expect(response.status).to eq(201) }
      it { expect(Routing::Destination.count).to eq(1) }
    end

    context 'when attributes are invalid' do
      let(:attributes) { { prefix: 'test' } }
      let(:relationships) { {} }

      it { expect(response.status).to eq(422) }
      it { expect(Routing::Destination.count).to eq(0) }
    end
  end

  describe 'PUT update' do
    let!(:destination) { create :destination, rate_group: rate_group }
    before do
      put :update, params: {
        id: destination.to_param, data: { type: 'destinations',
                                          id: destination.to_param,
                                          attributes: attributes,
                                          relationships: relationships }
      }
    end

    context 'when attributes are valid' do
      let(:attributes) { { prefix: 'test' } }
      let(:relationships) { {} }

      it { expect(response.status).to eq(200) }
      it { expect(destination.reload.prefix).to eq('test') }
    end

    context 'when attributes are invalid' do
      let(:attributes) { { prefix: 'test' } }
      let(:relationships) do
        { 'rate-group': wrap_relationship(:'rate-groups', nil) }
      end

      it { expect(response.status).to eq(422) }
      it { expect(destination.reload.prefix).to_not eq('test') }
    end
  end

  describe 'DELETE destroy' do
    let!(:destination) { create :destination, rate_group: rate_group }

    before { delete :destroy, params: { id: destination.to_param } }

    it { expect(response.status).to eq(204) }
    it { expect(Routing::Destination.count).to eq(0) }
  end

  describe 'editable routing_tag_ids' do
    include_examples :jsonapi_resource_with_routing_tag_ids do
      let(:resource_type) { 'destinations' }
      let(:factory_name) { :destination }
    end
  end
end
