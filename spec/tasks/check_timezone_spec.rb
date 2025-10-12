# frozen_string_literal: true

Rails.application.load_tasks

RSpec.describe 'check_timezones.rake' do
  it 'run check timezones' do
    Rake::Task['check_timezones'].invoke
  end
end
