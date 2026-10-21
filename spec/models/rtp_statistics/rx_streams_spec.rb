# frozen_string_literal: true

RSpec.describe RtpStatistics::RxStream do
  describe 'scope' do
    subject { described_class.public_send(scope_name, scope_value) }

    let(:record_attrs) { {} }
    let!(:record) { FactoryBot.create(:rx_stream, record_attrs) }
    let!(:records) { FactoryBot.create_list(:rx_stream, 2) }
    let(:scope_name) { :all }
    let(:scope_value) { '' }

    describe '.rx_ssrc_hex' do
      let(:scope_name) { :rx_ssrc_hex }
      let(:record_attrs) { { rx_ssrc: '123' } }

      context 'when value is empty string' do
        let(:scope_value) { '' }

        it 'should NOT include record in scope' do
          expect(subject).not_to include(record)
        end
      end

      context 'when value is string' do
        let(:scope_value) { 'string' }

        it 'should NOT include record in scope' do
          expect(subject).not_to include(record)
        end
      end

      context 'when value is Hexadecimal' do
        let(:scope_value) { '007B' }
        let(:record_attrs) { { rx_ssrc: '123' } }

        it 'should include record in scope' do
          expect(subject).to include(record)
        end
      end

      context 'when value is Decimal' do
        let(:scope_value) { '123' }
        let(:record_attrs) { { rx_ssrc: '123' } }

        it 'should NOT include record in scope' do
          expect(subject).not_to include(record)
        end
      end
    end

    describe '.remote_host_within' do
      let(:scope_name) { :remote_host_within }
      let(:record_attrs) { { remote_host: '194.28.167.87' } }

      [['194.28.167.87', true], ['194.28.167.0/24', true], ['194.28.168.0/24', false], ['not an ip', false]].each do |value, included|
        context "when value is #{value.inspect}" do
          let(:scope_value) { value }

          it { included ? is_expected.to(contain_exactly(record)) : is_expected.to(be_empty) }
        end
      end
    end

    describe '.local_host_within' do
      let(:scope_name) { :local_host_within }
      let(:record_attrs) { { local_host: '194.28.167.87' } }

      [['194.28.167.87', true], ['194.28.167.0/24', true], ['194.28.168.0/24', false], ['not an ip', false]].each do |value, included|
        context "when value is #{value.inspect}" do
          let(:scope_value) { value }

          it { included ? is_expected.to(contain_exactly(record)) : is_expected.to(be_empty) }
        end
      end
    end
  end
end
