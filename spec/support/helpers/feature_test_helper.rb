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

  # sets value of date time picker.
  def fill_in_date_time(field, with:)
    # date time picker can't be found by label
    # so we need to find it by input id
    input_id = page.find('label', text: field)['for']
    input = find_field(input_id)
    input.set(with)
    input.send_keys(:enter)
  end

  def have_semantic_error_texts(*texts)
    satisfy do |actual|
      expect(actual).to have_semantic_errors(count: texts.size)
      texts.each do |text|
        expect(actual).to have_semantic_error(text)
      end
    end
  end

  def table_select_all
    page.find('.resource_selection_toggle_cell label').click
  end

  def table_select_row(id)
    within_table_row(id:) do
      find('.resource_selection_cell .collection_selection').set(true)
    end
  end

  def within_main_content(&block)
    within('#main_content_wrapper', &block)
  end
end
