class AddWebrtcDialerToCustomerPortalAccessProfiles < ActiveRecord::Migration[7.2]

  def up
    execute %q{
      alter table sys.customer_portal_access_profiles add webrtc_dialer boolean not null default true;
    }
  end

  def down
    execute %q{
      alter table sys.customer_portal_access_profiles drop column webrtc_dialer;
    }
  end

end
