# frozen_string_literal: true

RSpec.describe GatewayQualityCheck do
  shared_examples :locks_gateway do
    it 'locks gateway' do
      expect { subject }.to change { gateway.reload.locked }.from(false).to(true)
    end

    it 'sends notification event gateway_locked' do
      expect(NotificationEvent).to receive(:gateway_locked).with(gateway, quality_stat)
      subject
    end
  end

  shared_examples :does_not_lock_gateway do
    it 'does not lock gateway' do
      expect { subject }.not_to change { gateway.reload.locked }
    end

    it 'sends notification event gateway_locked' do
      expect(NotificationEvent).not_to receive(:gateway_locked)
      subject
    end
  end

  describe '#check_quality' do
    subject do
      described_class.new(gateway).check_quality(quality_stat)
    end

    let!(:gateway) { FactoryBot.create(:gateway, gateway_attrs) }
    let(:gateway_attrs) do
      { acd_limit: 0.71, asr_limit: 0.5 }
    end
    let(:quality_stat) { double(acd: 0.69, asr: 0.1) } # see Stats::TerminationQualityStat.dp_measurement

    include_examples :locks_gateway

    context 'when gateway already locked' do
      let(:gateway_attrs) do
        super().merge locked: true
      end

      include_examples :does_not_lock_gateway
    end

    context 'when acd > acd_limit' do
      let(:gateway_attrs) do
        super().merge acd_limit: 0.62
      end

      include_examples :locks_gateway
    end

    context 'when asr > asr_limit' do
      let(:gateway_attrs) do
        super().merge asr_limit: 0.09
      end

      include_examples :locks_gateway
    end

    context 'when both acd > acd_limit and asr > asr_limit' do
      let(:gateway_attrs) do
        super().merge acd_limit: 0.62, asr_limit: 0.09
      end

      include_examples :does_not_lock_gateway
    end

    context 'when both acd = acd_limit and asr = asr_limit' do
      let(:gateway_attrs) do
        super().merge acd_limit: 0.69, asr_limit: 0.1
      end

      include_examples :does_not_lock_gateway
    end
  end

  describe '#unlock' do
    subject do
      described_class.new(gateway).unlock
    end

    let!(:gateway) { FactoryBot.create(:gateway, gateway_attrs) }
    let(:gateway_attrs) do
      { locked: true }
    end

    it 'unlocks gateway' do
      expect { subject }.to change { gateway.reload.locked }.from(true).to(false)
    end

    it 'sends notification event gateway_unlocked' do
      expect(NotificationEvent).to receive(:gateway_unlocked).with(gateway)
      subject
    end

    context 'when gateway is not locked' do
      let(:gateway_attrs) do
        super().merge locked: false
      end

      it 'does not change gateway.locked' do
        expect { subject }.not_to change { gateway.reload.locked }
      end

      it 'sends notification event gateway_unlocked' do
        expect(NotificationEvent).to receive(:gateway_unlocked).with(gateway)
        subject
      end
    end
  end
end
