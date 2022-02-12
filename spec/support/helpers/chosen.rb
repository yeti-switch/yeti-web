# frozen_string_literal: true

module Helpers
  module Chosen
    def fill_in_chosen(label, options = {})
      exact_label = options.fetch(:exact_label, false)
      exact = options.fetch(:exact, false)
      ajax = options.fetch(:ajax, false)
      disabled = options.fetch(:disabled, false)
      no_search = options.fetch(:no_search, false)
      multiple = options.fetch(:multiple, false)
      value = options.delete(:with)
      find_field_opts = { visible: false, disabled: disabled }
      find_field_opts[:match] = :prefer_exact if exact_label
      select_node = find_field(label, find_field_opts)
      chosen_selector = "select##{select_node[:id]} + .chosen-container"
      if no_search
        chosen_pick(chosen_selector, text: value, exact: exact)
      else
        chosen_select(chosen_selector, search: value, multiple: multiple, ajax: ajax, exact: exact)
      end
    end

    def chosen_select_selector(label, disabled: nil, exact: false)
      disabled = false if disabled.nil?
      find_field_opts = { visible: false, disabled: disabled }
      find_field_opts[:match] = :prefer_exact if exact
      select = find_field(label, find_field_opts)
      "select##{select[:id]}"
    end

    def chosen_container_selector(label, disabled: nil, exact: false)
      disabled = false if disabled.nil?
      select_selector = chosen_select_selector(label, disabled: disabled, exact: exact)
      chosen_selector = '.chosen-container'
      chosen_selector += disabled ? '.chosen-disabled' : ':not(.chosen-disabled)'
      "#{select_selector} + #{chosen_selector}"
    end

    def chosen_select(chosen_selector, search:, multiple: false, chosen_node: nil, ajax: false, exact: false)
      chosen_node ||= page.find(chosen_selector)
      if multiple
        chosen_node.find('.search-field').click
      else
        chosen_node.click
      end
      expect(page).to have_selector('ul.chosen-results li.active-result') unless ajax
      if multiple
        chosen_node.find('.chosen-choices input').native.send_keys(search.to_s)
      else
        chosen_node.find('.chosen-search input').native.send_keys(search.to_s)
      end
      within(chosen_node) do
        expect(page).to have_selector('ul.chosen-results li.active-result') if ajax
        find('.active-result', text: search, exact_text: exact).click
      end
    end

    def chosen_pick(css_selector, text:, chosen_node: nil, exact: false)
      chosen_node ||= page.find(css_selector)
      chosen_node.click
      find('ul.chosen-results li.active-result', text: text, exact_text: exact).click
    end

    def chosen_deselect_value(label, exact: false)
      select_selector = chosen_container_selector(label, exact: exact)
      chosen_node = page.find(select_selector)
      chosen_node.find('abbr.search-choice-close').click
    end

    # Checks chosen select presence on page
    # @param label [String] field label.
    # @param options [Hash]
    #   :with [String, nil] check selected option text whether not nil,
    #   :disabled [Boolean, nil] default false,
    #   :exact [Boolean] match :with by exact text (default true),
    #   for other options @see #have_selector.
    def have_field_chosen(label, exact_label: false, **options)
      with = options.delete(:with)
      disabled = options.delete(:disabled)
      exact = options.delete(:exact)
      exact = true if exact.nil?
      warn 'empty :with will be ignored because :exact is false' if with.blank? && !exact
      options[exact ? :exact_text : :text] = with unless with.nil?
      selector = chosen_container_selector(label, disabled: disabled, exact: exact_label)
      have_selector(selector, options)
    end
  end
end
