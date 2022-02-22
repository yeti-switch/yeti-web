# frozen_string_literal: true

RSpec.describe ActiveCalls::CreateStats, '.call' do
  subject do
    described_class.call(service_params)
  end

  let(:service_params) do
    {
      calls: calls,
      current_time: 1.minute.ago
    }
  end
  let!(:nodes) do
    FactoryBot.create_list(:node, 5)
  end

  context 'without calls' do
    let!(:calls) { {} }

    it 'creates correct stats' do
      expect { subject }.to change { Stats::ActiveCall.count }.by(nodes.size)

      nodes.each do |node|
        stats = Stats::ActiveCall.where(node_id: node.id).to_a
        expect(stats.size).to eq(1)
        expect(stats.first).to have_attributes(
                                 count: 0,
                                 created_at: be_within(1).of(service_params[:current_time])
                               )
      end
    end
  end

  context 'with calls' do
    let(:calls) do
      {
        nodes.first.id.to_s => [double, double],
        nodes.second.id.to_s => [double],
        nodes.third.id.to_s => [double, double, double, double]
      }
    end

    it 'creates correct stats' do
      expect { subject }.to change { Stats::ActiveCall.count }.by(nodes.size)

      node1_stats = Stats::ActiveCall.where(node_id: nodes.first.id).to_a
      expect(node1_stats.size).to eq(1)
      expect(node1_stats.first).to have_attributes(
                                    count: 2,
                                    created_at: be_within(1).of(service_params[:current_time])
                                  )

      node2_stats = Stats::ActiveCall.where(node_id: nodes.second.id).to_a
      expect(node2_stats.size).to eq(1)
      expect(node2_stats.first).to have_attributes(
                                     count: 1,
                                     created_at: be_within(1).of(service_params[:current_time])
                                   )

      node3_stats = Stats::ActiveCall.where(node_id: nodes.third.id).to_a
      expect(node3_stats.size).to eq(1)
      expect(node3_stats.first).to have_attributes(
                                     count: 4,
                                     created_at: be_within(1).of(service_params[:current_time])
                                   )

      other_nodes = nodes - [nodes.first, nodes.second, nodes.third]
      other_nodes.each do |node|
        stats = Stats::ActiveCall.where(node_id: node.id).to_a
        expect(stats.size).to eq(1)
        expect(stats.first).to have_attributes(
                                 count: 0,
                                 created_at: be_within(1).of(service_params[:current_time])
                               )
      end
    end
  end

  context 'without nodes' do
    let!(:calls) { {} }
    let!(:nodes) { nil }

    it 'does not create any stats' do
      expect { subject }.to change { Stats::ActiveCall.count }.by(0)
    end
  end
end
