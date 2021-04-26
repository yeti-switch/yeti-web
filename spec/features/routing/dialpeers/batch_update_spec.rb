# frozen_string_literal: true

RSpec.describe BatchUpdateForm::Dialpeer, :js do
  include_context :login_as_admin
  let!(:_dialpeers) { FactoryBot.create_list :dialpeer, 3 }
  let!(:gateway_shared) { FactoryBot.create :gateway, is_shared: true }
  let!(:gateway) { FactoryBot.create :gateway }
  let!(:vendor_main) { FactoryBot.create :vendor }
  let!(:account_vendors) { FactoryBot.create :account, contractor: vendor_main }
  let(:success_message) { I18n.t 'flash.actions.batch_actions.batch_update.job_scheduled' }
  let!(:gateway_allow_t_f) { FactoryBot.create :gateway, allow_termination: false }
  let!(:gateway_group) { FactoryBot.create :gateway_group }
  let!(:gateway_vendors) { FactoryBot.create :gateway, contractor: vendor_main }
  let!(:gateway_group_vendors) { FactoryBot.create :gateway_group, vendor: vendor_main }
  let!(:vendor) { FactoryBot.create :vendor }
  let!(:account) { FactoryBot.create :account }
  let!(:routing_tag_mode) { Routing::RoutingTagMode.last! }
  let!(:routing_tag_mode) { Routing::RoutingTagMode.last! }
  let!(:routeset_discriminator) { Routing::RoutesetDiscriminator.last! }
  let(:pg_max_smallint) { Yeti::ActiveRecord::PG_MAX_SMALLINT }
  let!(:routing_tags) { create_list(:routing_tag, 5) }

  before do
    visit dialpeers_path
    click_button 'Update batch'
    expect(page).to have_selector('.ui-dialog')
  end

  let(:assign_params) do
    {
      enabled: true,
      prefix: 'string',
      dst_number_min_length: '10',
      dst_number_max_length: '20',
      routing_tag_mode_id: routing_tag_mode.id.to_s,
      routing_group_id: routing_tag_mode.id.to_s,
      priority: '3',
      force_hit_rate: '0.5',
      exclusive_route: true,
      initial_interval: '12',
      initial_rate: '12',
      next_interval: '12',
      next_rate: '12',
      connect_fee: '12',
      lcr_rate_multiplier: '12',
      gateway_id: gateway_vendors.id.to_s,
      gateway_group_id: gateway_group_vendors.id.to_s,
      vendor_id: vendor_main.id.to_s,
      account_id: account_vendors.id.to_s,
      routeset_discriminator_id: routeset_discriminator.id.to_s,
      valid_from: '2020-01-10',
      valid_till: '2020-01-20',
      asr_limit: '0.9',
      acd_limit: '0.9',
      short_calls_limit: '0.9',
      capacity: '12',
      src_name_rewrite_rule: '12',
      src_name_rewrite_result: '12',
      src_rewrite_rule: '12',
      src_rewrite_result: '12',
      dst_rewrite_rule: '12',
      dst_rewrite_result: '12',
      routing_tag_ids: routing_tags.map { |tag| tag.id.to_s }
    }
  end
  let(:fill_batch_form) do
    if assign_params.key? :enabled
      check :Enabled
      select_by_value assign_params[:enabled], from: :enabled
    end

    if assign_params.key? :prefix
      check :Prefix
      fill_in :prefix, with: assign_params[:prefix]
    end

    if assign_params.key? :dst_number_min_length
      check :Dst_number_min_length
      fill_in :dst_number_min_length, with: assign_params[:dst_number_min_length]
    end

    if assign_params.key? :dst_number_max_length
      check :Dst_number_max_length
      fill_in :dst_number_max_length, with: assign_params[:dst_number_max_length]
    end

    if assign_params.key? :routing_tag_mode_id
      check :Routing_tag_mode_id
      select_by_value assign_params[:routing_tag_mode_id], from: :routing_tag_mode_id
    end

    if assign_params.key? :routing_group_id
      check :Routing_group_id
      select_by_value assign_params[:routing_group_id], from: :routing_group_id
    end

    if assign_params.key? :priority
      check :Priority
      fill_in :priority, with: assign_params[:priority]
    end

    if assign_params.key? :force_hit_rate
      check :Force_hit_rate
      fill_in :force_hit_rate, with: assign_params[:force_hit_rate]
    end

    if assign_params.key? :exclusive_route
      check :Exclusive_route
      select_by_value assign_params[:exclusive_route], from: :exclusive_route
    end

    if assign_params.key? :initial_interval
      check :Initial_interval
      fill_in :initial_interval, with: assign_params[:initial_interval]
    end

    if assign_params.key? :initial_rate
      check :Initial_rate
      fill_in :initial_rate, with: assign_params[:initial_rate]
    end

    if assign_params.key? :next_interval
      check :Next_interval
      fill_in :next_interval, with: assign_params[:next_interval]
    end

    if assign_params.key? :next_rate
      check :Next_rate
      fill_in :next_rate, with: assign_params[:next_rate]
    end

    if assign_params.key? :connect_fee
      check :Connect_fee
      fill_in :connect_fee, with: assign_params[:connect_fee]
    end

    if assign_params.key? :lcr_rate_multiplier
      check :Lcr_rate_multiplier
      fill_in :lcr_rate_multiplier, with: assign_params[:lcr_rate_multiplier]
    end

    if assign_params.key? :gateway_id
      check :Gateway_id
      select_by_value assign_params[:gateway_id], from: :gateway_id
    end

    if assign_params.key? :gateway_group_id
      check :Gateway_group_id
      select_by_value assign_params[:gateway_group_id], from: :gateway_group_id
    end

    if assign_params.key? :vendor_id
      check :Vendor_id
      select_by_value assign_params[:vendor_id], from: :vendor_id
    end

    if assign_params.key? :account_id
      check :Account_id
      select_by_value assign_params[:account_id], from: :account_id
    end

    if assign_params.key? :routeset_discriminator_id
      check :Routeset_discriminator_id
      select_by_value assign_params[:routeset_discriminator_id], from: :routeset_discriminator_id
    end

    if assign_params.key? :valid_from
      check :Valid_from
      fill_in :valid_from, with: assign_params[:valid_from]
    end

    if assign_params.key? :valid_till
      check :Valid_till
      fill_in :valid_till, with: assign_params[:valid_till]
    end

    if assign_params.key? :asr_limit
      check :Asr_limit
      fill_in :asr_limit, with: assign_params[:asr_limit]
    end

    if assign_params.key? :acd_limit
      check :Acd_limit
      fill_in :acd_limit, with: assign_params[:acd_limit]
    end

    if assign_params.key? :short_calls_limit
      check :Short_calls_limit
      fill_in :short_calls_limit, with: assign_params[:short_calls_limit]
    end

    if assign_params.key? :capacity
      check :Capacity
      fill_in :capacity, with: assign_params[:capacity]
    end

    if assign_params.key? :src_name_rewrite_rule
      check :Src_name_rewrite_rule
      fill_in :src_name_rewrite_rule, with: assign_params[:src_name_rewrite_rule]
    end

    if assign_params.key? :src_name_rewrite_result
      check :Src_name_rewrite_result
      fill_in :src_name_rewrite_result, with: assign_params[:src_name_rewrite_result]
    end

    if assign_params.key? :src_rewrite_rule
      check :Src_rewrite_rule
      fill_in :src_rewrite_rule, with: assign_params[:src_rewrite_rule]
    end

    if assign_params.key? :src_rewrite_result
      check :Src_rewrite_result
      fill_in :src_rewrite_result, with: assign_params[:src_rewrite_result]
    end

    if assign_params.key? :dst_rewrite_rule
      check :Dst_rewrite_rule
      fill_in :dst_rewrite_rule, with: assign_params[:dst_rewrite_rule]
    end

    if assign_params.key? :dst_rewrite_result
      check :Dst_rewrite_result
      fill_in :dst_rewrite_result, with: assign_params[:dst_rewrite_result]
    end

    if assign_params.key? :routing_tag_ids
      check :Routing_tag_ids
      routing_tags.each { |tag| fill_in_chosen 'routing_tag_ids[]', with: tag.name, multiple: true, visible: false }
    end
  end

  subject do
    fill_batch_form
    click_button 'OK'
  end

  context 'check validation' do
    context 'when :initial_rate is not a number' do
      let(:assign_params) { { initial_rate: 'string' } }

      it 'should have error: is not a number' do
        subject
        expect(page).to have_selector '.flash', text: 'Initial rate is not a number'
      end
    end

    context 'when all fields filled with valid values' do
      it 'should pass validation' do
        expect do
          subject
          expect(page).to have_selector '.flash', text: success_message
        end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Dialpeer', be_present, assign_params, be_present
      end
    end
  end
end
