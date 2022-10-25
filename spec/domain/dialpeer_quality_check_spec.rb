# frozen_string_literal: true

RSpec.describe DialpeerQualityCheck do
  shared_examples :locks_dialpeer do
    it 'locks dialpeer' do
      expect { subject }.to change { dialpeer.reload.locked }.from(false).to(true)
    end

    it 'sends notification event dialpeer_locked' do
      expect(NotificationEvent).to receive(:dialpeer_locked).with(dialpeer, quality_stat)
      subject
    end
  end

  shared_examples :does_not_lock_dialpeer do
    it 'does not lock dialpeer' do
      expect { subject }.not_to change { dialpeer.reload.locked }
    end

    it 'sends notification event dialpeer_locked' do
      expect(NotificationEvent).not_to receive(:dialpeer_locked)
      subject
    end
  end

  describe '#check_quality' do
    subject do
      described_class.new(dialpeer).check_quality(quality_stat)
    end

    let!(:dialpeer) { FactoryBot.create(:dialpeer, dialpeer_attrs) }
    let(:dialpeer_attrs) do
      { acd_limit: 0.71, asr_limit: 0.5 }
    end
    let(:quality_stat) { double(acd: 0.69, asr: 0.1) } # see Stats::TerminationQualityStat.dp_measurement

    include_examples :locks_dialpeer

    context 'when dialpeer already locked' do
      let(:dialpeer_attrs) do
        super().merge locked: true
      end

      include_examples :does_not_lock_dialpeer
    end

    context 'when acd > acd_limit' do
      let(:dialpeer_attrs) do
        super().merge acd_limit: 0.62
      end

      include_examples :locks_dialpeer
    end

    context 'when asr > asr_limit' do
      let(:dialpeer_attrs) do
        super().merge asr_limit: 0.09
      end

      include_examples :locks_dialpeer
    end

    context 'when both acd > acd_limit and asr > asr_limit' do
      let(:dialpeer_attrs) do
        super().merge acd_limit: 0.62, asr_limit: 0.09
      end

      include_examples :does_not_lock_dialpeer
    end

    context 'when both acd = acd_limit and asr = asr_limit' do
      let(:dialpeer_attrs) do
        super().merge acd_limit: 0.69, asr_limit: 0.1
      end

      include_examples :does_not_lock_dialpeer
    end
  end

  describe '#unlock' do
    subject do
      described_class.new(dialpeer).unlock
    end

    let!(:dialpeer) { FactoryBot.create(:dialpeer, dialpeer_attrs) }
    let(:dialpeer_attrs) do
      { locked: true }
    end

    it 'unlocks dialpeer' do
      expect { subject }.to change { dialpeer.reload.locked }.from(true).to(false)
    end

    it 'sends notification event dialpeer_unlocked' do
      expect(NotificationEvent).to receive(:dialpeer_unlocked).with(dialpeer)
      subject
    end

    context 'when dialpeer is not locked' do
      let(:dialpeer_attrs) do
        super().merge locked: false
      end

      it 'does not change dialpeer.locked' do
        expect { subject }.not_to change { dialpeer.reload.locked }
      end

      it 'sends notification event dialpeer_unlocked' do
        expect(NotificationEvent).to receive(:dialpeer_unlocked).with(dialpeer)
        subject
      end
    end
  end
end
