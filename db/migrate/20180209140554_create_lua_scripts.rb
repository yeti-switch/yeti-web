class CreateLuaScripts < ActiveRecord::Migration
  def up
    execute %q{
      CREATE TABLE sys.lua_scripts (
        id serial PRIMARY KEY,
        name character varying NOT NULL UNIQUE,
        source character varying NOT NULL,
        created_at timestamp without time zone NOT NULL,
        updated_at timestamp without time zone NOT NULL
      );
    }
  end

  def down
    execute %q{
      DROP TABLE sys.lua_scripts;
    }
  end
end
