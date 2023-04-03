# frozen_string_literal: true

# == Schema Information
#
# Table name: events
#
#  id         :integer(4)       not null, primary key
#  command    :string           not null
#  last_error :string
#  retries    :integer(4)       default(0), not null
#  created_at :datetime         not null
#  updated_at :datetime
#  node_id    :integer(4)       not null
#
# Foreign Keys
#
#  events_node_id_fkey  (node_id => nodes.id)
#
RSpec.describe Event do
  let!(:pop) { create(:pop) }
  let!(:nodes) { create_list(:node, 2, pop: pop) }
  let!(:another_pop) { create(:pop) }
  let!(:another_node) { create(:node, pop: another_pop) }

  let(:event_node1) { Event.find_by(node_id: nodes.first.id) }
  let(:event_node2) { Event.find_by(node_id: nodes.second.id) }
  let(:event_another_node) { Event.find_by(node_id: another_node.id) }
  let(:expected_event_attributes) do
    {
      retries: 0,
      last_error: nil,
      created_at: be_within(10).of(Time.now),
      updated_at: be_within(10).of(Time.now)
    }
  end

  describe '.reload_translations' do
    subject do
      Event.reload_translations
    end

    let(:expected_event_attributes) do
      super().merge command: 'request.router.translations.reload'
    end

    it 'performs jsonrpc request for all nodes' do
      expect { subject }.to change { Event.count }.by(3)
      expect(event_node1).to have_attributes(expected_event_attributes)
      expect(event_node2).to have_attributes(expected_event_attributes)
      expect(event_another_node).to have_attributes(expected_event_attributes)
    end
  end

  describe '.reload_codec_groups' do
    subject do
      Event.reload_codec_groups
    end

    let(:expected_event_attributes) do
      super().merge command: 'request.router.codec-groups.reload'
    end

    it 'performs jsonrpc request for all nodes' do
      expect { subject }.to change { Event.count }.by(3)
      expect(event_node1).to have_attributes(expected_event_attributes)
      expect(event_node2).to have_attributes(expected_event_attributes)
      expect(event_another_node).to have_attributes(expected_event_attributes)
    end
  end

  describe '.reload_radius_auth_profiles' do
    subject do
      Event.reload_radius_auth_profiles
    end

    let(:expected_event_attributes) do
      super().merge command: 'request.radius.authorization.profiles.reload'
    end

    it 'performs jsonrpc request for all nodes' do
      expect { subject }.to change { Event.count }.by(3)
      expect(event_node1).to have_attributes(expected_event_attributes)
      expect(event_node2).to have_attributes(expected_event_attributes)
      expect(event_another_node).to have_attributes(expected_event_attributes)
    end
  end

  describe '.reload_radius_acc_profiles' do
    subject do
      Event.reload_radius_acc_profiles
    end

    let(:expected_event_attributes) do
      super().merge command: 'request.radius.accounting.profiles.reload'
    end

    it 'performs jsonrpc request for all nodes' do
      expect { subject }.to change { Event.count }.by(3)
      expect(event_node1).to have_attributes(expected_event_attributes)
      expect(event_node2).to have_attributes(expected_event_attributes)
      expect(event_another_node).to have_attributes(expected_event_attributes)
    end
  end

  describe '.reload_sensors' do
    subject do
      Event.reload_sensors
    end

    let(:expected_event_attributes) do
      super().merge command: 'request.sensors.reload'
    end

    it 'performs jsonrpc request for all nodes' do
      expect { subject }.to change { Event.count }.by(3)
      expect(event_node1).to have_attributes(expected_event_attributes)
      expect(event_node2).to have_attributes(expected_event_attributes)
      expect(event_another_node).to have_attributes(expected_event_attributes)
    end
  end

  describe '.reload_incoming_auth' do
    subject do
      Event.reload_incoming_auth
    end

    let(:expected_event_attributes) do
      super().merge command: 'request.auth.credentials.reload'
    end

    it 'performs jsonrpc request for all nodes' do
      expect { subject }.to change { Event.count }.by(3)
      expect(event_node1).to have_attributes(expected_event_attributes)
      expect(event_node2).to have_attributes(expected_event_attributes)
      expect(event_another_node).to have_attributes(expected_event_attributes)
    end
  end

  describe '.reload_registrations' do
    subject do
      Event.reload_registrations(event_params)
    end

    let(:expected_event_attributes) do
      super().merge command: "request.registrations.reload #{event_params[:id]}"
    end

    context 'without node_id nor pop_id' do
      let(:event_params) { { pop_id: nil, node_id: nil, id: 123 } }

      it 'performs jsonrpc request for all nodes' do
        expect { subject }.to change { Event.count }.by(3)
        expect(event_node1).to have_attributes(expected_event_attributes)
        expect(event_node2).to have_attributes(expected_event_attributes)
        expect(event_another_node).to have_attributes(expected_event_attributes)
      end
    end

    context 'with node_id' do
      let(:event_params) { { pop_id: nil, node_id: nodes.first.id, id: 123 } }

      it 'performs jsonrpc request only from first pop node' do
        expect { subject }.to change { Event.count }.by(1)
        expect(event_node1).to have_attributes(expected_event_attributes)
        expect(event_node2).to be_nil
        expect(event_another_node).to be_nil
      end
    end

    context 'with pop_id' do
      let(:event_params) { { pop_id: pop.id, node_id: nil, id: 123 } }

      it 'performs jsonrpc request only from pop nodes' do
        expect { subject }.to change { Event.count }.by(2)
        expect(event_node1).to have_attributes(expected_event_attributes)
        expect(event_node2).to have_attributes(expected_event_attributes)
        expect(event_another_node).to be_nil
      end
    end

    context 'with invalid node_id' do
      let(:event_params) { { pop_id: nil, node_id: 999_999_999, id: 123 } }

      it 'performs jsonrpc request for all nodes' do
        expect { subject }.to change { Event.count }.by(0)
        expect(event_node1).to be_nil
        expect(event_node2).to be_nil
        expect(event_another_node).to be_nil
      end
    end

    context 'with invalid pop_id' do
      let(:event_params) { { pop_id: 999_999_999, node_id: nil, id: 123 } }

      it 'performs jsonrpc request for all nodes' do
        expect { subject }.to change { Event.count }.by(0)
        expect(event_node1).to be_nil
        expect(event_node2).to be_nil
        expect(event_another_node).to be_nil
      end
    end
  end

  describe '.reload_sip_options_probers' do
    subject do
      Event.reload_sip_options_probers(**event_params)
    end

    let(:expected_event_attributes) do
      super().merge command: 'request.options_prober.reload'
    end

    context 'without node_id nor pop_id' do
      let(:event_params) { { pop_id: nil, node_id: nil } }

      it 'performs jsonrpc request for all nodes' do
        expect { subject }.to change { Event.count }.by(3)
        expect(event_node1).to have_attributes(expected_event_attributes)
        expect(event_node2).to have_attributes(expected_event_attributes)
        expect(event_another_node).to have_attributes(expected_event_attributes)
      end
    end

    context 'with node_id' do
      let(:event_params) { { pop_id: nil, node_id: nodes.first.id } }

      it 'performs jsonrpc request only from first pop node' do
        expect { subject }.to change { Event.count }.by(1)
        expect(event_node1).to have_attributes(expected_event_attributes)
        expect(event_node2).to be_nil
        expect(event_another_node).to be_nil
      end
    end

    context 'with pop_id' do
      let(:event_params) { { pop_id: pop.id, node_id: nil } }

      it 'performs jsonrpc request only from pop nodes' do
        expect { subject }.to change { Event.count }.by(2)
        expect(event_node1).to have_attributes(expected_event_attributes)
        expect(event_node2).to have_attributes(expected_event_attributes)
        expect(event_another_node).to be_nil
      end
    end

    context 'with invalid node_id' do
      let(:event_params) { { pop_id: nil, node_id: 999_999_999 } }

      it 'performs jsonrpc request for all nodes' do
        expect { subject }.to change { Event.count }.by(0)
        expect(event_node1).to be_nil
        expect(event_node2).to be_nil
        expect(event_another_node).to be_nil
      end
    end

    context 'with invalid pop_id' do
      let(:event_params) { { pop_id: 999_999_999, node_id: nil } }

      it 'performs jsonrpc request for all nodes' do
        expect { subject }.to change { Event.count }.by(0)
        expect(event_node1).to be_nil
        expect(event_node2).to be_nil
        expect(event_another_node).to be_nil
      end
    end
  end
end
