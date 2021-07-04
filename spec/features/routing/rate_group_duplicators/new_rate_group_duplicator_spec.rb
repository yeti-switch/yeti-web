# frozen_string_literal: true

RSpec.describe 'Create new RateGroup Duplicator', type: :feature, js: true do
  subject do
    aa_form.submit
  end

  active_admin_form_for Routing::RateGroupDuplicatorForm, 'new'
  include_context :login_as_admin

  let!(:rate_group) { FactoryBot.create(:rate_group) }
  before do
    visit new_routing_rate_group_duplicator_path(from: rate_group.id)
    aa_form.set_text 'Name', "#{rate_group.name} dup"
  end

  it 'creates record' do
    expect {
      subject
      expect(page).to have_flash_message('Rate group duplicator was successfully created.', type: :notice)
    }.to change { Routing::RateGroup.count }.by(1)
    record = Routing::RateGroup.last!
    expect(record).to have_attributes(
      name: "#{rate_group.name} dup"
    )
  end
end
