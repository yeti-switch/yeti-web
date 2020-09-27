# frozen_string_literal: true

module Helpers
  module Chosen
    def chosen_select(chosen_selector, search:, multiple: false, chosen_node: nil, ajax: false, exact: true)
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

    def chosen_pick(css_selector, text:, chosen_node: nil)
      chosen_node ||= page.find(css_selector)
      chosen_node.click
      find('ul.chosen-results li.active-result', text: text).click
    end
  end
end

RSpec.configure do |config|
  config.include Helpers::Chosen
end
