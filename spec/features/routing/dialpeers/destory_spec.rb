# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Delete Dialpeer', type: :feature, js: true do
  subject do
    visit dialpeer_path(dialpeer.id)
    click_delete!
  end

  include_context :login_as_admin
  let(:click_delete!) do
    accept_confirm { click_link 'Delete Dialpeer' }
  end

  let!(:another_dialpeers) { FactoryBot.create_list(:dialpeer, 3) }
  let!(:dialpeer) { FactoryBot.create(:dialpeer) }

  it 'deletes dialpeer successfully' do
    expect do
      subject
      expect(page).to have_flash_message('Dialpeer was successfully destroyed.', type: :notice)
    end.to change(Dialpeer, :count).by(-1)
    expect(page).to have_current_path dialpeers_path
    expect(Dialpeer.exists?(id: dialpeer.id)).to eq false
  end

  context 'when linked to rate_management pricelist item' do
    let!(:pricelist_item) do
      pricelist = FactoryBot.create(:rate_management_pricelist, :with_project)
      FactoryBot.create(:rate_management_pricelist_item, :filed_from_project, pricelist: pricelist, dialpeer: dialpeer)
    end

    it 'does not delete dialpeer' do
      expect do
        subject
        expect(page).to have_current_path dialpeers_path
        expect(page).to have_flash_message("Can't be deleted because linked to not applied Rate Management Pricelist(s) ##{pricelist_item.pricelist_id}", type: :alert)
      end.to change(Dialpeer, :count).by(0)
      expect(dialpeer.reload).to be_present
    end
  end
end
