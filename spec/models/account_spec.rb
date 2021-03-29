# frozen_string_literal: true

# == Schema Information
#
# Table name: accounts
#
#  id                            :integer(4)       not null, primary key
#  balance                       :decimal(, )      not null
#  balance_high_threshold        :decimal(, )
#  balance_low_threshold         :decimal(, )
#  customer_invoice_ref_template :string           default("$id"), not null
#  destination_rate_limit        :decimal(, )
#  max_balance                   :decimal(, )      not null
#  max_call_duration             :integer(4)
#  min_balance                   :decimal(, )      not null
#  name                          :string           not null
#  next_customer_invoice_at      :datetime
#  next_vendor_invoice_at        :datetime
#  origination_capacity          :integer(2)
#  send_balance_notifications_to :integer(4)       is an Array
#  send_invoices_to              :integer(4)       is an Array
#  termination_capacity          :integer(2)
#  total_capacity                :integer(2)
#  uuid                          :uuid             not null
#  vat                           :decimal(, )      default(0.0), not null
#  vendor_invoice_ref_template   :string           default("$id"), not null
#  contractor_id                 :integer(4)       not null
#  customer_invoice_period_id    :integer(2)
#  customer_invoice_template_id  :integer(4)
#  external_id                   :bigint(8)
#  next_customer_invoice_type_id :integer(2)
#  next_vendor_invoice_type_id   :integer(2)
#  timezone_id                   :integer(4)       default(1), not null
#  vendor_invoice_period_id      :integer(2)
#  vendor_invoice_template_id    :integer(4)
#
# Indexes
#
#  accounts_external_id_key  (external_id) UNIQUE
#  accounts_name_key         (name) UNIQUE
#  accounts_uuid_key         (uuid) UNIQUE
#
# Foreign Keys
#
#  accounts_contractor_id_fkey             (contractor_id => contractors.id)
#  accounts_invoice_period_id_fkey         (customer_invoice_period_id => invoice_periods.id)
#  accounts_timezone_id_fkey               (timezone_id => timezones.id)
#  accounts_vendor_invoice_period_id_fkey  (vendor_invoice_period_id => invoice_periods.id)
#

