# frozen_string_literal: true

require 'spec_helper'

describe Gateway, type: :model do
  it do
    should validate_numericality_of(:max_30x_redirects).is_less_than_or_equal_to(Yeti::ActiveRecord::PG_MAX_SMALLINT)
    should validate_numericality_of(:max_transfers).is_less_than_or_equal_to(Yeti::ActiveRecord::PG_MAX_SMALLINT)
    should validate_numericality_of(:origination_capacity).is_less_than_or_equal_to(Yeti::ActiveRecord::PG_MAX_SMALLINT)
    should validate_numericality_of(:termination_capacity).is_less_than_or_equal_to(Yeti::ActiveRecord::PG_MAX_SMALLINT)
    should validate_numericality_of(:fake_180_timer).is_less_than_or_equal_to(Yeti::ActiveRecord::PG_MAX_SMALLINT)
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
      expect do
        subject
      end.to raise_error(ActiveRecord::RecordInvalid, full_expected_error_message)
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

  describe '.create' do
    subject do
      described_class.create(create_params)
    end

    let!(:vendor) { FactoryGirl.create(:vendor) }
    let!(:codec_group) { FactoryGirl.create(:codec_group) }

    let(:create_params) do
      {
        contractor: vendor,
        codec_group: codec_group,
        name: 'test',
        allow_termination: false,
        enabled: false
      }
    end

    include_examples :does_not_call_event_with, :reload_incoming_auth
    include_examples :creates_record
    include_examples :changes_records_qty_of, described_class, by: 1

    context 'with auth credentials' do
      let(:create_params) { super().merge(incoming_auth_username: 'qwe', incoming_auth_password: 'asd') }

      include_examples :calls_event_with, :reload_incoming_auth
      include_examples :creates_record
      include_examples :changes_records_qty_of, described_class, by: 1
    end
  end

  describe '#update' do
    subject do
      record.update(update_params)
    end

    let!(:record) { FactoryGirl.create(:gateway, record_attrs) }
    let(:record_attrs) { { enabled: false } }

    context 'without incoming_auth' do
      context 'when change enable false->true' do
        let(:record_attrs) { super().merge(enabled: false) }
        let(:update_params) { { enabled: true } }

        include_examples :updates_record
        include_examples :does_not_call_event_with, :reload_incoming_auth
      end

      context 'when change enable true->false' do
        let(:record_attrs) { super().merge(enabled: true) }
        let(:update_params) { { enabled: false } }

        include_examples :updates_record
        include_examples :does_not_call_event_with, :reload_incoming_auth
      end

      context 'when change incoming_auth_username to something' do
        let(:update_params) { { incoming_auth_username: 'qwe' } }

        include_examples :does_not_update_record, errors: {
          incoming_auth_password: "can't be blank"
        }
        include_examples :does_not_call_event_with, :reload_incoming_auth
      end

      context 'when change incoming_auth_password to something' do
        let(:update_params) { { incoming_auth_password: 'qwe' } }

        include_examples :does_not_update_record, errors: {
          incoming_auth_username: "can't be blank"
        }
        include_examples :does_not_call_event_with, :reload_incoming_auth
      end

      context 'when change incoming_auth_username and incoming_auth_password to something' do
        let(:update_params) { { incoming_auth_username: 'qwe', incoming_auth_password: 'asd' } }

        include_examples :updates_record
        include_examples :calls_event_with, :reload_incoming_auth
      end
    end

    context 'with incoming_auth' do
      let(:record_attrs) { super().merge(incoming_auth_username: 'qwe', incoming_auth_password: 'asd') }

      context 'when change enable false->true' do
        let(:record_attrs) { super().merge(enabled: false) }
        let(:update_params) { { enabled: true } }

        include_examples :updates_record
        include_examples :calls_event_with, :reload_incoming_auth
      end

      context 'when change enable true->false' do
        let(:record_attrs) { super().merge(enabled: true) }
        let(:update_params) { { enabled: false } }

        include_examples :updates_record
        include_examples :calls_event_with, :reload_incoming_auth
      end

      context 'when clear incoming_auth_username and incoming_auth_password' do
        let(:update_params) { { incoming_auth_username: nil, incoming_auth_password: nil } }
        before { record.customers_auths.where(require_incoming_auth: true).delete_all }

        include_examples :updates_record
        include_examples :calls_event_with, :reload_incoming_auth

        context 'when was enabled' do
          let(:record_attrs) { super().merge(enabled: true) }

          include_examples :updates_record
          include_examples :calls_event_with, :reload_incoming_auth
        end
      end
    end
  end

  describe '#destroy' do
    subject do
      record.destroy
    end

    let!(:record) { FactoryGirl.create(:gateway, record_attrs) }
    let(:record_attrs) { { enabled: false } }

    context 'without incoming_auth' do
      include_examples :changes_records_qty_of, described_class, by: -1
      include_examples :destroys_record
      include_examples :does_not_call_event_with, :reload_incoming_auth
    end

    context 'with incoming_auth' do
      let(:record_attrs) { super().merge(incoming_auth_username: 'qwe', incoming_auth_password: 'asd') }

      include_examples :changes_records_qty_of, described_class, by: -1
      include_examples :destroys_record
      include_examples :calls_event_with, :reload_incoming_auth
    end
  end
end
