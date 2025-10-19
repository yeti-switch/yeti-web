class NumberlistManagement < ActiveRecord::Migration[7.2]

  def up
    execute %q{
      alter table sys.api_access add allow_outgoing_numberlists_ids integer[] not null default '{}'::integer[];
    }
  end

  def down
    execute %q{
      alter table sys.api_access drop column allow_outgoing_numberlists_ids;
    }
  end

end
