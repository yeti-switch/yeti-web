# frozen_string_literal: true

# Persistent per-resource sorting — opt-in, stored on the AdminUser in
# gui.admin_users.saved_sortings. See lib/active_admin/sorting_saver/controller.rb.
RSpec.describe 'Persistent index sorting', type: :request do
  include_context :login_as_admin

  let!(:user_a) { create(:admin_user, username: 'aaa_user') }
  let!(:user_z) { create(:admin_user, username: 'zzz_user') }

  # The padlock toggle posts via XHR; mimic that.
  let(:xhr) { { 'X-Requested-With' => 'XMLHttpRequest' } }

  def stored_sortings
    admin_user.reload.saved_sortings
  end

  def enable_with(order)
    get admin_users_path(order: order, sorting_switch: 'true'), headers: xhr
  end

  describe 'enabling the toggle' do
    it 'persists the current order for this resource, keyed by controller' do
      enable_with('username_desc')

      expect(stored_sortings.values).to contain_exactly(
        'enabled' => true, 'order' => 'username_desc'
      )
    end
  end

  describe 'restoring on a later visit' do
    before { enable_with('username_desc') }

    it 'applies the stored order when the request carries none' do
      get admin_users_path

      expect(response.body.index('zzz_user')).to be < response.body.index('aaa_user')
    end

    it 'yields to an explicit ?order=, which becomes the new stored order' do
      get admin_users_path(order: 'username_asc')

      expect(stored_sortings.values.first).to include('order' => 'username_asc')
    end
  end

  describe 'disabling the toggle' do
    before { enable_with('username_desc') }

    it 'drops the entry so the resource falls back to its default sort' do
      get admin_users_path(sorting_switch: 'false'), headers: xhr

      expect(stored_sortings).to eq({})
    end
  end
end
