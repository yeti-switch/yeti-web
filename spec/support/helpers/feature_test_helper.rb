# frozen_string_literal: true

module FeatureTestHelper
  def select_by_value(value, from:)
    option_name = ''
    select = find_field(from)
    within select do
      option_name = page.find(:xpath, ".//option[@value = '#{value}']").text
    end
    select option_name, from: from
  end

  # useful when we need to click somewhere outside input/modal
  def click_on_text(text)
    page.find(:xpath, "//*[text()='#{text}']").click
  end

  # override Capybara::ActiveAdmin::Selectors::Form#has_many_fields_selector
  # @param association_name [String]
  # @return [String] selector.
  def has_many_fields_selector(association_name)
    ".has_many_container.#{association_name} > fieldset.inputs.has_many_fields"
  end

  def response_csv
    CSV.parse(page.body)
  end

  def response_csv_header
    response_csv.first
  end

  def response_csv_rows
    response_csv[1..-1]
  end

  # @return [Array<Hash>]
  def response_csv_collection
    response_csv_rows.map { |row| [response_csv_header, row].transpose.to_h }
  end
end
