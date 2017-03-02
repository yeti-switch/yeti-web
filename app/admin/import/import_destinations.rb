ActiveAdmin.register Importing::Destination , as: "Destination Imports"  do

  filter :rateplan, input_html: { class: 'chosen'}
  filter :routing_tag, input_html: { class: 'chosen'}
  filter :prefix
  filter :rate
  filter :connect_fee

  acts_as_import_preview


  controller do
    def resource_params
      return [] if request.get?
      [ params[active_admin_config.resource_class.model_name.param_key.to_sym].permit! ]
    end
    def scoped_collection
        super.includes(:rateplan, :routing_tag, :rate_policy)
    end
  end

  index do
    selectable_column
    actions
    id_column
    column :error_string
    column :o_id
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

    column :routing_tag, sortable: :routing_tag_name do |row|
      if row.routing_tag.blank?
        row.routing_tag_name
      else
        auto_link(row.routing_tag, row.routing_tag_name)
      end
    end
    
    column :rate_policy , sortable: :rate_policy_name do |row|
       if row.rate_policy.blank?
          row.rate_policy_name
       else
         auto_link(row.rate_policy, row.rate_policy_name)
       end
    end
    
    column :initial_interval
    column :initial_rate
    column :next_interval
    column :next_rate
    column :connect_fee
    column :use_dp_intervals
    column :dp_margin_fixed
    column :dp_margin_percent
  end

end
