# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Rate Management Pricelist Destroy', js: true, bullet: [:n] do
  include_context :login_as_admin

  subject do
    visit rate_management_pricelist_pricelist_items_path(rate_management_pricelist_id: record.id)
    accept_confirm do
      click_on 'Delete Pricelist'
    end
  end

  let!(:project) do
    FactoryBot.create(:rate_management_project, :filled)
  end
  let!(:record) do
    FactoryBot.create(:rate_management_pricelist, :new, project: project, items_qty: 10)
  end

  it 'project should be destroyed' do
    expect(RateManagement::BulkDeletePricelists).to receive(:call).with(pricelist_ids: [record.id]).and_call_original
    expect do
      subject
      expect(page).to have_flash_message('Pricelist was successfully destroyed.', type: :notice)
    end.to change { RateManagement::Pricelist.count }.by(-1)

    expect(RateManagement::Pricelist).not_to be_exists(record.id)
  end
end
