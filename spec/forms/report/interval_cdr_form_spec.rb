# frozen_string_literal: true

RSpec.describe Report::IntervalCdrForm do
  subject { form.save }

  let(:form) { described_class.new(form_attributes) }
  let(:form_attributes) do
    {
      date_start: Time.current.to_fs(:db),
      date_end: Time.current.to_fs(:db),
      interval_length: 5,
      aggregate_by: Report::IntervalCdr::CDR_AGG_COLUMNS.sample,
      aggregator_id: Report::IntervalAggregator.take!.id
    }
  end

  context 'when group_by is not filled' do
    let(:form_attributes) { super().merge group_by: [''] }

    it 'should create record with empty group_by' do
      expect { subject }.to change(Report::IntervalCdr, :count).by(1)
      expect(Report::IntervalCdr.take!).to have_attributes(group_by: [])
    end
  end

  context 'when group_by is filled' do
    let(:form_attributes) { super().merge group_by: Report::IntervalCdr::CDR_COLUMNS.first(2) }

    it 'should create record with NOT empty group_by' do
      expect { subject }.to change(Report::IntervalCdr, :count).by(1)
      expect(Report::IntervalCdr.take!).to have_attributes group_by: Report::IntervalCdr::CDR_COLUMNS.first(2).map(&:to_s)
    end
  end
end
