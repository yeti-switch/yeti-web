module ResourceDSL
  module BatchActionUpdate

    def batch_update_attributes attributes_names

      batch_action :change_attributes, form: -> {
        {
            attribute: attributes_names,
            value: :text
        }
      } do |ids, inputs|
        begin
          attribute_sym = inputs[:attribute].underscore.parameterize('_').to_sym
          count = apply_authorization_scope(scoped_collection).where(id: ids).update_all(attribute_sym => inputs['value'])
          flash[:notice] = "#{count}/#{ids.count} records updated"
        rescue StandardError => e
          flash[:error] = e.message
          Rails.logger.warn "UCS#batch_assign_to_group raise exception: #{e.message}\n#{e.backtrace.join("\n")}"
        end
        redirect_back fallback_location: root_path
      end

    end
  end
end
