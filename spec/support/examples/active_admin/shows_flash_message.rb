# frozen_string_literal: true

RSpec.shared_examples :shows_flash_message do |type, text|
  it "shows flash #{type}" do
    subject
    expect(page).to have_selector(".flashes > .flash_#{type}", text: text)
  end
end
