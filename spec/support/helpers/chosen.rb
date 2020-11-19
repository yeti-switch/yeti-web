# frozen_string_literal: true

module Helpers
  module Chosen
    def fill_in_chosen(label, with:, disabled: nil, **options)
      select_selector = chosen_container_selector(label, disabled: disabled)
      chosen_select(select_selector, search: with, **options)
    end

    def chosen_select_selector(label, disabled: nil)
      disabled = false if disabled.nil?
      select = find_field(label, visible: false, disabled: disabled)
      "select##{select[:id]}"
    end

    def chosen_container_selector(label, disabled: nil)
      disabled = false if disabled.nil?
      select_selector = chosen_select_selector(label, disabled: disabled)
      chosen_selector = '.chosen-container'
      chosen_selector += disabled ? '.chosen-disabled' : ':not(.chosen-disabled)'
      "#{select_selector} + #{chosen_selector}"
    end

    def chosen_select(chosen_selector, search:, multiple: false, chosen_node: nil, ajax: false, exact: false)
      chosen_node ||= page.find(chosen_selector)
      chosen_node.click
      expect(page).to have_selector('ul.chosen-results li.active-result') unless ajax
      if multiple
        chosen_node.find('.chosen-choices input').native.send_keys(search.to_s)
      else
        chosen_node.find('.chosen-search input').native.send_keys(search.to_s)
      end
      expect(page).to have_selector('ul.chosen-results li.active-result') if ajax
      find('.active-result', text: search, exact_text: exact).click
    end

    def chosen_pick(css_selector, text:, chosen_node: nil, exact: false)
      chosen_node ||= page.find(css_selector)
      chosen_node.click
      find('ul.chosen-results li.active-result', text: text, exact_text: exact).click
    end
  end
end

RSpec.configure do |config|
  config.include Helpers::Chosen
end
