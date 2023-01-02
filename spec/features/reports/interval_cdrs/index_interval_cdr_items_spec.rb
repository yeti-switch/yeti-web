# frozen_string_literal: true

RSpec.describe 'Index interval cdr interval items', js: true do
  subject do
    visit report_interval_cdr_interval_items_path report_interval_cdr_id: report.id
  end

  include_context :login_as_admin

  let!(:report) { create(:interval_cdr) }
  let!(:interval_data) { create(:interval_data, report: report) }

  it 'should have table with interval data and destination rate policy' do
    subject
    expect(page).to have_table
    within_table_row(id: interval_data.id) do
      expect(page).to have_table_cell(text: 'Traffic switch', column: 'Disconnect initiator')
    end
  end
end
