class AddIdentityVerstat < ActiveRecord::Migration[6.1]
  def up
    execute %q{

INSERT INTO switch20.switch_interface_out (id, name, type, custom, rank, for_radius) VALUES (1035, 'lega_identity_attestation_id', 'smallint', true, 1974, true);
INSERT INTO switch20.switch_interface_out (id, name, type, custom, rank, for_radius) VALUES (1036, 'lega_identity_verstat_id', 'smallint', true, 1975, true);

      alter type switch20.callprofile_ty
        add attribute lega_identity_attestation_id smallint,
        add attribute lega_identity_verstat_id smallint;


            }
  end

  def down
    execute %q{

      delete from switch20.switch_interface_out where id in (1035, 1036);

      alter type switch20.callprofile_ty
        drop attribute lega_identity_attestation_id,
        drop attribute lega_identity_verstat_id;


            }
  end
end
