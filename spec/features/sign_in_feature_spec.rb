# frozen_string_literal: true

RSpec.describe 'the signin process', type: :feature do
  subject do
    login_as(admin_user, scope: :admin_user)
  end

  let!(:admin_user) { FactoryBot.create(:admin_user) }

  it 'signs me in' do
    subject
    expect { visit root_path }.to_not raise_error
  end
end
