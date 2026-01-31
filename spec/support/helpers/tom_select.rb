# frozen_string_literal: true

module Helpers
  module TomSelect
    def fill_in_tom_select(label, options = {})
      exact_label = options.fetch(:exact_label, false)
      exact = options.fetch(:exact, false)
      ajax = options.fetch(:ajax, false)
      disabled = options.fetch(:disabled, false)
      no_search = options.fetch(:no_search, !ajax)
      value = options.delete(:with)
      find_field_opts = { visible: false, disabled: disabled }
      find_field_opts[:match] = :prefer_exact if exact_label
      tom_select = if options.fetch(:selector, false)
                     tom_select_by_css(label)
                   else
                     tom_select_by_label(label)
                   end
      if no_search
        tom_select_pick(nil, text: value, exact: exact, tom_select_node: tom_select)
      else
        tom_select_select(nil, search: value, ajax: ajax, exact: exact, tom_select_node: tom_select)
      end
    end

    def tom_select_selector(label, disabled: nil, exact: false)
      disabled = false if disabled.nil?
      find_field_opts = { visible: false, disabled: disabled }
      find_field_opts[:match] = :prefer_exact if exact
      select = find_field(label, **find_field_opts)
      "select##{select[:id]}"
    end

    def tom_select_container_selector(label, disabled: nil, exact: false)
      disabled = false if disabled.nil?
      select_selector = tom_select_selector(label, disabled: disabled, exact: exact)
      tom_select_selector = '.ts-wrapper'
      tom_select_selector += disabled ? '.disabled' : ':not(.disabled)'
      "#{select_selector} + #{tom_select_selector}"
    end

    def tom_select_select(css_selector, search:, tom_select_node: nil, ajax: false, exact: false)
      ts_control = tom_select_node || tom_select_by_css(css_selector)
      ts_control.click
      expect(page).to have_selector('.ts-dropdown .option') unless ajax
      ts_control.find('input').native.send_keys(search.to_s)
      within(tom_select_node) do
        expect(page).to have_selector('.ts-dropdown .option') if ajax
        find('.ts-dropdown .option', text: search, exact_text: exact).click
      end
    end

    # @return [Capybara::Node::Element] ts-control
    def tom_select_by_label(label, exact: false)
      label = find(:label, label, exact: exact)
      find("##{label[:for]}")
    end

    # @return [Capybara::Node::Element] ts-control
    def tom_select_by_css(css_selector)
      node = page.find(css_selector)
      node[:class].include?('ts-control') ? node : node.find('.ts-control')
    end

    def tom_select_pick(css_selector, text:, tom_select_node: nil, exact: false)
      ts_control = tom_select_node || tom_select_by_css(css_selector)
      ts_control.click
      find('.ts-dropdown .option', text: text, exact_text: exact).click
    end

    def tom_select_deselect_value(label, exact: false)
      tom_select_node = tom_select_by_label(label, exact: exact)
      tom_select_node.find('.clear-button').click
    end

    def tom_select_deselect_values(label, values:, exact: false)
      tom_select_node = tom_select_by_label(label, exact: exact)
      values.each do |value|
        item = tom_select_node.find('.ts-control .item', text: value.to_s)
        item.find('.remove').click
      end
    end

    # Checks tom select presence on page
    # @param label [String] field label.
    # @param options [Hash]
    #   :with [String, nil] check selected option text whether not nil,
    #   :disabled [Boolean, nil] default false,
    #   :exact [Boolean] match :with by exact text (default true),
    #   for other options @see #have_selector.
    def have_field_tom_select(label, exact_label: false, **options)
      with = options.delete(:with)
      disabled = options.delete(:disabled)
      exact = options.delete(:exact)
      exact = true if exact.nil?
      warn 'empty :with will be ignored because :exact is false' if with.blank? && !exact
      options[exact ? :exact_text : :text] = with unless with.nil?
      label = find(:label, label, exact_text: exact_label)
      selector = "##{label[:for]}"
      selector += disabled ? '.disabled' : ':not(.disabled)'
      have_selector(selector, **options)
    end
  end
end
