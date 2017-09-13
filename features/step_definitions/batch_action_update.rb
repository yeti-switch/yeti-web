# common

Given (/^"(.*?)" destinations$/) do |count|
  FactoryGirl.create :rate_profit_control_mode
  rate_plane = FactoryGirl.create :rateplan, profit_control_mode: FactoryGirl.create(:rate_profit_control_mode)
  FactoryGirl.create_list(:destination, count.to_i,
                          enabled: true,
                          initial_rate: 2.0,
                          rateplan: rate_plane,
                          rate_policy: DestinationRatePolicy.first)
end

When (/^I click checkbox to select all records$/) do
  sleep 1
  find(:css, "#collection_selection_toggle_all").click
end

And (/^I click the batch actions button and choose change_attributes$/) do
  sleep 1
  find(:css, ".batch_actions_selector.dropdown_menu").click
  sleep 1
  find(:css, "a[data-action='change_attributes']").click
end

And (/^I update attribute "(.*?)" with value "(.*?)"$/) do |attribute, value|
  sleep 2
  find("form#dialog_confirm").find('select').find('option', text: attribute).select_option
  sleep 1
  find(:css, "form#dialog_confirm ul li input[name='value']").set(value)
  sleep 1
  find(:css, "form#dialog_confirm button").click
end

Then (/^The destinations attribute "(.*?)" should be updated to "(.*?)"$/) do |attribute, value|
  expect(Destination.all.pluck(attribute)).to eq value
end

# it shows error panel when value is not valid

Then (/^The destinations attribute "(.*?)" should not be updated$/) do |attribute|
  expect(Destination.all.pluck(attribute)).to eq [2.0, 2.0]
end

And (/^flash error panel should be shown$/) do

end

# dropdown_menu_button is not disabled if any record selected

And (/^The dropdown_menu_button is disabled$/) do
  expect(page.to have_selector("dropdown_menu_button.disabled"))
end

Then (/^The dropdown_menu_button is not disabled$/) do
  expect(page.not_to have_selector("dropdown_menu_button.disabled"))
end
