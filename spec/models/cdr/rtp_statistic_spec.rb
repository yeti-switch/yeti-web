# frozen_string_literal: true

RSpec.describe Cdr::RtpStatistic do
  describe 'scope' do
    subject { described_class.public_send(scope_name, scope_value) }

    let(:record_attrs) { {} }
    let!(:record) { FactoryBot.create(:rtp_statistic, record_attrs) }
    let!(:records) { FactoryBot.create_list(:rtp_statistic, 2) }
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

    describe '.tx_ssrc_hex' do
      let(:scope_name) { :tx_ssrc_hex }
      let(:record_attrs) { { tx_ssrc: '123' } }

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

        it 'should include record in scope' do
          expect(subject).to include(record)
        end
      end

      context 'when value is Decimal' do
        let(:scope_value) { '123' }
        let(:record_attrs) { { tx_ssrc: '123' } }

        it 'should NOT include record in scope' do
          expect(subject).not_to include(record)
        end
      end
    end
  end
end
