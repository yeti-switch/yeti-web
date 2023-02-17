# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Rate Management Projects', bullet: [:n], js: true do
  include_context :login_as_admin

  subject { visit rate_management_projects_path }

  let!(:records) do
    FactoryBot.create_list(:rate_management_project, 3, :filled)
  end

  it 'should render correct table' do
    subject
    expect(page).to have_table_row(count: records.size)
    records.each do |record|
      within_table_row(id: record.id) do
        expect(page).to have_table_cell(column: 'Id', exact_text: record.id.to_s)
        expect(page).to have_table_cell(column: 'Name', exact_text: record.name)
        expect(page).to have_table_cell(column: 'Routing Group', exact_text: record.routing_group.display_name)
        expect(page).to have_table_cell(column: 'Vendor', exact_text: record.vendor.display_name)
        expect(page).to have_table_cell(column: 'Account', exact_text: record.account.display_name)
        expect(page).to have_table_cell(column: 'Routeset Discriminator', exact_text: record.routeset_discriminator.display_name)
        expect(page).to have_table_cell(column: 'Created At', exact_text: record.created_at.strftime('%F %T'))
        expect(page).to have_table_cell(column: 'Updated At', exact_text: record.updated_at.strftime('%F %T'))
      end
    end

    expect(page).not_to have_selector('.batch_actions_selector')
  end
end
