# frozen_string_literal: true

# == Schema Information
#
# Table name: class4.sip_options_probers
#
#  id                          :integer(4)       not null, primary key
#  append_headers              :string
#  auth_password               :string
#  auth_username               :string
#  contact_uri                 :string
#  enabled                     :boolean          default(TRUE), not null
#  from_uri                    :string
#  interval                    :integer(2)       default(60), not null
#  name                        :string           not null
#  proxy                       :string
#  ruri_domain                 :string           not null
#  ruri_username               :string           not null
#  sip_interface_name          :string
#  to_uri                      :string
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  external_id                 :bigint(8)
#  node_id                     :integer(2)
#  pop_id                      :integer(2)
#  proxy_transport_protocol_id :integer(2)       default(1), not null
#  sip_schema_id               :integer(2)       default(1), not null
#  transport_protocol_id       :integer(2)       default(1), not null
#
# Indexes
#
#  index_class4.sip_options_probers_on_external_id  (external_id) UNIQUE
#  sip_options_probers_name_key                     (name) UNIQUE
#
# Foreign Keys
#
#  sip_options_probers_node_id_fkey                      (node_id => nodes.id)
#  sip_options_probers_pop_id_fkey                       (pop_id => pops.id)
#  sip_options_probers_proxy_transport_protocol_id_fkey  (proxy_transport_protocol_id => transport_protocols.id)
#  sip_options_probers_sip_schema_id_fkey                (sip_schema_id => sip_schemas.id)
#  sip_options_probers_transport_protocol_id_fkey        (transport_protocol_id => transport_protocols.id)
#
RSpec.describe Equipment::SipOptionsProber do
  describe '.create' do
    subject do
      Equipment::SipOptionsProber.create(create_params)
    end

    let!(:pop) { create(:pop) }
    let!(:node) { create(:node, pop: pop) }

    let(:create_params) do
      {
        name: 'test',
        ruri_domain: 'example.com',
        ruri_username: 'rspec'
      }
    end

    context 'without node and without pop' do
      include_examples :calls_event_with, :reload_sip_options_probers do
        let(:event_meth_arguments) { { node_id: nil, pop_id: nil } }
      end

      include_examples :creates_record
      include_examples :changes_records_qty_of, Equipment::SipOptionsProber, by: 1
    end

    context 'with node_id' do
      let(:create_params) { super().merge node_id: node.id }

      include_examples :calls_event_with, :reload_sip_options_probers do
        let(:event_meth_arguments) { { node_id: node.id, pop_id: nil } }
      end

      include_examples :creates_record
      include_examples :changes_records_qty_of, Equipment::SipOptionsProber, by: 1
    end

    context 'with pop_id' do
      let(:create_params) { super().merge pop_id: pop.id }

      include_examples :calls_event_with, :reload_sip_options_probers do
        let(:event_meth_arguments) { { node_id: nil, pop_id: pop.id } }
      end

      include_examples :creates_record
      include_examples :changes_records_qty_of, Equipment::SipOptionsProber, by: 1
    end

    context 'without attributes' do
      let(:create_params) { {} }

      include_examples :does_not_call_event_with, :reload_sip_options_probers
      include_examples :does_not_create_record, errors: {
        name: ["can't be blank"],
        ruri_domain: ["can't be blank"],
        ruri_username: ["can't be blank"]
      }
    end
  end

  describe '#update' do
    subject do
      record.update(update_params)
    end

    let!(:pop) { create(:pop) }
    let!(:node) { create(:node, pop: pop) }
    let!(:record) { create(:sip_options_prober, record_attrs) }
    let(:record_attrs) { {} }

    context 'with name' do
      let(:update_params) { { name: 'new name' } }

      context 'when record does not have pop nor node' do
        include_examples :calls_event_with, :reload_sip_options_probers do
          let(:event_meth_arguments) { { node_id: nil, pop_id: nil } }
        end

        include_examples :updates_record
      end

      context 'when record has node' do
        let(:record_attrs) { { node: node } }

        include_examples :calls_event_with, :reload_sip_options_probers do
          let(:event_meth_arguments) { { node_id: node.id, pop_id: nil } }
        end

        include_examples :updates_record
      end

      context 'when record has pop' do
        let(:record_attrs) { { pop: pop } }

        include_examples :calls_event_with, :reload_sip_options_probers do
          let(:event_meth_arguments) { { node_id: nil, pop_id: pop.id } }
        end

        include_examples :updates_record
      end
    end

    context 'with pop_id' do
      let!(:new_pop) { create(:pop) }
      let(:update_params) { { pop_id: new_pop.id, node_id: nil } }

      context 'when record does not have pop nor node' do
        it 'calls Event with reload_sip_options_probers' do
          expect(Event).to receive(:reload_sip_options_probers).with(node_id: nil, pop_id: nil).once
          expect(Event).to receive(:reload_sip_options_probers).with(node_id: nil, pop_id: new_pop.id).once
          subject
        end

        include_examples :updates_record
      end

      context 'when record has node' do
        let(:record_attrs) { { node: node } }

        it 'calls Event with reload_sip_options_probers' do
          expect(Event).to receive(:reload_sip_options_probers).with(node_id: node.id, pop_id: nil).once
          expect(Event).to receive(:reload_sip_options_probers).with(node_id: nil, pop_id: new_pop.id).once
          subject
        end

        include_examples :updates_record
      end

      context 'when record has pop' do
        let(:record_attrs) { { pop: pop } }

        it 'calls Event with reload_sip_options_probers' do
          expect(Event).to receive(:reload_sip_options_probers).with(node_id: nil, pop_id: pop.id).once
          expect(Event).to receive(:reload_sip_options_probers).with(node_id: nil, pop_id: new_pop.id).once
          subject
        end

        include_examples :updates_record
      end
    end

    context 'with node_id' do
      let!(:new_node) { create(:node) }
      let(:update_params) { { pop_id: nil, node_id: new_node.id } }

      context 'when record does not have pop nor node' do
        it 'calls Event with reload_sip_options_probers' do
          expect(Event).to receive(:reload_sip_options_probers).with(node_id: nil, pop_id: nil).once
          expect(Event).to receive(:reload_sip_options_probers).with(node_id: new_node.id, pop_id: nil).once
          subject
        end

        include_examples :updates_record
      end

      context 'when record has node' do
        let(:record_attrs) { { node: node } }

        it 'calls Event with reload_sip_options_probers' do
          expect(Event).to receive(:reload_sip_options_probers).with(node_id: node.id, pop_id: nil).once
          expect(Event).to receive(:reload_sip_options_probers).with(node_id: new_node.id, pop_id: nil).once
          subject
        end

        include_examples :updates_record
      end

      context 'when record has pop' do
        let(:record_attrs) { { pop: pop } }

        it 'calls Event with reload_sip_options_probers' do
          expect(Event).to receive(:reload_sip_options_probers).with(node_id: nil, pop_id: pop.id).once
          expect(Event).to receive(:reload_sip_options_probers).with(node_id: new_node.id, pop_id: nil).once
          subject
        end

        include_examples :updates_record
      end
    end
  end

  describe '#destroy' do
    subject do
      record.destroy
    end

    let!(:pop) { create(:pop) }
    let!(:node) { create(:node, pop: pop) }
    let!(:record) { create(:sip_options_prober, record_attrs) }
    let(:record_attrs) { {} }

    context 'when record does not have pop nor node' do
      include_examples :calls_event_with, :reload_sip_options_probers do
        let(:event_meth_arguments) { { node_id: nil, pop_id: nil } }
      end

      include_examples :destroys_record
      include_examples :changes_records_qty_of, Equipment::SipOptionsProber, by: -1
    end

    context 'when record has node' do
      let(:record_attrs) { { node: node } }

      include_examples :calls_event_with, :reload_sip_options_probers do
        let(:event_meth_arguments) { { node_id: node.id, pop_id: nil } }
      end

      include_examples :destroys_record
      include_examples :changes_records_qty_of, Equipment::SipOptionsProber, by: -1
    end

    context 'when record has pop' do
      let(:record_attrs) { { pop: pop } }

      include_examples :calls_event_with, :reload_sip_options_probers do
        let(:event_meth_arguments) { { node_id: nil, pop_id: pop.id } }
      end

      include_examples :destroys_record
      include_examples :changes_records_qty_of, Equipment::SipOptionsProber, by: -1
    end
  end
end