RSpec.describe Account, type: :model do
  let(:server_time_zone) { ActiveSupport::TimeZone.new Rails.application.config.time_zone }
  let(:utc_timezone) { System::Timezone.find_by!(abbrev: 'UTC') }
  let(:la_timezone) { FactoryBot.create(:timezone, :los_angeles) }
  let(:kiev_timezone) { FactoryBot.create(:timezone, :kiev) }

  shared_examples :updates_account do
    # let(:expected_account_attrs) {}

    it 'updates account', :aggregate_failures do
      expect(subject).to eq(true)
      expect(account.errors.messages).to be_empty
      expect(account.reload).to have_attributes(expected_account_attrs)
    end
  end

  describe '.create' do
    subject do
      travel_to(current_time) do
        described_class.create(create_params)
      end
    end

    let(:current_time) { Time.now }
    let(:create_params) { { name: 'test', contractor_id: contractor.id } }
    let!(:contractor) { FactoryBot.create(:vendor) }
    let(:default_params) do
      {
        balance: 0.0,
        min_balance: 0.0,
        max_balance: 0.0,
        origination_capacity: nil,
        termination_capacity: nil,
        customer_invoice_period_id: nil,
        customer_invoice_template_id: nil,
        vendor_invoice_template_id: nil,
        next_customer_invoice_at: nil,
        next_vendor_invoice_at: nil,
        vendor_invoice_period_id: nil,
        send_invoices_to: nil,
        timezone_id: utc_timezone.id,
        next_customer_invoice_type_id: nil,
        next_vendor_invoice_type_id: nil,
        balance_high_threshold: nil,
        balance_low_threshold: nil,
        send_balance_notifications_to: nil,
        external_id: nil,
        vat: 0.0,
        total_capacity: nil,
        destination_rate_limit: nil,
        max_call_duration: nil
      }
    end
    let(:expected_account_attrs) { create_params.reverse_merge(default_params) }

    shared_examples :creates_account do
      include_examples :creates_record do
        let(:expected_record_attrs) { expected_account_attrs }
      end
    end

    context 'with empty params' do
      let(:create_params) { {} }

      include_examples :does_not_create_record, errors: {
        name: "can't be blank",
        contractor: 'must exist'
      }
    end

    context 'with only required params' do
      let(:expected_account_attrs) do
        super().merge next_customer_invoice_at: nil,
                      next_customer_invoice_type_id: nil,
                      customer_invoice_period_id: nil,
                      next_vendor_invoice_at: nil,
                      next_vendor_invoice_type_id: nil,
                      vendor_invoice_period_id: nil
      end

      include_examples :creates_account

      context 'with customer contractor' do
        let!(:contractor) { FactoryBot.create(:customer) }

        include_examples :creates_account
      end
    end
  end

  describe '#valid?' do
    it do
      is_expected.to validate_numericality_of(:origination_capacity).is_less_than_or_equal_to(Yeti::ActiveRecord::PG_MAX_SMALLINT)
      is_expected.to validate_numericality_of(:termination_capacity).is_less_than_or_equal_to(Yeti::ActiveRecord::PG_MAX_SMALLINT)
    end

    it do
      is_expected.to validate_numericality_of(:origination_capacity).is_less_than_or_equal_to(Yeti::ActiveRecord::PG_MAX_SMALLINT)
      is_expected.to validate_numericality_of(:termination_capacity).is_less_than_or_equal_to(Yeti::ActiveRecord::PG_MAX_SMALLINT)
    end

    context '#min_balance' do
      it { is_expected.to_not allow_value('').for :min_balance }
      it { is_expected.to_not allow_value(nil).for :min_balance }
      it { is_expected.to_not allow_value('string').for :min_balance }

      it { is_expected.to allow_value(2).for :min_balance }
      it { is_expected.to allow_value(2.5).for :min_balance }

      it "is_expected.to have error: can't be blank" do
        record = FactoryBot.build :account, min_balance: nil
        expect(record).to_not be_valid
        expect(record.errors[:min_balance]).to include "can't be blank"
      end
    end

    context '#max_balance' do
      it { is_expected.to_not allow_value('').for :max_balance }
      it { is_expected.to_not allow_value(nil).for :max_balance }
      it { is_expected.to_not allow_value('string').for :max_balance }

      it { is_expected.to allow_value(2).for :max_balance }
      it { is_expected.to allow_value(2.5).for :max_balance }

      it "is_expected.to have error: can't be blank" do
        record = FactoryBot.build :account, max_balance: nil
        expect(record).to_not be_valid
        expect(record.errors[:max_balance]).to include "can't be blank"
      end
    end
  end

  describe '#destroy!' do
    subject do
      account.destroy!
    end

    let!(:account) { create(:account) }

    context 'wihtout linked ApiAccess records' do
      let!(:api_access) { create(:api_access) }

      it 'removes Account successfully' do
        expect { subject }.to change { described_class.count }.by(-1)
      end

      it 'keeps ApiAccess records' do
        expect { subject }.not_to change { System::ApiAccess.count }
      end
    end

    context 'when Account is linked from ApiAccess' do
      let!(:api_access) { create(:api_access) }
      let(:accounts) { create_list(:account, 3, contractor: api_access.customer) }

      before do
        api_access.update!(account_ids: accounts.map(&:id))
      end

      subject do
        accounts.second.destroy!
      end

      it 'update relaated ApiAccess#account_ids (removes second element from array)' do
        expect { subject }.to change {
          api_access.reload.account_ids
        }.from(accounts.map(&:id)).to(accounts.map(&:id).values_at(0, 2))
      end
    end

    context 'when Account has Payments' do
      let!(:p1) do
        create(:payment, account: account)
      end
      let!(:p2) do
        create(:payment) # for another account
      end

      it 'removes all related Payments' do
        expect { subject }.to change {
          Payment.pluck(:id)
        }.from([p1.id, p2.id]).to([p2.id])
      end
    end

    context 'when Account has related CustomersAuth' do
      let(:customers_auth) { create(:customers_auth) }
      let(:account) { customers_auth.account }

      it 'throw error' do
        expect { subject }.to raise_error(ActiveRecord::RecordNotDestroyed)
      end
    end

    context 'when Account has related Dialpeer' do
      let(:dialpeer) { create(:dialpeer) }
      let(:account) { dialpeer.account }

      it 'throw error' do
        expect { subject }.to raise_error(ActiveRecord::RecordNotDestroyed)
      end
    end
  end
end
