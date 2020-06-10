# frozen_string_literal: true

RSpec.describe 'Index Reports Custom Cdr Schedulers', type: :feature do
  include_context :login_as_admin

  it 'n+1 checks' do
    custom_cdr_schedulers = create_list(:custom_cdr_scheduler, 2, :filled)
    visit custom_cdr_schedulers_path
    custom_cdr_schedulers.each do |custom_cdr_scheduler|
      expect(page).to have_css('.col-id', text: custom_cdr_scheduler.id)
    end
  end
end
