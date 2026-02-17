# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Rate Management Project Update', js: true, bullet: [:n] do
  include_context :login_as_admin

  subject do
    visit edit_rate_management_project_path(record)
    fill_form!
    click_on 'Update Project'
  end

  let(:fill_form!) do
    fill_in 'Name', with: new_name
    clear_tom_select 'Gateway'
    fill_in_tom_select 'Gateway Group', with: gateway_group.display_name
    tom_select_deselect_values 'Routing Tags', values: record.routing_tags.map(&:name)
  end

  let!(:record) { FactoryBot.create(:rate_management_project, :filled, :with_routing_tags) }
  let!(:gateway_group) { FactoryBot.create(:gateway_group, vendor: record.vendor) }
  let(:new_name) { 'new_name' }

  it 'should be successfully update project' do
    subject
    expect(page).to have_flash_message('Project was successfully updated.', type: :notice)

    expect(record.reload).to have_attributes(
                               name: new_name,
                               routing_tag_ids: [],
                               gateway: nil,
                               gateway_group: gateway_group
                             )
  end

  context 'when project with same scope attributes exists' do
    let(:fill_form!) do
      fill_in_tom_select 'Vendor', with: another_project.vendor.name, search: true
      fill_in_tom_select 'Account', with: another_project.account.name
      fill_in_tom_select 'Routing group', with: another_project.routing_group.name
      fill_in_tom_select 'Routeset discriminator', with: another_project.routeset_discriminator.name
      fill_in_tom_select 'Gateway', with: another_gateway.name
    end
    let!(:another_project) do
      FactoryBot.create(:rate_management_project, :filled)
    end
    let!(:another_gateway) do
      FactoryBot.create(:gateway, contractor: another_project.vendor)
    end

    it 'does not update project' do
      expect do
        subject
        expect(page).to have_semantic_error_texts(
                          'Project with same scope attributes already exists'
                        )
      end.not_to change { record.reload.attributes }
    end
  end
end
