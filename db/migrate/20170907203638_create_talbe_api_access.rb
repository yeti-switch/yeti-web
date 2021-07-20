class CreateTalbeApiAccess < ActiveRecord::Migration[4.2]
  def up
    execute %q{
      CREATE TABLE sys.api_access (
        id serial PRIMARY KEY,
        customer_id integer NOT NULL REFERENCES public.contractors(id),
        login varchar NOT NULL UNIQUE,
        password_digest varchar NOT NULL,
        account_ids integer[] NOT NULL DEFAULT '{}',
        allowed_ips inet[] NOT NULL DEFAULT '{"0.0.0.0/0"}'
      );
    }
  end

  def down
    execute %q{
      DROP TABLE sys.api_access;
    }
  end
end
