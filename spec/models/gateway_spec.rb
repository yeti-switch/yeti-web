RSpec.describe Gateway, type: :model do

  it do
    is_expected.to validate_numericality_of(:max_30x_redirects).is_less_than_or_equal_to(Yeti::ActiveRecord::PG_MAX_SMALLINT)
    is_expected.to validate_numericality_of(:max_transfers).is_less_than_or_equal_to(Yeti::ActiveRecord::PG_MAX_SMALLINT)
    is_expected.to validate_numericality_of(:origination_capacity).is_less_than_or_equal_to(Yeti::ActiveRecord::PG_MAX_SMALLINT)
    is_expected.to validate_numericality_of(:termination_capacity).is_less_than_or_equal_to(Yeti::ActiveRecord::PG_MAX_SMALLINT)
    is_expected.to validate_numericality_of(:fake_180_timer).is_less_than_or_equal_to(Yeti::ActiveRecord::PG_MAX_SMALLINT)
  end

  shared_examples :validation_error_on_is_shared_change do
    let(:expected_error_message) {}

    let(:full_expected_error_message) do
      "Validation failed: Is shared #{expected_error_message}"
    end

    subject do
      record.update!(is_shared: false)
    end

    it 'raise error' do
      expect {
        subject
      }.to raise_error(ActiveRecord::RecordInvalid, full_expected_error_message)
    end
  end

  context 'uncheck is_shared' do

    let(:record) { create(:gateway, is_shared: true) }

    context 'when has linked CustomersAuth' do
      include_examples :validation_error_on_is_shared_change do
        before { create(:customers_auth, gateway: record) }
        let(:expected_error_message) do
          I18n.t('activerecord.errors.models.gateway.attributes.contractor.cant_be_changed_when_linked_to_customers_auth')
        end
      end
    end

    context 'when has linked Dialpeer' do
      include_examples :validation_error_on_is_shared_change do
        before { create(:dialpeer, gateway: record) }

        let(:expected_error_message) do
          I18n.t('activerecord.errors.models.gateway.attributes.contractor.cant_be_changed_when_linked_to_dialpeer')
        end
      end
    end

  end

  context 'scope :for_termination' do

    before do
      # in scope
      @record = create(:gateway, is_shared: false, allow_termination: true, name: 'b-gateway')
      @record_2 = create(:gateway, is_shared: true, allow_termination: true, name: 'a-gateway')
    end

    # out of scope
    before do
      # other vendor
      create(:gateway, allow_termination: true)
      # shared but not for termination
      create(:gateway, allow_termination: false, is_shared: true)
      # same vendor but not for termination
      create(:gateway, allow_termination: false, contractor: vendor)
    end

    let(:vendor) { @record.vendor }

    subject do
      described_class.for_termination(vendor.id)
    end

    it 'allow_termination is mandatory, then look for shared or vendors gateways, order by name' do
      expect(subject.pluck(:id)).to match_array([@record_2.id, @record.id])
    end

  end
end
