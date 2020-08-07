# frozen_string_literal: true

RSpec.describe BatchUpdateForm::Contractor do
  let!(:contractor_with_customers_auth) { FactoryBot.create :customer }
  let!(:customers_auth) { FactoryBot.create :customers_auth, customer: contractor_with_customers_auth }
  let!(:smtp) { FactoryBot.create :smtp_connection }
  let!(:assign_params) do
    {
      enabled: 'false',
      vendor: 'false',
      customer: 'true',
      description: 'some text',
      address: 'address',
      phones: '+380978520001',
      smtp_connection_id: smtp.id.to_s
    }
  end

  subject do
    form = described_class.new(assign_params)
    form.valid?
    form
  end

  describe 'validation' do
    it 'should be valid' do expect(subject).to be_valid end

    # enabled
    context 'when :enabled is true' do
      # because in front-end we have <option value="t">Yes</option>
      let(:assign_params) { { enabled: 'true' } }

      it 'should pass validations' do
        expect(subject).to be_valid
      end
    end

    context 'when :enabled is false' do
      # because in front-end we have <option value="f">No</option>
      let(:assign_params) { { enabled: 'false' } }

      it 'should pass validations' do
        expect(subject).to be_valid
      end
    end

    # vendor
    context 'when :vendor and :customer have true value' do
      let(:assign_params) { { vendor: 'true', customer: 'true' } }

      it 'should have failed' do
        subject
        expect(subject.errors[:base]).to contain_exactly I18n.t 'activerecord.errors.models.contractor.vendor_or_customer'
        expect(subject.errors.size).to eq 1
      end
    end

    context 'when contractor used at Customer auth' do
      let(:assign_params) { { vendor: true, customer: false } }

      it 'should have failed with invalid message' do
        subject
        expect(subject.errors[:customer]).to contain_exactly I18n.t 'activerecord.errors.models.contractor.attributes.customer'
        expect(subject.errors.size).to eq 1
      end
    end

    it { is_expected.to allow_value('', 'string').for :description }
    it { is_expected.to allow_value('', 'string', 'DIDWW Ireland Limited 10/13 Thomas Street The Digital Hub, Dublin 8 Ireland').for :address }
    it { is_expected.to allow_value('', '+380970005868').for :phones }
  end
end
