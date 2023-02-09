# frozen_string_literal: true

RSpec.describe RateManagement::CreatePricelistItems do
  subject { described_class.call(**service_params) }

  shared_examples :raise_service_error do |message|
    it 'raises RateManagement::CreatePricelistItems::InvalidAttributesError' do
      expect { subject }.to raise_error(RateManagement::CreatePricelistItems::InvalidAttributesError, message)
    end
  end

  let(:service_params) do
    {
      pricelist_items_attrs: pricelist_items_attrs,
      pricelist: pricelist
    }
  end

  let!(:project) do
    FactoryBot.create(:rate_management_project, :filled, :with_routing_tags, **project_attrs)
  end
  let(:project_attrs) { {} }
  let!(:pricelist) { FactoryBot.create(:rate_management_pricelist, **pricelist_attrs) }
  let(:pricelist_attrs) { { project: project } }
  let!(:routing_tags) { FactoryBot.create_list(:routing_tag, 3) }
  let(:default_item_attrs) do
    {
      pricelist_id: pricelist.id,
      valid_till: pricelist.valid_till,
      src_rewrite_rule: project.src_rewrite_rule,
      dst_rewrite_rule: project.dst_rewrite_rule,
      src_rewrite_result: project.src_rewrite_result,
      dst_rewrite_result: project.dst_rewrite_result,
      src_name_rewrite_rule: project.src_name_rewrite_rule,
      src_name_rewrite_result: project.src_name_rewrite_result,
      acd_limit: project.acd_limit,
      asr_limit: project.asr_limit,
      capacity: project.capacity,
      lcr_rate_multiplier: project.lcr_rate_multiplier,
      force_hit_rate: project.force_hit_rate,
      short_calls_limit: project.short_calls_limit,
      exclusive_route: project.exclusive_route,
      reverse_billing: project.reverse_billing,
      account_id: project.account_id,
      vendor_id: project.vendor_id,
      routing_group_id: project.routing_group_id,
      routeset_discriminator_id: project.routeset_discriminator_id,
      gateway_id: project.gateway_id,
      gateway_group_id: project.gateway_group_id
    }
  end
  let(:pricelist_items_attrs) do
    [
      {
        prefix: '523',
        initial_rate: 1,
        next_rate: 2,
        connect_fee: 0.5,
        dst_number_min_length: 25,
        dst_number_max_length: 60,
        initial_interval: 1,
        next_interval: 2,
        routing_tag_ids: [routing_tags.first.id, routing_tags.second.id, nil],
        routing_tag_mode_id: Routing::RoutingTagMode::CONST::AND,
        enabled: true,
        priority: 200,
        valid_from: 2.days.from_now.change(sec: 0),
        **default_item_attrs
      },
      {
        prefix: '524',
        initial_rate: 0.5,
        next_rate: 0.3,
        connect_fee: 1.1,
        dst_number_min_length: 10,
        dst_number_max_length: 20,
        initial_interval: 1,
        next_interval: 60,
        routing_tag_ids: [nil],
        routing_tag_mode_id: Routing::RoutingTagMode::CONST::OR,
        enabled: false,
        priority: 100,
        valid_from: 1.day.from_now.change(sec: 0),
        **default_item_attrs
      },
      {
        prefix: '',
        initial_rate: 2,
        next_rate: 3,
        connect_fee: 0.6,
        dst_number_min_length: project.dst_number_min_length,
        dst_number_max_length: project.dst_number_max_length,
        initial_interval: project.initial_interval,
        next_interval: project.initial_interval,
        routing_tag_ids: project.routing_tag_ids,
        routing_tag_mode_id: project.routing_tag_mode_id,
        enabled: nil,
        priority: nil,
        valid_from: nil,
        **default_item_attrs
      }
    ]
  end

  it 'creates pricelist items' do
    expect { subject }.to change { RateManagement::PricelistItem.count }.by(pricelist_items_attrs.size)
    expect(pricelist.reload.items_count).to eq(pricelist_items_attrs.size)
    pricelist_items = RateManagement::PricelistItem.last(3)
    expect(pricelist_items.first).to have_attributes(
                                       pricelist_items_attrs[0]
                                     )
    expect(pricelist_items.second).to have_attributes(
                                        pricelist_items_attrs[1]
                                      )
    expect(pricelist_items.third).to have_attributes(
                                       pricelist_items_attrs[2]
                                     )
  end

  context 'when pricelist_items_attrs is empty' do
    let(:pricelist_items_attrs) { [] }

    it 'raises RateManagement::CreatePricelistItems::InvalidAttributesError' do
      expect { subject }.to raise_error RateManagement::CreatePricelistItems::InvalidAttributesError,
                                        'must be filled at least 1 item'
    end
  end

  context 'when pricelist is null' do
    let(:service_params) { super().merge pricelist: nil }

    it 'raises RateManagement::CreatePricelistItems::Error' do
      expect { subject }.to raise_error RateManagement::CreatePricelistItems::Error, 'Pricelist must be exist'
    end
  end
end
