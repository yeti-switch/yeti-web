# frozen_string_literal: true

RSpec.describe Api::Rest::Admin::RateGroupsController, type: :controller do
  include_context :jsonapi_admin_headers

  describe 'GET index' do
    subject { get :index }

    let!(:first_rateplan) { FactoryBot.create(:rateplan) }
    let!(:second_rateplan) { FactoryBot.create(:rateplan) }
    let!(:records) do
      [
        FactoryBot.create(:rate_group, rateplans: [first_rateplan]),
        FactoryBot.create(:rate_group, rateplans: [second_rateplan])
      ]
    end

    context 'when valid data' do
      it 'returns the list of rate groups' do
        subject

        expect(response_body[:errors]).to be_nil
        expect(response.status).to eq(200)
        expect(response_body.fetch(:data).size).to eq(records.size)
        expect(response_body.fetch(:data).pluck(:id)).to match_array(records.pluck(:id).map(&:to_s))
        expect(response_body.dig(:data, 0, :relationships)).to match rateplans: { links: { related: be_present } }
      end
    end

    context 'when include rateplans' do
      subject { get :index, params: { include: 'rateplans' } }

      it 'returns the list of rate groups with rateplans' do
        subject

        expect(response_body[:errors]).to be_nil
        expect(response.status).to eq(200)
        expect(response_body.fetch(:data).size).to eq(records.size)
        expect(response_body.fetch(:data).pluck(:id)).to match_array(records.pluck(:id).map(&:to_s))
        expect(response_body.dig(:data, 0, :relationships)).to match rateplans: { links: be_present, data: be_present }
      end
    end
  end

  describe 'GET show' do
    before { get :show, params: { id: record.to_param } }

    context 'when valid data' do
      let!(:record) { FactoryBot.create(:rate_group) }

      it 'returns the requested rate group' do
        subject

        expect(response_body[:errors]).to be_nil
        expect(response.status).to eq(200)
        expect(response_body.dig(:data, :id)).to eq(record.id.to_s)
        expect(response_body.dig(:data, :relationships)).to match rateplans: { links: { related: be_present } }
      end
    end
  end
end
