# frozen_string_literal: true

RSpec.describe 'Rate Management Pricelists Destroy', bullet: [:n], js: true do
  include_context :login_as_admin

  subject do
    visit rate_management_pricelists_path
    table_select_all
    click_batch_action('Delete Selected')
    confirm_modal_dialog
  end

  let!(:pricelists) do
    [
      FactoryBot.create(:rate_management_pricelist, :with_project, items_qty: 1, valid_from: 2.days.from_now),
      FactoryBot.create(:rate_management_pricelist, :with_project, items_qty: 2, valid_from: nil),
      FactoryBot.create(:rate_management_pricelist, :with_project, items_qty: 5, retain_enabled: true),
      FactoryBot.create(:rate_management_pricelist, :with_project, items_qty: 10, retain_priority: true),
      FactoryBot.create(:rate_management_pricelist, :with_project, items_qty: 17, retain_enabled: true, retain_priority: true)
    ]
  end
  let(:pricelist_ids) do
    pricelists.map(&:id).sort.reverse.map(&:to_s)
  end

  it 'should render correct table' do
    expect(RateManagement::BulkDeletePricelists).to receive(:call).with(pricelist_ids: pricelist_ids).and_call_original

    expect do
      subject
      expect(page).to have_flash_message('Selected Pricelists Destroyed!', type: :notice)
    end.to change { RateManagement::Pricelist.count }.by(-pricelists.size)
  end
end
