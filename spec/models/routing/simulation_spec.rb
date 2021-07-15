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
  end
end
