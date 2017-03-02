ActiveAdmin.register Importing::Dialpeer, as: "Dialpeer Imports" do

  filter :o_id
  filter :prefix
  filter :enabled, as: :select, collection: [["Yes", true], ["No", false]]
  filter :vendor, input_html: {class: 'chosen'}
  filter :account, input_html: {class: 'chosen'}
  filter :gateway, input_html: {class: 'chosen'}
  filter :routing_group, input_html: {class: 'chosen'}

  acts_as_import_preview

  controller do
    def resource_params
      return [] if request.get?
      [params[active_admin_config.resource_class.model_name.param_key.to_sym].permit!]
    end

    def scoped_collection
      super.includes(:gateway, :gateway_group, :routing_group, :routing_tag, :vendor, :account)
    end
  end


  index do
    selectable_column
    actions
    id_column
    column :error_string
    column :o_id
    column :prefix
    column :enabled
    column :priority
    column :force_hit_rate
    column :initial_interval
    column :initial_rate
    column :next_interval
    column :next_rate
    column :connect_fee
    column :lcr_rate_multiplier
    column :gateway, sortable: :gateway_name do |row|
      if row.gateway.blank?
        row.gateway_name
      else
        auto_link(row.gateway, row.gateway_name)
      end
    end

    column :gateway_group, sortable: :gateway_group_name do |row|
      if row.gateway_group.blank?
        row.gateway_group_name
      else
        auto_link(row.gateway_group, row.gateway_group_name)
      end
    end

    column :routing_group, sortable: :routing_group_name do |row|
      if row.routing_group.blank?
        row.routing_group_name
      else
        auto_link(row.routing_group, row.routing_group_name)
      end
    end

    column :routing_tag, sortable: :routing_tag_name do |row|
      if row.routing_tag.blank?
        row.routing_tag_name
      else
        auto_link(row.routing_tag, row.routing_tag_name)
      end
    end

    column :vendor, sortable: :vendor_name do |row|
      if row.vendor_name.blank?
        row.vendor_name
      else
        auto_link(row.vendor, row.vendor_name)
      end
    end

    column :account, sortable: :account_name do |row|
      if row.account_name.blank?
        row.account_name
      else
        auto_link(row.account, row.account_name)
      end
    end
    column :valid_from
    column :valid_till
    column :acd_limit
    column :asr_limit
    column :short_calls_limit
    column :capacity
    column :src_rewrite_rule
    column :src_rewrite_result
    column :dst_rewrite_rule
    column :dst_rewrite_result
  end
end
