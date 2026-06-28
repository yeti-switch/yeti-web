# frozen_string_literal: true

RSpec.describe 'Destroy System Background Task', type: :feature, js: true do
  include_context :login_as_admin

  let!(:record) { FactoryBot.create(:background_task) }

  subject do
    visit background_task_path(record)

    accept_confirm do
      click_on 'Delete Background Task'
    end
  end

  it 'record should be destroyed' do
    expect do
      subject

      expect(page).to have_flash_message('Background task was successfully destroyed.', type: :notice)
    end.to change { BackgroundTask.count }.by(-1)
  end
end
