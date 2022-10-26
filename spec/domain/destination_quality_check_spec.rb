# frozen_string_literal: true

RSpec.describe DestinationQualityCheck do
  shared_examples :alarms_destination do
    it 'alarms destination' do
      expect { subject }.to change { destination.reload.quality_alarm }.from(false).to(true)
    end

    it 'sends notification event destination_quality_alarm_fired' do
      expect(NotificationEvent).to receive(:destination_quality_alarm_fired).with(destination, quality_stat)
      subject
    end
  end

  shared_examples :does_not_alarm_destination do
    it 'does not alarm destination' do
      expect { subject }.not_to change { destination.reload.quality_alarm }
    end

    it 'sends notification event destination_quality_alarm_fired' do
      expect(NotificationEvent).not_to receive(:destination_quality_alarm_fired)
      subject
    end
  end

  describe '#check_quality' do
    subject do
      described_class.new(destination).check_quality(quality_stat)
    end

    let!(:destination) { FactoryBot.create(:destination, destination_attrs) }
    let(:destination_attrs) do
      { acd_limit: 0.71, asr_limit: 0.5 }
    end
    let(:quality_stat) { double(acd: 0.69, asr: 0.1) } # see Stats::TerminationQualityStat.dp_measurement

    include_examples :alarms_destination

    context 'when destination has quality_alarm=true' do
      let(:destination_attrs) do
        super().merge quality_alarm: true
      end

      include_examples :does_not_alarm_destination
    end

    context 'when acd > acd_limit' do
      let(:destination_attrs) do
        super().merge acd_limit: 0.62
      end

      include_examples :alarms_destination
    end

    context 'when asr > asr_limit' do
      let(:destination_attrs) do
        super().merge asr_limit: 0.09
      end

      include_examples :alarms_destination
    end

    context 'when both acd > acd_limit and asr > asr_limit' do
      let(:destination_attrs) do
        super().merge acd_limit: 0.62, asr_limit: 0.09
      end

      include_examples :does_not_alarm_destination
    end

    context 'when both acd = acd_limit and asr = asr_limit' do
      let(:destination_attrs) do
        super().merge acd_limit: 0.69, asr_limit: 0.1
      end

      include_examples :does_not_alarm_destination
    end
  end

  describe '#clear_quality_alarm' do
    subject do
      described_class.new(destination).clear_quality_alarm
    end

    let!(:destination) { FactoryBot.create(:destination, destination_attrs) }
    let(:destination_attrs) do
      { quality_alarm: true }
    end

    it 'unlocks destination' do
      expect { subject }.to change { destination.reload.quality_alarm }.from(true).to(false)
    end

    it 'sends notification event destination_quality_alarm_cleared' do
      expect(NotificationEvent).to receive(:destination_quality_alarm_cleared).with(destination)
      subject
    end

    context 'when destination has quality_alarm=false' do
      let(:destination_attrs) do
        super().merge quality_alarm: false
      end

      it 'does not change destination.quality_alarm' do
        expect { subject }.not_to change { destination.reload.quality_alarm }
      end

      it 'sends notification event destination_quality_alarm_cleared' do
        expect(NotificationEvent).to receive(:destination_quality_alarm_cleared).with(destination)
        subject
      end
    end
  end
end
