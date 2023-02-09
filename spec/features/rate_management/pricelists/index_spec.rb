# frozen_string_literal: true

RSpec.describe 'Rate Management Pricelists', bullet: [:n], js: true do
  include_context :login_as_admin

  subject { visit rate_management_pricelists_path(scope: :all) }

  let!(:pricelists) do
    [
      FactoryBot.create(:rate_management_pricelist, :with_project, items_qty: 1, valid_from: 2.days.from_now),
      FactoryBot.create(:rate_management_pricelist, :with_project, :applied, items_qty: 2, valid_from: nil),
      FactoryBot.create(:rate_management_pricelist, :with_project, items_qty: 5, retain_enabled: true),
      FactoryBot.create(:rate_management_pricelist, :with_project, items_qty: 10, retain_priority: true),
      FactoryBot.create(:rate_management_pricelist, :with_project, items_qty: 17, retain_enabled: true, retain_priority: true)
    ]
  end

  it 'should render correct table' do
    subject
    expect(page).to have_table_row(count: pricelists.size)
    pricelists.each do |pricelist|
      within_table_row(id: pricelist.id) do
        expect(page).to have_table_cell(column: 'ID', exact_text: pricelist.id.to_s)
        expect(page).to have_table_cell(column: 'Name', exact_text: pricelist.name)
        expect(page).to have_table_cell(column: 'Project', exact_text: pricelist.project.display_name)
        expect(page).to have_table_cell(column: 'State', exact_text: pricelist.state_name.upcase)
        expect(page).to have_table_cell(column: 'Filename', exact_text: pricelist.filename)
        expect(page).to have_table_cell(column: 'Retain Enabled', exact_text: pricelist.retain_enabled ? 'YES' : 'NO')
        expect(page).to have_table_cell(column: 'Retain Priority', exact_text: pricelist.retain_priority ? 'YES' : 'NO')
        expect(page).to have_table_cell(column: 'Filename', exact_text: pricelist.filename)
        expect(page).to have_table_cell(column: 'Valid From', exact_text: pricelist.valid_from&.strftime('%F %T') || 'NOW')
        expect(page).to have_table_cell(column: 'Valid Till', exact_text: pricelist.valid_till.strftime('%F %T'))
        expect(page).to have_table_cell(column: 'Applied At', exact_text: pricelist.applied_at&.strftime('%F %T'))
        expect(page).to have_link("items (#{pricelist.items.count})", href: rate_management_pricelist_pricelist_items_path(pricelist))
      end
    end

    expect(page).to have_selector('.batch_actions_selector')
  end
end
