# frozen_string_literal: true

RSpec.describe BatchUpdateForm::Gateway do
  let(:pg_max_smallint) { Yeti::ActiveRecord::PG_MAX_SMALLINT }
  let!(:assign_params) do
    {
      enabled: 'true',
      priority: '1',
      weight: '12',
      is_shared: 'false',
      acd_limit: '1',
      asr_limit: '1',
      short_calls_limit: '1'
    }
  end

  subject do
    form = described_class.new(assign_params)
    form.valid?
    form
  end

  describe 'validation' do
    it 'should be valid' do expect(subject).to be_valid end

    # presence
    it { is_expected.to_not allow_value('', ' ').for :priority }
    it { is_expected.to_not allow_value('', ' ').for :weight }
    it { is_expected.to_not allow_value('', ' ').for :asr_limit }
    it { is_expected.to_not allow_value('', ' ').for :acd_limit }

    # numericality
    it { is_expected.to validate_numericality_of(:priority).only_integer }
    it { is_expected.to validate_numericality_of(:priority).is_greater_than 0 }
    it { is_expected.to validate_numericality_of(:priority).is_less_than_or_equal_to pg_max_smallint }
    it { is_expected.to validate_numericality_of(:weight).only_integer }
    it { is_expected.to validate_numericality_of(:weight).is_greater_than 0 }
    it { is_expected.to validate_numericality_of(:weight).is_less_than_or_equal_to pg_max_smallint }
    it { is_expected.to validate_numericality_of(:acd_limit).is_greater_than_or_equal_to 0.00 }
    it { is_expected.to validate_numericality_of(:asr_limit).is_less_than_or_equal_to 1.00 }
    it { is_expected.to validate_numericality_of(:asr_limit).is_greater_than_or_equal_to 0.00 }
    it { is_expected.to validate_numericality_of(:short_calls_limit).is_greater_than_or_equal_to 0.00 }
    it { is_expected.to validate_numericality_of(:short_calls_limit).is_less_than_or_equal_to 1.00 }

    # only integer
    it { is_expected.to_not allow_value('0.1').for :priority }
    it { is_expected.to_not allow_value('0.1').for :weight }
  end
end
