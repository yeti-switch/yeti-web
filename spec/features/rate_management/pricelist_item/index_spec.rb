# frozen_string_literal: true

RSpec.describe 'Rate Management Pricelist Items table', bullet: [:n], js: true do
  include_context :login_as_admin

  subject do
    visit rate_management_pricelist_pricelist_items_path(pricelist, index_params)
  end

  let(:index_params) { {} }
  let!(:project) { FactoryBot.create(:rate_management_project, :filled, :with_routing_tags) }
  let!(:pricelist) do
    FactoryBot.create(
      :rate_management_pricelist,
      state,
      project: project,
      **pricelist_attrs
    )
  end
  let(:pricelist_attrs) { { valid_from: 2.days.from_now.beginning_of_day.in_time_zone } }
  let(:state) { :new }
  let!(:pricelist_items) do
    [
      FactoryBot.create(:rate_management_pricelist_item, :filed_from_project, pricelist: pricelist, enabled: true, priority: 55, dst_rewrite_rule: '^+12313(.*)$'),
      FactoryBot.create(:rate_management_pricelist_item, :filed_from_project, pricelist: pricelist, enabled: false, priority: nil, src_rewrite_rule: '^+12313(.*)$'),
      FactoryBot.create(:rate_management_pricelist_item, :filed_from_project, pricelist: pricelist, enabled: nil, priority: 100, dst_rewrite_rule: '^+12313(.*)$'),
      FactoryBot.create(:rate_management_pricelist_item, :filed_from_project, pricelist: pricelist, enabled: nil, priority: nil, src_rewrite_rule: '^+12313(.*)$')
    ]
  end

  before do
    # out of scope pricelist items
    another_pricelist = FactoryBot.create(:rate_management_pricelist, :with_project)
    FactoryBot.create_list(:rate_management_pricelist_item, 2, :filed_from_project, pricelist: another_pricelist)
  end

  it 'should be correct render' do
    subject

    within_main_content do
      expect(page).to have_table_row(count: pricelist_items.size)
      pricelist_items.each do |item|
        within_table_row(id: item.id) do
          expect(page).to have_table_cell(column: 'ID', exact_text: item.id.to_s)
          expect(page).to have_table_cell(column: 'Prefix', exact_text: item.prefix)
          expect(page).to have_table_cell(column: 'Connect Fee', exact_text: item.connect_fee.to_s)
          expect(page).to have_table_cell(column: 'Routing Tags', exact_text: item.routing_tags.map(&:name).map(&:upcase).join(' | '))
          expect(page).to have_table_cell(column: 'Initial Rate', exact_text: item.initial_rate.to_s)
          expect(page).to have_table_cell(column: 'Next Rate', exact_text: item.next_rate.to_s)
          expect(page).to have_table_cell(column: 'Vendor', exact_text: item.vendor.display_name)
          expect(page).to have_table_cell(column: 'Account', exact_text: item.account.display_name)
          if item.enabled.nil?
            expect(page).to have_table_cell(column: 'Enabled', exact_text: 'EMPTY')
          else
            expect(page).to have_table_cell(column: 'Enabled', exact_text: item.enabled ? 'YES' : 'NO')
          end
          expect(page).to have_table_cell(column: 'Priority', exact_text: item.priority.nil? ? 'EMPTY' : item.priority.to_s)
          expect(page).to have_table_cell(column: 'Routeset Discriminator', exact_text: item.routeset_discriminator.display_name)
          expect(page).to have_table_cell(column: 'Gateway', exact_text: item.gateway.display_name)
          expect(page).to have_table_cell(column: 'Gateway Group', exact_text: 'EMPTY')
          expect(page).to have_table_cell(column: 'Routing Group', exact_text: item.routing_group.display_name)
          expect(page).to have_table_cell(column: 'Exclusive Route', exact_text: item.exclusive_route ? 'YES' : 'NO')
          expect(page).to have_table_cell(column: 'Acd Limit', exact_text: item.acd_limit.to_s)
          expect(page).to have_table_cell(column: 'Asr Limit', exact_text: item.asr_limit.to_s)
          expect(page).to have_table_cell(column: 'Capacity', exact_text: 'EMPTY')
          expect(page).to have_table_cell(column: 'Dst Number Max Length', exact_text: item.dst_number_max_length.to_s)
          expect(page).to have_table_cell(column: 'Dst Number Min Length', exact_text: item.dst_number_min_length.to_s)
          expect(page).to have_table_cell(column: 'Dst Rewrite Result', exact_text: item.dst_rewrite_result)
          expect(page).to have_table_cell(column: 'Dst Rewrite Rule', exact_text: item.dst_rewrite_rule)
          expect(page).to have_table_cell(column: 'Force Hit Rate', exact_text: 'EMPTY')
          expect(page).to have_table_cell(column: 'Lcr Rate Multiplier', exact_text: item.lcr_rate_multiplier.to_s)
          expect(page).to have_table_cell(column: 'Initial Interval', exact_text: item.initial_interval.to_s)
          expect(page).to have_table_cell(column: 'Next Interval', exact_text: item.next_interval.to_s)
          expect(page).to have_table_cell(column: 'Reverse Billing', exact_text: item.reverse_billing ? 'YES' : 'NO')
          expect(page).to have_table_cell(column: 'Short Calls Limit', exact_text: item.short_calls_limit.to_s)
          expect(page).to have_table_cell(column: 'Src Name Rewrite Result', exact_text: item.src_name_rewrite_result)
          expect(page).to have_table_cell(column: 'Src Name Rewrite Rule', exact_text: item.src_name_rewrite_rule)
          expect(page).to have_table_cell(column: 'Src Rewrite Result', exact_text: item.src_rewrite_result)
          expect(page).to have_table_cell(column: 'Src Rewrite Rule', exact_text: item.src_rewrite_rule)
          expect(page).to have_table_cell(column: 'Valid From', exact_text: item.valid_from.to_s(:db))
          expect(page).to have_table_cell(column: 'Valid Till', exact_text: item.valid_till.to_s(:db))
        end
      end
    end

    expect(page).not_to have_selector('.batch_actions_selector')
    expect(page).to have_action_item('Detect Dialpeers')
    expect(page).not_to have_action_item('Redetect Dialpeers')
    expect(page).not_to have_action_item('Apply Changes')

    within_panel 'Rate Management Pricelist' do
      expect(page).to have_attribute_row('ID', exact_text: pricelist.id.to_s)
      expect(page).to have_attribute_row('NAME', exact_text: pricelist.name.to_s)
      expect(page).to have_attribute_row('PROJECT', exact_text: project.display_name.to_s)
      expect(page).to have_attribute_row('STATE', exact_text: 'NEW')
      expect(page).to have_attribute_row('BACKGROUND JOB', exact_text: 'NOTHING')
      expect(page).to have_attribute_row('DIALPEERS', exact_text: 'Dialpeers')
      expect(page).to have_attribute_row('RETAIN ENABLED', exact_text: 'NO')
      expect(page).to have_attribute_row('RETAIN PRIORITY', exact_text: 'NO')
      expect(page).to have_attribute_row('VALID TILL', exact_text: pricelist.valid_till.strftime('%F %T'))
      expect(page).not_to have_attribute_row('APPLIED AT')
      expect(page).to have_attribute_row('CREATED AT', exact_text: pricelist.created_at.strftime('%F %T'))
    end
  end

  context 'when project has gateway_group' do
    let(:project) { FactoryBot.create(:rate_management_project, :filled, :with_routing_tags, :with_gateway_group) }

    it 'should be correct render' do
      subject

      within_main_content do
        expect(page).to have_table_row(count: pricelist_items.size)
        pricelist_items.each do |item|
          within_table_row(id: item.id) do
            expect(page).to have_table_cell(column: 'ID', exact_text: item.id.to_s)
            expect(page).to have_table_cell(column: 'Prefix', exact_text: item.prefix)
            expect(page).to have_table_cell(column: 'Connect Fee', exact_text: item.connect_fee.to_s)
            expect(page).to have_table_cell(column: 'Routing Tags', exact_text: item.routing_tags.map(&:name).map(&:upcase).join(' | '))
            expect(page).to have_table_cell(column: 'Initial Rate', exact_text: item.initial_rate.to_s)
            expect(page).to have_table_cell(column: 'Next Rate', exact_text: item.next_rate.to_s)
            expect(page).to have_table_cell(column: 'Vendor', exact_text: item.vendor.display_name)
            expect(page).to have_table_cell(column: 'Account', exact_text: item.account.display_name)
            if item.enabled.nil?
              expect(page).to have_table_cell(column: 'Enabled', exact_text: 'EMPTY')
            else
              expect(page).to have_table_cell(column: 'Enabled', exact_text: item.enabled ? 'YES' : 'NO')
            end
            expect(page).to have_table_cell(column: 'Priority', exact_text: item.priority.nil? ? 'EMPTY' : item.priority.to_s)
            expect(page).to have_table_cell(column: 'Routeset Discriminator', exact_text: item.routeset_discriminator.display_name)
            expect(page).to have_table_cell(column: 'Gateway', exact_text: 'EMPTY')
            expect(page).to have_table_cell(column: 'Gateway Group', exact_text: item.gateway_group.display_name)
            expect(page).to have_table_cell(column: 'Routing Group', exact_text: item.routing_group.display_name)
            expect(page).to have_table_cell(column: 'Exclusive Route', exact_text: item.exclusive_route ? 'YES' : 'NO')
            expect(page).to have_table_cell(column: 'Acd Limit', exact_text: item.acd_limit.to_s)
            expect(page).to have_table_cell(column: 'Asr Limit', exact_text: item.asr_limit.to_s)
            expect(page).to have_table_cell(column: 'Capacity', exact_text: 'EMPTY')
            expect(page).to have_table_cell(column: 'Dst Number Max Length', exact_text: item.dst_number_max_length.to_s)
            expect(page).to have_table_cell(column: 'Dst Number Min Length', exact_text: item.dst_number_min_length.to_s)
            expect(page).to have_table_cell(column: 'Dst Rewrite Result', exact_text: item.dst_rewrite_result)
            expect(page).to have_table_cell(column: 'Dst Rewrite Rule', exact_text: item.dst_rewrite_rule)
            expect(page).to have_table_cell(column: 'Force Hit Rate', exact_text: 'EMPTY')
            expect(page).to have_table_cell(column: 'Lcr Rate Multiplier', exact_text: item.lcr_rate_multiplier.to_s)
            expect(page).to have_table_cell(column: 'Initial Interval', exact_text: item.initial_interval.to_s)
            expect(page).to have_table_cell(column: 'Next Interval', exact_text: item.next_interval.to_s)
            expect(page).to have_table_cell(column: 'Reverse Billing', exact_text: item.reverse_billing ? 'YES' : 'NO')
            expect(page).to have_table_cell(column: 'Short Calls Limit', exact_text: item.short_calls_limit.to_s)
            expect(page).to have_table_cell(column: 'Src Name Rewrite Result', exact_text: item.src_name_rewrite_result)
            expect(page).to have_table_cell(column: 'Src Name Rewrite Rule', exact_text: item.src_name_rewrite_rule)
            expect(page).to have_table_cell(column: 'Src Rewrite Result', exact_text: item.src_rewrite_result)
            expect(page).to have_table_cell(column: 'Src Rewrite Rule', exact_text: item.src_rewrite_rule)
            expect(page).to have_table_cell(column: 'Valid From', exact_text: item.valid_from.to_s(:db))
            expect(page).to have_table_cell(column: 'Valid Till', exact_text: item.valid_till.to_s(:db))
          end
        end
      end

      expect(page).not_to have_selector('.batch_actions_selector')
      expect(page).to have_action_item('Detect Dialpeers')
      expect(page).not_to have_action_item('Redetect Dialpeers')
      expect(page).not_to have_action_item('Apply Changes')

      within_panel 'Rate Management Pricelist' do
        expect(page).to have_attribute_row('ID', exact_text: pricelist.id.to_s)
        expect(page).to have_attribute_row('NAME', exact_text: pricelist.name.to_s)
        expect(page).to have_attribute_row('PROJECT', exact_text: project.display_name.to_s)
        expect(page).to have_attribute_row('STATE', exact_text: 'NEW')
        expect(page).to have_attribute_row('BACKGROUND JOB', exact_text: 'NOTHING')
        expect(page).to have_attribute_row('DIALPEERS', exact_text: 'Dialpeers')
        expect(page).to have_attribute_row('RETAIN ENABLED', exact_text: 'NO')
        expect(page).to have_attribute_row('RETAIN PRIORITY', exact_text: 'NO')
        expect(page).to have_attribute_row('VALID TILL', exact_text: pricelist.valid_till.strftime('%F %T'))
        expect(page).to have_attribute_row('CREATED AT', exact_text: pricelist.created_at.strftime('%F %T'))
      end
    end
  end

  context 'when pricelist has retain_enabled=true' do
    let!(:pricelist) do
      FactoryBot.create(
        :rate_management_pricelist,
        state,
        project: project,
        valid_from: 2.days.from_now.beginning_of_day.in_time_zone,
        retain_enabled: true
      )
    end

    it 'should be correct render' do
      subject

      within_main_content do
        expect(page).to have_table_row(count: pricelist_items.size)
        pricelist_items.each do |item|
          within_table_row(id: item.id) do
            expect(page).to have_table_cell(column: 'ID', exact_text: item.id.to_s)
          end
        end
      end

      expect(page).not_to have_selector('.batch_actions_selector')
      expect(page).to have_action_item('Detect Dialpeers')
      expect(page).not_to have_action_item('Redetect Dialpeers')
      expect(page).not_to have_action_item('Apply Changes')

      within_panel 'Rate Management Pricelist' do
        expect(page).to have_attribute_row('ID', exact_text: pricelist.id.to_s)
        expect(page).to have_attribute_row('NAME', exact_text: pricelist.name.to_s)
        expect(page).to have_attribute_row('PROJECT', exact_text: project.display_name.to_s)
        expect(page).to have_attribute_row('STATE', exact_text: 'NEW')
        expect(page).to have_attribute_row('BACKGROUND JOB', exact_text: 'NOTHING')
        expect(page).to have_attribute_row('DIALPEERS', exact_text: 'Dialpeers')
        expect(page).to have_attribute_row('RETAIN ENABLED', exact_text: 'YES')
        expect(page).to have_attribute_row('RETAIN PRIORITY', exact_text: 'NO')
        expect(page).to have_attribute_row('VALID TILL', exact_text: pricelist.valid_till.strftime('%F %T'))
        expect(page).to have_attribute_row('CREATED AT', exact_text: pricelist.created_at.strftime('%F %T'))
      end
    end
  end

  context 'when pricelist has retain_priority=true' do
    let!(:pricelist) do
      FactoryBot.create(
        :rate_management_pricelist,
        state,
        project: project,
        valid_from: 2.days.from_now.beginning_of_day.in_time_zone,
        retain_priority: true
      )
    end

    it 'should be correct render' do
      subject

      within_main_content do
        expect(page).to have_table_row(count: pricelist_items.size)
        pricelist_items.each do |item|
          within_table_row(id: item.id) do
            expect(page).to have_table_cell(column: 'ID', exact_text: item.id.to_s)
          end
        end
      end

      expect(page).not_to have_selector('.batch_actions_selector')
      expect(page).to have_action_item('Detect Dialpeers')
      expect(page).not_to have_action_item('Redetect Dialpeers')
      expect(page).not_to have_action_item('Apply Changes')

      within_panel 'Rate Management Pricelist' do
        expect(page).to have_attribute_row('ID', exact_text: pricelist.id.to_s)
        expect(page).to have_attribute_row('NAME', exact_text: pricelist.name.to_s)
        expect(page).to have_attribute_row('PROJECT', exact_text: project.display_name.to_s)
        expect(page).to have_attribute_row('STATE', exact_text: 'NEW')
        expect(page).to have_attribute_row('BACKGROUND JOB', exact_text: 'NOTHING')
        expect(page).to have_attribute_row('DIALPEERS', exact_text: 'Dialpeers')
        expect(page).to have_attribute_row('RETAIN ENABLED', exact_text: 'NO')
        expect(page).to have_attribute_row('RETAIN PRIORITY', exact_text: 'YES')
        expect(page).to have_attribute_row('VALID TILL', exact_text: pricelist.valid_till.strftime('%F %T'))
        expect(page).to have_attribute_row('CREATED AT', exact_text: pricelist.created_at.strftime('%F %T'))
      end
    end
  end

  context 'when detect dialpeers in progress' do
    let(:pricelist) do
      FactoryBot.create(:rate_management_pricelist, state, project: project, detect_dialpeers_in_progress: true)
    end

    it 'shows correct Pricelist sidebar' do
      subject

      within_panel 'Rate Management Pricelist' do
        expect(page).to have_attribute_row('ID', exact_text: pricelist.id.to_s)
        expect(page).to have_attribute_row('NAME', exact_text: pricelist.name.to_s)
        expect(page).to have_attribute_row('PROJECT', exact_text: project.display_name.to_s)
        expect(page).to have_attribute_row('STATE', exact_text: 'NEW')
        expect(page).to have_attribute_row('BACKGROUND JOB', exact_text: 'DETECT DIALPEERS')
        expect(page).to have_attribute_row('DIALPEERS', exact_text: 'Dialpeers')
        expect(page).to have_attribute_row('RETAIN ENABLED', exact_text: 'NO')
        expect(page).to have_attribute_row('RETAIN PRIORITY', exact_text: 'NO')
        expect(page).to have_attribute_row('VALID TILL', exact_text: pricelist.valid_till.strftime('%F %T'))
        expect(page).to have_attribute_row('CREATED AT', exact_text: pricelist.created_at.strftime('%F %T'))
      end

      expect(page).not_to have_action_item('Detect Dialpeers')
      expect(page).not_to have_action_item('Redetect Dialpeers')
      expect(page).not_to have_action_item('Apply Changes')
    end
  end

  context 'when pricelist in dialpeer detected state' do
    let(:state) { :dialpeers_detected }
    let(:to_create) do
      [
        FactoryBot.create(:rate_management_pricelist_item, :filed_from_project, pricelist: pricelist),
        FactoryBot.create(:rate_management_pricelist_item, :filed_from_project, pricelist: pricelist, valid_from: nil)
      ]
    end
    let(:to_change) do
      dialpeer_attrs = {
        vendor: project.vendor,
        account: project.account,
        routeset_discriminator: project.routeset_discriminator,
        routing_group: project.routing_group
      }
      dialpeer = FactoryBot.create(:dialpeer, prefix: '123', gateway_group: nil, **dialpeer_attrs)
      dialpeer_2 = FactoryBot.create(:dialpeer, prefix: '124', gateway: nil, src_name_rewrite_result: nil, **dialpeer_attrs)
      dialpeer_3 = FactoryBot.create(:dialpeer, prefix: '125', enabled: false, **dialpeer_attrs)
      dialpeer_4 = FactoryBot.create(:dialpeer, prefix: '126', **dialpeer_attrs)
      dialpeer_5 = FactoryBot.create(:dialpeer, prefix: '127', **dialpeer_attrs)
      dialpeer_6 = FactoryBot.create(:dialpeer, prefix: '128', **dialpeer_attrs)
      [
        FactoryBot.create(
          :rate_management_pricelist_item,
          :filed_from_project,
          pricelist: pricelist,
          prefix: dialpeer.prefix,
          routing_tag_ids: dialpeer.routing_tag_ids,
          dialpeer: dialpeer,
          detected_dialpeer_ids: [dialpeer.id],
          enabled: true,
          initial_rate: 1.5,
          next_rate: 1.5,
          next_interval: 1.5,
          initial_interval: 1.5,
          connect_fee: 1.5,
          valid_from: nil,
          src_name_rewrite_result: '123'
        ),
        FactoryBot.create(
          :rate_management_pricelist_item,
          :filed_from_project,
          pricelist: pricelist,
          prefix: dialpeer_2.prefix,
          routing_tag_ids: dialpeer_2.routing_tag_ids,
          dialpeer: dialpeer_2,
          detected_dialpeer_ids: [dialpeer_2.id],
          enabled: false,
          initial_rate: 1.6,
          next_rate: 1.6,
          next_interval: 1.6,
          initial_interval: 1.6,
          connect_fee: 1.6,
          gateway_group: dialpeer_2.gateway_group,
          gateway: nil,
          valid_from: 3.days.from_now.beginning_of_day.in_time_zone,
          src_name_rewrite_result: ''
        ),
        FactoryBot.create(
          :rate_management_pricelist_item,
          :filed_from_project,
          pricelist: pricelist,
          prefix: dialpeer_3.prefix,
          routing_tag_ids: dialpeer_3.routing_tag_ids,
          dialpeer: dialpeer_3,
          detected_dialpeer_ids: [dialpeer_3.id],
          enabled: false
        ),
        FactoryBot.create(
          # only rate fields changed
          :rate_management_pricelist_item,
          :filed_from_project,
          pricelist: pricelist,
          dialpeer: dialpeer_4,
          detected_dialpeer_ids: [dialpeer_4.id],
          prefix: dialpeer_4.prefix,
          routing_tag_ids: dialpeer_4.routing_tag_ids,
          enabled: dialpeer_4.enabled,
          src_rewrite_rule: dialpeer_4.src_rewrite_rule,
          dst_rewrite_rule: dialpeer_4.dst_rewrite_rule,
          acd_limit: dialpeer_4.acd_limit,
          asr_limit: dialpeer_4.asr_limit,
          gateway_id: dialpeer_4.gateway_id,
          connect_fee: 0.123,
          initial_rate: 0.01,
          initial_interval: 13,
          next_rate: 0.02,
          next_interval: 14,
          src_rewrite_result: dialpeer_4.src_rewrite_result,
          dst_rewrite_result: dialpeer_4.dst_rewrite_result,
          priority: dialpeer_4.priority,
          capacity: dialpeer_4.capacity,
          lcr_rate_multiplier: dialpeer_4.lcr_rate_multiplier,
          gateway_group_id: dialpeer_4.gateway_group_id,
          force_hit_rate: dialpeer_4.force_hit_rate,
          short_calls_limit: dialpeer_4.short_calls_limit,
          src_name_rewrite_rule: dialpeer_4.src_name_rewrite_rule,
          src_name_rewrite_result: dialpeer_4.src_name_rewrite_result,
          exclusive_route: dialpeer_4.exclusive_route,
          dst_number_min_length: dialpeer_4.dst_number_min_length,
          dst_number_max_length: dialpeer_4.dst_number_max_length,
          reverse_billing: dialpeer_4.reverse_billing,
          routing_tag_mode_id: dialpeer_4.routing_tag_mode_id
        ),
        FactoryBot.create(
          # all fields are same
          :rate_management_pricelist_item,
          :filed_from_project,
          pricelist: pricelist,
          dialpeer: dialpeer_5,
          detected_dialpeer_ids: [dialpeer_5.id],
          prefix: dialpeer_5.prefix,
          routing_tag_ids: dialpeer_5.routing_tag_ids,
          enabled: dialpeer_5.enabled,
          src_rewrite_rule: dialpeer_5.src_rewrite_rule,
          dst_rewrite_rule: dialpeer_5.dst_rewrite_rule,
          acd_limit: dialpeer_5.acd_limit,
          asr_limit: dialpeer_5.asr_limit,
          gateway_id: dialpeer_5.gateway_id,
          next_rate: dialpeer_5.next_rate,
          connect_fee: dialpeer_5.connect_fee,
          src_rewrite_result: dialpeer_5.src_rewrite_result,
          dst_rewrite_result: dialpeer_5.dst_rewrite_result,
          priority: dialpeer_5.priority,
          capacity: dialpeer_5.capacity,
          lcr_rate_multiplier: dialpeer_5.lcr_rate_multiplier,
          initial_rate: dialpeer_5.initial_rate,
          initial_interval: dialpeer_5.initial_interval,
          next_interval: dialpeer_5.next_interval,
          gateway_group_id: dialpeer_5.gateway_group_id,
          force_hit_rate: dialpeer_5.force_hit_rate,
          short_calls_limit: dialpeer_5.short_calls_limit,
          src_name_rewrite_rule: dialpeer_5.src_name_rewrite_rule,
          src_name_rewrite_result: dialpeer_5.src_name_rewrite_result,
          exclusive_route: dialpeer_5.exclusive_route,
          dst_number_min_length: dialpeer_5.dst_number_min_length,
          dst_number_max_length: dialpeer_5.dst_number_max_length,
          reverse_billing: dialpeer_5.reverse_billing,
          routing_tag_mode_id: dialpeer_5.routing_tag_mode_id,
          valid_till: dialpeer_5.valid_till,
          valid_from: dialpeer_5.valid_from + 1.day
        ),
        FactoryBot.create(
          # all fields are same
          :rate_management_pricelist_item,
          :filed_from_project,
          pricelist: pricelist,
          dialpeer: dialpeer_6,
          detected_dialpeer_ids: [dialpeer_6.id],
          prefix: dialpeer_6.prefix,
          routing_tag_ids: dialpeer_6.routing_tag_ids,
          enabled: dialpeer_6.enabled,
          src_rewrite_rule: dialpeer_6.src_rewrite_rule,
          dst_rewrite_rule: dialpeer_6.dst_rewrite_rule,
          acd_limit: dialpeer_6.acd_limit,
          asr_limit: dialpeer_6.asr_limit,
          gateway_id: dialpeer_6.gateway_id,
          next_rate: dialpeer_6.next_rate,
          connect_fee: dialpeer_6.connect_fee,
          src_rewrite_result: dialpeer_6.src_rewrite_result,
          dst_rewrite_result: dialpeer_6.dst_rewrite_result,
          priority: dialpeer_6.priority,
          capacity: dialpeer_6.capacity,
          lcr_rate_multiplier: dialpeer_6.lcr_rate_multiplier,
          initial_rate: dialpeer_6.initial_rate,
          initial_interval: dialpeer_6.initial_interval,
          next_interval: dialpeer_6.next_interval,
          gateway_group_id: dialpeer_6.gateway_group_id,
          force_hit_rate: dialpeer_6.force_hit_rate,
          short_calls_limit: dialpeer_6.short_calls_limit,
          src_name_rewrite_rule: dialpeer_6.src_name_rewrite_rule,
          src_name_rewrite_result: dialpeer_6.src_name_rewrite_result,
          exclusive_route: dialpeer_6.exclusive_route,
          dst_number_min_length: dialpeer_6.dst_number_min_length,
          dst_number_max_length: dialpeer_6.dst_number_max_length,
          reverse_billing: dialpeer_6.reverse_billing,
          routing_tag_mode_id: dialpeer_6.routing_tag_mode_id,
          valid_till: dialpeer_6.valid_till,
          valid_from: dialpeer_6.valid_from - 1.day
        )
      ]
    end
    let(:to_delete) do
      dialpeer = FactoryBot.create(:dialpeer, prefix: '125', vendor: project.vendor, account: project.account, routeset_discriminator: project.routeset_discriminator, routing_group: project.routing_group)
      [FactoryBot.create(:rate_management_pricelist_item, :filed_from_project, pricelist: pricelist, prefix: dialpeer.prefix, routing_tag_ids: dialpeer.routing_tag_ids, dialpeer: dialpeer, detected_dialpeer_ids: [dialpeer.id], to_delete: true)]
    end
    let(:with_error) do
      dialpeers = FactoryBot.create_list(:dialpeer, 2, prefix: '126', vendor: project.vendor, account: project.account, routeset_discriminator: project.routeset_discriminator, routing_group: project.routing_group)
      [FactoryBot.create(:rate_management_pricelist_item, :filed_from_project, prefix: '126', pricelist: pricelist, dialpeer: nil, detected_dialpeer_ids: dialpeers.map(&:id))]
    end
    let(:pricelist_items) do
      [
        *to_create,
        *to_change,
        *to_delete,
        *with_error
      ]
    end

    it 'shows all items' do
      subject

      within_main_content do
        expect(page).to have_table_row(count: pricelist_items.size)
        pricelist_items.each do |item|
          within_table_row(id: item.id) do
            expect(page).to have_table_cell(column: 'ID', exact_text: item.id.to_s)
          end
        end
      end

      within_panel 'Rate Management Pricelist' do
        expect(page).to have_attribute_row('ID', exact_text: pricelist.id.to_s)
        expect(page).to have_attribute_row('NAME', exact_text: pricelist.name.to_s)
        expect(page).to have_attribute_row('PROJECT', exact_text: project.display_name.to_s)
        expect(page).to have_attribute_row('STATE', exact_text: 'DIALPEERS DETECTED')
        expect(page).to have_attribute_row('BACKGROUND JOB', exact_text: 'NOTHING')
        expect(page).to have_attribute_row('DIALPEERS', exact_text: 'Dialpeers')
        expect(page).to have_attribute_row('RETAIN ENABLED', exact_text: 'NO')
        expect(page).to have_attribute_row('RETAIN PRIORITY', exact_text: 'NO')
        expect(page).to have_attribute_row('VALID TILL', exact_text: pricelist.valid_till.strftime('%F %T'))
        expect(page).to have_attribute_row('CREATED AT', exact_text: pricelist.created_at.strftime('%F %T'))
      end

      expect(page).not_to have_action_item('Detect Dialpeers')
      expect(page).to have_action_item('Redetect Dialpeers')
      expect(page).not_to have_action_item('Apply Changes')
    end

    context 'when there are no error items' do
      let(:with_error) { [] }

      it 'shows all items' do
        subject

        within_main_content do
          expect(page).to have_table_row(count: pricelist_items.size)
          pricelist_items.each do |item|
            within_table_row(id: item.id) do
              expect(page).to have_table_cell(column: 'ID', exact_text: item.id.to_s)
            end
          end
        end

        within_panel 'Rate Management Pricelist' do
          expect(page).to have_attribute_row('ID', exact_text: pricelist.id.to_s)
          expect(page).to have_attribute_row('NAME', exact_text: pricelist.name.to_s)
          expect(page).to have_attribute_row('PROJECT', exact_text: project.display_name.to_s)
          expect(page).to have_attribute_row('STATE', exact_text: 'DIALPEERS DETECTED')
          expect(page).to have_attribute_row('BACKGROUND JOB', exact_text: 'NOTHING')
          expect(page).to have_attribute_row('DIALPEERS', exact_text: 'Dialpeers')
          expect(page).to have_attribute_row('RETAIN ENABLED', exact_text: 'NO')
          expect(page).to have_attribute_row('RETAIN PRIORITY', exact_text: 'NO')
          expect(page).to have_attribute_row('VALID TILL', exact_text: pricelist.valid_till.strftime('%F %T'))
          expect(page).to have_attribute_row('CREATED AT', exact_text: pricelist.created_at.strftime('%F %T'))
        end

        expect(page).not_to have_action_item('Detect Dialpeers')
        expect(page).to have_action_item('Redetect Dialpeers')
        expect(page).to have_action_item('Apply Changes')
      end
    end

    context 'when detect dialpeers in progress' do
      let(:with_error) { [] }
      let(:pricelist) do
        FactoryBot.create(:rate_management_pricelist, state, project: project, detect_dialpeers_in_progress: true)
      end

      it 'shows all items' do
        subject

        within_main_content do
          expect(page).to have_table_row(count: pricelist_items.size)
          pricelist_items.each do |item|
            within_table_row(id: item.id) do
              expect(page).to have_table_cell(column: 'ID', exact_text: item.id.to_s)
            end
          end
        end

        within_panel 'Rate Management Pricelist' do
          expect(page).to have_attribute_row('ID', exact_text: pricelist.id.to_s)
          expect(page).to have_attribute_row('NAME', exact_text: pricelist.name.to_s)
          expect(page).to have_attribute_row('PROJECT', exact_text: project.display_name.to_s)
          expect(page).to have_attribute_row('STATE', exact_text: 'DIALPEERS DETECTED')
          expect(page).to have_attribute_row('BACKGROUND JOB', exact_text: 'REDETECT DIALPEERS')
          expect(page).to have_attribute_row('DIALPEERS', exact_text: 'Dialpeers')
          expect(page).to have_attribute_row('RETAIN ENABLED', exact_text: 'NO')
          expect(page).to have_attribute_row('RETAIN PRIORITY', exact_text: 'NO')
          expect(page).to have_attribute_row('VALID TILL', exact_text: pricelist.valid_till.strftime('%F %T'))
          expect(page).to have_attribute_row('CREATED AT', exact_text: pricelist.created_at.strftime('%F %T'))
        end

        expect(page).not_to have_action_item('Detect Dialpeers')
        expect(page).not_to have_action_item('Redetect Dialpeers')
        expect(page).not_to have_action_item('Apply Changes')
      end
    end

    context 'when apply changes in progress' do
      let(:with_error) { [] }
      let(:pricelist) do
        FactoryBot.create(:rate_management_pricelist, :dialpeers_detected, project: project, apply_changes_in_progress: true)
      end

      it 'shows correct Pricelist sidebar' do
        subject

        within_main_content do
          expect(page).to have_table_row(count: pricelist_items.size)
          pricelist_items.each do |item|
            within_table_row(id: item.id) do
              expect(page).to have_table_cell(column: 'ID', exact_text: item.id.to_s)
            end
          end
        end

        within_panel 'Rate Management Pricelist' do
          expect(page).to have_attribute_row('ID', exact_text: pricelist.id.to_s)
          expect(page).to have_attribute_row('NAME', exact_text: pricelist.name.to_s)
          expect(page).to have_attribute_row('PROJECT', exact_text: project.display_name.to_s)
          expect(page).to have_attribute_row('STATE', exact_text: 'DIALPEERS DETECTED')
          expect(page).to have_attribute_row('BACKGROUND JOB', exact_text: 'APPLY CHANGES')
          expect(page).to have_attribute_row('DIALPEERS', exact_text: 'Dialpeers')
          expect(page).to have_attribute_row('RETAIN ENABLED', exact_text: 'NO')
          expect(page).to have_attribute_row('RETAIN PRIORITY', exact_text: 'NO')
          expect(page).to have_attribute_row('VALID TILL', exact_text: pricelist.valid_till.strftime('%F %T'))
          expect(page).to have_attribute_row('CREATED AT', exact_text: pricelist.created_at.strftime('%F %T'))
        end

        expect(page).not_to have_action_item('Detect Dialpeers')
        expect(page).not_to have_action_item('Redetect Dialpeers')
        expect(page).not_to have_action_item('Apply Changes')
      end
    end

    context 'create scope' do
      let(:index_params) { { scope: 'create' } }

      it 'should render correct record' do
        subject

        within_main_content do
          expect(page).to have_table_row(count: to_create.size)
          to_create.each do |item|
            within_table_row(id: item.id) do
              expect(page).to have_table_cell(column: 'ID', exact_text: item.id.to_s)
              expect(page).to have_table_cell(column: 'Type', exact_text: 'CREATE')
              expect(page).to have_table_cell(column: 'Dialpeer', exact_text: 'EMPTY')
              expect(page).to have_table_cell(column: 'Valid from', exact_text: item.valid_from&.to_s(:db) || 'NOW')
            end
          end
        end
      end
    end

    context 'change scope' do
      let(:index_params) { { scope: 'change' } }

      it 'should render correct record' do
        subject

        within_main_content do
          expect(page).to have_table_row(count: to_change.size)
          within_table_row(id: to_change.first.id) do
            expect(page).to have_table_cell(column: 'ID', exact_text: to_change.first.id.to_s)
            expect(page).to have_table_cell(column: 'Type', exact_text: 'CHANGE')
            expect(page).to have_table_cell(column: 'Dialpeer', exact_text: to_change.first.dialpeer.display_name)
            expect(page).to have_table_cell(column: 'Initial Rate', exact_text: "#{to_change.first.dialpeer.initial_rate} => #{to_change.first.initial_rate}")
            expect(page).to have_table_cell(column: 'Next Rate', exact_text: "#{to_change.first.dialpeer.next_rate} => #{to_change.first.next_rate}")
            expect(page).to have_table_cell(column: 'Initial Interval', exact_text: "#{to_change.first.dialpeer.initial_interval} => #{to_change.first.initial_interval}")
            expect(page).to have_table_cell(column: 'Next Interval', exact_text: "#{to_change.first.dialpeer.next_interval} => #{to_change.first.next_interval}")
            expect(page).to have_table_cell(column: 'Gateway', exact_text: "EMPTY => #{to_change.first.gateway.display_name}")
            expect(page).to have_table_cell(column: 'Gateway Group', exact_text: "#{to_change.first.dialpeer.gateway_group.display_name} => EMPTY")
            expect(page).to have_table_cell(column: 'Connect Fee', exact_text: "#{to_change.first.dialpeer.connect_fee} => #{to_change.first.connect_fee}")
            expect(page).to have_table_cell(column: 'Enabled', exact_text: 'YES')
            expect(page).to have_table_cell(column: 'Valid From', exact_text: "#{to_change.first.dialpeer.valid_from.to_s(:db)} => NOW")
            expect(page).to have_table_cell(column: 'Src Name Rewrite Result', exact_text: "EMPTY => #{to_change.first.src_name_rewrite_result}")
          end
          within_table_row(id: to_change.second.id) do
            expect(page).to have_table_cell(column: 'ID', exact_text: to_change.second.id.to_s)
            expect(page).to have_table_cell(column: 'Type', exact_text: 'CHANGE')
            expect(page).to have_table_cell(column: 'Dialpeer', exact_text: to_change.second.dialpeer.display_name)
            expect(page).to have_table_cell(column: 'Initial Rate', exact_text: "#{to_change.second.dialpeer.initial_rate} => #{to_change.second.initial_rate}")
            expect(page).to have_table_cell(column: 'Next Rate', exact_text: "#{to_change.second.dialpeer.next_rate} => #{to_change.second.next_rate}")
            expect(page).to have_table_cell(column: 'Initial Interval', exact_text: "#{to_change.second.dialpeer.initial_interval} => #{to_change.second.initial_interval}")
            expect(page).to have_table_cell(column: 'Next Interval', exact_text: "#{to_change.second.dialpeer.next_interval} => #{to_change.second.next_interval}")
            expect(page).to have_table_cell(column: 'Gateway', exact_text: 'EMPTY')
            expect(page).to have_table_cell(column: 'Gateway Group', exact_text: to_change.second.dialpeer.gateway_group.display_name.to_s)
            expect(page).to have_table_cell(column: 'Connect Fee', exact_text: "#{to_change.second.dialpeer.connect_fee} => #{to_change.second.connect_fee}")
            expect(page).to have_table_cell(column: 'Enabled', exact_text: "#{to_change.second.dialpeer.enabled ? 'YES' : 'NO'} => NO")
            expect(page).to have_table_cell(column: 'Valid From', exact_text: "#{to_change.second.dialpeer.valid_from.to_s(:db)} => #{to_change.second.valid_from.to_s(:db)}")
            expect(page).to have_table_cell(column: 'Src Name Rewrite Result', exact_text: 'EMPTY')
          end
          within_table_row(id: to_change.third.id) do
            expect(page).to have_table_cell(column: 'ID', exact_text: to_change.third.id.to_s)
            expect(page).to have_table_cell(column: 'Type', exact_text: 'CHANGE')
            expect(page).to have_table_cell(column: 'Dialpeer', exact_text: to_change.third.dialpeer.display_name)
            expect(page).to have_table_cell(column: 'Enabled', exact_text: 'NO')
          end
          within_table_row(id: to_change.fourth.id) do
            expect(page).to have_table_cell(column: 'ID', exact_text: to_change.fourth.id.to_s)
            expect(page).to have_table_cell(column: 'Type', exact_text: 'CHANGE NEXT RATE')
            expect(page).to have_table_cell(column: 'Dialpeer', exact_text: to_change.fourth.dialpeer.display_name)
          end
          within_table_row(id: to_change.fifth.id) do
            expect(page).to have_table_cell(column: 'ID', exact_text: to_change.fifth.id.to_s)
            expect(page).to have_table_cell(column: 'Type', exact_text: 'CHANGE NO CHANGE')
            expect(page).to have_table_cell(column: 'Dialpeer', exact_text: to_change.fifth.dialpeer.display_name)
            expect(page).to have_table_cell(column: 'Valid From', exact_text: to_change.fifth.dialpeer.valid_from&.strftime('%F %T'))
          end
          within_table_row(id: to_change[5].id) do
            expect(page).to have_table_cell(column: 'ID', exact_text: to_change[5].id.to_s)
            expect(page).to have_table_cell(column: 'Type', exact_text: 'CHANGE NO CHANGE')
            expect(page).to have_table_cell(column: 'Dialpeer', exact_text: to_change[5].dialpeer.display_name)
            expect(page).to have_table_cell(column: 'Valid From', exact_text: "#{to_change[5].dialpeer.valid_from.strftime('%F %T')} => #{to_change[5].valid_from.strftime('%F %T')}")
          end
        end
      end
    end

    context 'delete scope' do
      let(:index_params) { { scope: 'delete' } }

      it 'should render correct record' do
        subject

        within_main_content do
          expect(page).to have_table_row(count: to_delete.size)
          to_delete.each do |item|
            within_table_row(id: item.id) do
              expect(page).to have_table_cell(column: 'ID', exact_text: item.id.to_s)
              expect(page).to have_table_cell(column: 'Type', exact_text: 'DELETE')
              expect(page).to have_table_cell(column: 'Dialpeer', exact_text: item.dialpeer.display_name)
              expect(page).to have_table_cell(column: 'Valid Till', exact_text: "#{item.dialpeer.valid_till.to_s(:db)} => #{pricelist.valid_from.to_s(:db)}")
            end
          end
        end
      end

      context 'when pricelist valid_from=nil' do
        let(:pricelist_attrs) { super().merge(valid_from: nil) }

        it 'should render correct record' do
          subject

          within_main_content do
            expect(page).to have_table_row(count: to_delete.size)
            to_delete.each do |item|
              within_table_row(id: item.id) do
                expect(page).to have_table_cell(column: 'ID', exact_text: item.id.to_s)
                expect(page).to have_table_cell(column: 'Type', exact_text: 'DELETE')
                expect(page).to have_table_cell(column: 'Dialpeer', exact_text: item.dialpeer.display_name)
                expect(page).to have_table_cell(column: 'Valid Till', exact_text: "#{item.dialpeer.valid_till.to_s(:db)} => NOW")
              end
            end
          end
        end
      end
    end

    context 'error scope' do
      let(:index_params) { { scope: 'error' } }

      it 'should render correct record' do
        subject

        within_main_content do
          expect(page).to have_table_row(count: with_error.size)
          with_error.each do |item|
            within_table_row(id: item.id) do
              expect(page).to have_table_cell(column: 'ID', exact_text: item.id.to_s)
              expect(page).to have_table_cell(column: 'Type', exact_text: 'ERROR')
              expect(page).to have_link("Dialpeers (#{item.detected_dialpeer_ids.size})", href: dialpeers_path(q: { id_in_string: item.detected_dialpeer_ids.join(',') }))
            end
          end
        end
      end
    end
  end

  context 'when pricelist in applied state' do
    let(:state) { :applied }
    let(:to_create) do
      FactoryBot.create_list(:rate_management_pricelist_item, 2, :filed_from_project, pricelist: pricelist)
    end
    let(:to_change) do
      [
        FactoryBot.create(
          :rate_management_pricelist_item,
          :filed_from_project,
          pricelist: pricelist,
          prefix: '3215',
          routing_tag_ids: project.routing_tag_ids,
          dialpeer: nil,
          detected_dialpeer_ids: [123],
          enabled: true,
          initial_rate: 1.5,
          next_rate: 1.5,
          next_interval: 1.5,
          initial_interval: 1.5,
          connect_fee: 1.5,
          valid_from: Time.zone.now.beginning_of_day.in_time_zone
        ),
        FactoryBot.create(
          :rate_management_pricelist_item,
          :filed_from_project,
          pricelist: pricelist,
          prefix: '86756',
          routing_tag_ids: project.routing_tag_ids,
          dialpeer: nil,
          detected_dialpeer_ids: [456],
          enabled: false,
          initial_rate: 1.6,
          next_rate: 1.6,
          next_interval: 1.6,
          initial_interval: 1.6,
          connect_fee: 1.6,
          valid_from: 3.days.from_now.beginning_of_day.in_time_zone
        )
      ]
    end
    let(:to_delete) do
      [
        FactoryBot.create(
          :rate_management_pricelist_item,
          :filed_from_project,
          pricelist: pricelist,
          prefix: '1123',
          routing_tag_ids: project.routing_tag_ids,
          dialpeer: nil,
          detected_dialpeer_ids: [789],
          to_delete: true
        )
      ]
    end
    let(:pricelist_items) do
      [
        *to_create,
        *to_change,
        *to_delete
      ]
    end

    it 'shows all items' do
      subject

      within_main_content do
        expect(page).to have_table_row(count: pricelist_items.size)
        pricelist_items.each do |item|
          within_table_row(id: item.id) do
            expect(page).to have_table_cell(column: 'ID', exact_text: item.id.to_s)
          end
        end
      end

      within_panel 'Rate Management Pricelist' do
        expect(page).to have_attribute_row('ID', exact_text: pricelist.id.to_s)
        expect(page).to have_attribute_row('NAME', exact_text: pricelist.name.to_s)
        expect(page).to have_attribute_row('PROJECT', exact_text: project.display_name.to_s)
        expect(page).to have_attribute_row('STATE', exact_text: 'APPLIED')
        expect(page).to have_attribute_row('BACKGROUND JOB', exact_text: 'NOTHING')
        expect(page).to have_attribute_row('DIALPEERS', exact_text: 'Dialpeers')
        expect(page).to have_attribute_row('RETAIN ENABLED', exact_text: 'NO')
        expect(page).to have_attribute_row('RETAIN PRIORITY', exact_text: 'NO')
        expect(page).to have_attribute_row('VALID TILL', exact_text: pricelist.valid_till.strftime('%F %T'))
        expect(page).to have_attribute_row('APPLIED AT', exact_text: pricelist.applied_at.strftime('%F %T'))
        expect(page).to have_attribute_row('CREATED AT', exact_text: pricelist.created_at.strftime('%F %T'))
      end

      expect(page).not_to have_action_item('Detect Dialpeers')
      expect(page).not_to have_action_item('Redetect Dialpeers')
      expect(page).not_to have_action_item('Apply Changes')
    end

    context 'create scope' do
      let(:index_params) { { scope: 'create' } }

      it 'should render correct record' do
        subject

        within_main_content do
          expect(page).to have_table_row(count: to_create.size)
          to_create.each do |item|
            within_table_row(id: item.id) do
              expect(page).to have_table_cell(column: 'ID', exact_text: item.id.to_s)
              expect(page).to have_table_cell(column: 'Type', exact_text: 'CREATE')
              expect(page).to have_table_cell(column: 'Dialpeer', exact_text: 'EMPTY')
              expect(page).to have_table_cell(column: 'Prefix', exact_text: item.prefix)
              expect(page).to have_table_cell(column: 'Connect Fee', exact_text: item.connect_fee.to_s)
              expect(page).to have_table_cell(column: 'Routing Tags', exact_text: item.routing_tags.map(&:name).map(&:upcase).join(' | '))
              expect(page).to have_table_cell(column: 'Initial Rate', exact_text: item.initial_rate.to_s)
              expect(page).to have_table_cell(column: 'Next Rate', exact_text: item.next_rate.to_s)
              expect(page).to have_table_cell(column: 'Vendor', exact_text: item.vendor.display_name)
              expect(page).to have_table_cell(column: 'Account', exact_text: item.account.display_name)
              expect(page).to have_table_cell(column: 'Enabled', exact_text: item.enabled ? 'YES' : 'NO')
              expect(page).to have_table_cell(column: 'Priority', exact_text: item.priority.nil? ? 'EMPTY' : item.priority.to_s)
              expect(page).to have_table_cell(column: 'Routeset Discriminator', exact_text: item.routeset_discriminator.display_name)
              expect(page).to have_table_cell(column: 'Gateway', exact_text: item.gateway.display_name)
              expect(page).to have_table_cell(column: 'Gateway Group', exact_text: 'EMPTY')
              expect(page).to have_table_cell(column: 'Routing Group', exact_text: item.routing_group.display_name)
              expect(page).to have_table_cell(column: 'Exclusive Route', exact_text: item.exclusive_route ? 'YES' : 'NO')
              expect(page).to have_table_cell(column: 'Acd Limit', exact_text: item.acd_limit.to_s)
              expect(page).to have_table_cell(column: 'Asr Limit', exact_text: item.asr_limit.to_s)
              expect(page).to have_table_cell(column: 'Capacity', exact_text: 'EMPTY')
              expect(page).to have_table_cell(column: 'Dst Number Max Length', exact_text: item.dst_number_max_length.to_s)
              expect(page).to have_table_cell(column: 'Dst Number Min Length', exact_text: item.dst_number_min_length.to_s)
              expect(page).to have_table_cell(column: 'Dst Rewrite Result', exact_text: item.dst_rewrite_result)
              expect(page).to have_table_cell(column: 'Dst Rewrite Rule', exact_text: item.dst_rewrite_rule)
              expect(page).to have_table_cell(column: 'Force Hit Rate', exact_text: 'EMPTY')
              expect(page).to have_table_cell(column: 'Lcr Rate Multiplier', exact_text: item.lcr_rate_multiplier.to_s)
              expect(page).to have_table_cell(column: 'Initial Interval', exact_text: item.initial_interval.to_s)
              expect(page).to have_table_cell(column: 'Next Interval', exact_text: item.next_interval.to_s)
              expect(page).to have_table_cell(column: 'Reverse Billing', exact_text: item.reverse_billing ? 'YES' : 'NO')
              expect(page).to have_table_cell(column: 'Short Calls Limit', exact_text: item.short_calls_limit.to_s)
              expect(page).to have_table_cell(column: 'Src Name Rewrite Result', exact_text: item.src_name_rewrite_result)
              expect(page).to have_table_cell(column: 'Src Name Rewrite Rule', exact_text: item.src_name_rewrite_rule)
              expect(page).to have_table_cell(column: 'Src Rewrite Result', exact_text: item.src_rewrite_result)
              expect(page).to have_table_cell(column: 'Src Rewrite Rule', exact_text: item.src_rewrite_rule)
              expect(page).to have_table_cell(column: 'Valid From', exact_text: item.valid_from.to_s(:db))
              expect(page).to have_table_cell(column: 'Valid Till', exact_text: item.valid_till.to_s(:db))
            end
          end
        end
      end
    end

    context 'change scope' do
      let(:index_params) { { scope: 'change' } }

      it 'should render correct record' do
        subject

        within_main_content do
          expect(page).to have_table_row(count: to_change.size)
          to_change.each do |item|
            within_table_row(id: item.id) do
              expect(page).to have_table_cell(column: 'ID', exact_text: item.id.to_s)
              expect(page).to have_table_cell(column: 'Type', exact_text: 'CHANGE')
              expect(page).to have_table_cell(column: 'Dialpeer', exact_text: item.detected_dialpeer_ids.first.to_s)
              expect(page).to have_table_cell(column: 'Prefix', exact_text: item.prefix)
              expect(page).to have_table_cell(column: 'Connect Fee', exact_text: item.connect_fee.to_s)
              expect(page).to have_table_cell(column: 'Routing Tags', exact_text: item.routing_tags.map(&:name).map(&:upcase).join(' | '))
              expect(page).to have_table_cell(column: 'Initial Rate', exact_text: item.initial_rate.to_s)
              expect(page).to have_table_cell(column: 'Next Rate', exact_text: item.next_rate.to_s)
              expect(page).to have_table_cell(column: 'Vendor', exact_text: item.vendor.display_name)
              expect(page).to have_table_cell(column: 'Account', exact_text: item.account.display_name)
              expect(page).to have_table_cell(column: 'Enabled', exact_text: item.enabled ? 'YES' : 'NO')
              expect(page).to have_table_cell(column: 'Priority', exact_text: item.priority.nil? ? 'EMPTY' : item.priority.to_s)
              expect(page).to have_table_cell(column: 'Routeset Discriminator', exact_text: item.routeset_discriminator.display_name)
              expect(page).to have_table_cell(column: 'Gateway', exact_text: item.gateway.display_name)
              expect(page).to have_table_cell(column: 'Gateway Group', exact_text: 'EMPTY')
              expect(page).to have_table_cell(column: 'Routing Group', exact_text: item.routing_group.display_name)
              expect(page).to have_table_cell(column: 'Exclusive Route', exact_text: item.exclusive_route ? 'YES' : 'NO')
              expect(page).to have_table_cell(column: 'Acd Limit', exact_text: item.acd_limit.to_s)
              expect(page).to have_table_cell(column: 'Asr Limit', exact_text: item.asr_limit.to_s)
              expect(page).to have_table_cell(column: 'Capacity', exact_text: 'EMPTY')
              expect(page).to have_table_cell(column: 'Dst Number Max Length', exact_text: item.dst_number_max_length.to_s)
              expect(page).to have_table_cell(column: 'Dst Number Min Length', exact_text: item.dst_number_min_length.to_s)
              expect(page).to have_table_cell(column: 'Dst Rewrite Result', exact_text: item.dst_rewrite_result)
              expect(page).to have_table_cell(column: 'Dst Rewrite Rule', exact_text: item.dst_rewrite_rule)
              expect(page).to have_table_cell(column: 'Force Hit Rate', exact_text: 'EMPTY')
              expect(page).to have_table_cell(column: 'Lcr Rate Multiplier', exact_text: item.lcr_rate_multiplier.to_s)
              expect(page).to have_table_cell(column: 'Initial Interval', exact_text: item.initial_interval.to_s)
              expect(page).to have_table_cell(column: 'Next Interval', exact_text: item.next_interval.to_s)
              expect(page).to have_table_cell(column: 'Reverse Billing', exact_text: item.reverse_billing ? 'YES' : 'NO')
              expect(page).to have_table_cell(column: 'Short Calls Limit', exact_text: item.short_calls_limit.to_s)
              expect(page).to have_table_cell(column: 'Src Name Rewrite Result', exact_text: item.src_name_rewrite_result)
              expect(page).to have_table_cell(column: 'Src Name Rewrite Rule', exact_text: item.src_name_rewrite_rule)
              expect(page).to have_table_cell(column: 'Src Rewrite Result', exact_text: item.src_rewrite_result)
              expect(page).to have_table_cell(column: 'Src Rewrite Rule', exact_text: item.src_rewrite_rule)
              expect(page).to have_table_cell(column: 'Valid From', exact_text: item.valid_from.to_s(:db))
              expect(page).to have_table_cell(column: 'Valid Till', exact_text: item.valid_till.to_s(:db))
            end
          end
        end
      end
    end

    context 'delete scope' do
      let(:index_params) { { scope: 'delete' } }

      it 'should render correct record' do
        subject

        within_main_content do
          expect(page).to have_table_row(count: to_delete.size)
          to_delete.each do |item|
            within_table_row(id: item.id) do
              expect(page).to have_table_cell(column: 'ID', exact_text: item.id.to_s)
              expect(page).to have_table_cell(column: 'Type', exact_text: 'DELETE')
              expect(page).to have_table_cell(column: 'Dialpeer', exact_text: item.detected_dialpeer_ids.first.to_s)
              expect(page).to have_table_cell(column: 'Prefix', exact_text: item.prefix)
              expect(page).to have_table_cell(column: 'Connect Fee', exact_text: item.connect_fee.to_s)
              expect(page).to have_table_cell(column: 'Routing Tags', exact_text: item.routing_tags.map(&:name).map(&:upcase).join(' | '))
              expect(page).to have_table_cell(column: 'Initial Rate', exact_text: item.initial_rate.to_s)
              expect(page).to have_table_cell(column: 'Next Rate', exact_text: item.next_rate.to_s)
              expect(page).to have_table_cell(column: 'Vendor', exact_text: item.vendor.display_name)
              expect(page).to have_table_cell(column: 'Account', exact_text: item.account.display_name)
              expect(page).to have_table_cell(column: 'Enabled', exact_text: item.enabled ? 'YES' : 'NO')
              expect(page).to have_table_cell(column: 'Priority', exact_text: item.priority.nil? ? 'EMPTY' : item.priority.to_s)
              expect(page).to have_table_cell(column: 'Routeset Discriminator', exact_text: item.routeset_discriminator.display_name)
              expect(page).to have_table_cell(column: 'Gateway', exact_text: item.gateway.display_name)
              expect(page).to have_table_cell(column: 'Gateway Group', exact_text: 'EMPTY')
              expect(page).to have_table_cell(column: 'Routing Group', exact_text: item.routing_group.display_name)
              expect(page).to have_table_cell(column: 'Exclusive Route', exact_text: item.exclusive_route ? 'YES' : 'NO')
              expect(page).to have_table_cell(column: 'Acd Limit', exact_text: item.acd_limit.to_s)
              expect(page).to have_table_cell(column: 'Asr Limit', exact_text: item.asr_limit.to_s)
              expect(page).to have_table_cell(column: 'Capacity', exact_text: 'EMPTY')
              expect(page).to have_table_cell(column: 'Dst Number Max Length', exact_text: item.dst_number_max_length.to_s)
              expect(page).to have_table_cell(column: 'Dst Number Min Length', exact_text: item.dst_number_min_length.to_s)
              expect(page).to have_table_cell(column: 'Dst Rewrite Result', exact_text: item.dst_rewrite_result)
              expect(page).to have_table_cell(column: 'Dst Rewrite Rule', exact_text: item.dst_rewrite_rule)
              expect(page).to have_table_cell(column: 'Force Hit Rate', exact_text: 'EMPTY')
              expect(page).to have_table_cell(column: 'Lcr Rate Multiplier', exact_text: item.lcr_rate_multiplier.to_s)
              expect(page).to have_table_cell(column: 'Initial Interval', exact_text: item.initial_interval.to_s)
              expect(page).to have_table_cell(column: 'Next Interval', exact_text: item.next_interval.to_s)
              expect(page).to have_table_cell(column: 'Reverse Billing', exact_text: item.reverse_billing ? 'YES' : 'NO')
              expect(page).to have_table_cell(column: 'Short Calls Limit', exact_text: item.short_calls_limit.to_s)
              expect(page).to have_table_cell(column: 'Src Name Rewrite Result', exact_text: item.src_name_rewrite_result)
              expect(page).to have_table_cell(column: 'Src Name Rewrite Rule', exact_text: item.src_name_rewrite_rule)
              expect(page).to have_table_cell(column: 'Src Rewrite Result', exact_text: item.src_rewrite_result)
              expect(page).to have_table_cell(column: 'Src Rewrite Rule', exact_text: item.src_rewrite_rule)
              expect(page).to have_table_cell(column: 'Valid From', exact_text: item.valid_from.to_s(:db))
              expect(page).to have_table_cell(column: 'Valid Till', exact_text: item.valid_till.to_s(:db))
            end
          end
        end
      end
    end

    context('when pricelist item include deleted rotuing tag id') do
      let(:pricelist_items) do
        [FactoryBot.create(:rate_management_pricelist_item,
                           :filed_from_project,
                           pricelist: pricelist,
                           routing_tag_ids: project.routing_tag_ids + [523])]
      end

      it 'should render correct' do
        subject

        within_main_content do
          expect(page).to have_table_row(count: pricelist_items.size)
          pricelist_items.each do |item|
            within_table_row(id: item.id) do
              expect(page).to have_table_cell(column: 'ID', exact_text: item.id.to_s)
              routing_tags = project.routing_tags.map(&:name).join(' | ').upcase
              expect(page).to have_table_cell(column: 'Routing Tags', exact_text: "#{routing_tags} | 523")
            end
          end
        end
      end
    end
  end
end
