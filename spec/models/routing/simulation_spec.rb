# frozen_string_literal: true

RSpec.describe Routing::SimulationForm do
  describe 'validates' do
    context '#remote_ip' do
      it { is_expected.to_not allow_value('').for :remote_ip }

      it { is_expected.to allow_value('127.0.0.1').for :remote_ip }
    end

    context '#remote_port' do
      it { is_expected.to_not allow_value('').for :remote_port }

      it { is_expected.to allow_value(ApplicationRecord::L4_PORT_MIN + 10).for :remote_port }
    end

    context '#src_number' do
      it { is_expected.to_not allow_value('').for :src_number }

      it { is_expected.to allow_value(3).for :src_number }
    end

    context '#dst_number' do
      it { is_expected.to_not allow_value('').for :dst_number }

      it { is_expected.to allow_value(4).for :dst_number }
    end

    context '#pop_id' do
      it { is_expected.to_not allow_value('').for :pop_id }
      it { is_expected.to_not allow_value('string').for :pop_id }

      it { is_expected.to allow_value(3).for :pop_id }
    end

    context '#transport_protocol_id' do
      it { is_expected.to_not allow_value('').for :transport_protocol_id }
      it { is_expected.to_not allow_value('string').for :transport_protocol_id }

      it { is_expected.to allow_value(Equipment::TransportProtocol.take!.id).for :transport_protocol_id }
    end

    context '#remote_port' do
      it { is_expected.to_not allow_value('').for :remote_port }
      it { is_expected.to_not allow_value('string').for :remote_port }
      it { is_expected.to_not allow_value(ApplicationRecord::L4_PORT_MIN - 1).for :remote_port }
      it { is_expected.to_not allow_value(ApplicationRecord::L4_PORT_MAX + 1).for :remote_port }
      it { is_expected.to_not allow_value(ApplicationRecord::L4_PORT_MAX).for :remote_port }
      it { is_expected.to_not allow_value(2.5).for :remote_port }

      it { is_expected.to allow_value(ApplicationRecord::L4_PORT_MIN).for :remote_port }
      it { is_expected.to allow_value(ApplicationRecord::L4_PORT_MAX - 1).for :remote_port }
    end

    shared_examples 'valid sip uri values' do |field|
      it { is_expected.to allow_value('').for(field) }
      it { is_expected.to allow_value(nil).for(field) }
      it { is_expected.to allow_value('sip:user@example.com').for(field) }
      it { is_expected.to allow_value('sips:user@example.com').for(field) }
      it { is_expected.to allow_value('tel:+1234567890').for(field) }
      it { is_expected.to allow_value('"Alice" <sip:alice@atlanta.com:5060;transport=tcp>;tag=123').for(field) }
    end

    shared_examples 'sip uri field' do |field|
      include_examples 'valid sip uri values', field

      it {
        is_expected.to_not allow_value('invalid-uri')
          .for(field)
          .with_message('is not a valid SIP URI, must begin with sip:, sips: or tel: scheme')
      }

      it {
        is_expected.to_not allow_value('12345')
          .for(field)
          .with_message('is not a valid SIP URI, must begin with sip:, sips: or tel: scheme')
      }
    end

    shared_examples 'sip uri array field' do |field|
      include_examples 'valid sip uri values', field

      it { is_expected.to allow_value('sip:alice@atlanta.com, sip:bob@biloxi.com').for(field) }
      it { is_expected.to allow_value('<sip:+123@gw1.example.com>;reason=unconditional, <sip:+456@gw2.example.com>').for(field) }

      it {
        is_expected.to_not allow_value('invalid-uri')
          .for(field)
          .with_message('contains invalid SIP URI, each entry must begin with sip:, sips: or tel: scheme')
      }

      it {
        is_expected.to_not allow_value('sip:user@example.com, invalid-uri')
          .for(field)
          .with_message('contains invalid SIP URI, each entry must begin with sip:, sips: or tel: scheme')
      }
    end

    context '#diversion' do
      include_examples 'sip uri array field', :diversion
    end

    context '#pai' do
      include_examples 'sip uri array field', :pai
    end

    context '#ppi' do
      include_examples 'sip uri field', :ppi
    end

    context '#rpid' do
      include_examples 'sip uri field', :rpid
    end
  end
end
