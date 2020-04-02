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

  includes :rateplan, :rate_policy, :routing_tag_mode

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
    column :rateplan, sortable: :rateplan_name do |row|
      if row.rateplan.blank?
        row.rateplan_name
      else
        auto_link(row.rateplan, row.rateplan_name)
      end
    end

    column :routing_tag_ids do |row|
      if row.routing_tag_ids.present?
        Routing::RoutingTag.where(id: row.routing_tag_ids).pluck(:name).join(', ')
      else
        row.routing_tag_names
      end
    end

    column :routing_tag_mode, sortable: :routing_tag_mode_name do |row|
      if row.routing_tag_mode_name.blank?
        row.routing_tag_mode_name
      else
        auto_link(row.routing_tag_mode, row.routing_tag_mode_name)
      end
    end

    column :rate_policy, sortable: :rate_policy_name do |row|
      if row.rate_policy.blank?
        row.rate_policy_name
      else
        auto_link(row.rate_policy, row.rate_policy_name)
      end
    end
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
