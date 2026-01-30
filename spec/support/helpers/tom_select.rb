# frozen_string_literal: true

module Helpers
  module TomSelect
    # @return [Capybara::Node::Element] ts-control
    def find_tom_select(label, exact: true, selector: nil)
      if selector
        node = page.find(css_selector)
        node[:class].include?('ts-control') ? node : node.find('.ts-control')
      else
        label = find(:label, label, exact: exact)
        find("##{label[:for]}")
      end
    end

    def fill_in_tom_select(label, options = {})
      exact_label = options.fetch(:exact_label, false)
      exact = options.fetch(:exact, false)
      ajax = options.fetch(:ajax, false)
      search = options.fetch(:search, ajax)
      selector = options[:selector]
      value = options.delete(:with)
      ts_control = find_tom_select(label, exact: exact_label, selector:)
      if search
        tom_select_search(ts_control, search: value, ajax:, exact:)
      else
        tom_select_pick(ts_control, text: value, exact:)
      end
    end

    def clear_tom_select(label, exact: false)
      tom_select_node = find_tom_select(label, exact: exact)
      tom_select_node.find('.clear-button').click
    end

    def tom_select_deselect_values(label, values:, exact: false)
      tom_select_node = find_tom_select(label, exact: exact)
      values.each do |value|
        item = tom_select_node.find('.item', text: value.to_s)
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
      clearable = options.delete(:clearable)
      exact = true if exact.nil?
      warn 'empty :with will be ignored because :exact is false' if with.blank? && !exact
      with = "#{with}\n⨯" if with.present? && clearable && exact
      options[exact ? :exact_text : :text] = with unless with.nil?
      label = find(:label, label, exact_text: exact_label)
      selector = "##{label[:for]}"
      selector += disabled ? '.disabled' : ':not(.disabled)'
      have_selector(selector, **options)
    end

    def tom_select_pick(ts_control, text:, exact: false)
      ts_wrapper = ts_control.find(:xpath, './..')
      ts_control.click
      Array.wrap(text).each do |text_item|
        ts_wrapper.find('.ts-dropdown .option', text: text_item, exact_text: exact).click
      end
    end

    def tom_select_search(ts_control, search:, ajax: false, exact: false)
      ts_wrapper = ts_control.find(:xpath, './..')
      ts_control.click
      expect(page).to have_selector('.ts-dropdown .option') unless ajax
      ts_wrapper.find('.ts-dropdown input').native.send_keys(search.to_s)
      expect(ts_wrapper).to have_selector('.ts-dropdown .option') if ajax
      ts_wrapper.find('.ts-dropdown .option', text: search, exact_text: exact).click
    end
  end
end
