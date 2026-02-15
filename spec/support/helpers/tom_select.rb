# frozen_string_literal: true

module Helpers
  module TomSelect
    # @return [Section::TomSelect]
    def find_tom_select(label, exact: false, selector: nil, parent: nil, **)
      parent ||= Capybara.current_session
      if selector
        node = within.find(label)
        root_element = node[:class].include?('ts-wrapper') ? node : node.ancestor('.ts-wrapper')
        Section::TomSelect.new(parent, root_element)
      else
        Section::TomSelect.by_label(label, exact:, parent:)
      end
    end

    def fill_in_tom_select(label, options = {})
      exact_label = options.fetch(:exact_label, false)
      exact = options.fetch(:exact, false)
      search = options.fetch(:search, false)
      selector = options[:selector]
      with = options.delete(:with)
      tom_select = find_tom_select(label, exact_label:, selector:)

      if search
        search_text = search.is_a?(TrueClass) ? with : search
        tom_select.search_and_select(search_text, select: with, exact:)
      else
        tom_select.select(with, exact:)
      end
    end

    def clear_tom_select(label, **)
      tom_select = find_tom_select(label)
      tom_select.clear
    end

    def tom_select_deselect_values(label, values:, exact: true, **)
      tom_select = find_tom_select(label)
      tom_select.remove_item(values, exact:)
    end

    # Checks tom select presence on page
    # @param label [String] field label.
    # @param options [Hash]
    #   :with [String, nil] check selected option text whether not nil,
    #   :disabled [Boolean, nil] default false,
    #   :exact [Boolean] match :with by exact text (default true),
    #   for other options @see #have_selector.
    def have_field_tom_select(label, with:, exact: true, exact_label: false, disabled: false, **options)
      warn 'empty :with will be ignored because :exact is false' if with.blank? && !exact
      label_node = find(:label, text: label, exact_text: exact_label, match: :prefer_exact)
      selector = "##{label_node[:for]}"
      selector += disabled ? '.disabled' : ':not(.disabled)'
      unless with.nil?
        options[:text] = with
        options[:exact_text] = exact
        selector += ' .item'
      end
      have_selector(selector, **options)
    end
  end
end
