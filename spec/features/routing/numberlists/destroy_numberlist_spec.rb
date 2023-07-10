# frozen_string_literal: true

RSpec.describe 'Destroy Numberlist', type: :feature, js: true do
  include_context :login_as_admin

  let!(:numberlist) { FactoryBot.create(:numberlist) }

  subject do
    visit numberlist_path(numberlist)
    accept_confirm do
      click_link 'Delete Numberlist'
    end
  end

  it 'should delete numberlist correctly' do
    expect do
      subject
      expect(page).to have_flash_message('Numberlist was successfully destroyed.', type: :notice)
    end.to change { Routing::Numberlist.count }.by(-1)
  end

  context 'when numberlist linked to customers_auth as src_numberlist' do
    before { FactoryBot.create(:customers_auth, src_numberlist: numberlist) }

    it 'should delete numberlist correctly' do
      expect do
        subject
        expect(page).to have_flash_message('Numberlist could not be removed. Cannot delete record because dependent src customers auths exist.', type: :alert)
      end.to change { Routing::Numberlist.count }.by(0)
    end
  end

  context 'when numberlist linked to customers_auth as dst_numberlist' do
    before { FactoryBot.create(:customers_auth, dst_numberlist: numberlist) }

    it 'should delete numberlist correctly' do
      expect do
        subject
        expect(page).to have_flash_message('Numberlist could not be removed. Cannot delete record because dependent dst customers auths exist.', type: :alert)
      end.to change { Routing::Numberlist.count }.by(0)
    end
  end

  context 'when numberlist linked to gateway as termination_dst_numberlist' do
    before { FactoryBot.create(:gateway, termination_dst_numberlist: numberlist) }

    it 'should delete numberlist correctly' do
      expect do
        subject
        expect(page).to have_flash_message('Numberlist could not be removed. Cannot delete record because dependent termination dst gateways exist.', type: :alert)
      end.to change { Routing::Numberlist.count }.by(0)
    end
  end

  context 'when numberlist linked to gateway as termination_src_numberlist' do
    before { FactoryBot.create(:gateway, termination_src_numberlist: numberlist) }

    it 'should delete numberlist correctly' do
      expect do
        subject
        expect(page).to have_flash_message('Numberlist could not be removed. Cannot delete record because dependent termination src gateways exist.', type: :alert)
      end.to change { Routing::Numberlist.count }.by(0)
    end
  end
end
