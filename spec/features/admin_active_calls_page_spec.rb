require 'spec_helper'

describe 'Active Calls page', type: :feature do

  let(:admin_user) { create :admin_user }
  before { login_as(admin_user, scope: :admin_user) }

  context 'index' do
    before { visit active_calls_path }

    it 'renders page without errors' do
      expect(page).to have_content('Please, specify at least 1 filter')
    end
  end

end
