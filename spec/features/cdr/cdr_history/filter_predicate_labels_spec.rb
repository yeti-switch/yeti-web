# frozen_string_literal: true

RSpec.describe 'Cdrs index filter predicate labels' do
  include_context :login_as_admin

  before { visit cdrs_path }

  # Asserts the rendered operator options exactly match the labels resolved
  # from config/locales/ransack.en.yml (via the same path ActiveAdmin uses),
  # so the test stays in sync with the locale instead of hardcoding strings.
  def option_texts(scope_css)
    first(scope_css).all('option', visible: :all).map { |o| o.text.strip }
  end

  it 'labels string filter predicates from the locale' do
    expect(option_texts('.filter_form_field.filter_string.select_and_search'))
      .to match_array(ransack_predicate_labels(:eq, :cont, :start, :end))
  end

  it 'labels numeric/integer filter predicates from the locale' do
    expect(option_texts('.filter_form_field.filter_numeric'))
      .to match_array(ransack_predicate_labels(:eq, :gt, :lt))
  end
end
