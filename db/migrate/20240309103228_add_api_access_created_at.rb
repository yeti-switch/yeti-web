class AddApiAccessCreatedAt < ActiveRecord::Migration[7.0]
  def up
    execute %q{
      alter table sys.api_access
        add created_at timestamptz,
        add updated_at timestamptz;
    }
  end

  def down
    execute %q{
      alter table sys.api_access
        drop column created_at,
        drop column updated_at;
    }
  end
end
