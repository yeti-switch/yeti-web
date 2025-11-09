class AddMoreCustomerPortalPermissions < ActiveRecord::Migration[7.2]
    def up
      execute %q{
      alter table sys.customer_portal_access_profiles
        add outgoing_statistics_acd_value boolean not null default true,
        add outgoing_statistics_asr_value boolean not null default true,
        add outgoing_statistics_failed_calls_value boolean not null default true,
        add outgoing_statistics_successful_calls_value boolean not null default true,
        add outgoing_statistics_total_calls_value boolean not null default true,
        add outgoing_statistics_total_duration_value boolean not null default true,
        add outgoing_statistics_total_price_value boolean not null default true,

        add incoming_statistics_active_calls boolean not null default true,
        add incoming_statistics_acd boolean not null default true,
        add incoming_statistics_asr boolean not null default true,
        add incoming_statistics_failed_calls boolean not null default true,
        add incoming_statistics_successful_calls boolean not null default true,
        add incoming_statistics_total_calls boolean not null default true,
        add incoming_statistics_total_duration boolean not null default true,
        add incoming_statistics_total_price boolean not null default true,

        add incoming_statistics_acd_value boolean not null default true,
        add incoming_statistics_asr_value boolean not null default true,
        add incoming_statistics_failed_calls_value boolean not null default true,
        add incoming_statistics_successful_calls_value boolean not null default true,
        add incoming_statistics_total_calls_value boolean not null default true,
        add incoming_statistics_total_duration_value boolean not null default true,
        add incoming_statistics_total_price_value boolean not null default true;
    }
    end

    def down
      execute %q{
      alter table sys.customer_portal_access_profiles
        drop column outgoing_statistics_acd_value,
        drop column outgoing_statistics_asr_value,
        drop column outgoing_statistics_failed_calls_value,
        drop column outgoing_statistics_successful_calls_value,
        drop column outgoing_statistics_total_calls_value,
        drop column outgoing_statistics_total_duration_value,
        drop column outgoing_statistics_total_price_value,

        drop column incoming_statistics_active_calls,
        drop column incoming_statistics_acd,
        drop column incoming_statistics_asr,
        drop column incoming_statistics_failed_calls,
        drop column incoming_statistics_successful_calls,
        drop column incoming_statistics_total_calls,
        drop column incoming_statistics_total_duration,
        drop column incoming_statistics_total_price,

        drop column incoming_statistics_acd_value,
        drop column incoming_statistics_asr_value,
        drop column incoming_statistics_failed_calls_value,
        drop column incoming_statistics_successful_calls_value,
        drop column incoming_statistics_total_calls_value,
        drop column incoming_statistics_total_duration_value,
        drop column incoming_statistics_total_price_value;
    }
    end

end
