# frozen_string_literal: true

RSpec.describe BatchUpdateForm::Destination do
  let(:prefix_err_message) { I18n.t 'activerecord.errors.models.routing\destination.attributes.prefix.with_spaces' }
  let!(:rate_group) { Routing::RateGroup.take || FactoryBot.create(:rate_group) }
  let!(:rate_policy_id) { Routing::DestinationRatePolicy::POLICY_MAX }
  let!(:profit_control_mode_id) { Routing::RateProfitControlMode::MODE_PER_CALL }
  let!(:assign_params) do
    {
      enabled: 'true',
      prefix: '_test',
      dst_number_min_length: '0',
      dst_number_max_length: '0',
      routing_tag_mode_id: Routing::RoutingTagMode::MODE_OR.to_s,
      reject_calls: 'false',
      quality_alarm: 'true',
      rate_group_id: rate_group.id.to_s,
      valid_from: '2020-01-10',
      valid_till: '2020-01-20',
      rate_policy_id: rate_policy_id.to_s,
      initial_interval: '1',
      initial_rate: '1',
      next_interval: '2',
      next_rate: '3',
      use_dp_intervals: 'false',
      connect_fee: '1',
      profit_control_mode_id: profit_control_mode_id.to_s,
      dp_margin_fixed: '1',
      dp_margin_percent: '2',
      asr_limit: '0.9',
      acd_limit: '1',
      short_calls_limit: '4'
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
    it { is_expected.to_not allow_value('', ' ').for :dst_number_min_length }
    it { is_expected.to_not allow_value('', ' ').for :dst_number_max_length }
    it { is_expected.to_not allow_value('', ' ').for :initial_rate }
    it { is_expected.to_not allow_value('', ' ').for :next_rate }
    it { is_expected.to_not allow_value('', ' ').for :initial_interval }
    it { is_expected.to_not allow_value('', ' ').for :next_interval }
    it { is_expected.to_not allow_value('', ' ').for :connect_fee }
    it { is_expected.to_not allow_value('', ' ').for :dp_margin_fixed }
    it { is_expected.to_not allow_value('', ' ').for :dp_margin_percent }
    it { is_expected.to_not allow_value('', ' ').for :asr_limit }
    it { is_expected.to_not allow_value('', ' ').for :acd_limit }
    it { is_expected.to_not allow_value('', ' ').for :short_calls_limit }
    it { is_expected.to_not allow_value('', ' ').for :valid_from }
    it { is_expected.to_not allow_value('', ' ').for :valid_till }

    # numericality
    it { is_expected.to validate_numericality_of(:dst_number_min_length).is_greater_than_or_equal_to 0 }
    it { is_expected.to validate_numericality_of(:dst_number_min_length).is_less_than_or_equal_to 100 }
    it { is_expected.to validate_numericality_of(:dst_number_min_length).only_integer }
    it { is_expected.to validate_numericality_of(:dst_number_max_length).is_less_than_or_equal_to 100 }
    it { is_expected.to validate_numericality_of(:dst_number_max_length).only_integer }
    it { is_expected.to validate_numericality_of(:dp_margin_percent).is_greater_than 0 }
    it { is_expected.to validate_numericality_of(:connect_fee).is_greater_than_or_equal_to 0 }
    it { is_expected.to validate_numericality_of(:dp_margin_fixed).is_greater_than_or_equal_to 0 }
    it { is_expected.to validate_numericality_of(:asr_limit).is_greater_than_or_equal_to 0.00 }
    it { is_expected.to validate_numericality_of(:asr_limit).is_less_than_or_equal_to 1.00 }
    it { is_expected.to validate_numericality_of(:initial_interval).is_greater_than 0 }
    it { is_expected.to validate_numericality_of(:initial_interval).only_integer }
    it { is_expected.to validate_numericality_of(:acd_limit).is_greater_than_or_equal_to 0 }
    it { is_expected.to validate_numericality_of(:short_calls_limit).is_greater_than_or_equal_to 0 }
    it { is_expected.to validate_numericality_of(:next_interval).only_integer }
    it { is_expected.to validate_numericality_of(:next_interval).is_greater_than 0 }
    it { is_expected.to validate_numericality_of(:initial_rate) }
    it { is_expected.to validate_numericality_of(:next_rate) }

    it { is_expected.to allow_value('0.5').for :dp_margin_percent }
    it { is_expected.to allow_value('0.5').for :connect_fee }
    it { is_expected.to allow_value('0.5').for :dp_margin_fixed }
    it { is_expected.to allow_value('0.5').for :asr_limit }
    it { is_expected.to allow_value('0.5').for :acd_limit }
    it { is_expected.to allow_value('0.5').for :short_calls_limit }
    it { is_expected.to allow_value('0.5').for :initial_rate }
    it { is_expected.to allow_value('0.5').for :next_rate }

    # other validation
    context 'when :dst_number_min_length greater than :dst_number_max_length' do
      let(:assign_params) { { dst_number_min_length: '100', dst_number_max_length: '1' } }

      it 'should have error: must be greater than or equal to' do
        subject
        expect(subject.errors.to_a).to contain_exactly "Dst number max length must be greater than or equal to #{assign_params[:dst_number_min_length]}"
      end
    end

    context 'when :dst_number_min_length valid and :dst_number_max_length value is string' do
      let(:assign_params) { { dst_number_min_length: '100', dst_number_max_length: '1.' } }

      it 'should have error: is not a number' do
        subject
        expect(subject.errors.to_a).to contain_exactly 'Dst number max length is not a number'
      end
    end

    it { is_expected.to_not allow_value('string test').for(:prefix).with_message(prefix_err_message) }

    context 'when :valid_from date is later than :valid_till date' do
      let(:assign_params) { { valid_from: '2020-09-09', valid_till: '2020-01-01' } }

      it 'should have error: :valid_from must be before or equal to' do
        subject
        expect(subject.errors.to_a).to contain_exactly "Valid from must be before or equal to #{assign_params[:valid_till]}"
      end
    end

    context 'when :valid_from changed and :valid_till is empty' do
      let(:assign_params) { { valid_from: '2020-02-02', valid_till: '' } }

      it "should have error: Valid till can't be blank" do
        subject
        expect(subject.errors.to_a).to contain_exactly "Valid till can't be blank"
      end
    end

    context 'when :valid_from changed without :valid_till' do
      let(:assign_params) { { valid_from: '2020-02-02' } }

      it 'should have error: must be changed together' do
        subject
        expect(subject.errors.to_a).to contain_exactly 'Valid from must be changed together with Valid till'
      end
    end

    context 'when :dst_number_min_length changed and :dst_number_max_length is empty' do
      let(:assign_params) { { dst_number_min_length: '20', dst_number_max_length: '' } }

      it "should have error: Dst number max length can't be blank" do
        subject
        expect(subject.errors.to_a).to contain_exactly "Dst number max length can't be blank"
      end
    end

    context 'when :dst_number_min_length changed without :dst_number_max_length' do
      let(:assign_params) { { dst_number_min_length: '20' } }

      it 'should have error: must be changed together' do
        subject
        expect(subject.errors.to_a).to contain_exactly 'Dst number min length must be changed together with Dst number max length'
      end
    end
  end
end
