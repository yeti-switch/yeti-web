# frozen_string_literal: true

# == Schema Information
#
# Table name: sys.sensors
#
#  id               :integer(2)       not null, primary key
#  name             :string           not null
#  source_interface :string
#  source_ip        :inet
#  target_ip        :inet
#  target_mac       :macaddr
#  target_port      :integer(4)
#  use_routing      :boolean          not null
#  hep_capture_id   :integer(4)
#  mode_id          :integer(4)       not null
#
# Indexes
#
#  sensors_name_key  (name) UNIQUE
#
# Foreign Keys
#
#  sensors_mode_id_fkey  (mode_id => sensor_modes.id)
#

RSpec.describe System::Sensor do
  let(:mode_id) { 1 }
  let(:source_ip) { '192.168.0.1' }
  let(:target_ip) { '192.168.0.2' }
  let(:source_interface) { nil }
  let(:target_mac) { nil }

  describe '#create' do
    subject do
      FactoryBot.create(:sensor,
                        name: 'Experimental sensor',
                        mode_id: mode_id,
                        source_ip: source_ip,
                        target_ip: target_ip,
                        source_interface: source_interface,
                        target_mac: target_mac)
    end

    context 'with valid input data' do
      it 'creates Sensor successfully' do
        expect { subject }.to change { described_class.count }.from(0).to(1)
      end
    end

    context 'with invalid input data' do
      context 'when mode IP-IP encapsulation' do
        let(:mode_id) { 1 }
        let(:source_ip) { 'some arbitrary value' }
        let(:target_ip) { nil }
        let(:source_interface) { 'eth0' }
        let(:target_mac) { '00-B0-D0-86-BB-F7' }

        it 'raise error' do
          expect { subject }.to raise_error(ActiveRecord::RecordInvalid)
        end
      end

      context 'when mode IP-Ethernet encapsulation' do
        let(:mode_id) { 2 }
        let(:source_ip) { '192.168.0.1' }
        let(:target_ip) { '192.168.0.2' }
        let(:source_interface) { nil }
        let(:target_mac) { 'some arbitrary value' }

        it 'raise error' do
          expect { subject }.to raise_error(ActiveRecord::RecordInvalid)
        end
      end

      context 'when mode HEPv3 encapsulation' do
        let(:mode_id) { 3 }
        let(:target_ip) { '192.168.0.2' }
        let(:target_port) { nil }
        let(:hep_capture_id) { nil }

        it 'raise error' do
          expect { subject }.to raise_error(ActiveRecord::RecordInvalid)
        end
      end

      context 'when sensor-name duplicates' do
        let(:mode_id) { 1 }
        let(:source_ip) { '192.168.0.1' }
        let(:target_ip) { '192.168.0.2' }
        let(:source_interface) { nil }
        let(:target_mac) { nil }
        before do
          FactoryBot.create(:sensor,
                            name: 'Experimental sensor',
                            mode_id: mode_id,
                            source_ip: source_ip,
                            target_ip: target_ip,
                            source_interface: source_interface,
                            target_mac: target_mac)
        end

        it 'rise error' do
          expect { subject }.to raise_error(ActiveRecord::RecordInvalid)
        end
      end
    end
  end
end
