# frozen_string_literal: true

RSpec.describe Api::Rest::Dns::ZonesController, type: :request do
  let(:json_api_resource_type) { 'zones' }
  let(:json_api_request_path) { "/api/rest/dns/#{json_api_resource_type}" }
  let(:json_api_request_headers) do
    {
      'Accept' => JSONAPI::MEDIA_TYPE,
      'Content-Type' => JSONAPI::MEDIA_TYPE
    }
  end

  describe 'GET /api/rest/dns/zones' do
    subject do
      get json_api_request_path, params: json_api_request_query, headers: json_api_request_headers
    end

    let(:json_api_request_query) { nil }

    context 'when we GET without any query params' do
      let(:records_qty) { 8 }
      let!(:zones) do
        create_list(:dns_zone, records_qty)
      end

      include_examples :jsonapi_responds_with_pagination_links
      include_examples :returns_json_api_collection do
        let(:json_api_collection_ids) { zones.map { |zone| zone.id.to_s } }
      end

      it 'returns only required attributes' do
        subject
        attributes_list = response_json[:data].pluck(:attributes)
        expect(attributes_list).to all(
          match(name: be_present, serial: be_a(Integer))
        )
        expect(attributes_list.map(&:keys)).to all(match_array(%i[name serial]))
      end

      it_behaves_like :json_api_check_pagination do
        let(:records_ids) { zones.sort_by(&:id).map { |zone| zone.id.to_s } }
      end
    end

    context 'with filters' do
      let!(:target_zone) { create(:dns_zone, name: 'example-zone.tld', serial: 200) }
      before { create(:dns_zone, name: 'another-zone.tld', serial: 300) }

      let(:json_api_request_query) do
        { filter: { name_cont: 'example-zone' } }
      end

      include_examples :returns_json_api_collection do
        let(:json_api_collection_ids) { [target_zone.id.to_s] }
      end
    end

    context 'with sorting by all attributes at once' do
      let!(:zone_first) { create(:dns_zone, name: 'zone-b.tld', serial: 100) }
      let!(:zone_second) { create(:dns_zone, name: 'zone-a.tld', serial: 100) }
      let!(:zone_third) { create(:dns_zone, name: 'zone-c.tld', serial: 200) }

      let(:json_api_request_query) do
        { sort: 'serial,name,id' }
      end

      include_examples :returns_json_api_collection, respect_sorting: true do
        let(:json_api_collection_ids) do
          [zone_first, zone_second, zone_third]
            .sort_by { |zone| [zone.serial, zone.name, zone.id] }
            .map { |zone| zone.id.to_s }
        end
      end
    end

    context 'with filters together' do
      let!(:target_zone) { create(:dns_zone, name: 'filtered-zone.tld', serial: 777) }
      before { create(:dns_zone, name: 'filtered-zone-2.tld', serial: 777) }

      let(:json_api_request_query) do
        {
          filter: {
            id_eq: target_zone.id,
            name_cont: 'filtered-zone',
            serial_eq: target_zone.serial
          }
        }
      end

      include_examples :returns_json_api_collection do
        let(:json_api_collection_ids) { [target_zone.id.to_s] }
      end
    end

    context 'with filters together and sorting by all attributes at once' do
      let!(:zone_first) { create(:dns_zone, name: 'alpha-zone.tld', serial: 100) }
      let!(:zone_second) { create(:dns_zone, name: 'alpha-zone-2.tld', serial: 100) }
      let!(:zone_third) { create(:dns_zone, name: 'beta-zone.tld', serial: 100) }
      before { create(:dns_zone, name: 'gamma-zone.tld', serial: 200) }

      let(:json_api_request_query) do
        {
          filter: {
            serial_eq: 100,
            name_cont: 'alpha',
            id_not_eq: zone_third.id
          },
          sort: 'serial,name,id'
        }
      end

      include_examples :returns_json_api_collection, respect_sorting: true do
        let(:json_api_collection_ids) do
          [zone_first, zone_second]
            .sort_by { |zone| [zone.serial, zone.name, zone.id] }
            .map { |zone| zone.id.to_s }
        end
      end
    end

    context 'with invalid Authorization header' do
      let(:json_api_request_headers) do
        super().merge('Authorization' => 'invalid')
      end
      let!(:zones) { create_list(:dns_zone, 2) }

      include_examples :returns_json_api_collection do
        let(:json_api_collection_ids) { zones.map { |zone| zone.id.to_s } }
      end
    end
  end
end
