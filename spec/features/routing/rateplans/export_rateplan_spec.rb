# frozen_string_literal: true

RSpec.describe 'Export Rateplan', type: :feature do
  include_context :login_as_admin

  before { create(:rateplan) }

  let!(:item) do
    create(:rateplan)
  end

  before do
    visit routing_rateplans_path(format: :csv)
  end

  subject { CSV.parse(page.body).slice(0, 2).transpose }

  it 'has expected header and values' do
    expect(subject).to match_array(
      [
        ['Id', item.id.to_s],
        ['Name', item.name],
        ['Profit control mode name', item.profit_control_mode_name]
      ]
    )
  end
end
