# frozen_string_literal: true

RSpec.describe 'Info' do
  subject do
    visit info_path
  end

  include_context :login_as_admin

  it 'renders page' do
    subject
    expect(page).to have_content 'TOP10 tables in Routing database'
  end
end
