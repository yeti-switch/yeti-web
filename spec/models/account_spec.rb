# frozen_string_literal: true

# == Schema Information
#
# Table name: billing.accounts
#
#  id                     :integer(4)       not null, primary key
#  balance                :decimal(, )      not null
#  destination_rate_limit :decimal(, )
#  invoice_ref_template   :string           default("$id"), not null
#  max_balance            :decimal(, )      not null
#  max_call_duration      :integer(4)
#  min_balance            :decimal(, )      not null
#  name                   :string           not null
#  next_invoice_at        :timestamptz
#  origination_capacity   :integer(2)
#  send_invoices_to       :integer(4)       is an Array
#  termination_capacity   :integer(2)
#  total_capacity         :integer(2)
#  uuid                   :uuid             not null
#  vat                    :decimal(, )      default(0.0), not null
#  contractor_id          :integer(4)       not null
#  external_id            :bigint(8)
#  invoice_period_id      :integer(2)
#  invoice_template_id    :integer(4)
#  next_invoice_type_id   :integer(2)
#  timezone_id            :integer(4)       default(1), not null
#
# Indexes
#
#  accounts_contractor_id_idx  (contractor_id)
#  accounts_external_id_key    (external_id) UNIQUE
#  accounts_name_key           (name) UNIQUE
#  accounts_uuid_key           (uuid) UNIQUE
#
# Foreign Keys
#
#  accounts_contractor_id_fkey  (contractor_id => contractors.id)
#  accounts_timezone_id_fkey    (timezone_id => timezones.id)
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
        invoice_period_id: nil,
        invoice_template_id: nil,
        next_invoice_at: nil,
        send_invoices_to: nil,
        timezone_id: utc_timezone.id,
        next_invoice_type_id: nil,
        external_id: nil,
        vat: 0.0,
        total_capacity: nil,
        destination_rate_limit: nil,
        max_call_duration: nil
      }
    end
    let(:expected_account_attrs) { create_params.reverse_merge(default_params) }
    let(:expected_balance_notification_setting_attrs) do
      {
        low_threshold: nil,
        high_threshold: nil,
        send_to: nil
      }
    end

    shared_examples :creates_account do
      include_examples :creates_record do
        let(:expected_record_attrs) { expected_account_attrs }
      end

      it 'creates account_balance_notification_setting' do
        expect { subject }.to change { AccountBalanceNotificationSetting.count }.by(1)
        expect(subject.balance_notification_setting).to have_attributes(expected_balance_notification_setting_attrs)
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
        super().merge next_invoice_at: nil,
                      next_invoice_type_id: nil,
                      invoice_period_id: nil
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
      is_expected.to validate_numericality_of(:origination_capacity).is_less_than_or_equal_to(ApplicationRecord::PG_MAX_SMALLINT)
      is_expected.to validate_numericality_of(:termination_capacity).is_less_than_or_equal_to(ApplicationRecord::PG_MAX_SMALLINT)
    end

    it do
      is_expected.to validate_numericality_of(:origination_capacity).is_less_than_or_equal_to(ApplicationRecord::PG_MAX_SMALLINT)
      is_expected.to validate_numericality_of(:termination_capacity).is_less_than_or_equal_to(ApplicationRecord::PG_MAX_SMALLINT)
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

    let!(:account) { create(:account, account_attrs) }
    let(:account_attrs) { {} }

    context 'without linked ApiAccess records' do
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

    context 'when Account has related CDR Exports' do
      let(:account_attrs) { { contractor: customer } }
      let!(:customer) { create(:customer) }
      let!(:cdr_export) { create(:cdr_export, customer_account: account) }

      it 'removes Account successfully' do
        expect { subject }.to change { described_class.count }.by(-1)
        expect(Account.where(id: account.id)).not_to be_exists
      end

      it 'keeps ApiAccess records' do
        expect { subject }.not_to change { CdrExport.count }
        expect(cdr_export.reload).to have_attributes(customer_account: nil)
      end
    end

    context 'when Account is linked to RateManagement Project' do
      let!(:projects) { FactoryBot.create_list(:rate_management_project, 3, :filled, vendor: account.contractor, account: account) }

      it 'should raise validation error' do
        expect { subject }.to raise_error(ActiveRecord::RecordNotDestroyed)

        error_message = "Can't be deleted because linked to Rate Management Project(s) ##{projects.map(&:id).join(', #')}"
        expect(account.errors.to_a).to contain_exactly error_message

        expect(Account).to be_exists(account.id)
      end
    end

    context 'when Account is linked to RateManagement Pricelist Item' do
      let(:new_account) { FactoryBot.create(:account) }
      let(:project) { FactoryBot.create(:rate_management_project, :filled, account: new_account, vendor: new_account.contractor) }
      let!(:pricelists) do
        FactoryBot.create_list(:rate_management_pricelist, 2, pricelist_state, project: project)
      end
      let(:pricelist_state) { :new }
      let!(:pricelist_items) do
        [
          FactoryBot.create_list(:rate_management_pricelist_item, 2, :filed_from_project, pricelist: pricelists[0], account: account),
          FactoryBot.create_list(:rate_management_pricelist_item, 2, :filed_from_project, pricelist: pricelists[1], account: account)
        ].flatten
      end

      it 'should raise validation error' do
        expect { subject }.to raise_error(ActiveRecord::RecordNotDestroyed)

        error_message = "Can't be deleted because linked to not applied Rate Management Pricelist(s) ##{pricelists.map(&:id).join(', #')}"
        expect(account.errors.to_a).to contain_exactly error_message

        expect(Account).to be_exists(account.id)
      end

      context 'when pricelist has dialpeers_detected state' do
        let(:pricelist_state) { :dialpeers_detected }

        it 'should raise validation error' do
          expect { subject }.to raise_error(ActiveRecord::RecordNotDestroyed)

          error_message = "Can't be deleted because linked to not applied Rate Management Pricelist(s) ##{pricelists.map(&:id).join(', #')}"
          expect(account.errors.to_a).to contain_exactly error_message

          expect(Account).to be_exists(account.id)
        end
      end

      context 'when pricelist has applied state' do
        let(:pricelist_state) { :applied }

        it 'should delete account' do
          expect { subject }.not_to raise_error
          expect(Account).not_to be_exists(account.id)

          pricelist_items.each do |item|
            expect(item.reload.account_id).to be_nil
          end
        end
      end
    end

    context 'when Account is linked to RateManagement Project and Pricelist Items' do
      let!(:project) { FactoryBot.create(:rate_management_project, :filled, vendor: account.contractor, account: account) }
      let!(:pricelist) { FactoryBot.create(:rate_management_pricelist, project: project, items_qty: 1) }

      it 'should raise validation error' do
        expect { subject }.to raise_error(ActiveRecord::RecordNotDestroyed)

        error_messages = [
          "Can't be deleted because linked to Rate Management Project(s) ##{project.id}",
          "Can't be deleted because linked to not applied Rate Management Pricelist(s) ##{pricelist.id}"
        ]
        expect(account.errors).to contain_exactly *error_messages

        expect(Account).to be_exists(account.id)
      end
    end
  end
end
