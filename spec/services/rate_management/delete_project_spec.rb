# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RateManagement::DeleteProject, bullet: [:n] do
  subject do
    described_class.call(project: project)
  end

  let!(:project) { FactoryBot.create(:rate_management_project, :filled) }

  it 'destroys project' do
    expect(RateManagement::BulkDeletePricelists).not_to receive(:call)
    expect { subject }.to change { RateManagement::Project.count }.by(-1)
                                                                  .and change { RateManagement::Pricelist.count }.by(0)
                                                                                                                 .and change { RateManagement::PricelistItem.count }.by(0)

    expect(RateManagement::Project).not_to be_exists(project.id)
  end

  context 'when project has pricelists' do
    let!(:pricelists) do
      [
        FactoryBot.create(:rate_management_pricelist, :new, project: project),
        FactoryBot.create(:rate_management_pricelist, :new, project: project, items_qty: 5),
        FactoryBot.create(:rate_management_pricelist, :dialpeers_detected, project: project, items_qty: 10),
        FactoryBot.create(:rate_management_pricelist, :applied, project: project, items_qty: 15)
      ]
    end

    it 'destroys project with pricelists and items' do
      pricelist_ids = pricelists.map(&:id)
      item_ids = pricelists.flat_map(&:items).map(&:id)

      expect(RateManagement::BulkDeletePricelists).to receive(:call)
        .with(pricelist_ids: match_array(pricelist_ids))
        .and_call_original

      expect { subject }.to change { RateManagement::Project.count }.by(-1)
                                                                    .and change { RateManagement::Pricelist.count }.by(-pricelist_ids.size)
                                                                                                                   .and change { RateManagement::PricelistItem.count }.by(-item_ids.size)

      expect(RateManagement::Project).not_to be_exists(project.id)
      expect(RateManagement::Pricelist).not_to be_exists(id: pricelist_ids)
      expect(RateManagement::PricelistItem).not_to be_exists(id: item_ids)
    end
  end
end
