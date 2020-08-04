# frozen_string_literal: true

# == Schema Information
#
# Table name: invoices
#
#  id                       :integer(4)       not null, primary key
#  amount                   :decimal(, )      not null
#  billing_duration         :bigint(8)        not null
#  calls_count              :bigint(8)        not null
#  calls_duration           :bigint(8)        not null
#  end_date                 :datetime         not null
#  first_call_at            :datetime
#  first_successful_call_at :datetime
#  last_call_at             :datetime
#  last_successful_call_at  :datetime
#  start_date               :datetime         not null
#  successful_calls_count   :bigint(8)
#  vendor_invoice           :boolean          default(FALSE), not null
#  created_at               :datetime         not null
#  account_id               :integer(4)       not null
#  contractor_id            :integer(4)
#  state_id                 :integer(2)       default(1), not null
#  type_id                  :integer(2)       not null
#
# Foreign Keys
#
#  invoices_state_id_fkey  (state_id => invoice_states.id)
#  invoices_type_id_fkey   (type_id => invoice_types.id)
#
RSpec.describe InvoiceGenerator do
  describe '#save!' do
    subject do
      described_class.new(invoice).save!
    end

    let(:invoice) { Billing::Invoice.new(invoice_params) }
    let(:invoice_params) do
      { start_date: '2020-08-04 00:00:00', end_date: '2020-08-05 00:00:00' }
    end

    context 'with manual vendor invoice' do
      let(:invoice_params) do
        super().merge type_id: Billing::InvoiceType::MANUAL,
                      contractor_id: vendor.id,
                      account_id: account.id,
                      vendor_invoice: 'true'
      end

      let!(:vendor) { FactoryBot.create(:vendor) }
      let!(:account) { FactoryBot.create(:account, contractor: vendor) }

      it 'creates invoice with correct params' do
        subject
        expect(invoice.reload).to be_persisted
        expect(invoice).to have_attributes(
                               contractor_id: vendor.id,
                               account_id: account.id,
                               start_date: Time.parse('2020-08-04 00:00:00'),
                               end_date: Time.parse('2020-08-05 00:00:00'),
                               vendor_invoice: true,
                               type_id: Billing::InvoiceType::MANUAL,
                               state_id: Billing::InvoiceState::PENDING,
                               amount: 0,
                               billing_duration: 0,
                               calls_count: 0,
                               calls_duration: 0,
                               first_call_at: nil,
                               first_successful_call_at: nil,
                               last_call_at: nil,
                               last_successful_call_at: nil,
                               successful_calls_count: 0
                             )
      end
    end
  end
end
