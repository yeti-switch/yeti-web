class CustomersAuthRenameMatchConditionsColumns < ActiveRecord::Migration
  def up
    execute %q{
      -- deprecated columns
      ALTER TABLE class4.customers_auth DROP ip;
      ALTER TABLE class4.customers_auth DROP src_prefix;
      ALTER TABLE class4.customers_auth DROP dst_prefix;
      ALTER TABLE class4.customers_auth DROP uri_domain;
      ALTER TABLE class4.customers_auth DROP from_domain;
      ALTER TABLE class4.customers_auth DROP to_domain;
      ALTER TABLE class4.customers_auth DROP x_yeti_auth;

      -- rename '-s' columns
      ALTER TABLE class4.customers_auth RENAME ips TO ip;
      ALTER TABLE class4.customers_auth RENAME src_prefixes TO src_prefix;
      ALTER TABLE class4.customers_auth RENAME dst_prefixes TO dst_prefix;
      ALTER TABLE class4.customers_auth RENAME uri_domains TO uri_domain;
      ALTER TABLE class4.customers_auth RENAME from_domains TO from_domain;
      ALTER TABLE class4.customers_auth RENAME to_domains TO to_domain;
      ALTER TABLE class4.customers_auth RENAME x_yeti_auths TO x_yeti_auth;

    }
  end

  def down
    execute %q{
      -- rename '-s' columns
      ALTER TABLE class4.customers_auth RENAME ip TO ips;
      ALTER TABLE class4.customers_auth RENAME src_prefix TO src_prefixes;
      ALTER TABLE class4.customers_auth RENAME dst_prefix TO dst_prefixes;
      ALTER TABLE class4.customers_auth RENAME uri_domain TO uri_domains;
      ALTER TABLE class4.customers_auth RENAME from_domain TO from_domains;
      ALTER TABLE class4.customers_auth RENAME to_domain TO to_domains;
      ALTER TABLE class4.customers_auth RENAME x_yeti_auth TO x_yeti_auths;

      -- deprecated columns
      ALTER TABLE class4.customers_auth
        ADD ip inet,
        ADD src_prefix character varying NOT NULL DEFAULT '',
        ADD dst_prefix character varying NOT NULL DEFAULT '',
        ADD uri_domain character varying,
        ADD from_domain character varying,
        ADD to_domain character varying,
        ADD x_yeti_auth character varying;

      UPDATE class4.customers_auth SET
        ip = ips[1],
        uri_domain = uri_domains[1],
        from_domain = from_domains[1],
        to_domain = to_domains[1],
        x_yeti_auth = x_yeti_auths[1];

      UPDATE class4.customers_auth SET src_prefix = src_prefixes[1] WHERE src_prefixes[1] != '';
      UPDATE class4.customers_auth SET dst_prefix = dst_prefixes[1] WHERE dst_prefixes[1] != '';

    }
  end
end
