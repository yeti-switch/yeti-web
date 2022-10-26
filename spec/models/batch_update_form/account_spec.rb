# frozen_string_literal: true

RSpec.describe BatchUpdateForm::Account do
  let!(:contractor) { FactoryBot.create(:vendor) }
  let!(:timezone) { FactoryBot.create(:timezone) }
  let!(:invoice_template) { FactoryBot.create(:invoice_template) }
  let!(:assign_params) do
    {
      contractor_id: contractor.id.to_s,
      min_balance: '10',
      max_balance: '10',
      vat: '3',
      origination_capacity: '5',
      termination_capacity: '300',
      total_capacity: '50',
      max_call_duration: '10',
      vendor_invoice_period_id: Billing::InvoicePeriod.take!.id.to_s,
      customer_invoice_period_id: Billing::InvoicePeriod.take!.id.to_s,
      vendor_invoice_template_id: invoice_template.id.to_s,
      customer_invoice_template_id: invoice_template.id.to_s,
      timezone_id: timezone.id.to_s
    }
  end

  subject do
    form = described_class.new(assign_params)
    form.valid?
    form
  end

  describe 'validation' do
    it 'should be valid' do expect(subject).to be_valid end

    # min_balance
    it { is_expected.to_not allow_value('', ' ', 'string').for :min_balance }
    it { is_expected.to validate_numericality_of :min_balance }

    context 'when change value :min_balance without :max_balance' do
      let(:assign_params) { { min_balance: '12' } }

      it 'should have failed with invalid message' do
        subject
        expect(subject.errors.to_a).to contain_exactly 'Min balance must be changed together with Max balance'
      end
    end

    # :max_balance
    context 'when :min_balance is greater than :max_balance' do
      let(:assign_params) { { min_balance: '100', max_balance: '10' } }

      it 'should have failed with invalid message' do
        subject
        expect(subject.errors.to_a).to contain_exactly "Max balance must be greater than or equal to #{subject.min_balance}"
      end
    end

    context 'when :min_balance filled and :max_balance contains string' do
      let(:assign_params) { { min_balance: '100', max_balance: '10.' } }

      it 'should have failed with invalid message' do
        subject
        expect(subject.errors.to_a).to contain_exactly 'Max balance is not a number'
      end
    end

    context 'when :min_balance filled and :max_balance contains string' do
      let(:assign_params) { { max_balance: '100', min_balance: 'string' } }

      it 'should have failed with invalid message' do
        subject
        expect(subject.errors.to_a).to contain_exactly 'Min balance is not a number'
      end
    end

    # vat
    it { is_expected.to_not allow_value('', ' ', 'string').for :vat }
    it { is_expected.to validate_numericality_of :vat }
    it { is_expected.to validate_numericality_of(:vat).is_greater_than_or_equal_to 0 }
    it { is_expected.to validate_numericality_of(:vat).is_less_than_or_equal_to 100 }

    # destination_rate_limit
    it { is_expected.to_not allow_value('string').for :destination_rate_limit }
    it { is_expected.to_not validate_presence_of(:destination_rate_limit) }
    it { is_expected.to validate_numericality_of(:destination_rate_limit).allow_nil }
    it { is_expected.to validate_numericality_of(:destination_rate_limit).is_greater_than_or_equal_to 0 }
    it { is_expected.to allow_value(nil).for(:destination_rate_limit) }

    # origination_capacity
    it { is_expected.to_not allow_value('string', 1.5).for :origination_capacity }
    it { is_expected.to allow_value(nil, '', ' ').for :origination_capacity }
    it { is_expected.to validate_numericality_of(:origination_capacity).only_integer }
    it { is_expected.to validate_numericality_of(:origination_capacity).is_greater_than 0 }
    it { is_expected.to validate_numericality_of(:origination_capacity).is_less_than_or_equal_to ApplicationRecord::PG_MAX_SMALLINT }

    # termination_capacity
    it { is_expected.to_not allow_value('string', 1.5).for :termination_capacity }
    it { is_expected.to allow_value(nil, '', ' ').for :termination_capacity }
    it { is_expected.to validate_numericality_of(:termination_capacity).only_integer }
    it { is_expected.to validate_numericality_of(:termination_capacity).is_greater_than 0 }
    it { is_expected.to validate_numericality_of(:termination_capacity).is_less_than_or_equal_to ApplicationRecord::PG_MAX_SMALLINT }

    # total_capacity
    it { is_expected.to_not allow_value('string', 1.5).for :total_capacity }
    it { is_expected.to allow_value(nil, '', ' ').for :termination_capacity }
    it { is_expected.to validate_numericality_of(:total_capacity).only_integer }
    it { is_expected.to validate_numericality_of(:total_capacity).is_greater_than 0 }
    it { is_expected.to validate_numericality_of(:total_capacity).is_less_than_or_equal_to ApplicationRecord::PG_MAX_SMALLINT }

    # max_call_duration
    it { is_expected.to_not allow_value('string', 1.5).for :max_call_duration }
    it { is_expected.to allow_value(nil, '', ' ').for :max_call_duration }
    it { is_expected.to validate_numericality_of(:max_call_duration).is_greater_than 0 }
    it { is_expected.to validate_numericality_of(:max_call_duration).allow_nil }
    it { is_expected.to validate_numericality_of(:max_call_duration).only_integer }
  end
end
