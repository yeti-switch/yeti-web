# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Jobs::DeleteAppliedRateManagementPricelists do
  subject do
    job.call
  end

  let(:job) { described_class.new(double) }

  let(:project_1) do
    FactoryBot.create(:rate_management_project, :filled, keep_applied_pricelists_days: 30)
  end
  let(:project_2) do
    FactoryBot.create(:rate_management_project, :filled, keep_applied_pricelists_days: 0)
  end

  let!(:pricelists_to_delete) do
    # We subtract 1 minute because in scope postgresql NOW() function is used,
    # which returns time of current transaction start,
    # so it can be few seconds earlier that Time.zone.now.
    [
      FactoryBot.create(:rate_management_pricelist, :applied, project: project_1, applied_at: 30.days.ago - 1.minute),
      FactoryBot.create(:rate_management_pricelist, :applied, project: project_1, applied_at: 40.days.ago),
      FactoryBot.create(:rate_management_pricelist, :applied, project: project_2, applied_at: 1.minute.ago),
      FactoryBot.create(:rate_management_pricelist, :applied, project: project_2, applied_at: 30.days.ago - 1.minute)
    ]
  end

  let!(:ignored_pricelists) do
    [
      # ignored because updated_at < project.keep_applied_pricelists_days days ago
      FactoryBot.create(
        :rate_management_pricelist,
        :applied,
        project: project_1,
        applied_at: 29.days.ago,
        created_at: 45.days.ago,
        updated_at: 40.days.ago
      ),

      # ignored because state != applied
      FactoryBot.create(:rate_management_pricelist, :new, project: project_1),
      FactoryBot.create(:rate_management_pricelist, :dialpeers_detected, project: project_2)
    ]
  end

  it 'deletes correct pricelists' do
    expect { subject }.to change { RateManagement::Pricelist.count }.by(-pricelists_to_delete.size)
    deleted_pricelist_ids = pricelists_to_delete.map(&:id)
    expect(RateManagement::Pricelist.exists?(id: deleted_pricelist_ids)).to eq false
  end

  it 'deleted correct pricelist items' do
    deleted_items = ignored_pricelists.flat_map(&:items)
    expect { subject }.to change { RateManagement::PricelistItem.count }.by(-deleted_items.size)
    deleted_item_ids = deleted_items.map(&:id)
    expect(RateManagement::PricelistItem.exists?(id: deleted_item_ids)).to eq false
  end

  it 'does not change ignored pricelists' do
    expect { subject }.not_to change { ignored_pricelists.map(&:reload).map(&:attributes) }
  end

  it 'does not change ignored pricelist items' do
    ignored_items = ignored_pricelists.flat_map(&:items)
    expect { subject }.not_to change { ignored_items.map(&:reload).map(&:attributes) }
  end

  context 'when nothing to delete' do
    let!(:pricelists_to_delete) { [] }

    it 'does not delete pricelists' do
      expect { subject }.to change { RateManagement::Pricelist.count }.by(0)
    end

    it 'does not delete pricelist items' do
      expect { subject }.to change { RateManagement::PricelistItem.count }.by(0)
    end

    it 'does not change ignored pricelists' do
      expect { subject }.not_to change { ignored_pricelists.map(&:reload).map(&:attributes) }
    end

    it 'does not change ignored pricelist items' do
      ignored_items = ignored_pricelists.flat_map(&:items)
      expect { subject }.not_to change { ignored_items.map(&:reload).map(&:attributes) }
    end
  end

  context 'without data' do
    before do
      RateManagement::PricelistItem.delete_all
      RateManagement::Pricelist.delete_all
      RateManagement::Project.delete_all
    end

    it 'does not raise error' do
      expect { subject }.not_to raise_error
    end
  end
end
