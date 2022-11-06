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
      dump_level_id: dump_level_id,
      rateplan_id: rateplan.id.to_s,
      routing_plan_id: routing_plan.id.to_s,
      lua_script_id: lua_script.id.to_s
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

    #    if assign_params.key? :dump_level_id
    #      check :Dump_level_id
    #      select_by_value assign_params[:dump_level_id], from: :dump_level_id
    #    end

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
  end

  subject do
    fill_batch_form
    click_button 'OK'
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
