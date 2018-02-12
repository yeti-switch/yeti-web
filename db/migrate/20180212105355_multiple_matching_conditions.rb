class MultipleMatchingConditions < ActiveRecord::Migration
  def up
    execute %q{

      CREATE TABLE class4.customers_auth_normalized (
          id serial PRIMARY KEY,
          customers_auth_id integer NOT NULL REFERENCES class4.customers_auth(id),
          customer_id integer NOT NULL,
          rateplan_id integer NOT NULL,
          enabled boolean DEFAULT true NOT NULL,
          ip inet,
          account_id integer,
          gateway_id integer NOT NULL,
          src_rewrite_rule character varying,
          src_rewrite_result character varying,
          dst_rewrite_rule character varying,
          dst_rewrite_result character varying,
          src_prefix character varying DEFAULT ''::character varying NOT NULL,
          dst_prefix character varying DEFAULT ''::character varying NOT NULL,
          x_yeti_auth character varying,
          name character varying NOT NULL,
          dump_level_id integer DEFAULT 0 NOT NULL,
          capacity smallint,
          pop_id integer,
          uri_domain character varying,
          src_name_rewrite_rule character varying,
          src_name_rewrite_result character varying,
          diversion_policy_id integer DEFAULT 1 NOT NULL,
          diversion_rewrite_rule character varying,
          diversion_rewrite_result character varying,
          dst_numberlist_id smallint,
          src_numberlist_id smallint,
          routing_plan_id integer NOT NULL,
          allow_receive_rate_limit boolean DEFAULT false NOT NULL,
          send_billing_information boolean DEFAULT false NOT NULL,
          radius_auth_profile_id smallint,
          enable_audio_recording boolean DEFAULT false NOT NULL,
          src_number_radius_rewrite_rule character varying,
          src_number_radius_rewrite_result character varying,
          dst_number_radius_rewrite_rule character varying,
          dst_number_radius_rewrite_result character varying,
          radius_accounting_profile_id smallint,
          from_domain character varying,
          to_domain character varying,
          transport_protocol_id smallint,
          dst_number_min_length smallint DEFAULT 0 NOT NULL,
          dst_number_max_length smallint DEFAULT 100 NOT NULL,
          check_account_balance boolean DEFAULT true NOT NULL,
          require_incoming_auth boolean DEFAULT false NOT NULL,
          tag_action_id smallint,
          tag_action_value smallint[] DEFAULT '{}'::smallint[] NOT NULL,
          CONSTRAINT customers_auth_max_dst_number_length CHECK ((dst_number_min_length >= 0)),
          CONSTRAINT customers_auth_min_dst_number_length CHECK ((dst_number_min_length >= 0))
      );

      CREATE INDEX customers_auth_normalized_prefix_range_prefix_range1_idx ON customers_auth_normalized USING gist (((dst_prefix)::public.prefix_range), ((src_prefix)::public.prefix_range)) WHERE enabled;
      CREATE INDEX customers_auth_normalized_ip_prefix_range_prefix_range1_idx ON customers_auth_normalized USING gist (ip, ((dst_prefix)::public.prefix_range), ((src_prefix)::public.prefix_range));

      -- new columns
      ALTER TABLE class4.customers_auth ADD ips inet[] DEFAULT '{}';
      ALTER TABLE class4.customers_auth ADD src_prefixes varchar[] DEFAULT '{""}';
      ALTER TABLE class4.customers_auth ADD dst_prefixes varchar[] DEFAULT '{""}';
      ALTER TABLE class4.customers_auth ADD uri_domains varchar[] DEFAULT '{}';
      ALTER TABLE class4.customers_auth ADD from_domains varchar[] DEFAULT '{}';
      ALTER TABLE class4.customers_auth ADD to_domains varchar[] DEFAULT '{}';
      ALTER TABLE class4.customers_auth ADD x_yeti_auths varchar[] DEFAULT '{}';

      -- populate data
      UPDATE class4.customers_auth SET ips = array_append('{}', ip) WHERE ip IS NOT NULL;
      UPDATE class4.customers_auth SET src_prefixes = array_append('{}', src_prefix) WHERE src_prefix != '';
      UPDATE class4.customers_auth SET dst_prefixes = array_append('{}', dst_prefix) WHERE dst_prefix != '';
      UPDATE class4.customers_auth SET uri_domains = array_append('{}', uri_domain) WHERE uri_domain IS NOT NULL;
      UPDATE class4.customers_auth SET from_domains = array_append('{}', from_domain) WHERE from_domain IS NOT NULL;
      UPDATE class4.customers_auth SET to_domains = array_append('{}', to_domain) WHERE to_domain IS NOT NULL;
      UPDATE class4.customers_auth SET x_yeti_auths = array_append('{}', x_yeti_auth) WHERE x_yeti_auth IS NOT NULL;

      -- populate shadow-copy table
      INSERT INTO class4.customers_auth_normalized (
        customers_auth_id,
        customer_id,
        rateplan_id,
        enabled,
        ip,
        account_id,
        gateway_id,
        src_rewrite_rule,
        src_rewrite_result,
        dst_rewrite_rule,
        dst_rewrite_result,
        src_prefix,
        dst_prefix,
        x_yeti_auth,
        name,
        dump_level_id,
        capacity,
        pop_id,
        uri_domain,
        src_name_rewrite_rule,
        src_name_rewrite_result,
        diversion_policy_id,
        diversion_rewrite_rule,
        diversion_rewrite_result,
        dst_numberlist_id,
        src_numberlist_id,
        routing_plan_id,
        allow_receive_rate_limit,
        send_billing_information,
        radius_auth_profile_id,
        enable_audio_recording,
        src_number_radius_rewrite_rule,
        src_number_radius_rewrite_result,
        dst_number_radius_rewrite_rule,
        dst_number_radius_rewrite_result,
        radius_accounting_profile_id,
        from_domain,
        to_domain,
        transport_protocol_id,
        dst_number_min_length,
        dst_number_max_length,
        check_account_balance,
        require_incoming_auth,
        tag_action_id,
        tag_action_value
      )
      SELECT
        id AS customers_auth_id,
        customer_id,
        rateplan_id,
        enabled,
        ip,
        account_id,
        gateway_id,
        src_rewrite_rule,
        src_rewrite_result,
        dst_rewrite_rule,
        dst_rewrite_result,
        src_prefix,
        dst_prefix,
        x_yeti_auth,
        name,
        dump_level_id,
        capacity,
        pop_id,
        uri_domain,
        src_name_rewrite_rule,
        src_name_rewrite_result,
        diversion_policy_id,
        diversion_rewrite_rule,
        diversion_rewrite_result,
        dst_numberlist_id,
        src_numberlist_id,
        routing_plan_id,
        allow_receive_rate_limit,
        send_billing_information,
        radius_auth_profile_id,
        enable_audio_recording,
        src_number_radius_rewrite_rule,
        src_number_radius_rewrite_result,
        dst_number_radius_rewrite_rule,
        dst_number_radius_rewrite_result,
        radius_accounting_profile_id,
        from_domain,
        to_domain,
        transport_protocol_id,
        dst_number_min_length,
        dst_number_max_length,
        check_account_balance,
        require_incoming_auth,
        tag_action_id,
        tag_action_value
      FROM class4.customers_auth;
    }
  end

  def down
    execute %q{
      -- shadow copy of customers_auth
      DROP TABLE class4.customers_auth_normalized;

      -- new columns
      ALTER TABLE class4.customers_auth DROP ips;
      ALTER TABLE class4.customers_auth DROP src_prefixes;
      ALTER TABLE class4.customers_auth DROP dst_prefixes;
      ALTER TABLE class4.customers_auth DROP uri_domains;
      ALTER TABLE class4.customers_auth DROP from_domains;
      ALTER TABLE class4.customers_auth DROP to_domains;
      ALTER TABLE class4.customers_auth DROP x_yeti_auths;
    }
  end

  def stop_step
    true
  end
end
