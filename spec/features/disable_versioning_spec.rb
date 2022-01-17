# frozen_string_literal: true

RSpec.describe 'Disable versioning', type: :feature do
  include_context :login_as_admin

  context 'validate displaying the history sidebar and action item' do
    before do
      # Stub the config
      allow(YetiConfig.role_policy).to receive(:when_no_config).and_return('disallow')
      allow(YetiConfig.role_policy).to receive(:when_no_policy_class).and_return('raise')
      allow(YetiConfig).to receive(:versioning_disable_for_models).and_return(
        [
          'Routing::NumberlistItem',
          'Node'
        ]
      )
    end

    let(:vendor) { FactoryBot.create(:vendor) }
    let(:account) { FactoryBot.create(:account, contractor: vendor) }
    let(:numberlist_item) { FactoryBot.create(:numberlist_item) }
    let(:node) { FactoryBot.create(:node) }

    it 'should display history sidebar and action item for Account' do
      visit account_path(account)
      expect(page).to have_sidebar('History')
      expect(page).to have_action_item('History')
    end

    it 'should not display history sidebar and action item for Routing::NumberlistItem' do
      visit routing_numberlist_item_path(numberlist_item)
      expect(page).not_to have_sidebar('History')
      expect(page).not_to have_action_item('History')
    end

    it 'should not display history sidebar and action item for Node' do
      visit node_path(node)
      expect(page).not_to have_sidebar('History')
      expect(page).not_to have_action_item('History')
    end
  end
end
