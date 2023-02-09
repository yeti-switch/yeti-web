# frozen_string_literal: true

RSpec.describe 'Rate Management Pricelist Items CSV', type: :feature do
  include_context :login_as_admin

  subject do
    visit rate_management_pricelist_pricelist_items_path(pricelist, index_params)
    parsed_csv
  end

  let(:index_params) { { format: :csv } }
  let!(:project) { FactoryBot.create(:rate_management_project, :filled) }
  let!(:gateway_group) { FactoryBot.create(:gateway_group, vendor: project.vendor) }
  let!(:pricelist) do
    FactoryBot.create(:rate_management_pricelist, :new, project: project)
  end
  let!(:routing_tags) { FactoryBot.create_list(:routing_tag, 5) }
  let!(:dialpeers) do
    FactoryBot.create_list(:dialpeer, 5)
  end
  let!(:pricelist_items) do
    [
      FactoryBot.create(
        :rate_management_pricelist_item,
        :filed_from_project,
        pricelist: pricelist,
        routing_tag_ids: [routing_tags.first.id, routing_tags.second.id]
      ),
      FactoryBot.create(
        :rate_management_pricelist_item,
        :filed_from_project,
        pricelist: pricelist,
        routing_tag_ids: [routing_tags.first.id, routing_tags.third.id, nil]
      ),
      FactoryBot.create(
        :rate_management_pricelist_item,
        :filed_from_project,
        pricelist: pricelist,
        routing_tag_ids: [nil]
      ),
      FactoryBot.create(
        :rate_management_pricelist_item,
        :filed_from_project,
        pricelist: pricelist,
        routing_tag_ids: []
      ),
      FactoryBot.create(
        :rate_management_pricelist_item,
        :filed_from_project,
        pricelist: pricelist,
        gateway: nil,
        gateway_group: gateway_group
      ),
      FactoryBot.create(
        :rate_management_pricelist_item,
        :filed_from_project,
        pricelist: pricelist,
        valid_from: 2.days.from_now
      ),
      FactoryBot.create(
        :rate_management_pricelist_item,
        :filed_from_project,
        pricelist: pricelist,
        enabled: nil
      ),
      FactoryBot.create(
        :rate_management_pricelist_item,
        :filed_from_project,
        pricelist: pricelist,
        priority: nil
      ),
      FactoryBot.create(
        :rate_management_pricelist_item,
        :filed_from_project,
        pricelist: pricelist,
        enabled: true,
        priority: 101
      )
    ]
  end
  let(:parsed_csv) do
    parse_csv_text(page.body)
  end
  let(:expected_csv_rows) do
    pricelist_items.map do |item|
      routing_tag_names = item.routing_tags.map(&:name)
      routing_tag_names << Routing::RoutingTag::ANY_TAG if item.routing_tag_ids.include?(nil)
      routing_tag_names = [RateManagement::VerifyPricelistItems::NOT_TAGGED] if item.routing_tag_ids.empty?
      {
        id: item.id.to_s,
        type: item.type.to_s,
        dialpeer: item.detected_dialpeer_ids.join(', '),
        prefix: item.prefix,
        routing_tags: routing_tag_names.join(', '),
        initial_rate: item.initial_rate.to_s,
        next_rate: item.next_rate.to_s,
        connect_fee: item.connect_fee.to_s,
        initial_interval: item.initial_interval.to_s,
        next_interval: item.next_interval.to_s,
        dst_number_min_length: item.dst_number_min_length.to_s,
        dst_number_max_length: item.dst_number_max_length.to_s,
        enabled: item.enabled.to_s,
        priority: item.priority.to_s,
        vendor: item.vendor.display_name,
        account: item.account.display_name,
        routing_group: item.routing_group.display_name,
        routeset_discriminator: item.routeset_discriminator.display_name,
        gateway: item.gateway&.display_name.to_s,
        gateway_group: item.gateway_group&.display_name.to_s,
        exclusive_route: item.exclusive_route.to_s,
        acd_limit: item.acd_limit.to_s,
        asr_limit: item.asr_limit.to_s,
        capacity: item.capacity.to_s,
        force_hit_rate: item.force_hit_rate.to_s,
        lcr_rate_multiplier: item.lcr_rate_multiplier.to_s,
        reverse_billing: item.reverse_billing.to_s,
        short_calls_limit: item.short_calls_limit.to_s,
        valid_from: item.valid_from&.to_s(:db).to_s,
        valid_till: item.valid_till.to_s(:db),
        src_name_rewrite_result: item.src_name_rewrite_result.to_s,
        src_name_rewrite_rule: item.src_name_rewrite_rule.to_s,
        src_rewrite_result: item.src_rewrite_result.to_s,
        src_rewrite_rule: item.src_rewrite_rule.to_s,
        dst_rewrite_result: item.dst_rewrite_result.to_s,
        dst_rewrite_rule: item.dst_rewrite_rule.to_s
      }
    end
  end

  it 'responds with correct CSV' do
    expect(subject).to match_array(expected_csv_rows)
  end

  context 'when pricelist in dialpeers_detected state' do
    let(:pricelist) do
      FactoryBot.create(:rate_management_pricelist, :dialpeers_detected, project: project)
    end
    let(:pricelist_items) do
      super() + [
        FactoryBot.create(
          :rate_management_pricelist_item,
          :filed_from_project,
          pricelist: pricelist,
          dialpeer_id: dialpeers.first.id,
          detected_dialpeer_ids: [dialpeers.first.id]
        ),
        FactoryBot.create(
          :rate_management_pricelist_item,
          :filed_from_project,
          pricelist: pricelist,
          dialpeer_id: dialpeers.second.id,
          detected_dialpeer_ids: [dialpeers.second.id],
          to_delete: true
        ),
        FactoryBot.create(
          :rate_management_pricelist_item,
          :filed_from_project,
          pricelist: pricelist,
          dialpeer_id: nil,
          detected_dialpeer_ids: [dialpeers.third.id, dialpeers.fourth.id],
          to_delete: true
        )
      ]
    end

    it 'responds with correct CSV' do
      expect(subject).to match_array(expected_csv_rows)
    end
  end

  context 'when pricelist in applied state' do
    let(:pricelist) do
      FactoryBot.create(:rate_management_pricelist, :applied, project: project)
    end
    let(:pricelist_items) do
      super() + [
        FactoryBot.create(
          :rate_management_pricelist_item,
          :filed_from_project,
          pricelist: pricelist,
          dialpeer_id: nil,
          detected_dialpeer_ids: [123]
        ),
        FactoryBot.create(
          :rate_management_pricelist_item,
          :filed_from_project,
          pricelist: pricelist,
          dialpeer_id: nil,
          detected_dialpeer_ids: [dialpeers.second.id],
          to_delete: true
        )
      ]
    end

    it 'responds with correct CSV' do
      expect(subject).to match_array(expected_csv_rows)
    end
  end
end
