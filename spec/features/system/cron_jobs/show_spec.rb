# frozen_string_literal: true

RSpec.describe 'Cron Job show', js: true do
  subject do
    visit cron_job_path(record.id)
  end

  include_context :login_as_admin

  let!(:record) do
    CronJobInfo.take!
  end

  context 'with empty cron job info' do
    it 'renders show page correctly' do
      subject
      expect(page).to have_attribute_row('NAME', exact_text: record.name)
      expect(page).to have_attribute_row('LAST SUCCESS', exact_text: 'EMPTY')
      expect(page).to have_attribute_row('LAST RUN AT', exact_text: 'EMPTY') # last_run_at.strftime('%F %T')
      expect(page).to have_attribute_row('LAST DURATION', exact_text: 'EMPTY')
      expect(page).to have_attribute_row('CRON LINE', exact_text: record.handler_class.cron_line)
      within_panel 'Last Exception' do
        expect(page).to have_text('', exact: true)
      end
    end
  end

  context 'with success cron job info' do
    before do
      record.update!(last_run_at: Time.zone.now, last_duration: 123.456)
    end

    it 'renders show page correctly' do
      subject
      expect(page).to have_attribute_row('NAME', exact_text: record.name)
      expect(page).to have_attribute_row('LAST SUCCESS', exact_text: 'YES')
      expect(page).to have_attribute_row('LAST RUN AT', exact_text: record.last_run_at.strftime('%F %T'))
      expect(page).to have_attribute_row('LAST DURATION', exact_text: record.last_duration.to_s)
      expect(page).to have_attribute_row('CRON LINE', exact_text: record.handler_class.cron_line)
      within_panel 'Last Exception' do
        expect(page).to have_text('', exact: true)
      end
    end
  end

  context 'with failed cron job info' do
    before do
      record.update!(last_run_at: 1.minute.ago, last_duration: 0.01, last_exception: 'some error')
    end

    it 'renders show page correctly' do
      subject
      expect(page).to have_attribute_row('NAME', exact_text: record.name)
      expect(page).to have_attribute_row('LAST SUCCESS', exact_text: 'NO')
      expect(page).to have_attribute_row('LAST RUN AT', exact_text: record.last_run_at.strftime('%F %T'))
      expect(page).to have_attribute_row('LAST DURATION', exact_text: record.last_duration.to_s)
      expect(page).to have_attribute_row('CRON LINE', exact_text: record.handler_class.cron_line)
      within_panel 'Last Exception' do
        expect(page).to have_text('some error', exact: true)
      end
    end
  end
end
