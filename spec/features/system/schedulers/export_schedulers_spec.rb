# frozen_string_literal: true

RSpec.describe 'Export Schedulers', type: :feature do
  include_context :login_as_admin

  let!(:item) do
    create(:scheduler)
  end

  before do
    visit system_schedulers_path(format: :csv)
  end

  subject { CSV.parse(page.body).slice(0, 2).transpose }

  it 'has expected header and values' do
    expect(subject).to match_array(
                         [
                           ['Id', item.id.to_s],
                           ['Name', item.name],
                           ['Enabled', item.enabled.to_s],
                           ['Use reject calls', item.use_reject_calls.to_s],
                           ['Timezone', item.timezone]
                         ]
                       )
  end
end
