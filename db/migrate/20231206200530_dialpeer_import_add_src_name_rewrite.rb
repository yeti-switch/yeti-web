class DialpeerImportAddSrcNameRewrite < ActiveRecord::Migration[7.0]
  def up
    execute %q{
      alter table data_import.import_dialpeers
        add src_name_rewrite_rule varchar,
        add src_name_rewrite_result varchar;
    }
  end

  def down
    execute %q{
      alter table data_import.import_dialpeers
        drop column src_name_rewrite_rule,
        drop column src_name_rewrite_result;
    }
  end
end
