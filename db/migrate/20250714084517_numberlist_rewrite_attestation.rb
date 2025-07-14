class NumberlistRewriteAttestation < ActiveRecord::Migration[7.2]
  def up
    execute %q{
      alter table class4.numberlists add rewrite_ss_status_id smallint;
      alter table class4.numberlist_items add rewrite_ss_status_id smallint;

      alter table data_import.import_numberlists
        add rewrite_ss_status_id smallint,
        add rewrite_ss_status_name varchar;
      alter table data_import.import_numberlist_items
        add rewrite_ss_status_id smallint,
        add rewrite_ss_status_name varchar;
    }
  end

  def down
    execute %q{
      alter table class4.numberlists drop column rewrite_ss_status_id;
      alter table class4.numberlist_items drop column rewrite_ss_status_id;

      alter table data_import.import_numberlists
        drop column rewrite_ss_status_id,
        drop column rewrite_ss_status_name;
      alter table data_import.import_numberlist_items
        drop column rewrite_ss_status_id,
        drop column rewrite_ss_status_name;
    }
  end
end
