module ResourceDSL

  module ActsAsBatchChangeable
    def acts_as_batch_changeable columns_changeable
      section = ActiveAdmin::SidebarSection.new 'Update Filtered', class: 'toggle', only: :index do

        text_node form_tag(action: :batch_operation, id: "batch_operation_form")

        div class: "filter_form_field filter_select" do
          label class: "label", for: "batch_operation_attribute" do
            "Attribute to update"
          end
          text_node select_tag "attribute",
                               options_for_select(columns_changeable.map { |c| [c.to_s.humanize, c] }),
                               class: :chosen,
                               id: :batch_operation_attribute
          label class: "label", for: "batch_operation_value" do
            "New value"
          end
          text_node text_field_tag "value", "", id: "batch_operation_value"
        end
        div class: :buttons do
          text_node submit_tag "Save"
        end
        (params[:q] || {}).each do |k, v|
          text_node hidden_field_tag "q[#{k}]", v
        end
        input(name: :batch_operation, id: :batch_operation, type: :hidden)
        text_node "</form>".html_safe
      end

      config.sidebar_sections.unshift section

      collection_action :batch_operation, method: :post do
        collection = scoped_collection
        collection = apply_authorization_scope(collection)
        collection = apply_filtering(collection)
        if params[:attribute].present? and params[:value].present?
          if columns_changeable.map { |e| e.to_s }.include?(params[:attribute])
            collection.each do |item|
              item.send("#{params[:attribute]}=", params[:value])
              item.save!
            end
            flash[:notice] = "#{params[:attribute].humanize} was successfully changed"
          end
        end
        redirect_back fallback_location: root_path
      end
    end
  end
end
