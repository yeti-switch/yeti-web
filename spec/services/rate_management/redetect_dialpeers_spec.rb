# frozen_string_literal: true

RSpec.describe RateManagement::RedetectDialpeers do
  subject { described_class.call(**service_params) }

  let(:service_params) { { pricelist: pricelist } }

  let(:pricelist) { FactoryBot.create(:rate_management_pricelist, :with_project, :dialpeers_detected) }

  let!(:to_create_items) do
    FactoryBot.create_list(:rate_management_pricelist_item, 2, :filed_from_project, pricelist: pricelist)
  end

  let!(:to_change_items) do
    dialpeer = FactoryBot.create(:dialpeer)
    dialpeer_2 = FactoryBot.create(:dialpeer)
    [
      FactoryBot.create(:rate_management_pricelist_item, :filed_from_project, pricelist: pricelist, dialpeer: dialpeer, detected_dialpeer_ids: [dialpeer.id]),
      FactoryBot.create(:rate_management_pricelist_item, :filed_from_project, pricelist: pricelist, dialpeer: dialpeer_2, detected_dialpeer_ids: [dialpeer_2.id])
    ]
  end

  let!(:with_error_items) do
    dialpeers = FactoryBot.create_list(:dialpeer, 2)
    dialpeers_2 = FactoryBot.create_list(:dialpeer, 2)
    [
      FactoryBot.create(:rate_management_pricelist_item, :filed_from_project, pricelist: pricelist, dialpeer: nil, detected_dialpeer_ids: dialpeers.map(&:id)),
      FactoryBot.create(:rate_management_pricelist_item, :filed_from_project, pricelist: pricelist, dialpeer: nil, detected_dialpeer_ids: dialpeers_2.map(&:id))
    ]
  end

  let!(:to_delete_items) do
    dialpeer = FactoryBot.create(:dialpeer)
    dialpeer_2 = FactoryBot.create(:dialpeer)
    [
      FactoryBot.create(:rate_management_pricelist_item, :filed_from_project, pricelist: pricelist, dialpeer: dialpeer, detected_dialpeer_ids: [dialpeer.id], to_delete: true),
      FactoryBot.create(:rate_management_pricelist_item, :filed_from_project, pricelist: pricelist, dialpeer: dialpeer_2, detected_dialpeer_ids: [dialpeer_2.id], to_delete: true)
    ]
  end

  it 'should change pricelist state' do
    expect(RateManagement::DetectDialpeers).to receive(:call).with(pricelist: pricelist).once.and_call_original

    expect { subject }.not_to change {
      pricelist.reload.state_id
    }.from(RateManagement::Pricelist::CONST::STATE_ID_DIALPEERS_DETECTED)
  end

  it 'should unassign all dialpeers for items' do
    expect(RateManagement::DetectDialpeers).to receive(:call).with(pricelist: pricelist).once
    subject
    [*to_change_items, *with_error_items].each do |item|
      expect(item.reload).to have_attributes(
                               dialpeer_id: nil,
                               detected_dialpeer_ids: [],
                               type: nil
                             )
    end
  end

  it 'should remove items with delete type' do
    expect(RateManagement::DetectDialpeers).to receive(:call).with(pricelist: pricelist).once
    expect { subject }.to change { RateManagement::PricelistItem.count }.by(-to_delete_items.size)
    to_delete_items.each do |item|
      expect(RateManagement::PricelistItem).not_to be_exists(item.id)
    end
  end

  it 'should not change to create items' do
    expect(RateManagement::DetectDialpeers).to receive(:call).with(pricelist: pricelist).once
    expect { subject }.not_to change { to_create_items.map(&:reload).map(&:attributes) }
  end
end
