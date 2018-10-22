require 'spec_helper'

describe 'Copy Rateplan action', type: :feature do

  # TODO: move login admin to `shared_context :login_as_admin`
  let(:admin_user) { create :admin_user }
  before { login_as(admin_user, scope: :admin_user) }

  shared_examples :cloned_rateplan_is_valid do

    it 'creates new Rateplan with identical fields, except UUID' do
      subject
      expect(rateplan.send_quality_alarms_to).to eq(send_to_ids)
      expect(rateplan.destinations.count).to eq(0)
      expect(Rateplan.count).to eq(2)
      expect(Rateplan.last).to have_attributes(
        name: new_name,
        profit_control_mode_id: rateplan.profit_control_mode_id,
        send_quality_alarms_to: send_to_ids
      )
    end

  end

  context 'success' do

    before do
      create :admin_user, username: 'test send_to_ids'
    end

    let!(:rateplan) do
      create(:rateplan,
             send_quality_alarms_to: send_to_ids
            ).reload # after_save
    end

    let(:new_name) { rateplan.name + '_copy' }

    before { visit rateplan_path(rateplan.id) }

    before do
      click_link('Copy', exact_text: true)
      within '#new_rateplan' do
        fill_in('rateplan_name', with: new_name)
      end
    end

    subject do
      find('input[type=submit]').click
      find('h3', text: 'Rateplan Details') # wait page reload
    end

    context 'when "Send quality alarms to" is empty' do

      let(:send_to_ids) { [] }

      include_examples :cloned_rateplan_is_valid
    end

    context 'when "Send quality alarms to" has values' do

      # assign two Admins to "Send quality alarms to"
      let(:send_to_ids) { AdminUser.all.pluck(:id) }

      include_examples :cloned_rateplan_is_valid
    end

  end

end
