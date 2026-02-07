# frozen_string_literal: true

module HelperObjects
  class ActiveAdminForm
    # == Active Admin Form
    # Helper object for active admin forms.
    # Syntax sugar for common operations with forms in feature specs.
    # @see Helpers::ActiveAdminForms#active_admin_form

    delegate :page, :within, :expect, :have_selector, to: :@ctx

    # @param resource_class_name [String] class name of model
    # @param prefix [String] can be 'new' or 'edit'
    # @param ctx [Rspec::Core::Example] example which currently executed
    def initialize(resource_class_name, prefix, ctx)
      @resource_class = resource_class_name.constantize
      @prefix = prefix
      @ctx = ctx
      @within_has_many = nil
    end

    # sets value of text input by label or id.
    # @param field [String] field name or id
    # @param text [String] value which you want to set
    # @param exact_field [TrueClass,FalseClass] search by exact field attribute name
    def set_text(field, text, exact_field: false)
      input = field_input(field, exact: exact_field)
      input.set(text)
    end

    # sets value of date time picker input by label or id.
    # @param field [String] field name or id
    # @param text [String] value which you want to set
    def set_date_time(field, text)
      # date time picker can't be found by label
      # so we need to find it by input id
      input = field_input(field, exact: true)
      input.set(text)
    end

    # selects option of select by label or id.
    # @param field [String] field name or id
    # @param text [String] value which you want to select
    # @param exact_field [TrueClass,FalseClass] search by exact field attribute name
    def select_value(field, text, exact_field: false)
      select = field_input(field, exact: exact_field)
      select.find(:option, text).select_option
    end

    # search option of tom-select select (and wait while it appear) by label or id.
    # @param label [String]
    # @param with [String] value which you want to search
    # @param exact_field [TrueClass,FalseClass] search by exact field attribute name
    # @param ajax [TrueClass,FalseClass] whether tom-select uses ajax to load options
    def fill_in_tom_select(label, with:, exact_field: false, ajax: false)
      @ctx.fill_in_tom_select(label, with:, ajax:, exact_label: exact_field)
    end

    # check/uncheck checkbox.
    # @param field [String] field name or id
    # @param is_checked [TrueClass, FalseClass] check if true otherwise uncheck
    # @param exact [TrueClass,FalseClass] search by exact field attribute name
    def set_checkbox(field, is_checked, exact: false)
      field = has_many_input_id(field) if within_has_many?
      field = input_id(field) if exact && !within_has_many?
      if is_checked
        form_node.check(field)
      else
        form_node.uncheck(field)
      end
    end

    # Switches tab inside form.
    # @param tab_name [String] name of tab
    def switch_tab(tab_name)
      tabs = form_node.find('.ui-tabs')
      tabs.find_link(tab_name, class: 'ui-tabs-anchor').click
    end

    # click on submit button.
    def submit
      form_node.find('input[type="submit"]').click
    end

    # @return [Capybara::Node::Element] field input or select
    def field_input(field, opts = {})
      exact = opts.delete(:exact)
      if within_has_many?
        container = has_many_container_for(has_many_opts.name)
        fieldset = container.find_all('fieldset.has_many_fields')[has_many_opts.index]
        field = has_many_input_id(field) if exact
        fieldset.find(:field, field, opts)
      else
        field = input_id(field) if exact
        form_node.find_field(field, **opts)
      end
    end

    # @return [Capybara::Node::Element] form
    def form_node
      page.find("##{form_id}")
    end

    # @return [String] form id
    def form_id
      "#{@prefix}_#{@resource_class.model_name.singular}"
    end

    # @return [String] field id by attribute
    def input_id(field)
      attr = field.tr(' ', '_').underscore
      "#{@resource_class.model_name.singular}_#{attr}"
    end

    def has_many_input_id(field)
      return unless within_has_many?

      attr = field.tr(' ', '_').underscore
      assoc = has_many_opts.name
      index = has_many_opts.index
      "#{@resource_class.model_name.singular}_#{assoc}_attributes_#{index}_#{attr}"
    end

    # clicks on has_many inputs button for association `name`.
    # @param name [String] - name of association
    def add_has_many(name)
      container = has_many_container_for(name)
      container.find('a.has_many_add').click
    end

    # @yield within block inputs from particular fieldset of has_many association
    #   can be set via ordinary `set_text` method and similar.
    # @param name [String] - name of association
    # @param index [Integer] - index of fieldset (starts with 0)
    def within_has_many(name, index = 0)
      assoc_name = has_many_assoc(name)
      # selector = "li[id^=\"#{assoc_name}_attributes_#{index}_\"]"
      @within_has_many = { name: assoc_name, index: index }
      yield
    ensure
      @within_has_many = nil
    end

    # @return [Capybara::Node::Element] container node for has_many association
    def has_many_container_for(name)
      assoc_name = has_many_assoc(name)
      page.find("li.has_many_container.#{assoc_name}")
    end

    # formats association name for searching in DOM
    # @param name [String] - name of association
    def has_many_assoc(name)
      name.tr(' ', '_').underscore.pluralize
    end

    def within_has_many?
      !@within_has_many.nil?
    end

    def has_many_opts
      return unless within_has_many?

      OpenStruct.new(@within_has_many)
    end
  end
end
