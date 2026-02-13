# frozen_string_literal: true

module Helpers
  module TomSelect
    # @return [Section::TomSelect]
    def find_tom_select(label, exact: true, selector: nil, within: nil)
      within ||= Capybara.current_session
      root_el = if selector
                  node = within.find(css_selector)
                  node[:class].include?('ts-wrapper') ? node : node.parent
                else
                  within.find(:parent_by_label, label, exact: exact)
                end
      Section::TomSelect.new(within, root_el)
    end

    def fill_in_tom_select(label, options = {})
      exact_label = options.fetch(:exact_label, false)
      exact = options.fetch(:exact, false)
      ajax = options.fetch(:ajax, false)
      search = options.fetch(:search, ajax)
      selector = options[:selector]
      with = options.delete(:with)
      tom_select = find_tom_select(label, exact: exact_label, selector:)

      if search
        search_text = search.is_a?(TrueClass) ? with : search
        tom_select.search_and_select(search_text, select: with, exact:)
      else
        tom_select.select(with, exact:)
      end
    end

    def clear_tom_select(label, exact_label: false)
      tom_select = find_tom_select(label, exact: exact_label)
      tom_select.clear
    end

    def tom_select_deselect_values(label, values:, exact: true, exact_label: false)
      tom_select = find_tom_select(label, exact: exact_label)
      tom_select.remove_item(values, exact:)
    end

    # Checks tom select presence on page
    # @param label [String] field label.
    # @param options [Hash]
    #   :with [String, nil] check selected option text whether not nil,
    #   :disabled [Boolean, nil] default false,
    #   :exact [Boolean] match :with by exact text (default true),
    #   for other options @see #have_selector.
    def have_field_tom_select(label, exact_label: false, exact: true, **options)
      with = options.delete(:with)
      disabled = options.delete(:disabled)
      clearable = options.delete(:clearable)
      warn 'empty :with will be ignored because :exact is false' if with.blank? && !exact
      with = "#{with}\n⨯" if with.present? && clearable && exact
      options[exact ? :exact_text : :text] = with unless with.nil?
      label = find(:label, label, exact_text: exact_label)
      selector = "##{label[:for]}"
      selector += disabled ? '.disabled' : ':not(.disabled)'
      have_selector(selector, **options)
    end
  end
end
