# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RateManagement::BulkDeletePricelists, bullet: [:n] do
  subject do
    described_class.call(pricelist_ids: pricelist_ids)
  end

  shared_examples :deletes_pricelists do
    it 'destroys pricelist with items' do
      item_ids = RateManagement::PricelistItem.where(pricelist_id: pricelist_ids).pluck(:id)
      expect { subject }.to change { RateManagement::Pricelist.count }.by(-pricelist_ids.size)
                                                                      .and change { RateManagement::PricelistItem.count }.by(-item_ids.size)

      expect(RateManagement::Pricelist).not_to be_exists(project.id)
      expect(RateManagement::PricelistItem).not_to be_exists(id: item_ids)
    end
  end

  let(:pricelist_ids) { [pricelist.id] }
  let!(:project) { FactoryBot.create(:rate_management_project, :filled) }

  context 'when pricelist in new state' do
    let!(:pricelist) do
      FactoryBot.create(:rate_management_pricelist, :new, project: project, items_qty: 5)
    end

    include_examples :deletes_pricelists
  end

  context 'when pricelist in dialpeers_detected state' do
    let!(:pricelist) do
      FactoryBot.create(:rate_management_pricelist, :dialpeers_detected, project: project, items_qty: 5)
    end

    include_examples :deletes_pricelists
  end

  context 'when pricelist in applied state' do
    let!(:pricelist) do
      FactoryBot.create(:rate_management_pricelist, :applied, project: project, items_qty: 5)
    end

    include_examples :deletes_pricelists
  end

  context 'when many pricelists passed' do
    let!(:another_project) { FactoryBot.create(:rate_management_project, :filled) }
    let!(:pricelist_ids) { pricelists.map(&:id) }
    let!(:pricelists) do
      [
        FactoryBot.create(:rate_management_pricelist, :new, project: project, items_qty: 5),
        FactoryBot.create(:rate_management_pricelist, :dialpeers_detected, project: project, items_qty: 10),
        FactoryBot.create(:rate_management_pricelist, :applied, project: project, items_qty: 15),
        FactoryBot.create(:rate_management_pricelist, :new, project: another_project, items_qty: 20)
      ]
    end

    include_examples :deletes_pricelists
  end
end
