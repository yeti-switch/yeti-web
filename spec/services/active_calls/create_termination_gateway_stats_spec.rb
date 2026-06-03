# frozen_string_literal: true

RSpec.describe ActiveCalls::CreateTerminationGatewayStats, '.call' do
  subject do
    described_class.call(service_params)
  end

  let(:service_params) do
    {
      calls: calls,
      current_time: 1.minute.ago
    }
  end
  let!(:gateways) do
    FactoryBot.create_list(:gateway, 5)
  end

  context 'without calls' do
    let!(:calls) { {} }

    it 'does not create stats for gateways without calls' do
      expect { subject }.to change { Stats::ActiveCallTermGateway.count }.by(0)
    end
  end

  context 'with calls' do
    let(:calls) do
      {
        gateways.first.id.to_s => [double, double],
        gateways.second.id.to_s => [double],
        gateways.third.id.to_s => [double, double, double, double]
      }
    end

    it 'creates a row only for gateways with calls' do
      expect { subject }.to change { Stats::ActiveCallTermGateway.count }.by(3)

      gateway1_stats = Stats::ActiveCallTermGateway.where(gateway_id: gateways.first.id).to_a
      expect(gateway1_stats.size).to eq(1)
      expect(gateway1_stats.first).to have_attributes(
                                    count: 2,
                                    created_at: be_within(1).of(service_params[:current_time])
                                  )

      gateway2_stats = Stats::ActiveCallTermGateway.where(gateway_id: gateways.second.id).to_a
      expect(gateway2_stats.size).to eq(1)
      expect(gateway2_stats.first).to have_attributes(
                                     count: 1,
                                     created_at: be_within(1).of(service_params[:current_time])
                                   )

      gateway3_stats = Stats::ActiveCallTermGateway.where(gateway_id: gateways.third.id).to_a
      expect(gateway3_stats.size).to eq(1)
      expect(gateway3_stats.first).to have_attributes(
                                     count: 4,
                                     created_at: be_within(1).of(service_params[:current_time])
                                   )

      other_gateways = gateways - [gateways.first, gateways.second, gateways.third]
      other_gateways.each do |gateway|
        expect(Stats::ActiveCallTermGateway.where(gateway_id: gateway.id)).to be_empty
      end
    end
  end

  context 'without gateways' do
    let!(:calls) { {} }
    let!(:gateways) { nil }

    it 'does not create any stats' do
      expect { subject }.to change { Stats::ActiveCallTermGateway.count }.by(0)
    end
  end
end
