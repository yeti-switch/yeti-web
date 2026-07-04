# frozen_string_literal: true

# == Schema Information
#
# Table name: payments
#
#  id                     :bigint(8)        not null, primary key
#  amount                 :decimal(, )      not null
#  balance_before_payment :decimal(, )
#  metadata               :jsonb
#  notes                  :string
#  private_notes          :string
#  rolledback_at          :timestamptz
#  uuid                   :uuid             not null
#  created_at             :timestamptz      not null
#  account_id             :integer(4)       not null
#  currency_id            :integer(2)       not null
#  status_id              :integer(2)       default(20), not null
#  type_id                :integer(2)       default(20), not null
#
# Indexes
#
#  payments_account_id_idx  (account_id)
#  payments_uuid_key        (uuid) UNIQUE
#
# Foreign Keys
#
#  payments_account_id_fkey   (account_id => accounts.id)
#  payments_currency_id_fkey  (currency_id => currencies.id)
#
RSpec.describe Payment do
  describe 'currency assignment on create' do
    let(:account) { FactoryBot.create(:account) }

    it 'copies currency_id from account' do
      payment = described_class.create!(
        account: account,
        amount: 10,
        type_id: Payment::CONST::TYPE_ID_MANUAL,
        status_id: Payment::CONST::STATUS_ID_COMPLETED
      )
      expect(payment.currency_id).to eq account.currency_id
    end

    it 'keeps explicitly assigned currency_id' do
      other_currency = FactoryBot.create(:currency)
      payment = described_class.create!(
        account: account,
        currency: other_currency,
        amount: 10,
        type_id: Payment::CONST::TYPE_ID_MANUAL,
        status_id: Payment::CONST::STATUS_ID_COMPLETED
      )
      expect(payment.currency_id).to eq other_currency.id
    end
  end

  describe 'currency is readonly after create' do
    let(:currency) { FactoryBot.create(:currency) }
    let(:other_currency) { FactoryBot.create(:currency) }
    let(:account) { FactoryBot.create(:account, currency: currency) }
    let(:payment) { FactoryBot.create(:payment, account: account) }

    it 'rejects changing currency_id on update' do
      payment.currency_id = other_currency.id
      expect(payment.save).to be(false)
      expect(payment.errors.details[:currency_id]).to include(error: :readonly)
      expect(payment.errors[:currency_id]).to include('is readonly')
    end

    it 'allows unrelated updates that do not change currency' do
      Payment::Rollback.call(payment: payment)
      expect(payment.reload).to have_attributes(
        status_id: Payment::CONST::STATUS_ID_ROLLED_BACK,
        currency_id: currency.id
      )
    end
  end

  describe '.totals_per_currency' do
    let(:currency_a) { FactoryBot.create(:currency) }
    let(:currency_b) { FactoryBot.create(:currency) }
    let(:account_a) { FactoryBot.create(:account, currency: currency_a) }
    let(:account_b) { FactoryBot.create(:account, currency: currency_b) }

    before do
      FactoryBot.create(:payment, account: account_a, amount: 10)
      FactoryBot.create(:payment, account: account_a, amount: 5)
      FactoryBot.create(:payment, account: account_b, amount: 7)
    end

    it 'returns summed amount per currency name, sorted by name' do
      expected = [[currency_a.name, 15], [currency_b.name, 7]].sort_by(&:first)
      expect(described_class.totals_per_currency).to eq(expected)
    end

    it 'respects the current scope' do
      expect(described_class.where(currency_id: currency_b.id).totals_per_currency).to eq([[currency_b.name, 7]])
    end
  end
end
