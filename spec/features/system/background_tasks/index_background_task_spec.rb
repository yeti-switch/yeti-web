# frozen_string_literal: true

require 'spec_helper'

describe 'Index System Background Tasks', type: :feature do
  include_context :login_as_admin

  it 'n+1 checks' do
    background_tasks = create_list(:background_task, 2)
    visit background_tasks_path
    background_tasks.each do |background_task|
      expect(page).to have_css('.resource_id_link', text: background_task.id)
    end
  end
end
