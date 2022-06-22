# frozen_string_literal: true

RSpec.describe 'Copy Rateplan action', js: true do
  subject do
    visit routing_rateplan_path(rateplan.id)
    click_action_item 'Copy'
    fill_form!
  end

  shared_examples :creates_rateplan_copy do
    it 'creates new Rateplan with identical fields, except UUID' do
      expect {
        subject
        expect(page).to have_page_title(new_name)
      }.to change { Routing::Rateplan.count }.by(1)
                                             .and change { Routing::RateGroup.count }.by(0)

      expect(rateplan).to have_attributes(
                            send_quality_alarms_to: send_to_ids,
                            destinations: []
                          )

      new_rate_plan = Routing::Rateplan.last
      expect(new_rate_plan).to have_attributes(
                                 name: new_name,
                                 profit_control_mode_id: rateplan.profit_control_mode_id,
                                 send_quality_alarms_to: match_array(send_to_ids),
                                 rate_groups: match_array(rateplan.rate_groups)
                               )
    end
  end

  include_context :login_as_admin

  before do
    create :admin_user, username: 'test send_to_ids'
  end

  let(:fill_form!) do
    fill_in 'Name', with: new_name
    click_button 'Create'
  end

  let!(:rateplan) do
    create(:rateplan, :filled, send_quality_alarms_to: send_to_ids).reload # after_save
  end

  let(:new_name) { rateplan.name + '_copy' }

  context 'when "Send quality alarms to" is empty' do
    let(:send_to_ids) { [] }

    include_examples :creates_rateplan_copy
  end

  context 'when "Send quality alarms to" has values' do
    # assign two Admins to "Send quality alarms to"
    let(:send_to_ids) { Billing::Contact.all.pluck(:id) }
    before { expect(send_to_ids).to be_present }

    include_examples :creates_rateplan_copy
  end
end
