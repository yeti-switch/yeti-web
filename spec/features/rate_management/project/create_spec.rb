# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Rate Management Project Create', js: true, bullet: [:n] do
  include_context :login_as_admin

  subject do
    visit new_rate_management_project_path
    fill_form!
    click_on 'Create Project'
  end

  context 'with filled form' do
    let!(:vendor) { FactoryBot.create(:vendor) }
    let!(:account) { FactoryBot.create(:account, contractor: vendor) }
    let!(:routing_group) { FactoryBot.create(:routing_group) }
    let!(:routeset_discriminator) { FactoryBot.create(:routeset_discriminator) }
    let!(:gateway) { FactoryBot.create(:gateway, contractor: vendor) }

    let(:fill_form!) do
      fill_in 'Name', with: new_attrs[:name]
      fill_in_tom_select 'Vendor', with: new_attrs[:vendor].name, search: true
      fill_in_tom_select 'Account', with: new_attrs[:account].name
      fill_in_tom_select 'Routing group', with: new_attrs[:routing_group].name
      fill_in_tom_select 'Routeset discriminator', with: new_attrs[:routeset_discriminator].name
      fill_in_tom_select 'Gateway', with: new_attrs[:gateway].name
    end

    let(:new_attrs) do
      {
        account: account,
        routeset_discriminator: routeset_discriminator,
        routing_group: routing_group,
        vendor: vendor,
        routing_tags: [],
        name: 'test',
        gateway: gateway
      }
    end

    it 'should be successfully create project' do
      expect do
        subject
        expect(page).to have_flash_message('Project was successfully created.', type: :notice)
      end.to change { RateManagement::Project.count }.by(1)

      project = RateManagement::Project.last
      expect(project).to have_attributes(
                           account: new_attrs[:account],
                           routeset_discriminator: new_attrs[:routeset_discriminator],
                           routing_group: new_attrs[:routing_group],
                           vendor: new_attrs[:vendor],
                           routing_tag_ids: [],
                           name: new_attrs[:name],
                           gateway: new_attrs[:gateway],
                           enabled: true,
                           priority: 100
                         )
    end

    context 'when filled all field' do
      let(:fill_form!) do
        fill_in 'Name', with: new_attrs[:name]
        fill_in_tom_select 'Vendor', with: new_attrs[:vendor].name, search: true
        fill_in_tom_select 'Account', with: new_attrs[:account].name
        fill_in_tom_select 'Routing group', with: new_attrs[:routing_group].name
        fill_in_tom_select 'Gateway', with: new_attrs[:gateway].name
        fill_in_tom_select 'Routeset discriminator', with: new_attrs[:routeset_discriminator].name
        fill_in_tom_select 'Routing Tags', with: new_attrs[:routing_tags].first.name, multiple: true
        fill_in_tom_select 'Routing Tags', with: new_attrs[:routing_tags].second.name, multiple: true
        fill_in_tom_select 'Routing tag mode', with: Routing::RoutingTagMode::MODES[new_attrs[:routing_tag_mode_id]]
        fill_in 'Capacity', with: new_attrs[:capacity]
        fill_in 'Force hit rate', with: new_attrs[:force_hit_rate]
        fill_in 'Acd limit', with: new_attrs[:acd_limit]
        fill_in 'Asr limit', with: new_attrs[:asr_limit]
        fill_in 'Dst number max length', with: new_attrs[:dst_number_max_length]
        fill_in 'Dst number min length', with: new_attrs[:dst_number_min_length]
        fill_in 'Dst rewrite result', with: new_attrs[:dst_rewrite_result]
        fill_in 'Dst rewrite rule', with: new_attrs[:dst_rewrite_rule]
        fill_in 'Initial interval', with: new_attrs[:initial_interval]
        fill_in 'Keep applied pricelists days', with: new_attrs[:keep_applied_pricelists_days]
        fill_in 'Lcr rate multiplier', with: new_attrs[:lcr_rate_multiplier]
        fill_in 'Next interval', with: new_attrs[:next_interval]
        fill_in 'Priority', with: new_attrs[:priority]
        fill_in 'Short calls limit', with: new_attrs[:short_calls_limit]
        fill_in 'Src name rewrite result', with: new_attrs[:src_name_rewrite_result]
        fill_in 'Src name rewrite rule', with: new_attrs[:src_name_rewrite_rule]
        fill_in 'Src rewrite result', with: new_attrs[:src_rewrite_result]
        fill_in 'Src rewrite rule', with: new_attrs[:src_rewrite_rule]
        fill_in_tom_select 'Enabled', with: new_attrs[:enabled] ? 'Yes' : 'No'
        fill_in_tom_select 'Exclusive route', with: new_attrs[:exclusive_route] ? 'Yes' : 'No'
        fill_in_tom_select 'Reverse billing', with: new_attrs[:reverse_billing] ? 'Yes' : 'No'
      end

      let!(:gateway_group) { FactoryBot.create(:gateway_group, vendor: vendor) }
      let!(:routing_tags) { FactoryBot.create_list(:routing_tag, 3) }
      let(:routing_tag_mode_id) { Routing::RoutingTagMode::MODES.keys.sample }

      let(:new_attrs) do
        {
          account: account,
          acd_limit: 0.05,
          asr_limit: 0.05,
          capacity: 2,
          dst_number_max_length: 98,
          dst_number_min_length: 2,
          dst_rewrite_result: 'rspec1',
          dst_rewrite_rule: 'rspec2',
          enabled: false,
          exclusive_route: true,
          force_hit_rate: 0.05,
          gateway: gateway,
          gateway_group: nil,
          initial_interval: 2,
          keep_applied_pricelists_days: 31,
          lcr_rate_multiplier: 1.5,
          name: 'test',
          next_interval: 2,
          priority: 50,
          reverse_billing: true,
          routeset_discriminator: routeset_discriminator,
          routing_group: routing_group,
          routing_tag_mode_id: routing_tag_mode_id,
          routing_tags: [routing_tags.first, routing_tags.second],
          short_calls_limit: 0.5,
          src_name_rewrite_result: 'rspec3',
          src_name_rewrite_rule: 'rspec4',
          src_rewrite_result: 'rspec5',
          src_rewrite_rule: 'rspec6',
          vendor: vendor
        }
      end

      it 'should be successfully create project' do
        expect do
          subject
          expect(page).to have_flash_message('Project was successfully created.', type: :notice)
        end.to change { RateManagement::Project.count }.by(1)

        project = RateManagement::Project.last
        expect(project).to have_attributes(
                             account: new_attrs[:account],
                             acd_limit: new_attrs[:acd_limit],
                             asr_limit: new_attrs[:asr_limit],
                             capacity: new_attrs[:capacity],
                             dst_number_max_length: new_attrs[:dst_number_max_length],
                             dst_number_min_length: new_attrs[:dst_number_min_length],
                             dst_rewrite_result: new_attrs[:dst_rewrite_result],
                             dst_rewrite_rule: new_attrs[:dst_rewrite_rule],
                             enabled: new_attrs[:enabled],
                             exclusive_route: new_attrs[:exclusive_route],
                             force_hit_rate: new_attrs[:force_hit_rate],
                             gateway: new_attrs[:gateway],
                             gateway_group: new_attrs[:gateway_group],
                             initial_interval: new_attrs[:initial_interval],
                             keep_applied_pricelists_days: new_attrs[:keep_applied_pricelists_days],
                             lcr_rate_multiplier: new_attrs[:lcr_rate_multiplier],
                             name: new_attrs[:name],
                             next_interval: new_attrs[:next_interval],
                             priority: new_attrs[:priority],
                             reverse_billing: new_attrs[:reverse_billing],
                             routeset_discriminator: new_attrs[:routeset_discriminator],
                             routing_group: new_attrs[:routing_group],
                             routing_tag_mode_id: new_attrs[:routing_tag_mode_id],
                             routing_tag_ids: [routing_tags.first.id, routing_tags.second.id],
                             short_calls_limit: new_attrs[:short_calls_limit],
                             src_name_rewrite_result: new_attrs[:src_name_rewrite_result],
                             src_name_rewrite_rule: new_attrs[:src_name_rewrite_rule],
                             src_rewrite_result: new_attrs[:src_rewrite_result],
                             src_rewrite_rule: new_attrs[:src_rewrite_rule],
                             vendor: new_attrs[:vendor]
                           )
      end
    end

    context 'when routing tags are not sorted' do
      let!(:routing_tags) { FactoryBot.create_list(:routing_tag, 3) }
      let(:fill_form!) do
        fill_in 'Name', with: new_attrs[:name]
        fill_in_tom_select 'Vendor', with: new_attrs[:vendor].name, search: true
        fill_in_tom_select 'Account', with: new_attrs[:account].name
        fill_in_tom_select 'Routing group', with: new_attrs[:routing_group].name
        fill_in_tom_select 'Routeset discriminator', with: new_attrs[:routeset_discriminator].name
        fill_in_tom_select 'Gateway', with: new_attrs[:gateway].name
        fill_in_tom_select 'Routing Tags', with: routing_tags.third.name, multiple: true
        fill_in_tom_select 'Routing Tags', with: Routing::RoutingTag::ANY_TAG, multiple: true
        fill_in_tom_select 'Routing Tags', with: routing_tags.first.name, multiple: true
      end

      let(:new_attrs) do
        {
          account: account,
          routeset_discriminator: routeset_discriminator,
          routing_group: routing_group,
          vendor: vendor,
          name: 'test',
          gateway: gateway
        }
      end

      it 'creates project' do
        expect do
          subject
          expect(page).to have_flash_message('Project was successfully created.', type: :notice)
        end.to change { RateManagement::Project.count }.by(1)

        project = RateManagement::Project.last
        expect(project).to have_attributes(
                             account: new_attrs[:account],
                             routeset_discriminator: new_attrs[:routeset_discriminator],
                             routing_group: new_attrs[:routing_group],
                             vendor: new_attrs[:vendor],
                             routing_tag_ids: [routing_tags.first.id, routing_tags.third.id, nil],
                             name: new_attrs[:name]
                           )
      end
    end

    context 'when project with same scope attributes exists' do
      before do
        FactoryBot.create(
          :rate_management_project,
          :filled,
          vendor: vendor,
          account: account,
          routeset_discriminator: routeset_discriminator,
          routing_group: routing_group
        )
      end

      it 'does not create project' do
        expect do
          subject
          expect(page).to have_semantic_error_texts(
                            'Project with same scope attributes already exists'
                          )
        end.not_to change { RateManagement::Project.count }
      end
    end

    context 'when projects with partly same scope attributes exists' do
      before do
        account2 = FactoryBot.create(:account, contractor: vendor)
        FactoryBot.create(
          :rate_management_project,
          :filled,
          vendor: vendor,
          account: account2,
          routeset_discriminator: routeset_discriminator,
          routing_group: routing_group
        )

        another_vendor = FactoryBot.create(:vendor)
        another_account = FactoryBot.create(:account, contractor: another_vendor)
        FactoryBot.create(
          :rate_management_project,
          :filled,
          vendor: another_vendor,
          account: another_account,
          routeset_discriminator: routeset_discriminator,
          routing_group: routing_group
        )

        another_routeset_discriminator = FactoryBot.create(:routeset_discriminator)
        FactoryBot.create(
          :rate_management_project,
          :filled,
          vendor: vendor,
          account: account,
          routeset_discriminator: another_routeset_discriminator,
          routing_group: routing_group
        )

        another_routing_group = FactoryBot.create(:routing_group)
        FactoryBot.create(
          :rate_management_project,
          :filled,
          vendor: vendor,
          account: account,
          routeset_discriminator: routeset_discriminator,
          routing_group: another_routing_group
        )
      end

      it 'should be successfully create project' do
        expect do
          subject
          expect(page).to have_flash_message('Project was successfully created.', type: :notice)
        end.to change { RateManagement::Project.count }.by(1)

        project = RateManagement::Project.last
        expect(project).to have_attributes(
                             account: new_attrs[:account],
                             routeset_discriminator: new_attrs[:routeset_discriminator],
                             routing_group: new_attrs[:routing_group],
                             vendor: new_attrs[:vendor],
                             routing_tag_ids: [],
                             name: new_attrs[:name],
                             gateway: new_attrs[:gateway],
                             enabled: true,
                             priority: 100
                           )
      end
    end
  end

  context 'with only default fields filled' do
    let(:fill_form!) { nil }

    it 'does not create project' do
      expect do
        subject
        expect(page).to have_semantic_error_texts(
                          'Account must exist',
                          'Vendor must exist',
                          "Name can't be blank",
                          'specify a gateway_group or a gateway'
                        )
      end.not_to change { RateManagement::Project.count }
    end
  end

  context 'with all fields empty' do
    let(:fill_form!) do
      fill_in 'Keep applied pricelists days', with: ''
      fill_in 'Acd limit', with: ''
      fill_in 'Asr limit', with: ''
      fill_in 'Short calls limit', with: ''
      fill_in 'Dst number min length', with: ''
      fill_in 'Dst number max length', with: ''
      fill_in 'Initial interval', with: ''
      fill_in 'Next interval', with: ''
      fill_in 'Priority', with: ''
      fill_in 'Lcr rate multiplier', with: ''
    end

    it 'does not create project' do
      expect do
        subject
        expect(page).to have_semantic_error_texts(
                          'Account must exist',
                          'Vendor must exist',
                          "Dst number max length can't be blank",
                          "Dst number min length can't be blank",
                          "Short calls limit can't be blank",
                          "Keep applied pricelists days can't be blank",
                          "Priority can't be blank",
                          "Name can't be blank",
                          'specify a gateway_group or a gateway'
                        )
      end.not_to change { RateManagement::Project.count }
    end
  end
end
