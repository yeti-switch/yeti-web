# frozen_string_literal: true

RSpec.describe 'CDR exports', type: :feature do
  include_context :login_as_admin

  describe 'index' do
    let!(:cdr_exports) do
      create_list(:cdr_export, 2, :completed)
    end

    before do
      visit cdr_exports_path
    end

    it 'cdr export should be displayed' do
      cdr_exports.each do |cdr_export|
        within "#cdr_export_base_#{cdr_export.id}" do
          expect(page).to have_selector('.col-id a', text: cdr_export.id)
          expect(page).to have_selector('.col-download a', text: 'download')
          expect(page).to have_selector('.col-status', text: cdr_export.status)
          expect(page).to have_selector('.col-fields', text: cdr_export.fields.join(', '))
          expect(page).to have_selector('.col-filters', text: cdr_export.filters.as_json)
          expect(page).to have_selector('.col-callback_url', text: cdr_export.callback_url)
          expect(page).to have_selector('.col-created_at', text: cdr_export.created_at.strftime('%Y-%m-%d %H:%M:%S'))
        end
      end
    end
  end
end
