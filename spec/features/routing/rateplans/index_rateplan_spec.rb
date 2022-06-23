# frozen_string_literal: true

RSpec.describe 'Index Rateplans', type: :feature do
  subject do
    visit routing_rateplans_path
  end

  include_context :login_as_admin

  before do
    create :admin_user, username: 'test send_to_ids'
  end

  let(:send_to_ids) { Billing::Contact.all.pluck(:id) }
  let!(:rateplans) do
    [
      create_list(:rateplan, 2, :filled),
      create_list(:rateplan, 2, :filled, send_quality_alarms_to: send_to_ids)
    ].flatten
  end

  it 'responds with correct records' do
    subject
    expect(page).to have_table_row(count: rateplans.count)
    rateplans.each do |rateplan|
      expect(page).to have_table_cell(column: 'ID', exact_text: rateplan.id.to_s)
    end
  end
end
