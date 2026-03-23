# frozen_string_literal: true

class AllowHeaderNullable < ActiveRecord::Migration[7.0]
  def up
    execute %q{
      ALTER TABLE class4.gateways
        ALTER COLUMN transfer_append_headers_req DROP NOT NULL,
        ALTER COLUMN transfer_append_headers_req DROP DEFAULT;

      UPDATE class4.gateways SET transfer_append_headers_req = NULL WHERE transfer_append_headers_req = '{}';
    }
  end

  def down
    execute %q{
      UPDATE class4.gateways SET transfer_append_headers_req = '{}' WHERE transfer_append_headers_req IS NULL;

      ALTER TABLE class4.gateways
        ALTER COLUMN transfer_append_headers_req SET NOT NULL,
        ALTER COLUMN transfer_append_headers_req SET DEFAULT '{}'::character varying[];
    }
  end
end
