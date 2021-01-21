# frozen_string_literal: true

RSpec.describe 'Create new Custom Cdr', type: :feature, js: true do
  subject do
    aa_form.submit
  end

  active_admin_form_for Report::CustomCdr, 'new'
  include_context :login_as_admin
  let!(:smtp_connection) { FactoryBot.create(:smtp_connection) }
  let!(:customer) { FactoryBot.create(:customer) }
  let!(:contact) { FactoryBot.create(:contact, contractor: customer) }

  before do
    visit new_custom_cdr_path
  end

  context 'without send_to' do
    before do
      aa_form.select_chosen 'Group by', 'customer_id'
      aa_form.select_chosen 'Group by', 'rateplan_id'
      aa_form.set_date_time 'Date start', '2019-01-01 00:00'
      aa_form.set_date_time 'Date end', '2019-02-01 01:00'
    end

    it 'creates record' do
      subject
      record = Report::CustomCdr.last
      expect(record).to be_present
      expect(record).to have_attributes(
        date_start: Time.zone.parse('2019-01-01 00:00:00'),
        date_end: Time.zone.parse('2019-02-01 01:00:00'),
        group_by: 'customer_id,rateplan_id',
        filter: '',
        customer_id: nil
      )
    end

    include_examples :changes_records_qty_of, Report::CustomCdr, by: 1
    include_examples :changes_records_qty_of, ::Log::EmailLog, by: 0
    include_examples :shows_flash_message, :notice, 'Custom cdr was successfully created.'
  end

  context 'with send_to' do
    before do
      aa_form.select_chosen 'Send to', contact.display_name
      aa_form.select_chosen 'Group by', 'customer_id'
      aa_form.select_chosen 'Group by', 'rateplan_id'
      aa_form.set_date_time 'Date start', '2019-01-01 00:00'
      aa_form.set_date_time 'Date end', '2019-02-01 01:00'
    end

    it 'creates record and email log' do
      subject
      record = Report::CustomCdr.last
      expect(record).to be_present
      expect(record).to have_attributes(
        date_start: Time.zone.parse('2019-01-01 00:00:00'),
        date_end: Time.zone.parse('2019-02-01 01:00:00'),
        group_by: 'customer_id,rateplan_id',
        filter: '',
        customer_id: nil
      )
      email_log = ::Log::EmailLog.last!
      expect(email_log).to have_attributes(
        contact_id: contact.id,
        smtp_connection_id: contact.smtp_connection.id
      )
    end

    include_examples :changes_records_qty_of, Report::CustomCdr, by: 1
    include_examples :changes_records_qty_of, ::Log::EmailLog, by: 1
    include_examples :shows_flash_message, :notice, 'Custom cdr was successfully created.'
  end
end
