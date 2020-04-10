# frozen_string_literal: true

require 'spec_helper'

describe 'Index Payments', type: :feature do
  include_context :login_as_admin

  it 'n+1 checks' do
    payments = create_list(:payment, 2)
    visit payments_path
    payments.each do |payment|
      expect(page).to have_css('.resource_id_link', text: payment.id)
    end
  end
end
