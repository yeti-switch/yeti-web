class FixLnpRuleFk < ActiveRecord::Migration[7.0]
  def up
    execute %q{
      create index routing_plan_lnp_rules_database_id_idx on class4.routing_plan_lnp_rules using btree(database_id);
      ALTER TABLE class4.routing_plan_lnp_rules
        ADD CONSTRAINT routing_plan_lnp_rules_routing_plan_id_fkey FOREIGN KEY (routing_plan_id) REFERENCES class4.routing_plans(id);
    }
  end

  def down
    execute %q{
      drop index class4.routing_plan_lnp_rules_database_id_idx;
      ALTER TABLE class4.routing_plan_lnp_rules
        drop CONSTRAINT routing_plan_lnp_rules_routing_plan_id_fkey;
    }
  end

end
