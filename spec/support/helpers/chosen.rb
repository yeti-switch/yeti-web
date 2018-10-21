module Helpers
  module Chosen
    def chosen_select(chosen_selector, search:, multiple: false)
      page.find(chosen_selector).click
      expect(page).to have_selector('ul.chosen-results li.active-result')
      if multiple
        find('.chosen-choices input').native.send_keys(search.to_s)
      else
        find('.chosen-search input').native.send_keys(search.to_s)
      end
      find('.active-result', text: search, exact_text: true).click
    end

    def chosen_pick(css_selector, text:)
      find(css_selector).click
      find('ul.chosen-results li.active-result', text: text).click
    end
  end
end

RSpec.configure do |config|
  config.include Helpers::Chosen
end
