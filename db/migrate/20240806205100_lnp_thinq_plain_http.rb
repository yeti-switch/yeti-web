class LnpThinqPlainHttp < ActiveRecord::Migration[7.0]
  def up
    execute %q{
      ALTER TABLE class4.lnp_databases_thinq add plain_http boolean not null default false;
    }
  end

  def down
    execute %q{
      ALTER TABLE class4.lnp_databases_thinq drop column plain_http;
    }
  end

end
