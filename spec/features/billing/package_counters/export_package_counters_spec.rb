# frozen_string_literal: true

RSpec.describe 'Export Package counters', type: :feature do
  include_context :login_as_admin

  before { create(:billing_package_counter) }

  let!(:item) do
    create :billing_package_counter
  end

  before do
    visit package_counters_path(format: :csv)
  end

  subject { CSV.parse(page.body).slice(0, 2).transpose }

  it 'has expected header and values' do
    expect(subject).to match_array(
                         [
                           ['Id', item.id.to_s],
                           ['Account name', item.account.name.to_s],
                           ['Service name', item.service.name.to_s],
                           ['Prefix', item.prefix],
                           ['Exclude', item.exclude.to_s],
                           ['Duration', item.duration.to_s]
                         ]
                       )
  end
end
