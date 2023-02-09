# frozen_string_literal: true

RSpec.describe RateManagement::DetectDialpeers do
  subject { described_class.call(**service_params) }

  shared_examples :detects_dialpeers_to_create do
    it 'items should have create type' do
      subject

      pricelist_items_to_create.each do |item|
        expect(item.reload).to have_attributes(
                                 dialpeer_id: nil,
                                 detected_dialpeer_ids: [],
                                 type: :create
                               )
      end
    end
  end

  shared_examples :detects_dialpeers_to_change do
    it 'items should have change type' do
      subject
      pricelist_items_to_change.each_with_index do |item, index|
        expect(item.reload).to have_attributes(
                                 dialpeer_id: dialpeers_to_change[index].id,
                                 detected_dialpeer_ids: [dialpeers_to_change[index].id],
                                 type: :change
                               )
      end
    end
  end

  shared_examples :detect_with_error_items do
    it 'items should have error type' do
      subject
      pricelist_items_with_error.each_with_index do |item, index|
        expect(item.reload).to have_attributes(
                                 dialpeer_id: nil,
                                 detected_dialpeer_ids: dialpeers_matched_error[index].map(&:id),
                                 type: :error
                               )
      end
    end

    it 'does not update enabled and priority for error items' do
      expect { subject }.not_to change {
        pricelist_items_with_error.map { |r| r.reload.attributes.slice('enabled', 'priority') }
      }
    end
  end

  shared_examples :detects_dialpeers_to_delete do
    it 'items should have delete type' do
      count = dialpeers_to_delete.size
      expect { subject }.to change { RateManagement::PricelistItem.count }.by(count)

      pricelist_items = RateManagement::PricelistItem.last(count)
      pricelist_items.each_with_index do |item, index|
        expect(item).to have_attributes(
                          dialpeer_id: dialpeers_to_delete[index].id,
                          detected_dialpeer_ids: [dialpeers_to_delete[index].id],
                          type: :delete,
                          to_delete: true,
                          prefix: dialpeers_to_delete[index].prefix,
                          **dialpeer_attrs
                        )
      end
    end
  end

  shared_examples :performs_detect_dialpeers_successfully do
    it 'performs detect dialpeers successfully' do
      subject
      expect(pricelist.reload).to have_attributes(
                                    state_id: RateManagement::Pricelist::CONST::STATE_ID_DIALPEERS_DETECTED,
                                    detect_dialpeers_in_progress: false,
                                    items_count: pricelist.items.count
                                  )
    end
  end

  shared_examples :detect_dialpeers_failed do |error_message|
    it 'should raise error' do
      expect { subject }.to raise_error RateManagement::DetectDialpeers::Error, error_message
    end

    it 'does not change pricelist' do
      expect { safe_subject }.not_to change { pricelist.reload.attributes }
    end
  end

  let(:service_params) { { pricelist: pricelist } }

  let!(:routing_tags) { FactoryBot.create_list(:routing_tag, 6) }
  let!(:project) { FactoryBot.create(:rate_management_project, :filled, **project_attrs) }
  let(:project_attrs) do
    { routing_tag_ids: [routing_tags.first.id, routing_tags.second.id], enabled: true, priority: 100 }
  end
  let(:pricelist) { FactoryBot.create(:rate_management_pricelist, :new, **pricelist_attrs) }
  let(:pricelist_attrs) do
    { project: project, detect_dialpeers_in_progress: true }
  end

  let!(:pricelist_items_to_create) do
    [
      FactoryBot.create(:rate_management_pricelist_item, :filed_from_project, prefix: '123', pricelist: pricelist, enabled: true, priority: 99),
      FactoryBot.create(:rate_management_pricelist_item, :filed_from_project, prefix: '124', pricelist: pricelist, enabled: false, priority: 200),
      FactoryBot.create(:rate_management_pricelist_item, :filed_from_project, prefix: '125', pricelist: pricelist, enabled: nil, priority: 50),
      FactoryBot.create(:rate_management_pricelist_item, :filed_from_project, prefix: '126', pricelist: pricelist, enabled: true, priority: nil),
      FactoryBot.create(:rate_management_pricelist_item, :filed_from_project, prefix: '127', pricelist: pricelist, enabled: false, priority: nil),
      FactoryBot.create(:rate_management_pricelist_item, :filed_from_project, prefix: '128', pricelist: pricelist, enabled: nil, priority: nil)
    ]
  end
  let!(:pricelist_items_to_change) do
    [
      FactoryBot.create(:rate_management_pricelist_item, :filed_from_project, prefix: '223', pricelist: pricelist, enabled: true, priority: 99),
      FactoryBot.create(:rate_management_pricelist_item, :filed_from_project, prefix: '224', pricelist: pricelist, enabled: false, priority: 200),
      FactoryBot.create(:rate_management_pricelist_item, :filed_from_project, prefix: '225', pricelist: pricelist, enabled: nil, priority: 50),
      FactoryBot.create(:rate_management_pricelist_item, :filed_from_project, prefix: '226', pricelist: pricelist, enabled: true, priority: nil),
      FactoryBot.create(:rate_management_pricelist_item, :filed_from_project, prefix: '227', pricelist: pricelist, enabled: false, priority: nil),
      FactoryBot.create(:rate_management_pricelist_item, :filed_from_project, prefix: '228', pricelist: pricelist, enabled: nil, priority: nil),
      FactoryBot.create(:rate_management_pricelist_item, :filed_from_project, prefix: '229', pricelist: pricelist, enabled: nil, priority: nil)
    ]
  end
  let!(:pricelist_items_with_error) do
    [
      FactoryBot.create(:rate_management_pricelist_item, :filed_from_project, prefix: '323', pricelist: pricelist),
      FactoryBot.create(:rate_management_pricelist_item, :filed_from_project, prefix: '324', pricelist: pricelist),
      FactoryBot.create(:rate_management_pricelist_item, :filed_from_project, prefix: '325', pricelist: pricelist, enabled: nil, priority: nil)
    ]
  end

  let(:dialpeer_attrs) do
    {
      vendor: project.vendor,
      account: project.account,
      routing_group: project.routing_group,
      routeset_discriminator: project.routeset_discriminator,
      routing_tag_ids: project.routing_tag_ids
    }
  end
  let!(:dialpeers_to_change) do
    [
      FactoryBot.create(:dialpeer, **dialpeer_attrs, prefix: '223', enabled: false, priority: 101),
      FactoryBot.create(:dialpeer, **dialpeer_attrs, prefix: '224', enabled: true, priority: 102),
      FactoryBot.create(:dialpeer, **dialpeer_attrs, prefix: '225', enabled: false, priority: 103),
      FactoryBot.create(:dialpeer, **dialpeer_attrs, prefix: '226', enabled: false, priority: 104),
      FactoryBot.create(:dialpeer, **dialpeer_attrs, prefix: '227', enabled: true, priority: 105),
      FactoryBot.create(:dialpeer, **dialpeer_attrs, prefix: '228', enabled: false, priority: 106),
      FactoryBot.create(:dialpeer, **dialpeer_attrs, prefix: '229', enabled: true, priority: 107)
    ]
  end
  let!(:dialpeers_matched_error) do
    [
      FactoryBot.create_list(:dialpeer, 2, **dialpeer_attrs, prefix: '323'),
      FactoryBot.create_list(:dialpeer, 2, **dialpeer_attrs, prefix: '324'),
      FactoryBot.create_list(:dialpeer, 2, **dialpeer_attrs, prefix: '325')
    ]
  end
  let!(:dialpeers_to_delete) do
    [
      FactoryBot.create(:dialpeer, **dialpeer_attrs, prefix: 'invalid'),
      FactoryBot.create(:dialpeer, **dialpeer_attrs, prefix: 'invalid')
    ]
  end

  before do
    # out of scope pricelist with items
    pricelist = FactoryBot.create(:rate_management_pricelist, :with_project)
    FactoryBot.create_list(:rate_management_pricelist_item, 3, :filed_from_project, prefix: '130', pricelist: pricelist)
    # out of scope dialpeers
    FactoryBot.create_list(:dialpeer, 3)
  end

  include_examples :performs_detect_dialpeers_successfully
  include_examples :detects_dialpeers_to_create
  include_examples :detects_dialpeers_to_change
  include_examples :detect_with_error_items
  include_examples :detects_dialpeers_to_delete

  it 'fills to_create items with enabled and priority from project' do
    subject
    pricelist_items_to_create.each(&:reload)

    expect(pricelist_items_to_create[0]).to have_attributes(
                                              enabled: true,
                                              priority: 99
                                            )
    expect(pricelist_items_to_create[1]).to have_attributes(
                                              enabled: false,
                                              priority: 200
                                            )
    expect(pricelist_items_to_create[2]).to have_attributes(
                                              enabled: true, # from project
                                              priority: 50
                                            )
    expect(pricelist_items_to_create[3]).to have_attributes(
                                              enabled: true,
                                              priority: 100 # from project
                                            )
    expect(pricelist_items_to_create[4]).to have_attributes(
                                              enabled: false,
                                              priority: 100 # from project
                                            )
    expect(pricelist_items_to_create[5]).to have_attributes(
                                              enabled: true, # from project
                                              priority: 100 # from project
                                            )
  end

  it 'fills to_change items with enabled and priority from project' do
    subject
    pricelist_items_to_change.each(&:reload)

    expect(pricelist_items_to_change[0]).to have_attributes(
                                              enabled: true,
                                              priority: 99
                                            )
    expect(pricelist_items_to_change[1]).to have_attributes(
                                              enabled: false,
                                              priority: 200
                                            )
    expect(pricelist_items_to_change[2]).to have_attributes(
                                              enabled: true, # from project
                                              priority: 50
                                            )
    expect(pricelist_items_to_change[3]).to have_attributes(
                                              enabled: true,
                                              priority: 100 # from project
                                            )
    expect(pricelist_items_to_change[4]).to have_attributes(
                                              enabled: false,
                                              priority: 100 # from project
                                            )
    expect(pricelist_items_to_change[5]).to have_attributes(
                                              enabled: true, # from project
                                              priority: 100 # from project
                                            )
    expect(pricelist_items_to_change[6]).to have_attributes(
                                              enabled: true, # from project
                                              priority: 100 # from project
                                            )
  end

  context 'when pricelist has retain_enabled=true' do
    let(:pricelist_attrs) do
      super().merge retain_enabled: true
    end

    include_examples :performs_detect_dialpeers_successfully
    include_examples :detects_dialpeers_to_create
    include_examples :detects_dialpeers_to_change
    include_examples :detect_with_error_items
    include_examples :detects_dialpeers_to_delete

    it 'fills to_create items with enabled and priority from project' do
      subject
      pricelist_items_to_create.each(&:reload)

      expect(pricelist_items_to_create[0]).to have_attributes(
                                                enabled: true,
                                                priority: 99
                                              )
      expect(pricelist_items_to_create[1]).to have_attributes(
                                                enabled: false,
                                                priority: 200
                                              )
      expect(pricelist_items_to_create[2]).to have_attributes(
                                                enabled: true, # from project
                                                priority: 50
                                              )
      expect(pricelist_items_to_create[3]).to have_attributes(
                                                enabled: true,
                                                priority: 100 # from project
                                              )
      expect(pricelist_items_to_create[4]).to have_attributes(
                                                enabled: false,
                                                priority: 100 # from project
                                              )
      expect(pricelist_items_to_create[5]).to have_attributes(
                                                enabled: true, # from project
                                                priority: 100 # from project
                                              )
    end

    it 'fills to_change items with enabled and priority from project' do
      subject
      pricelist_items_to_change.each(&:reload)

      expect(pricelist_items_to_change[0]).to have_attributes(
                                                enabled: true,
                                                priority: 99
                                              )
      expect(pricelist_items_to_change[1]).to have_attributes(
                                                enabled: false,
                                                priority: 200
                                              )
      expect(pricelist_items_to_change[2]).to have_attributes(
                                                enabled: false, # from dialpeer
                                                priority: 50
                                              )
      expect(pricelist_items_to_change[3]).to have_attributes(
                                                enabled: true,
                                                priority: 100 # from project
                                              )
      expect(pricelist_items_to_change[4]).to have_attributes(
                                                enabled: false,
                                                priority: 100 # from project
                                              )
      expect(pricelist_items_to_change[5]).to have_attributes(
                                                enabled: false, # from dialpeer
                                                priority: 100 # from project
                                              )
      expect(pricelist_items_to_change[6]).to have_attributes(
                                                enabled: true, # from dialpeer
                                                priority: 100 # from project
                                              )
    end
  end

  context 'when pricelist has retain_priority=true' do
    let(:pricelist_attrs) do
      super().merge retain_priority: true
    end

    include_examples :performs_detect_dialpeers_successfully
    include_examples :detects_dialpeers_to_create
    include_examples :detects_dialpeers_to_change
    include_examples :detect_with_error_items
    include_examples :detects_dialpeers_to_delete

    it 'fills to_create items with enabled and priority from project' do
      subject
      pricelist_items_to_create.each(&:reload)

      expect(pricelist_items_to_create[0]).to have_attributes(
                                                enabled: true,
                                                priority: 99
                                              )
      expect(pricelist_items_to_create[1]).to have_attributes(
                                                enabled: false,
                                                priority: 200
                                              )
      expect(pricelist_items_to_create[2]).to have_attributes(
                                                enabled: true, # from project
                                                priority: 50
                                              )
      expect(pricelist_items_to_create[3]).to have_attributes(
                                                enabled: true,
                                                priority: 100 # from project
                                              )
      expect(pricelist_items_to_create[4]).to have_attributes(
                                                enabled: false,
                                                priority: 100 # from project
                                              )
      expect(pricelist_items_to_create[5]).to have_attributes(
                                                enabled: true, # from project
                                                priority: 100 # from project
                                              )
    end

    it 'fills to_change items with enabled and priority from project' do
      subject
      pricelist_items_to_change.each(&:reload)

      expect(pricelist_items_to_change[0]).to have_attributes(
                                                enabled: true,
                                                priority: 99
                                              )
      expect(pricelist_items_to_change[1]).to have_attributes(
                                                enabled: false,
                                                priority: 200
                                              )
      expect(pricelist_items_to_change[2]).to have_attributes(
                                                enabled: true, # from project
                                                priority: 50
                                              )
      expect(pricelist_items_to_change[3]).to have_attributes(
                                                enabled: true,
                                                priority: 104 # from dialpeer
                                              )
      expect(pricelist_items_to_change[4]).to have_attributes(
                                                enabled: false,
                                                priority: 105 # from project
                                              )
      expect(pricelist_items_to_change[5]).to have_attributes(
                                                enabled: true, # from project
                                                priority: 106 # from project
                                              )
      expect(pricelist_items_to_change[6]).to have_attributes(
                                                enabled: true, # from project
                                                priority: 107 # from project
                                              )
    end
  end

  context 'when pricelist has both retain_enabled=true and retain_priority=true' do
    let(:pricelist_attrs) do
      super().merge retain_enabled: true, retain_priority: true
    end

    include_examples :performs_detect_dialpeers_successfully
    include_examples :detects_dialpeers_to_create
    include_examples :detects_dialpeers_to_change
    include_examples :detect_with_error_items
    include_examples :detects_dialpeers_to_delete

    it 'fills to_create items with enabled and priority from project' do
      subject
      pricelist_items_to_create.each(&:reload)

      expect(pricelist_items_to_create[0]).to have_attributes(
                                                enabled: true,
                                                priority: 99
                                              )
      expect(pricelist_items_to_create[1]).to have_attributes(
                                                enabled: false,
                                                priority: 200
                                              )
      expect(pricelist_items_to_create[2]).to have_attributes(
                                                enabled: true, # from project
                                                priority: 50
                                              )
      expect(pricelist_items_to_create[3]).to have_attributes(
                                                enabled: true,
                                                priority: 100 # from project
                                              )
      expect(pricelist_items_to_create[4]).to have_attributes(
                                                enabled: false,
                                                priority: 100 # from project
                                              )
      expect(pricelist_items_to_create[5]).to have_attributes(
                                                enabled: true, # from project
                                                priority: 100 # from project
                                              )
    end

    it 'fills to_change items with enabled and priority from project' do
      subject
      pricelist_items_to_change.each(&:reload)

      expect(pricelist_items_to_change[0]).to have_attributes(
                                                enabled: true,
                                                priority: 99
                                              )
      expect(pricelist_items_to_change[1]).to have_attributes(
                                                enabled: false,
                                                priority: 200
                                              )
      expect(pricelist_items_to_change[2]).to have_attributes(
                                                enabled: false, # from dialpeer
                                                priority: 50
                                              )
      expect(pricelist_items_to_change[3]).to have_attributes(
                                                enabled: true,
                                                priority: 104 # from dialpeer
                                              )
      expect(pricelist_items_to_change[4]).to have_attributes(
                                                enabled: false,
                                                priority: 105 # from dialpeer
                                              )
      expect(pricelist_items_to_change[5]).to have_attributes(
                                                enabled: false, # from dialpeer
                                                priority: 106 # from dialpeer
                                              )
      expect(pricelist_items_to_change[6]).to have_attributes(
                                                enabled: true, # from project
                                                priority: 107 # from dialpeer
                                              )
    end
  end

  context 'when pricelist has state dialpeers_detected' do
    let(:pricelist_attrs) do
      super().merge state_id: RateManagement::Pricelist::CONST::STATE_ID_DIALPEERS_DETECTED
    end

    include_examples :detect_dialpeers_failed, 'Pricelist must be in New state'
  end

  context 'when pricelist has state applied' do
    let(:pricelist_attrs) do
      super().merge state_id: RateManagement::Pricelist::CONST::STATE_ID_APPLIED
    end

    include_examples :detect_dialpeers_failed, 'Pricelist must be in New state'
  end
end
