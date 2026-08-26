# frozen_string_literal: true

RSpec.describe 'Batch Destroy System Background Tasks', type: :feature, js: true do
  include_context :login_as_admin

  let!(:records) { FactoryBot.create_list(:background_task, 3) }

  subject do
    visit background_tasks_path
    table_select_all
    # ActiveAdmin 4 confirms batch actions through rails-ujs `data-confirm`, a
    # native browser dialog raised DURING the click — so it must be accepted
    # around the click, not after it as AA3's in-page modal was.
    accept_confirm { click_batch_action('Delete Selected') }
  end

  it 'selected records should be destroyed' do
    expect do
      subject

      expect(page).to have_flash_message('Selected Background Tasks deleted', type: :notice)
    end.to change { BackgroundTask.count }.by(-records.size)
  end
end
