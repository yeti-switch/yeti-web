# frozen_string_literal: true

require 'spec_helper'

describe 'Index Invoice templates', type: :feature do
  include_context :login_as_admin

  it 'n+1 checks' do
    invoice_templates = create_list(:invoice_template, 2)
    visit invoice_templates_path
    invoice_templates.each do |itp|
      expect(page).to have_css('.resource_id_link', text: itp.id)
    end
  end
end
