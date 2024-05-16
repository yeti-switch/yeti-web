# frozen_string_literal: true

RSpec.describe 'Routing Schedule Rate Changes', js: true do
  subject do
    visit destinations_path
    filter!

    click_button 'Schedule rate changes'
    fill_form!
    submit_form!
  end

  include_context :login_as_admin

  let!(:destinations) { FactoryBot.create_list(:destination, 5) }
  let(:affected_destinations) { destinations }

  let(:ids_sql) do
    <<-SQL.squish
        SELECT "class4"."destinations"."id" FROM "class4"."destinations"
    SQL
  end
  let(:apply_time) { 1.month.from_now.to_date }

  let(:apply_time_formatted) { apply_time.to_fs(:db) }
  let(:initial_interval) { '60' }
  let(:initial_rate) { '0.1' }
  let(:next_interval) { '60' }
  let(:next_rate) { '0.2' }
  let(:connect_fee) { '0.03' }

  let(:filter!) { nil }
  let(:fill_form!) do
    check :Apply_time
    fill_in :apply_time, with: apply_time_formatted
    check :Initial_interval
    fill_in :initial_interval, with: initial_interval
    check :Initial_rate
    fill_in :initial_rate, with: initial_rate
    check :Next_interval
    fill_in :next_interval, with: next_interval
    check :Next_rate
    fill_in :next_rate, with: next_rate
    check :Connect_fee
    fill_in :connect_fee, with: connect_fee
  end
  let(:submit_form!) { click_button 'OK' }

  it 'should enqueue Worker::ScheduleRateChanges job' do
    expect do
      subject

      expect(page).to have_flash_message('Rate changes are scheduled', type: :notice)
    end.to have_enqueued_job(Worker::ScheduleRateChanges).on_queue('batch_actions').with(
      ids_sql,
      {
        apply_time:,
        initial_interval:,
        initial_rate:,
        next_interval:,
        next_rate:,
        connect_fee:
      }
    )
  end

  context 'when selected only apply_time field' do
    let(:fill_form!) do
      check :Apply_time
      fill_in :apply_time, with: apply_time_formatted
    end

    it 'should show error message' do
      expect do
        subject

        expect(page).to have_flash_message('At least one of the following fields must be filled: '\
                                             'initial_interval, initial_rate, next_interval, next_rate, connect_fee',
                                           type: :error)
      end.not_to have_enqueued_job(Worker::ScheduleRateChanges)
    end
  end

  context 'when selected only rate field' do
    let(:fill_form!) do
      check :Initial_interval
      fill_in :initial_interval, with: initial_interval
    end

    it 'should show error message' do
      expect do
        subject

        expect(page).to have_flash_message("Apply time can't be blank", type: :error)
      end.not_to have_enqueued_job(Worker::ScheduleRateChanges)
    end
  end

  context 'when selected only apply_time and initial_interval field' do
    let(:fill_form!) do
      check :Apply_time
      fill_in :apply_time, with: apply_time_formatted
      check :Initial_interval
      fill_in :initial_interval, with: initial_interval
    end

    it 'should enqueue Worker::ScheduleRateChanges job' do
      expect do
        subject

        expect(page).to have_flash_message('Rate changes are scheduled', type: :notice)
      end.to have_enqueued_job(Worker::ScheduleRateChanges).on_queue('batch_actions').with(
        ids_sql,
        {
          apply_time:,
          initial_interval:,
          initial_rate: nil,
          next_interval: nil,
          next_rate: nil,
          connect_fee: nil
        }
      )
    end
  end

  context 'when selected only apply_time and initial_rate field' do
    let(:fill_form!) do
      check :Apply_time
      fill_in :apply_time, with: apply_time_formatted
      check :Initial_rate
      fill_in :initial_rate, with: initial_rate
    end

    it 'should enqueue Worker::ScheduleRateChanges job' do
      expect do
        subject

        expect(page).to have_flash_message('Rate changes are scheduled', type: :notice)
      end.to have_enqueued_job(Worker::ScheduleRateChanges).on_queue('batch_actions').with(
        ids_sql,
        {
          apply_time:,
          initial_interval: nil,
          initial_rate:,
          next_interval: nil,
          next_rate: nil,
          connect_fee: nil
        }
      )
    end
  end

  context 'when selected only apply_time and next_interval field' do
    let(:fill_form!) do
      check :Apply_time
      fill_in :apply_time, with: apply_time_formatted
      check :Next_interval
      fill_in :next_interval, with: next_interval
    end

    it 'should enqueue Worker::ScheduleRateChanges job' do
      expect do
        subject

        expect(page).to have_flash_message('Rate changes are scheduled', type: :notice)
      end.to have_enqueued_job(Worker::ScheduleRateChanges).on_queue('batch_actions').with(
        ids_sql,
        {
          apply_time:,
          initial_interval: nil,
          initial_rate: nil,
          next_interval:,
          next_rate: nil,
          connect_fee: nil
        }
      )
    end
  end

  context 'when selected only apply_time and next_rate field' do
    let(:fill_form!) do
      check :Apply_time
      fill_in :apply_time, with: apply_time_formatted
      check :Next_rate
      fill_in :next_rate, with: next_rate
    end

    it 'should enqueue Worker::ScheduleRateChanges job' do
      expect do
        subject

        expect(page).to have_flash_message('Rate changes are scheduled', type: :notice)
      end.to have_enqueued_job(Worker::ScheduleRateChanges).on_queue('batch_actions').with(
        ids_sql,
        {
          apply_time:,
          initial_interval: nil,
          initial_rate: nil,
          next_interval: nil,
          next_rate:,
          connect_fee: nil
        }
      )
    end
  end

  context 'when selected only apply_time and connect_fee field' do
    let(:fill_form!) do
      check :Apply_time
      fill_in :apply_time, with: apply_time_formatted
      check :Connect_fee
      fill_in :connect_fee, with: connect_fee
    end

    it 'should enqueue Worker::ScheduleRateChanges job' do
      expect do
        subject

        expect(page).to have_flash_message('Rate changes are scheduled', type: :notice)
      end.to have_enqueued_job(Worker::ScheduleRateChanges).on_queue('batch_actions').with(
        ids_sql,
        {
          apply_time:,
          initial_interval: nil,
          initial_rate: nil,
          next_interval: nil,
          next_rate: nil,
          connect_fee:
        }
      )
    end
  end

  context 'when selected records' do
    let(:filter!) do
      check "batch_action_item_#{destinations[0].id}"
      check "batch_action_item_#{destinations[1].id}"
    end

    let(:affected_destinations) { [destinations[1], destinations[0]] }
    let(:ids_sql) do
      <<-SQL.squish
        SELECT "class4"."destinations"."id" FROM "class4"."destinations" WHERE "class4"."destinations"."id" IN (#{affected_destinations.pluck(:id).join(', ')})
      SQL
    end

    it 'should enqueue Worker::ScheduleRateChanges job' do
      expect do
        subject

        expect(page).to have_flash_message('Rate changes are scheduled', type: :notice)
      end.to have_enqueued_job(Worker::ScheduleRateChanges).on_queue('batch_actions').with(
                ids_sql,
                {
                  apply_time:,
                  initial_interval:,
                  initial_rate:,
                  next_interval:,
                  next_rate:,
                  connect_fee:
                }
              )
    end
  end

  context 'when filtered records' do
    let(:filter!) do
      within_filters do
        fill_in_chosen 'Rate group', with: rate_group.display_name
        click_button :Filter
      end
    end

    let(:affected_destinations) { [destinations[0], destinations[1], destinations[2]] }
    let(:ids_sql) do
      <<-SQL.squish
        SELECT "class4"."destinations"."id" FROM "class4"."destinations" WHERE "class4"."destinations"."rate_group_id" = #{rate_group.id}
      SQL
    end

    let!(:rate_group) { FactoryBot.create(:rate_group) }

    before do
      affected_destinations.each do |destination|
        destination.update!(rate_group:)
      end
    end

    it 'should enqueue Worker::ScheduleRateChanges job' do
      expect do
        subject

        expect(page).to have_flash_message('Rate changes are scheduled', type: :notice)
      end.to have_enqueued_job(Worker::ScheduleRateChanges).on_queue('batch_actions').with(
                ids_sql,
                {
                  apply_time:,
                  initial_interval:,
                  initial_rate:,
                  next_interval:,
                  next_rate:,
                  connect_fee:
                }
              )
    end
  end

  context 'with not selected fields' do
    let(:fill_form!) { nil }

    it 'should show error message' do
      expect do
        subject

        expect(page).to have_flash_message("Validation Error: Apply time can't be blank and At least one of the "\
                                             'following fields must be filled: initial_interval, initial_rate, '\
                                             'next_interval, next_rate, connect_fee',
                                           type: :error)
      end.not_to have_enqueued_job(Worker::ScheduleRateChanges)
    end
  end

  context 'with empty form values' do
    let(:apply_time_formatted) { '' }
    let(:initial_interval) { '' }
    let(:initial_rate) { '' }
    let(:next_interval) { '' }
    let(:next_rate) { '' }
    let(:connect_fee) { '' }

    it 'should show error message' do
      expect do
        subject

        expect(page).to have_flash_message(
                          'Validation Error: Initial rate is not a number, Next rate is not a number, Connect fee is not a number,'\
                            " Initial interval is not a number, Next interval is not a number, and Apply time can't be blank",
                          type: :error
                        )
      end.not_to have_enqueued_job(Worker::ScheduleRateChanges)
    end
  end

  context 'with invalid form values' do
    let(:apply_time_formatted) { 'invalid' }
    let(:initial_interval) { 'invalid' }
    let(:initial_rate) { 'invalid' }
    let(:next_interval) { 'invalid' }
    let(:next_rate) { 'invalid' }
    let(:connect_fee) { 'invalid' }

    it 'should show error message' do
      expect do
        subject

        expect(page).to have_flash_message(
                          'Validation Error: Initial rate is not a number, Next rate is not a number, Connect fee is not a number,'\
                            " Initial interval is not a number, Next interval is not a number, and Apply time can't be blank",
                          type: :error
                        )
      end.not_to have_enqueued_job(Worker::ScheduleRateChanges)
    end
  end

  context 'when apply_time is in the past' do
    let(:apply_time) { 1.second.ago.to_date }

    it 'should show error message' do
      expect do
        subject

        expect(page).to have_flash_message('Validation Error: Apply time must be in the future', type: :error)
      end.not_to have_enqueued_job(Worker::ScheduleRateChanges)
    end
  end
end
