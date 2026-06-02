# frozen_string_literal: true

class AddPkceToOauthAccessGrants < ActiveRecord::Migration[7.2]
  def up
    execute %q{
      ALTER TABLE gui.oauth_access_grants
        ADD COLUMN code_challenge        varchar,
        ADD COLUMN code_challenge_method varchar;
    }
  end

  def down
    execute %q{
      ALTER TABLE gui.oauth_access_grants
        DROP COLUMN code_challenge,
        DROP COLUMN code_challenge_method;
    }
  end
end
