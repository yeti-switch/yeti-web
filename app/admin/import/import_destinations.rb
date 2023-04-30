# frozen_string_literal: true

ActiveAdmin.register Importing::Destination, as: 'Destination Imports' do
  filter :rateplan, input_html: { class: 'chosen' }
  filter :prefix
  filter :rate
  filter :connect_fee
  boolean_filter :is_changed

  acts_as_import_preview

  controller do
    def resource_params
      return [{}] if request.get?

      [params[active_admin_config.resource_class.model_name.param_key.to_sym].permit!]
    end
  end

  index do
    selectable_column
    actions
    id_column
    column :error_string
    column :o_id
    column :is_changed

    column :enabled
    column :prefix
    column :reject_calls
    column :rate_group, sortable: :rate_group_name
    column :routing_tag_ids
    column :routing_tag_mode, sortable: :routing_tag_mode_name
    column :profit_control_mode, &:profit_control_mode_name
    column :rate_policy, &:rate_policy_display_name
    column :reverse_billing
    column :initial_interval
    column :initial_rate
    column :next_interval
    column :next_rate
    column :connect_fee
    column :use_dp_intervals
    column :dp_margin_fixed
    column :dp_margin_percent
    column :valid_from
    column :valid_till
    column :asr_limit
    column :acd_limit
    column :short_calls_limit
  end
end
