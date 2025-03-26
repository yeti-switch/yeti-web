class AdditionalDc < ActiveRecord::Migration[7.2]
  def up
    execute %q{
      INSERT INTO class4.disconnect_code
        (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop)
      VALUES
        (1604, 2, false, true, 411, 'Length Required', NULL, NULL, false, false, true, false),
        (1605, 2, false, true, 430, 'Flow Failed', NULL, NULL, false, false, true, false),
        (1606, 2, false, true, 439, 'First Hop Lacks Outbound Support', NULL, NULL, false, false, true, false),
        (1607, 2, false, true, 470, 'Consent Needed', NULL, NULL, false, false, true, false),
        (1608, 2, false, true, 699, 'CAC exceeded', NULL, NULL, false, false, true, false);

      UPDATE class4.disconnect_code set code=433, reason='Anonymity Disallowed' WHERE id=8015;
      UPDATE class4.disconnect_code set code=428, reason='Use Identity Header' WHERE id=8018;
      UPDATE class4.disconnect_code set code=438, reason='Invalid Identity Header' WHERE id=8019;

    }
  end

  def down
    execute %q{
      delete from class4.disconnect_code where id in( 1604, 1605, 1606, 1607,1608);

      UPDATE class4.disconnect_code set code=500, reason='Anonymous calls not allowed' WHERE id=8015;
      UPDATE class4.disconnect_code set code=403, reason='Identity required' WHERE id=8018;
      UPDATE class4.disconnect_code set code=403, reason='Identity invalid' WHERE id=8019;
    }
  end

end