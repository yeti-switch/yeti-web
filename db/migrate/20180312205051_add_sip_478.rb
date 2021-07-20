class AddSip478 < ActiveRecord::Migration[4.2]
  def up
    execute %q{
      insert into class4.disconnect_code(
        id,
        namespace_id,
        stop_hunting,
        pass_reason_to_originator,
        code,
        reason,
        success,
        successnozerolen,
        store_cdr,
        silently_drop
      ) values( 50, 2, false,false, 478, 'Unresolvable destination', false, false, true, false);

     }
  end

  def down
    execute %q{
    delete from class4.disconnect_code where id=50;
    }

  end

end
