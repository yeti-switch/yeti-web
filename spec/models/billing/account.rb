# frozen_string_literal: true

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
#  total_capacity                :integer
#  destination_rate_limit        :decimal(, )
#  max_call_duration             :integer
#

RSpec.describe Account do
  describe 'validates' do
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
end
