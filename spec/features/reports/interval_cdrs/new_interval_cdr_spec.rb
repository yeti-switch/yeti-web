# frozen_string_literal: true

RSpec.describe 'Create new Interval Cdr', type: :feature, js: true do
  subject do
    visit new_report_interval_cdr_path
    fill_form!
    submit_form!
  end

  include_context :login_as_admin

  let(:submit_form!) { click_submit('Create Interval cdr report') }
  let(:fill_form!) do
    fill_in_chosen 'Interval length', with: '10 Min'
    fill_in_chosen 'Aggregation function', with: 'Count'
    fill_in_chosen 'Aggregate by', with: 'destination_fee'
    fill_in_date_time 'Date start', with: '2019-01-01 00:00:00'
    fill_in_date_time 'Date end', with: '2019-02-01 01:00:00'
  end

  it 'creates record' do
    expect {
      subject
      expect(page).to have_flash_message('Interval cdr report was successfully created.', type: :notice)
    }.to change { Report::IntervalCdr.count }.by(1)
    record = Report::IntervalCdr.last!
    expect(record).to have_attributes(
      date_start: Time.zone.parse('2019-01-01 00:00:00'),
      date_end: Time.zone.parse('2019-02-01 01:00:00'),
      aggregator_id: Report::IntervalAggregator.find_by!(name: 'Count').id,
      aggregate_by: 'destination_fee',
      interval_length: 10,
      send_to: nil,
      group_by: nil,
      filter: nil
    )
  end

  context 'with single group_by' do
    let(:fill_form!) do
      super()
      fill_in_chosen 'Group by', with: 'customer_id', no_search: true
    end

    it 'creates record' do
      expect {
        subject
        expect(page).to have_flash_message('Interval cdr report was successfully created.', type: :notice)
      }.to change { Report::IntervalCdr.count }.by(1)
      record = Report::IntervalCdr.last!
      expect(record).to have_attributes(
                          date_start: Time.zone.parse('2019-01-01 00:00:00'),
                          date_end: Time.zone.parse('2019-02-01 01:00:00'),
                          aggregator_id: Report::IntervalAggregator.find_by!(name: 'Count').id,
                          aggregate_by: 'destination_fee',
                          interval_length: 10,
                          send_to: nil,
                          group_by: %w[customer_id],
                          filter: nil
                        )
    end
  end

  context 'with single group_by' do
    let(:fill_form!) do
      super()
      fill_in_chosen 'Group by', with: 'customer_id', no_search: true
      fill_in_chosen 'Group by', with: 'vendor_id', no_search: true
    end

    it 'creates record' do
      expect {
        subject
        expect(page).to have_flash_message('Interval cdr report was successfully created.', type: :notice)
      }.to change { Report::IntervalCdr.count }.by(1)
      record = Report::IntervalCdr.last!
      expect(record).to have_attributes(
                          date_start: Time.zone.parse('2019-01-01 00:00:00'),
                          date_end: Time.zone.parse('2019-02-01 01:00:00'),
                          aggregator_id: Report::IntervalAggregator.find_by!(name: 'Count').id,
                          aggregate_by: 'destination_fee',
                          interval_length: 10,
                          send_to: nil,
                          group_by: %w[customer_id vendor_id],
                          filter: nil
                        )
    end
  end

  context 'with filter' do
    let(:fill_form!) do
      super()
      fill_in 'Filter', with: 'customer_id=123'
    end

    it 'creates record' do
      expect {
        subject
        expect(page).to have_flash_message('Interval cdr report was successfully created.', type: :notice)
      }.to change { Report::IntervalCdr.count }.by(1)
      record = Report::IntervalCdr.last!
      expect(record).to have_attributes(
                          date_start: Time.zone.parse('2019-01-01 00:00:00'),
                          date_end: Time.zone.parse('2019-02-01 01:00:00'),
                          aggregator_id: Report::IntervalAggregator.find_by!(name: 'Count').id,
                          aggregate_by: 'destination_fee',
                          interval_length: 10,
                          send_to: nil,
                          group_by: nil,
                          filter: 'customer_id=123'
                        )
    end
  end

  context 'with single send_to' do
    let!(:contact) { FactoryBot.create(:contact) }
    let(:fill_form!) do
      super()
      fill_in_chosen 'Send to', with: contact.display_name, multiple: true
    end

    it 'creates record' do
      expect {
        subject
        expect(page).to have_flash_message('Interval cdr report was successfully created.', type: :notice)
      }.to change { Report::IntervalCdr.count }.by(1)
      record = Report::IntervalCdr.last!
      expect(record).to have_attributes(
                          date_start: Time.zone.parse('2019-01-01 00:00:00'),
                          date_end: Time.zone.parse('2019-02-01 01:00:00'),
                          aggregator_id: Report::IntervalAggregator.find_by!(name: 'Count').id,
                          aggregate_by: 'destination_fee',
                          interval_length: 10,
                          send_to: [contact.id],
                          group_by: nil,
                          filter: nil
                        )
    end
  end

  context 'with multiple send_to' do
    let!(:contacts) { FactoryBot.create_list(:contact, 3) }
    let(:fill_form!) do
      super()
      fill_in_chosen 'Send to', with: contacts.first.display_name, multiple: true
      fill_in_chosen 'Send to', with: contacts.second.display_name, multiple: true
    end

    it 'creates record' do
      expect {
        subject
        expect(page).to have_flash_message('Interval cdr report was successfully created.', type: :notice)
      }.to change { Report::IntervalCdr.count }.by(1)
      record = Report::IntervalCdr.last!
      expect(record).to have_attributes(
                          date_start: Time.zone.parse('2019-01-01 00:00:00'),
                          date_end: Time.zone.parse('2019-02-01 01:00:00'),
                          aggregator_id: Report::IntervalAggregator.find_by!(name: 'Count').id,
                          aggregate_by: 'destination_fee',
                          interval_length: 10,
                          send_to: [contacts.first.id, contacts.second.id],
                          group_by: nil,
                          filter: nil
                        )
    end
  end

  context 'with empty form' do
    let(:fill_form!) { nil }

    it 'does not create report' do
      subject
      expect(page).to have_semantic_error_texts(
                        "Date start can't be blank",
                        "Date end can't be blank",
                        "Interval length can't be blank",
                        "Aggregation function can't be blank",
                        "Aggregate by can't be blank"
                      )
    end
  end
end
