# frozen_string_literal: true

require 'spec_helper'

describe 'Export Payments', type: :feature do
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
        ['Account name', item.account.name],
        ['Amount', item.amount.to_s],
        ['Notes', item.notes.to_s],
        ['Created at', item.created_at.to_s]
      ]
    )
  end
end
