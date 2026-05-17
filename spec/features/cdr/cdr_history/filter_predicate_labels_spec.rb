# frozen_string_literal: true

RSpec.describe 'Cdrs index filter predicate labels' do
  include_context :login_as_admin

  before { visit cdrs_path }

  it 'uses short word labels for string-with-predicate filters' do
    within first('.filter_form_field.filter_string.select_and_search') do
      %w[Equals Has Starts Ends].each do |label|
        expect(page).to have_css('option', text: /\A#{label}\z/)
      end
      expect(page).to have_no_css('option', text: 'Contains')
      expect(page).to have_no_css('option', text: 'Starts with')
      expect(page).to have_no_css('option', text: 'Ends with')
    end
  end

  it 'uses short single-word labels for numeric/integer filters' do
    within first('.filter_form_field.filter_numeric') do
      %w[Equals Greater Less].each do |label|
        expect(page).to have_css('option', exact_text: label)
      end
      expect(page).to have_no_css('option', text: 'Greater than')
      expect(page).to have_no_css('option', text: 'Less than')
    end
  end
end
