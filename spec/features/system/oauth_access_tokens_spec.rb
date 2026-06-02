# frozen_string_literal: true

# Covers the AA "OAuth Access Tokens" page: route helpers, policy class
# resolution, role-gated access (no owner scoping), and the revoke action.
RSpec.describe 'OAuth Access Tokens page', :js do
  include_context :with_oauth_routes

  let(:application) { create_oauth_application }
  let!(:my_token) do
    OauthAccessToken.create!(
      resource_owner_id: admin_user.id,
      application: application,
      scopes: 'mcp',
      expires_in: 3600
    )
  end
  let(:other_admin) { create(:admin_user) }
  let!(:other_token) do
    OauthAccessToken.create!(
      resource_owner_id: other_admin.id,
      application: application,
      scopes: 'mcp',
      expires_in: 3600
    )
  end

  # Scope ID assertions to the resource table — raw ID strings collide with
  # timestamps, version banners ("Routing 20260527160430"), and other digits
  # on the full page.
  def table_row_ids
    page.all('table.index_table tbody tr').map { |row| row['id'].to_s.sub(/^.*_/, '') }
  end

  context 'as an admin whose role allows access' do
    include_context :login_as_admin

    it 'lists every admin’s tokens, including revoked ones (no scoping)' do
      other_token.revoke
      visit oauth_access_tokens_path
      expect(table_row_ids).to contain_exactly(my_token.id.to_s, other_token.id.to_s)
      # Application is shown as "name (uid)" via OauthApplication#display_name.
      expect(page).to have_content("#{application.name} (#{application.uid})")
    end

    it 'exposes the Application, Resource owner and Scopes filters' do
      visit oauth_access_tokens_path
      within '.filter_form' do
        expect(page).to have_field('Application')
        expect(page).to have_field('Resource owner')
        expect(page).to have_field('Scopes')
      end
    end

    it 'filters the list by Resource owner' do
      visit oauth_access_tokens_path
      within('.filter_form') { select other_admin.username, from: 'Resource owner' }
      click_button 'Filter'
      expect(table_row_ids).to contain_exactly(other_token.id.to_s)
    end

    it 'revokes a token via the Revoke link, leaving the row in place' do
      visit oauth_access_tokens_path
      accept_confirm { find_link('Revoke', href: oauth_access_token_path(my_token)).click }
      expect(page).to have_content('Access token revoked.')
      expect(my_token.reload.revoked_at).to be_present
      # The row stays listed, but its Revoke link is gone now that it's revoked.
      expect(table_row_ids).to contain_exactly(my_token.id.to_s, other_token.id.to_s)
      expect(page).to have_no_link('Revoke', href: oauth_access_token_path(my_token))
      expect(page).to have_link('Revoke', href: oauth_access_token_path(other_token))
    end
  end

  context 'as an admin whose role denies access' do
    include_context :login_as_admin

    before do
      policy_roles = Rails.configuration.policy_roles.deep_merge(
        user: { :'System/OauthAccessToken' => { read: false } }
      )
      allow(Rails.configuration).to receive(:policy_roles).and_return(policy_roles)
    end

    it 'is redirected away from the page' do
      visit oauth_access_tokens_path
      expect(page).to have_current_path(root_path)
      expect(page).not_to have_css('table.index_table')
    end
  end
end
