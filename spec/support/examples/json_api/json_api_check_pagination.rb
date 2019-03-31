# frozen_string_literal: true

RSpec.shared_examples :json_api_check_pagination do
  # let(:records_ids) required
  # let(:records_qty) required (override should affects records_ids qty)

  context 'with pagination page 1 size 10' do
    let(:json_api_request_query) { (super() || {}).merge page: { number: 1, size: 10 } }
    let(:records_qty) { 12 }

    it 'returns records of this customer' do
      subject
      expect(response.status).to eq(200)
      expect(response_json[:meta]).to eq('total-count': records_qty)
      expect(response_json[:data]).to match_array(
        records_ids.first(10).map do |id|
          hash_including(id: id)
        end
      )
    end
  end

  context 'with pagination page 2 size 10' do
    let(:json_api_request_query) { (super() || {}).merge page: { number: 2, size: 10 } }
    let(:records_qty) { 12 }

    it 'returns 2 records from 12 total' do
      subject
      expect(response.status).to eq(200)
      expect(response_json[:meta]).to eq('total-count': records_qty)
      expect(response_json[:data]).to match_array(
        records_ids.last(2).map do |id|
          hash_including(id: id)
        end
      )
    end
  end

  context 'with pagination page 1 size default' do
    let(:json_api_request_query) { (super() || {}).merge page: { number: 1 } }
    let(:records_qty) { 51 }

    it 'returns 50 records from 51 total' do
      subject
      expect(response.status).to eq(200)
      expect(response_json[:meta]).to eq('total-count': records_qty)
      expect(response_json[:data]).to match_array(
        records_ids.first(50).map do |id|
          hash_including(id: id)
        end
      )
    end
  end

  context 'with pagination page default size default' do
    let(:records_qty) { 51 }

    it 'returns 50 records from 51 total' do
      subject
      expect(response.status).to eq(200)
      expect(response_json[:meta]).to eq('total-count': records_qty)
      expect(response_json[:data]).to match_array(
        records_ids.first(50).map do |id|
          hash_including(id: id)
        end
      )
    end
  end
end
