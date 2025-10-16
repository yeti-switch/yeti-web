# frozen_string_literal: true

RSpec.describe 'Export Payments', type: :feature do
  include_context :login_as_admin

  before { create(:payment) }

  let!(:item) do
    create :payment
  end

  before do
    visit payments_path(format: :csv)
  end

  subject { CSV.parse(page.body).slice(0, 2).transpose }

  it 'has expected header and values' do
    expect(subject).to match_array(
      [
        ['Id', item.id.to_s],
        ['Uuid', item.uuid.to_s],
        ['Account name', item.account.name],
        ['Amount', item.amount.to_s],
        ['Notes', item.notes.to_s],
        ['Private notes', item.private_notes.to_s],
        ['Status', item.status],
        ['Type name', item.type_name],
        ['Created at', item.created_at.to_s],
        ['Balance before payment', item.balance_before_payment.to_s],
        ['Rolledback at', item.rolledback_at.to_s]
      ]
    )
  end
end
