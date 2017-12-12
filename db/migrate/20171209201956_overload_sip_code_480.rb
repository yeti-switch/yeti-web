class OverloadSipCode480 < ActiveRecord::Migration
  def up
    execute %q{
      update switch13.resource_type set reject_code = 480;
    }
  end
  def down
    execute %q{
      update switch13.resource_type set reject_code = 503;
    }
  end
end
