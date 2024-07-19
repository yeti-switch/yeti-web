# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Rate Management Project Show', js: true, bullet: [:n] do
  include_context :login_as_admin

  subject { visit rate_management_project_path(record) }

  let(:record) { FactoryBot.create(:rate_management_project, :filled, **record_attrs) }
  let(:record_attrs) do
    {
      capacity: 2,
      enabled: false,
      exclusive_route: false,
      reverse_billing: true,
      force_hit_rate: 0.05
    }
  end

  it 'should correct render show page' do
    subject

    within_panel 'Project details' do
      expect(page).to have_attribute_row('ID', exact_text: record.id.to_s)
      expect(page).to have_attribute_row('Name', exact_text: record.name)
      expect(page).to have_attribute_row('Keep Applied Pricelists Days', exact_text: record.keep_applied_pricelists_days.to_s)
      expect(page).to have_attribute_row('Created At', exact_text: record.created_at.strftime('%F %T'))
      expect(page).to have_attribute_row('Updated At', exact_text: record.updated_at.strftime('%F %T'))
    end

    within_panel 'Scope attributes' do
      expect(page).to have_attribute_row('Routing Group', exact_text: record.routing_group.display_name)
      expect(page).to have_attribute_row('Vendor', exact_text: record.vendor.display_name)
      expect(page).to have_attribute_row('Account', exact_text: record.account.display_name)
      expect(page).to have_attribute_row('Routeset Discriminator', exact_text: record.routeset_discriminator.display_name)
    end

    within_panel 'Constant attributes' do
      expect(page).to have_attribute_row('Acd Limit', exact_text: record.acd_limit.to_s)
      expect(page).to have_attribute_row('Asr Limit', exact_text: record.asr_limit.to_s)
      expect(page).to have_attribute_row('Capacity', exact_text: record.capacity.to_s)
      expect(page).to have_attribute_row('Dst Number Max Length', exact_text: record.dst_number_max_length.to_s)
      expect(page).to have_attribute_row('Dst Number Min Length', exact_text: record.dst_number_min_length.to_s)
      expect(page).to have_attribute_row('Dst Rewrite Result', exact_text: record.dst_rewrite_result)
      expect(page).to have_attribute_row('Dst Rewrite Rule', exact_text: record.dst_rewrite_rule)
      expect(page).to have_attribute_row('Enabled', exact_text: 'NO')
      expect(page).to have_attribute_row('Exclusive Route', exact_text: 'NO')
      expect(page).to have_attribute_row('Force Hit Rate', exact_text: record.force_hit_rate.to_s)
      expect(page).to have_attribute_row('Initial Interval', exact_text: record.initial_interval.to_s)
      expect(page).to have_attribute_row('Lcr Rate Multiplier', exact_text: record.lcr_rate_multiplier.to_s)
      expect(page).to have_attribute_row('Next Interval', exact_text: record.next_interval.to_s)
      expect(page).to have_attribute_row('Priority', exact_text: record.priority.to_s)
      expect(page).to have_attribute_row('Reverse Billing', exact_text: 'YES')
      expect(page).to have_attribute_row('Routing Tags', exact_text: 'NOT TAGGED')
      expect(page).to have_attribute_row('Short Calls Limit', exact_text: record.short_calls_limit.to_s)
      expect(page).to have_attribute_row('Src Name Rewrite Result', exact_text: record.src_name_rewrite_result)
      expect(page).to have_attribute_row('Src Name Rewrite Rule', exact_text: record.src_name_rewrite_rule)
      expect(page).to have_attribute_row('Src Rewrite Result', exact_text: record.src_rewrite_result)
      expect(page).to have_attribute_row('Src Rewrite Rule', exact_text: record.src_rewrite_rule)
      expect(page).to have_attribute_row('Gateway Group', exact_text: 'EMPTY')
      expect(page).to have_attribute_row('Gateway', exact_text: record.gateway.display_name)
      expect(page).to have_attribute_row('Routing Tag Mode', exact_text: record.routing_tag_mode.name)
    end
  end

  context 'when project has many routing tags and mode OR' do
    let(:record_attrs) do
      super().merge routing_tag_ids: routing_tags.map(&:id),
                    routing_tag_mode_id: Routing::RoutingTagMode::CONST::OR
    end
    let!(:routing_tags) do
      FactoryBot.create_list(:routing_tag, 20)
    end

    before do
      FactoryBot.create(:routing_tag)
    end

    it 'shows all routing tags', js: false do
      subject

      expect(find(attributes_row_selector('Routing Tags')).text.split(' | ')).to match_array record.routing_tags.pluck(:name)
      expect(page).to have_attribute_row('Routing Tag Mode', exact_text: 'OR')
    end
  end

  context 'when project has many routing tags and mode AND' do
    let(:record_attrs) do
      super().merge routing_tag_ids: routing_tags.map(&:id),
                    routing_tag_mode_id: Routing::RoutingTagMode::CONST::AND
    end
    let!(:routing_tags) do
      FactoryBot.create_list(:routing_tag, 20)
    end

    before do
      FactoryBot.create(:routing_tag)
    end

    it 'shows all routing tags' do
      subject
      routing_tag_names = record.routing_tags.map { |r| r.name.upcase }
      expect(page).to have_attribute_row 'Routing Tags', exact_text: routing_tag_names.join(' & ')
      expect(page).to have_attribute_row('Routing Tag Mode', exact_text: 'AND')
    end
  end
end
