# == Schema Information
#
# Table name: sys.sensors
#
#  id               :integer          not null, primary key
#  name             :string           not null
#  mode_id          :integer          not null
#  source_interface :string
#  target_mac       :macaddr
#  use_routing      :boolean          not null
#  target_ip        :inet
#  source_ip        :inet
#

require 'spec_helper'
require 'shared_examples/shared_examples_for_events'

describe System::Sensor do

  let(:mode_id) { 1 }
  let(:source_ip) {'192.168.0.1'}
  let(:target_ip) {'192.168.0.2'}
  let(:source_interface) { nil }
  let(:target_mac) { nil }

  it_behaves_like 'Event originator for all Nodes' do
    let(:request_command) { 'request sensors reload' }
    let(:object_name) { :sensor }
    let(:object_fields) do
      {
        name: 'Experimental sensor',
        mode_id: mode_id,
        source_ip: source_ip,
        target_ip: target_ip,
        source_interface: source_interface,
        target_mac: target_mac
      }
    end
  end

  describe '#create' do
    subject do
      FactoryGirl.create(:sensor, {
                                    name: 'Experimental sensor',
                                    mode_id: mode_id,
                                    source_ip: source_ip,
                                    target_ip: target_ip,
                                    source_interface: source_interface,
                                    target_mac: target_mac
                                })
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
        let(:source_ip) {'192.168.0.1'}
        let(:target_ip) {'192.168.0.2'}
        let(:source_interface) { nil }
        let(:target_mac) { 'some arbitrary value' }

        it 'raise error' do
          expect { subject }.to raise_error(ActiveRecord::RecordInvalid)
        end
      end

      context 'when sensor-name duplicates' do
        let(:mode_id) { 1 }
        let(:source_ip) {'192.168.0.1'}
        let(:target_ip) {'192.168.0.2'}
        let(:source_interface) { nil }
        let(:target_mac) { nil }
        before do
          FactoryGirl.create(:sensor, {
                                        name: 'Experimental sensor',
                                        mode_id: mode_id,
                                        source_ip: source_ip,
                                        target_ip: target_ip,
                                        source_interface: source_interface,
                                        target_mac: target_mac
                                    })
        end

        it 'rise error' do
          expect { subject }.to raise_error
        end
      end
    end

  end

end
