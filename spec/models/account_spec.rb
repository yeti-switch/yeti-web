# == Schema Information
#
# Table name: accounts
#
#  id                            :integer          not null, primary key
#  contractor_id                 :integer          not null
#  balance                       :decimal(, )      not null
#  min_balance                   :decimal(, )      not null
#  max_balance                   :decimal(, )      not null
#  name                          :string           not null
#  origination_capacity          :integer
#  termination_capacity          :integer
#  customer_invoice_period_id    :integer
#  customer_invoice_template_id  :integer
#  vendor_invoice_template_id    :integer
#  next_customer_invoice_at      :datetime
#  next_vendor_invoice_at        :datetime
#  vendor_invoice_period_id      :integer
#  send_invoices_to              :integer          is an Array
#  timezone_id                   :integer          default(1), not null
#  next_customer_invoice_type_id :integer
#  next_vendor_invoice_type_id   :integer
#  balance_high_threshold        :decimal(, )
#  balance_low_threshold         :decimal(, )
#  send_balance_notifications_to :integer          is an Array
#  uuid                          :uuid             not null
#  external_id                   :integer
#  vat                           :decimal(, )      default(0.0), not null
#

require 'spec_helper'

describe Account, type: :model do

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
        }.from(accounts.map(&:id)).to(accounts.map(&:id).values_at(0,2))
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
