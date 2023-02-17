# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Rate Management Project Destroy', js: true, bullet: [:n] do
  include_context :login_as_admin

  subject do
    visit rate_management_project_path(record)
    accept_confirm do
      click_on 'Delete Rate Management Project'
    end
  end

  let!(:record) { FactoryBot.create(:rate_management_project, :filled) }

  it 'project should be destroyed' do
    expect(RateManagement::DeleteProject).to receive(:call).with(project: record).and_call_original
    expect do
      subject
      expect(page).to have_flash_message('Project was successfully destroyed.')
    end.to change { RateManagement::Project.count }.by(-1)
    expect(RateManagement::Project).not_to be_exists(record.id)
  end
end
