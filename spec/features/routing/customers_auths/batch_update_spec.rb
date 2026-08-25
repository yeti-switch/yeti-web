# frozen_string_literal: true

RSpec.describe BatchUpdateForm::CustomersAuth, :js do
  include_context :login_as_admin
  let!(:_customers_auth) { FactoryBot.create_list :customers_auth, 3 }
  let(:success_message) { I18n.t 'flash.actions.batch_actions.batch_update.job_scheduled' }
  let!(:routing_plan) { FactoryBot.create :routing_plan }
  let!(:lua_script) { FactoryBot.create :lua_script }
  let!(:rateplan) { FactoryBot.create :rateplan }
  let!(:dump_level_id) { CustomersAuth::DUMP_LEVEL_CAPTURE_SIP }
  let!(:numberlist) { FactoryBot.create :numberlist }
  let!(:protocol) { Equipment::TransportProtocol.last! }

  before do
    visit customers_auths_path
    click_button 'Update batch'
    expect(page).to have_selector('.ui-dialog')
  end

  let(:assign_params) do
    {
      enabled: true,
      reject_calls: true,
      transport_protocol_id: protocol.id.to_s,
      src_number_min_length: '2',
      src_number_max_length: '20',
      dst_number_min_length: '5',
      dst_number_max_length: '50',
      dst_numberlist_id: numberlist.id.to_s,
      src_numberlist_id: numberlist.id.to_s,
      dump_level_id: dump_level_id.to_s,
      rateplan_id: rateplan.id.to_s,
      routing_plan_id: routing_plan.id.to_s,
      lua_script_id: lua_script.id.to_s,
      src_name_field_id: CustomersAuth::SRC_NAME_FIELD_FROM_USERPART.to_s,
      src_name_rewrite_rule: 'src-name-rule',
      src_name_rewrite_result: 'src-name-result',
      src_number_field_id: CustomersAuth::SRC_NUMBER_FIELD_RURI_USERPART.to_s,
      src_rewrite_rule: 'src-rule',
      src_rewrite_result: 'src-result',
      dst_number_field_id: CustomersAuth::DST_NUMBER_FIELD_TO_USERPART.to_s,
      dst_rewrite_rule: 'dst-rule',
      dst_rewrite_result: 'dst-result',
      privacy_mode_id: CustomersAuth::PRIVACY_MODE_REJECT.to_s,
      diversion_policy_id: CustomersAuth::DIVERSION_POLICY_ACCEPT.to_s,
      diversion_rewrite_rule: 'diversion-rule',
      diversion_rewrite_result: 'diversion-result',
      pai_policy_id: CustomersAuth::PAI_POLICY_REQUIRE.to_s,
      pai_rewrite_rule: 'pai-rule',
      pai_rewrite_result: 'pai-result'
    }
  end

  let(:fill_batch_form) do
    if assign_params.key? :enabled
      check :Enabled
      select_by_value assign_params[:enabled], from: :enabled
    end

    if assign_params.key? :reject_calls
      check :Reject_calls
      select_by_value assign_params[:reject_calls], from: :reject_calls
    end

    if assign_params.key? :transport_protocol_id
      check :Transport_protocol_id
      select_by_value assign_params[:transport_protocol_id], from: :transport_protocol_id
    end

    if assign_params.key? :src_number_min_length
      check :Src_number_min_length
      fill_in :src_number_min_length, with: assign_params[:src_number_min_length]
    end

    if assign_params.key? :src_number_max_length
      check :Src_number_max_length
      fill_in :src_number_max_length, with: assign_params[:src_number_max_length]
    end

    if assign_params.key? :dst_number_min_length
      check :Dst_number_min_length
      fill_in :dst_number_min_length, with: assign_params[:dst_number_min_length]
    end

    if assign_params.key? :dst_number_max_length
      check :Dst_number_max_length
      fill_in :dst_number_max_length, with: assign_params[:dst_number_max_length]
    end

    if assign_params.key? :dst_numberlist_id
      check :Dst_numberlist_id
      select_by_value assign_params[:dst_numberlist_id], from: :dst_numberlist_id
    end

    if assign_params.key? :src_numberlist_id
      check :Src_numberlist_id
      select_by_value assign_params[:src_numberlist_id], from: :src_numberlist_id
    end

    if assign_params.key? :dump_level_id
      check :Dump_level_id
      select_by_value assign_params[:dump_level_id], from: :dump_level_id
    end

    if assign_params.key? :rateplan_id
      check :Rateplan_id
      select_by_value assign_params[:rateplan_id], from: :rateplan_id
    end

    if assign_params.key? :routing_plan_id
      check :Routing_plan_id
      select_by_value assign_params[:routing_plan_id], from: :routing_plan_id
    end

    if assign_params.key? :lua_script_id
      check :Lua_script_id
      select_by_value assign_params[:lua_script_id], from: :lua_script_id
    end

    %i[src_name_field_id src_number_field_id dst_number_field_id privacy_mode_id diversion_policy_id pai_policy_id].each do |attr|
      next unless assign_params.key? attr

      check attr.to_s.capitalize
      select_by_value assign_params[attr], from: attr
    end

    %i[src_name_rewrite_rule src_name_rewrite_result src_rewrite_rule src_rewrite_result dst_rewrite_rule dst_rewrite_result
       diversion_rewrite_rule diversion_rewrite_result pai_rewrite_rule pai_rewrite_result].each do |attr|
      next unless assign_params.key? attr

      check attr.to_s.capitalize
      fill_in attr, with: assign_params[attr]
    end
  end

  subject do
    fill_batch_form
    click_button 'OK'
    confirm_batch_update
  end

  context 'check validations' do
    context 'when :dst_number_max_length is not a number' do
      let(:assign_params) { { dst_number_max_length: 'string', dst_number_min_length: '12' } }

      it 'should have error: is not a number' do
        subject
        expect(page).to have_selector '.flash', text: 'Dst number max length is not a number'
      end
    end

    context 'when all fields filled with valid values' do
      it 'all fields should pass validates' do
        expect do
          subject
          expect(page).to have_selector '.flash', text: success_message
        end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'CustomersAuth', be_present, assign_params, be_present
      end
    end
  end

  it 'schedules update successfully' do
    subject
    expect(page).to have_flash_message('Batch Update is scheduled', type: :notice)
    expect(AsyncBatchUpdateJob).to have_been_enqueued.with(
      'CustomersAuth',
      'SELECT "class4"."customers_auth".* FROM "class4"."customers_auth"',
      assign_params,
      {
        whodunnit: admin_user.id,
        controller_info: { ip: '127.0.0.1' }
      }
    )
  end
end
