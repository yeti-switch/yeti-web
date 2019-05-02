# frozen_string_literal: true

module FeatureTestHelper
  # useful when element which we want to modify/check is outside of visible area
  def scroll_to_element(element_or_selector)
    element = element_or_selector.is_a?(String) ? page.find(element_or_selector) : element_or_selector
    element.native.location_once_scrolled_into_view
  end

  # useful when we need to click somewhere outside input/modal
  def click_on_text(text)
    page.find(:xpath, "//*[text()='#{text}']").click
  end
end
