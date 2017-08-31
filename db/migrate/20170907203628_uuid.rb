class Uuid < ActiveRecord::Migration
  def up
    execute %q{
      CREATE EXTENSION "uuid-ossp" WITH SCHEMA public;

      ALTER TABLE billing.accounts ADD uuid uuid NOT NULL DEFAULT uuid_generate_v1() UNIQUE;
      ALTER TABLE class4.rateplans ADD uuid uuid NOT NULL DEFAULT public.uuid_generate_v1() UNIQUE;
      ALTER TABLE class4.destinations ADD uuid uuid NOT NULL DEFAULT uuid_generate_v1() UNIQUE;
    }
  end

  def down
    execute %q{
      ALTER TABLE billing.accounts DROP COLUMN uuid;
      ALTER TABLE class4.rateplans DROP COLUMN uuid;
      ALTER TABLE class4.destinations DROP COLUMN uuid;

      DROP EXTENSION "uuid-ossp";
    }
  end
end
