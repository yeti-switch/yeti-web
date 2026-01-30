# frozen_string_literal: true

module Helpers
  module ActiveAdminForms
    # === Active Admin Form Helper
    # Module adds syntax sugar for testing active_admin forms
    # Usage example:
    #
    #   describe 'create new User' do
    #     subject
    #       aa_form.submit
    #     end
    #
    #     active_admin_form_for User, 'new'
    #
    #     before do
    #      aa_form.fill_in_tom_select 'Department', with: 'developer'
    #      aa_form.set_text 'First name', 'John'
    #      aa_form.set_text 'Doe name', 'Doe'
    #     end
    #   end

    module ExampleGroups
      extend ActiveSupport::Concern
      # Helpers which are exposed on example groups level.

      class_methods do
        def inherited(subclass)
          subclass.active_admin_form_for
        end
      end

      # Sets active admin form for current context and all inside contexts.
      # Should be called within example group.
      # @param resource_class [Class, String] form object class (usually it's a AR model)
      # @param prefix [String, Symbol] generally it's 'new' or 'edit'
      def active_admin_form_for(resource_class, prefix)
        @active_admin_form_for = OpenStruct.new(resource_class: resource_class.to_s, prefix: prefix.to_s)
      end

      # Needed to access active_admin_form_for data inside example.
      # @return [#resource_class #prefix] active_admin_form_for config
      # @raise [RuntimeError] raises runtime error if active_admin_form_for config was not set
      def _active_admin_form_for
        @active_admin_form_for ||= superclass.try(:_safe_active_admin_form_for)
        raise('active_admin_form_for was not set') if @active_admin_form_for.nil?

        @active_admin_form_for
      end

      # Needed for propagate active_admin_form_for config to subclasses of ExampleGroup
      # @return [#resource_class #prefix, NilClass] active_admin_form_for config or nil
      def _safe_active_admin_form_for
        @active_admin_form_for
      end
    end

    module Examples
      # Helpers which are exposed on examples level.

      # active_admin_form will be recreated in each example
      # and cache within example.
      def active_admin_form
        form_data = self.class._active_admin_form_for
        @active_admin_for ||= HelperObjects::ActiveAdminForm.new(form_data.resource_class, form_data.prefix, self)
      end

      # shorter alias for #active_admin_form
      def aa_form
        active_admin_form
      end
    end
  end
end
