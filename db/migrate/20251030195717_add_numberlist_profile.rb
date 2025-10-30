class AddNumberlistProfile < ActiveRecord::Migration[7.2]
  def up
    execute %q{
      alter table sys.customer_portal_access_profiles add outgoing_numberlists boolean not null default true;
    }
  end

  def down
    execute %q{
      alter table sys.customer_portal_access_profiles drop column outgoing_numberlists;
    }
  end

end
