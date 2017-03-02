module ActiveAdmin
  module Views
    class ActiveAdminForm < FormtasticProxy

      def commit_action_with_cancel_link
        action :submit, button_html: { data: { disable_with: "Please wait..." } }
        cancel_link
      end

    end
  end
end