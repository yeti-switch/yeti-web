# frozen_string_literal: true

RSpec.describe BatchUpdateForm::CustomersAuth, :js do
  include_context :login_as_admin
  let!(:_customers_auth) { create_list :customers_auth, 3 }
  let!(:accounts) { create_list :account, 5 }
  let(:success_message) { I18n.t 'flash.actions.batch_actions.batch_update.job_scheduled' }
  let!(:routing_plan) { create :routing_plan }
  let!(:lua_script) { create :lua_script }
  let!(:rateplan) { create :rateplan }
  let!(:dump_level) { DumpLevel.take! }
  let!(:numberlist) { create :numberlist }
  let!(:protocol) { Equipment::TransportProtocol.last! }
  before do
    visit customers_auths_path
    click_button 'Update batch'
  end

  subject { click_button :OK }

  context 'check validations for the field:' do
    context '"enabled"' do
      let(:changes) { { enabled: true } }
      it 'should change value lonely' do
        check :Enabled
        select :Yes, from: :enabled
        expect do
          subject
          expect(page).to have_selector '.flash', text: success_message
        end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'CustomersAuth', be_present, changes, be_present
      end
    end

    context '"reject_calls"' do
      let(:changes) { { reject_calls: true } }
      it 'should change value lonely' do
        check :Reject_calls
        select :Yes, from: :reject_calls
        expect do
          subject
          expect(page).to have_selector '.flash', text: success_message
        end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'CustomersAuth', be_present, changes, be_present
      end
    end

    context '"transport_protocol_id"' do
      let(:changes) { { transport_protocol_id: protocol.id.to_s } }
      it 'should change value lonely' do
        check :Transport_protocol_id
        select protocol.name, from: :transport_protocol_id
        expect do
          subject
          expect(page).to have_selector '.flash', text: success_message
        end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'CustomersAuth', be_present, changes, be_present
      end
    end

    context '"src_number_min_length"' do
      context 'should have error:' do
        it "can't be blank and is not a number" do
          check :Src_number_min_length
          fill_in :src_number_min_length, with: nil
          click_button :OK
          expect(page).to have_selector '.flash', text: "can't be blank"
          expect(page).to have_selector '.flash', text: 'is not a number'
        end

        it 'must be changed together' do
          check :Src_number_min_length
          fill_in :src_number_min_length, with: 12
          click_button :OK
          expect(page).to have_selector '.flash', text: 'must be changed together'
        end

        it 'must be greater than or equal to' do
          check :Src_number_min_length
          check :Src_number_max_length
          fill_in :src_number_min_length, with: 50
          fill_in :src_number_max_length, with: 10
          click_button :OK
          expect(page).to have_selector '.flash', text: 'must be greater than or equal to'
        end
      end

      context 'should pass validates success' do
        let(:changes) { { src_number_min_length: '10', src_number_max_length: '20' } }
        it 'src_number_min_length and src_number_max_length should change lonely' do
          check :Src_number_min_length
          check :Src_number_max_length
          fill_in :src_number_min_length, with: changes[:src_number_min_length]
          fill_in :src_number_max_length, with: changes[:src_number_max_length]
          expect do
            subject
            expect(page).to have_selector '.flash', text: success_message
          end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'CustomersAuth', be_present, changes, be_present
        end
      end
    end

    context '"dst_number_max_length"' do
      context 'should have error:' do
        it "can't be blank and is not a number" do
          check :Dst_number_max_length
          fill_in :dst_number_max_length, with: nil
          click_button :OK
          expect(page).to have_selector '.flash', text: "can't be blank"
          expect(page).to have_selector '.flash', text: 'is not a number'
        end

        it 'must be changed together' do
          check :Dst_number_max_length
          fill_in :dst_number_max_length, with: 12
          click_button :OK
          expect(page).to have_selector '.flash', text: 'must be changed together'
        end
      end

      context 'should change min and max together' do
        let(:changes) { { dst_number_min_length: '10', dst_number_max_length: '20' } }
        it 'must be changed together' do
          check :Dst_number_min_length
          check :Dst_number_max_length
          fill_in :dst_number_min_length, with: changes[:dst_number_min_length]
          fill_in :dst_number_max_length, with: changes[:dst_number_max_length]
          expect do
            subject
            expect(page).to have_selector '.flash', text: success_message
          end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'CustomersAuth', be_present, changes, be_present
        end
      end
    end

    context '"dst_number_min_length" should have error:' do
      it "can't be blank and is not a number" do
        check :Dst_number_min_length
        fill_in :dst_number_min_length, with: nil
        click_button :OK
        expect(page).to have_selector '.flash', text: "can't be blank"
        expect(page).to have_selector '.flash', text: 'is not a number'
      end

      it 'must be changed together' do
        check :Dst_number_min_length
        fill_in :dst_number_min_length, with: 12
        click_button :OK
        expect(page).to have_selector '.flash', text: 'must be changed together'
      end
    end

    context '"dst_number_max_length" should have error:' do
      before { check :Dst_number_max_length }
      it "can't be blank and is not a number" do
        fill_in :dst_number_max_length, with: nil
        click_button :OK
        expect(page).to have_selector '.flash', text: "can't be blank"
        expect(page).to have_selector '.flash', text: 'is not a number'
      end

      it 'must be changed together' do
        fill_in :dst_number_max_length, with: 12
        click_button :OK
        expect(page).to have_selector '.flash', text: 'must be changed together'
      end

      it 'must be greater than or equal to' do
        check :Dst_number_min_length
        fill_in :dst_number_min_length, with: 50
        fill_in :dst_number_max_length, with: 10
        click_button :OK
        expect(page).to have_selector '.flash', text: 'must be greater than or equal to'
      end
    end

    context '"dst_numberlist_id"' do
      let(:changes) { { dst_numberlist_id: numberlist.id.to_s } }
      it 'should change value lonely' do
        check :Dst_numberlist_id
        select numberlist.name, from: :dst_numberlist_id
        expect do
          subject
          expect(page).to have_selector '.flash', text: success_message
        end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'CustomersAuth', be_present, changes, be_present
      end
    end

    context '"src_numberlist_id"' do
      let(:changes) { { src_numberlist_id: numberlist.id.to_s } }
      it 'should change value lonely' do
        check :Src_numberlist_id
        select numberlist.name, from: :src_numberlist_id
        expect do
          subject
          expect(page).to have_selector '.flash', text: success_message
        end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'CustomersAuth', be_present, changes, be_present
      end
    end

    context '"dump_level_id"' do
      let(:changes) { { dump_level_id: DumpLevel.last!.id.to_s } }
      it 'should change value lonely' do
        check :Dump_level_id
        select DumpLevel.last!.name, from: :dump_level_id
        expect do
          subject
          expect(page).to have_selector '.flash', text: success_message
        end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'CustomersAuth', be_present, changes, be_present
      end
    end

    context '"rateplan_id"' do
      let(:changes) { { rateplan_id: rateplan.id.to_s } }
      it 'should change value lonely' do
        check :Rateplan_id
        select rateplan.name, from: :rateplan_id
        expect do
          subject
          expect(page).to have_selector '.flash', text: success_message
        end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'CustomersAuth', be_present, changes, be_present
      end
    end

    context '"routing_plan_id"' do
      let(:changes) { { routing_plan_id: routing_plan.id.to_s } }
      it 'should change value lonely' do
        check :Routing_plan_id
        select routing_plan.name, from: :routing_plan_id
        expect do
          subject
          expect(page).to have_selector '.flash', text: success_message
        end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'CustomersAuth', be_present, changes, be_present
      end
    end

    context '"lua_script_id"' do
      let(:changes) { { lua_script_id: lua_script.id.to_s } }
      it 'should change value lonely' do
        check :Lua_script_id
        select lua_script.name, from: :lua_script_id
        expect do
          subject
          expect(page).to have_selector '.flash', text: success_message
        end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'CustomersAuth', be_present, changes, be_present
      end
    end

    it 'all fields should pass validates' do
      changes = {
        enabled: true,
        reject_calls: true,
        transport_protocol_id: protocol.id.to_s,
        src_number_min_length: '2',
        src_number_max_length: '20',
        dst_number_min_length: '5',
        dst_number_max_length: '50',
        dst_numberlist_id: numberlist.id.to_s,
        src_numberlist_id: numberlist.id.to_s,
        dump_level_id: DumpLevel.last!.id.to_s,
        rateplan_id: rateplan.id.to_s,
        routing_plan_id: routing_plan.id.to_s,
        lua_script_id: lua_script.id.to_s
      }
      check :Enabled
      select :Yes, from: :enabled

      check :Reject_calls
      select :Yes, from: :reject_calls

      check :Transport_protocol_id
      select protocol.name, from: :transport_protocol_id

      check :Src_number_min_length
      fill_in :src_number_min_length, with: changes[:src_number_min_length]

      check :Src_number_max_length
      fill_in :src_number_max_length, with: changes[:src_number_max_length]

      check :Dst_number_min_length
      fill_in :dst_number_min_length, with: changes[:dst_number_min_length]

      check :Dst_number_max_length
      fill_in :dst_number_max_length, with: changes[:dst_number_max_length]

      check :Dst_numberlist_id
      select numberlist.name, from: :dst_numberlist_id

      check :Src_numberlist_id
      select numberlist.name, from: :src_numberlist_id

      check :Dump_level_id
      select DumpLevel.last!.name, from: :dump_level_id

      check :Rateplan_id
      select rateplan.name, from: :rateplan_id

      check :Routing_plan_id
      select routing_plan.name, from: :routing_plan_id

      check :Lua_script_id
      select lua_script.name, from: :lua_script_id

      expect do
        subject
        expect(page).to have_selector '.flash', text: success_message
      end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'CustomersAuth', be_present, changes, be_present
    end
  end
end
