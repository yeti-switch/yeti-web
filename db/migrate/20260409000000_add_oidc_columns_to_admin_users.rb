# frozen_string_literal: true

class AddOidcColumnsToAdminUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :admin_users, :provider, :string
    add_column :admin_users, :uid, :string
    add_column :admin_users, :oidc_raw_info, :jsonb

    add_index :admin_users, %i[provider uid],
              unique: true,
              where: 'provider IS NOT NULL AND uid IS NOT NULL',
              name: 'index_admin_users_on_provider_and_uid'
  end
end
