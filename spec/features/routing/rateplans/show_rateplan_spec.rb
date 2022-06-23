# frozen_string_literal: true

RSpec.describe 'Rateplan details' do
  subject do
    visit routing_rateplan_path(rateplan.id)
  end

  include_context :login_as_admin

  before do
    create :admin_user, username: 'test send_to_ids'
  end

  let(:send_to_ids) { Billing::Contact.all.pluck(:id) }
  let!(:rateplan) do
    FactoryBot.create(:rateplan, :filled, send_quality_alarms_to: send_to_ids)
  end

  it 'renders details page' do
    subject
    expect(page).to have_attribute_row('ID', exact_text: rateplan.id.to_s)
  end
end
