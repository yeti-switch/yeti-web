# frozen_string_literal: true

# == Schema Information
#
# Table name: accounts
#
#  id                            :integer(4)       not null, primary key
#  balance                       :decimal(, )      not null
#  balance_high_threshold        :decimal(, )
#  balance_low_threshold         :decimal(, )
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
  it do
    should validate_numericality_of(:origination_capacity).is_less_than_or_equal_to(Yeti::ActiveRecord::PG_MAX_SMALLINT)
    should validate_numericality_of(:termination_capacity).is_less_than_or_equal_to(Yeti::ActiveRecord::PG_MAX_SMALLINT)
  end

  context '#destroy' do
    let!(:account) { create(:account) }

    subject do
      account.destroy!
    end

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
