# frozen_string_literal: true

class CreateDoorkeeperTables < ActiveRecord::Migration[7.2]
  def up
    execute %q{
      CREATE TABLE gui.oauth_applications (
        id           bigserial   PRIMARY KEY,
        name         varchar     NOT NULL,
        uid          varchar     NOT NULL,
        secret       varchar     NOT NULL,
        redirect_uri text        NOT NULL,
        scopes       varchar     NOT NULL DEFAULT '',
        confidential boolean     NOT NULL DEFAULT true,
        created_at   timestamptz NOT NULL,
        updated_at   timestamptz NOT NULL
      );
      CREATE UNIQUE INDEX index_oauth_applications_on_uid ON gui.oauth_applications (uid);

      CREATE TABLE gui.oauth_access_grants (
        id                bigserial   PRIMARY KEY,
        resource_owner_id bigint      NOT NULL REFERENCES gui.admin_users(id) ON DELETE CASCADE,
        application_id    bigint      NOT NULL REFERENCES gui.oauth_applications(id),
        token             varchar     NOT NULL,
        expires_in        integer     NOT NULL,
        redirect_uri      text        NOT NULL,
        scopes            varchar     NOT NULL DEFAULT '',
        created_at        timestamptz NOT NULL,
        revoked_at        timestamptz
      );
      CREATE INDEX index_oauth_access_grants_on_resource_owner_id ON gui.oauth_access_grants (resource_owner_id);
      CREATE INDEX index_oauth_access_grants_on_application_id    ON gui.oauth_access_grants (application_id);
      CREATE UNIQUE INDEX index_oauth_access_grants_on_token      ON gui.oauth_access_grants (token);

      CREATE TABLE gui.oauth_access_tokens (
        id                     bigserial   PRIMARY KEY,
        resource_owner_id      bigint      REFERENCES gui.admin_users(id) ON DELETE CASCADE,
        application_id         bigint      NOT NULL REFERENCES gui.oauth_applications(id),
        token                  varchar     NOT NULL,
        refresh_token          varchar,
        expires_in             integer,
        scopes                 varchar,
        created_at             timestamptz NOT NULL,
        revoked_at             timestamptz,
        previous_refresh_token varchar     NOT NULL DEFAULT ''
      );
      CREATE INDEX index_oauth_access_tokens_on_resource_owner_id ON gui.oauth_access_tokens (resource_owner_id);
      CREATE INDEX index_oauth_access_tokens_on_application_id    ON gui.oauth_access_tokens (application_id);
      CREATE UNIQUE INDEX index_oauth_access_tokens_on_token      ON gui.oauth_access_tokens (token);
      CREATE UNIQUE INDEX index_oauth_access_tokens_on_refresh_token ON gui.oauth_access_tokens (refresh_token);
    }
  end

  def down
    execute %q{
      DROP TABLE gui.oauth_access_tokens;
      DROP TABLE gui.oauth_access_grants;
      DROP TABLE gui.oauth_applications;
    }
  end
end
