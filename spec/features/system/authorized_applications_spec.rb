# frozen_string_literal: true

# Covers the AA "Authorized Applications" page: route helpers, policy class
# resolution, owner-scoped visibility, and the revoke action. Several of the
# bugs caught here in development would have been surfaced by this spec.
RSpec.describe 'Authorized Applications page', :js do
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

  context 'as a non-root admin' do
    include_context :login_as_admin

    it 'lists only the admin’s own active tokens' do
      visit authorized_applications_path
      expect(page).to have_content(my_token.id.to_s)
      expect(page).not_to have_content(other_token.id.to_s)
    end

    it 'revokes the token via the Revoke link' do
      visit authorized_applications_path
      accept_confirm { click_link 'Revoke' }
      expect(page).to have_content('Access token revoked.')
      expect(my_token.reload.revoked_at).to be_present
      expect(page).not_to have_content(my_token.id.to_s)
    end
  end

  context 'as a root admin' do
    let(:admin_user) { create(:admin_user, roles: ['root']) }

    before { login_as(admin_user, scope: :admin_user) }

    it 'lists all admins’ tokens' do
      visit authorized_applications_path
      expect(page).to have_content(my_token.id.to_s)
      expect(page).to have_content(other_token.id.to_s)
    end
  end
end
