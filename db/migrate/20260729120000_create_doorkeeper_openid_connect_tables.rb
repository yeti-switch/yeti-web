# frozen_string_literal: true

# Storage for the OIDC `nonce`, which has to survive between the authorization
# request (where the client sends it) and the token exchange (where it must be
# echoed into the id_token). Without this table every login fails on the
# client's replay check.
class CreateDoorkeeperOpenidConnectTables < ActiveRecord::Migration[7.2]
  def up
    execute %q{
      CREATE TABLE gui.oauth_openid_requests (
        id              bigserial PRIMARY KEY,
        access_grant_id bigint    NOT NULL REFERENCES gui.oauth_access_grants(id) ON DELETE CASCADE,
        nonce           varchar   NOT NULL
      );
      CREATE INDEX index_oauth_openid_requests_on_access_grant_id ON gui.oauth_openid_requests (access_grant_id);
    }
  end

  def down
    execute %q{
      DROP TABLE gui.oauth_openid_requests;
    }
  end
end
