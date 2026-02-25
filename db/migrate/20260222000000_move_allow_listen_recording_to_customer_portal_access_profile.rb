# frozen_string_literal: true

class MoveAllowListenRecordingToCustomerPortalAccessProfile < ActiveRecord::Migration[7.2]
  def up
    execute %q{
      alter table sys.customer_portal_access_profiles add allow_listen_recording boolean not null default false;

      update sys.customer_portal_access_profiles p
      set allow_listen_recording = true
      where exists (
        select 1 from sys.api_access a
        where a.customer_portal_access_profile_id = p.id
      )
      and not exists (
        select 1 from sys.api_access a
        where a.customer_portal_access_profile_id = p.id
          and a.allow_listen_recording = false
      );

      alter table sys.api_access drop column allow_listen_recording;
    }
  end

  def down
    execute %q{
      alter table sys.api_access add allow_listen_recording boolean not null default false;

      update sys.api_access a
      set allow_listen_recording = p.allow_listen_recording
      from sys.customer_portal_access_profiles p
      where a.customer_portal_access_profile_id = p.id;

      alter table sys.customer_portal_access_profiles drop column allow_listen_recording;
    }
  end
end
