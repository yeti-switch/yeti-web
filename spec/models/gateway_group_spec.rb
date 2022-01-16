# frozen_string_literal: true

# == Schema Information
#
# Table name: gateway_groups
#
#  id                :integer(4)       not null, primary key
#  is_shared         :boolean          default(FALSE), not null
#  name              :string           not null
#  prefer_same_pop   :boolean          default(TRUE), not null
#  balancing_mode_id :integer(2)       default(1), not null
#  vendor_id         :integer(4)       not null
#
# Indexes
#
#  gateway_groups_name_key  (name) UNIQUE
#
# Foreign Keys
#
#  gateway_groups_balancing_mode_id_fkey  (balancing_mode_id => gateway_group_balancing_modes.id)
#  gateway_groups_contractor_id_fkey      (vendor_id => contractors.id)
#
RSpec.describe GatewayGroup, type: :model do
  shared_examples :validation_error_on_is_shared_change do
    let(:expected_error_message) {}

    let(:full_expected_error_message) do
      "Validation failed: Is shared #{expected_error_message}"
    end

    subject do
      record.update!(is_shared: false)
    end

    it 'raise error' do
      expect do
        subject
      end.to raise_error(ActiveRecord::RecordInvalid, full_expected_error_message)
    end
  end

  context 'uncheck is_shared' do
    let(:record) { create(:gateway_group, is_shared: true) }

    context 'when has linked Dialpeer' do
      include_examples :validation_error_on_is_shared_change do
        before { create(:dialpeer, gateway_group: record) }

        let(:expected_error_message) do
          I18n.t('activerecord.errors.models.gateway_group.attributes.is_shared.cant_be_disabled_when_linked_to_dialpeer')
        end
      end
    end
  end

  context 'scope :for_termination' do
    before do
      # in scope
      @record = create(:gateway_group, is_shared: false, name: 'b-gw-group')
      @record_2 = create(:gateway_group, is_shared: true, name: 'a-gw-group')
    end

    # out of scope
    before do
      # other vendor
      create(:gateway_group)
      # other vendor and not shared
      create(:gateway_group, is_shared: false)
    end

    let(:vendor) { @record.vendor }

    subject do
      described_class.for_termination(vendor.id)
    end

    it 'allow_termination is mandatory, then look for shared or vendors gateway groups, order by name' do
      expect(subject.pluck(:id)).to match_array([@record_2.id, @record.id])
    end
  end
end
