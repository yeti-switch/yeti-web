# frozen_string_literal: true

RSpec.describe 'Create new Customer Traffic', type: :feature, js: true do
  subject do
    visit new_customer_traffic_path
    fill_form!
    submit_form!
  end

  include_context :login_as_admin

  before do
    FactoryBot.create(:customer)
    FactoryBot.create(:vendor)
  end

  let!(:customer) { FactoryBot.create(:customer, name: 'John Doe') }
  let(:submit_form!) { click_submit('Create Customer traffic report') }
  let(:fill_form!) do
    fill_in_tom_select 'Customer', with: customer.name, search: true
    fill_in_date_time 'Date start', with: '2019-01-01 00:00:00'
    fill_in_date_time 'Date end', with: '2019-02-01 01:00:00'
  end

  it 'creates record' do
    expect {
      subject
      expect(page).to have_flash_message('Customer traffic report was successfully created.', type: :notice)
    }.to change { Report::CustomerTraffic.count }.by(1)
    record = Report::CustomerTraffic.last!
    expect(record).to have_attributes(
      date_start: Time.zone.parse('2019-01-01 00:00:00'),
      date_end: Time.zone.parse('2019-02-01 01:00:00'),
      customer_id: customer.id,
      send_to: nil
    )
  end

  context 'with empty form' do
    let(:fill_form!) { nil }

    it 'does not create report' do
      subject
      expect(page).to have_semantic_error_texts(
                        "Date start can't be blank",
                        "Date end can't be blank",
                        "Customer can't be blank"
                      )
    end
  end
end
