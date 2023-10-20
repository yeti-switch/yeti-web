# frozen_string_literal: true

RSpec.describe 'Index Reports Custom Cdrs', type: :feature do
  include_context :login_as_admin

  it 'n+1 checks' do
    custom_cdrs = create_list(:custom_cdr, 2)
    visit custom_cdrs_path
    custom_cdrs.each do |custom_cdr|
      expect(page).to have_css('.col-id', text: custom_cdr.id)
    end
  end

  describe 'filter' do
    subject { click_button :Filter }

    context 'by all filters', js: false do
      before do
        visit custom_cdrs_path
        fill_in 'ID', with: '123'
        select 'customer_id', from: 'Group By'
        fill_in 'Filter', with: 'filter'
      end

      it 'should reload page without error' do
        subject

        expect(page).to have_page_title 'Custom Cdrs'
      end
    end
  end
end
