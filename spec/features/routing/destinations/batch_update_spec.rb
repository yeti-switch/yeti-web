# frozen_string_literal: true

RSpec.describe BatchUpdateForm::Destination, js: true do
  include_context :login_as_admin
  let!(:_destinations) { FactoryBot.create_list :destination, 3 }
  let(:success_message) { I18n.t 'flash.actions.batch_actions.batch_update.job_scheduled' }
  let!(:rate_group) { Routing::RateGroup.take || FactoryBot.create(:rate_group) }
  let!(:routing_tag_mode) { Routing::RoutingTagMode.take! }
  let!(:rate_policy) { Routing::DestinationRatePolicy.take! }
  let!(:profit_control_mode) { Routing::RateProfitControlMode.take! || FactoryBot.create(:rate_profit_control_mode) }

  before do
    visit destinations_path
    click_button 'Update batch'
    expect(page).to have_selector('.ui-dialog')
  end

  subject do
    fill_batch_form
    click_button 'OK'
  end

  let(:assign_params) do
    {
      enabled: true,
      prefix: '_test',
      dst_number_min_length: '0',
      dst_number_max_length: '15',
      routing_tag_mode_id: routing_tag_mode.id.to_s,
      reject_calls: false,
      quality_alarm: true,
      rate_group_id: rate_group.id.to_s,
      valid_from: '2020-01-10',
      valid_till: '2020-01-20',
      rate_policy_id: rate_policy.id.to_s,
      initial_interval: '1',
      initial_rate: '1',
      next_interval: '2',
      next_rate: '3',
      use_dp_intervals: false,
      connect_fee: '1',
      profit_control_mode_id: profit_control_mode.id.to_s,
      dp_margin_fixed: '1',
      dp_margin_percent: '2',
      asr_limit: '0.9',
      acd_limit: '1',
      short_calls_limit: '4'
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

    if assign_params.key? :reject_calls
      check :Reject_calls
      select_by_value assign_params[:reject_calls], from: :reject_calls
    end

    if assign_params.key? :quality_alarm
      check :Quality_alarm
      select_by_value assign_params[:quality_alarm], from: :quality_alarm
    end

    if assign_params.key? :rate_group_id
      check :Rate_group_id
      select_by_value assign_params[:rate_group_id], from: :rate_group_id
    end

    if assign_params.key? :valid_from
      check :Valid_from
      fill_in :valid_from, with: assign_params[:valid_from]
    end

    if assign_params.key? :valid_till
      check :Valid_till
      fill_in :valid_till, with: assign_params[:valid_till]
    end

    if assign_params.key? :rate_policy_id
      check :Rate_policy_id
      select_by_value assign_params[:rate_policy_id], from: :rate_policy_id
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

    if assign_params.key? :use_dp_intervals
      check :Use_dp_intervals
      select_by_value assign_params[:use_dp_intervals], from: :use_dp_intervals
    end

    if assign_params.key? :connect_fee
      check :Connect_fee
      fill_in :connect_fee, with: assign_params[:connect_fee]
    end

    if assign_params.key? :profit_control_mode_id
      check :Profit_control_mode_id
      select_by_value assign_params[:profit_control_mode_id], from: :profit_control_mode_id
    end

    if assign_params.key? :dp_margin_fixed
      check :Dp_margin_fixed
      fill_in :dp_margin_fixed, with: assign_params[:dp_margin_fixed]
    end

    if assign_params.key? :dp_margin_percent
      check :Dp_margin_percent
      fill_in :dp_margin_percent, with: assign_params[:dp_margin_percent]
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
  end

  context 'should check validates' do
    context 'when change :dp_margin_percent' do
      let(:assign_params) { { dp_margin_percent: '0' } }

      it 'should have error: must be greater than zero' do
        subject
        expect(page).to have_selector '.flash', text: 'Dp margin percent must be greater than 0'
      end
    end

    context 'when all fields filled with valid values' do
      it 'should have success message' do
        expect do
          subject
          expect(page).to have_selector '.flash', text: success_message
        end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Routing::Destination', be_present, assign_params, be_present
      end
    end
  end
end
