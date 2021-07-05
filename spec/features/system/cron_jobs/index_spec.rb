# frozen_string_literal: true

RSpec.describe 'Cron Jobs index', js: true do
  subject do
    visit cron_jobs_path
  end

  include_context :login_as_admin

  let!(:jobs) do
    CronJobInfo.all.to_a
  end
  let(:success_job) do
    jobs.first
  end
  let(:failed_job) do
    jobs.second
  end
  let(:empty_jobs) do
    jobs - [success_job, failed_job]
  end
  before do
    success_job.update!(last_run_at: Time.zone.now, last_duration: 123.456)
    failed_job.update!(last_run_at: 1.minute.ago, last_duration: 0.01, last_exception: 'some error')
  end

  it 'renders index page correctly' do
    subject
    expect(page).to have_table_row count: jobs.count
    empty_jobs.each do |job_info|
      within_table_row(id: job_info.id) do
        expect(page).to have_table_cell column: 'Name', exact_text: job_info.name
        expect(page).to have_table_cell column: 'Last Success', exact_text: ''
        expect(page).to have_table_cell column: 'Last Run At', exact_text: ''
        expect(page).to have_table_cell column: 'Last Duration', exact_text: ''
        expect(page).to have_table_cell column: 'Cron Line', exact_text: job_info.handler_class.cron_line
      end
    end
    within_table_row(id: success_job.id) do
      expect(page).to have_table_cell column: 'Name', exact_text: success_job.name
      expect(page).to have_table_cell column: 'Last Success', exact_text: 'YES'
      expect(page).to have_table_cell column: 'Last Run At', exact_text: success_job.last_run_at.strftime('%F %T')
      expect(page).to have_table_cell column: 'Last Duration', exact_text: success_job.last_duration.to_s
      expect(page).to have_table_cell column: 'Cron Line', exact_text: success_job.handler_class.cron_line
    end
    within_table_row(id: failed_job.id) do
      expect(page).to have_table_cell column: 'Name', exact_text: failed_job.name
      expect(page).to have_table_cell column: 'Last Success', exact_text: 'NO'
      expect(page).to have_table_cell column: 'Last Run At', exact_text: failed_job.last_run_at.strftime('%F %T')
      expect(page).to have_table_cell column: 'Last Duration', exact_text: failed_job.last_duration.to_s
      expect(page).to have_table_cell column: 'Cron Line', exact_text: failed_job.handler_class.cron_line
    end
  end
end
