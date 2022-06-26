# frozen_string_literal: true

RSpec.describe 'Create new Custom Cdr', type: :feature, js: true do
  subject do
    visit new_custom_cdr_path
    fill_form!
    submit_form!
  end

  shared_examples :creates_custom_cdr_report do
    it 'creates custom cdr report' do
      expect(CreateReport::CustomCdr).to receive(:call).with(expected_service_params).and_call_original
      expect {
        subject
        expect(page).to have_flash_message('Custom cdr report was successfully created.', type: :notice)
      }.to change { Report::CustomCdr.count }.by(1)
      record = Report::CustomCdr.last!
      expect(page).to have_current_path custom_cdrs_path
      expect(page).to have_table_cell(column: 'ID', text: record.id.to_s, exact: true)
    end
  end

  include_context :login_as_admin
  let!(:customer) { FactoryBot.create(:customer) }
  let!(:contact) { FactoryBot.create(:contact, contractor: customer) }

  let(:submit_form!) { click_submit('Create Custom cdr report') }
  let(:fill_form!) do
    fill_in_chosen 'Group by', with: 'customer_id', no_search: true
    fill_in_chosen 'Group by', with: 'rateplan_id', no_search: true
    fill_in_date_time 'Date start', with: '2019-01-01 00:00:00'
    fill_in_date_time 'Date end', with: '2019-02-01 01:00:00'
  end
  let(:expected_service_params) do
    {
      date_start: Time.zone.parse('2019-01-01 00:00:00'),
      date_end: Time.zone.parse('2019-02-01 01:00:00'),
      group_by: %w[customer_id rateplan_id],
      filter: nil,
      customer: nil,
      send_to: nil
    }
  end

  include_examples :creates_custom_cdr_report

  context 'with set range date_start date_end' do
    let(:fill_form!) do
      fill_in_chosen 'Group by', with: 'customer_id', no_search: true
      within_form_for { click_link 'Set range' }
      within('.block_timerange') { click_on_text 'This Week' }
    end
    let(:expected_service_params) do
      {
        date_start: Time.zone.now.beginning_of_month,
        date_end: Time.zone.now.next_month,
        group_by: %w[customer_id],
        filter: nil,
        customer: nil,
        send_to: nil
      }
    end

    include_examples :creates_custom_cdr_report
  end

  context 'with customer' do
    let(:fill_form!) do
      super()
      fill_in_chosen 'Customer', with: customer.name, ajax: true
    end
    let(:expected_service_params) do
      super().merge customer: customer
    end

    include_examples :creates_custom_cdr_report
  end

  context 'with send_to' do
    let(:fill_form!) do
      super()
      fill_in_chosen 'Send to', with: contact.display_name, multiple: true
    end
    let(:expected_service_params) do
      super().merge send_to: [contact.id]
    end

    include_examples :creates_custom_cdr_report
  end

  context 'with filter' do
    let(:fill_form!) do
      super()
      fill_in 'Filter', with: 'dialpeer_id = 123'
    end
    let(:expected_service_params) do
      super().merge filter: 'dialpeer_id = 123'
    end

    include_examples :creates_custom_cdr_report
  end

  context 'with empty form' do
    let(:fill_form!) { nil }

    it 'does not create report' do
      subject
      expect(page).to have_semantic_error_texts(
                        "Date start can't be blank",
                        "Date end can't be blank",
                        "Group by can't be blank"
                      )
    end
  end
end
