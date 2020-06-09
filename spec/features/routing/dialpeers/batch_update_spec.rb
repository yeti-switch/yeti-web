# frozen_string_literal: true

RSpec.describe BatchUpdateForm::Dialpeer, :js do
  include_context :login_as_admin
  let!(:_dialpeers) { create_list :dialpeer, 3 }
  let!(:gateway_shared) { create :gateway, is_shared: true }
  let!(:gateway) { create :gateway }
  let!(:vendor_main) { create :vendor }
  let!(:account_vendors) { create :account, contractor: vendor_main }
  let(:success_message) { I18n.t 'flash.actions.batch_actions.batch_update.job_scheduled' }
  let!(:gateway_allow_t_f) { create :gateway, allow_termination: false }
  let!(:gateway_group) { create :gateway_group }
  let!(:gateway_vendors) { create :gateway, contractor: vendor_main }
  let!(:gateway_group_vendors) { create :gateway_group, vendor: vendor_main }
  let!(:vendor) { create :vendor }
  let!(:account) { create :account }
  let(:pg_max_smallint) { Yeti::ActiveRecord::PG_MAX_SMALLINT }
  before do
    visit dialpeers_path
    click_button 'Update batch'
  end

  subject { click_button :OK }

  context 'check validation for field:' do
    context '"prefix"' do
      before { check :Prefix }
      context 'should have error:' do
        it "can't be blank" do
          fill_in :prefix, with: nil
          click_button :OK
          expect(page).to have_selector '.flash', text: "can't be blank"
        end

        it 'spaced is not allowed' do
          fill_in :prefix, with: 'with space'
          click_button :OK
          expect(page).to have_selector '.flash', text: 'spaced is not allowed'
        end
      end

      context 'should have success' do
        let(:changes) { { prefix: '_prefix_' } }
        it 'change value lonely' do
          fill_in :prefix, with: changes[:prefix]
          expect do
            subject
            expect(page).to have_selector '.flash', text: success_message
          end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Dialpeer', be_present, changes, be_present
        end
      end
    end

    context '"exclusive_route"' do
      let(:changes) { { exclusive_route: true } }
      it 'should change value lonely' do
        check :Exclusive_route
        select :Yes, from: :exclusive_route
        expect do
          subject
          expect(page).to have_selector '.flash', text: success_message
        end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Dialpeer', be_present, changes, be_present
      end
    end

    context '"dst_number_min_length"' do
      before { check :Dst_number_min_length }
      context 'should have error:' do
        it "can't be blank and is not a number" do
          fill_in :dst_number_min_length, with: nil
          click_button :OK
          expect(page).to have_selector '.flash', text: "can't be blank"
          expect(page).to have_selector '.flash', text: 'is not a number'
        end

        it 'must be greater than or equal t zero' do
          fill_in :dst_number_min_length, with: -1
          click_button :OK
          expect(page).to have_selector '.flash', text: 'must be greater than or equal to 0'
        end

        it 'must be less than or equal to 100' do
          fill_in :dst_number_min_length, with: 101
          click_button :OK
          expect(page).to have_selector '.flash', text: 'must be less than or equal to 100'
        end

        it 'must be an integer' do
          fill_in :dst_number_min_length, with: 1.5
          click_button :OK
          expect(page).to have_selector '.flash', text: 'must be an integer'
        end

        it 'must be changed together' do
          fill_in :dst_number_min_length, with: 12
          click_button :OK
          expect(page).to have_selector '.flash', text: 'must be changed together'
        end
      end

      context 'should have success' do
        let(:changes) { { dst_number_min_length: '5', dst_number_max_length: '12' } }
        it 'must be changed together dst_number_min_length and dst_number_max_length lonely' do
          check :Dst_number_max_length
          fill_in :dst_number_min_length, with: changes[:dst_number_min_length]
          fill_in :dst_number_max_length, with: changes[:dst_number_max_length]
          expect do
            subject
            expect(page).to have_selector '.flash', text: success_message
          end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Dialpeer', be_present, changes, be_present
        end
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

      it 'must be greater than or equal to zero' do
        fill_in :dst_number_max_length, with: -1
        click_button :OK
        expect(page).to have_selector '.flash', text: 'must be greater than or equal to 0'
      end

      it 'must be less than or equal to 100' do
        fill_in :dst_number_max_length, with: 101
        click_button :OK
        expect(page).to have_selector '.flash', text: 'must be less than or equal to 100'
      end

      it 'must be an integer' do
        fill_in :dst_number_max_length, with: 1.5
        click_button :OK
        expect(page).to have_selector '.flash', text: 'must be an integer'
      end

      it 'must be changed together' do
        fill_in :dst_number_max_length, with: 12
        click_button :OK
        expect(page).to have_selector '.flash', text: 'must be changed together'
      end
    end

    context '"routing_tag_mode_id"' do
      let(:changes) { { routing_tag_mode_id: Routing::RoutingTagMode.last.id.to_s } }
      it 'should change value lonely' do
        check :Routing_tag_mode_id
        select Routing::RoutingTagMode.last.name, from: :routing_tag_mode_id
        expect do
          subject
          expect(page).to have_selector '.flash', text: success_message
        end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Dialpeer', be_present, changes, be_present
      end
    end

    context '"initial_interval"' do
      before { check :Initial_interval }
      context 'should have error:' do
        it "can't be blank and is not a number" do
          fill_in :initial_interval, with: nil
          click_button :OK
          expect(page).to have_selector '.flash', text: "can't be blank"
          expect(page).to have_selector '.flash', text: 'is not a number'
        end

        it 'must be greater than zero' do
          fill_in :initial_interval, with: 0
          click_button :OK
          expect(page).to have_selector '.flash', text: 'must be greater than 0'
        end

        it 'must be an integer' do
          fill_in :initial_interval, with: 1.5
          click_button :OK
          expect(page).to have_selector '.flash', text: 'must be an integer'
        end
      end

      context 'should have success' do
        let(:changes) { { initial_interval: '8' } }
        it 'change value lonely' do
          fill_in :initial_interval, with: changes[:initial_interval]
          expect do
            subject
            expect(page).to have_selector '.flash', text: success_message
          end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Dialpeer', be_present, changes, be_present
        end
      end
    end

    context '"initial_rate"' do
      before { check :Initial_rate }
      context 'should have error:' do
        it "can't be blank" do
          fill_in :initial_rate, with: nil
          click_button :OK
          expect(page).to have_selector '.flash', text: "can't be blank"
        end

        it 'is not a number' do
          fill_in :initial_rate, with: 'string'
          click_button :OK
          expect(page).to have_selector '.flash', text: 'is not a number'
        end
      end

      context 'should have success' do
        let(:changes) { { initial_rate: '5' } }
        it 'change value lonely' do
          fill_in :initial_rate, with: changes[:initial_rate]
          expect do
            subject
            expect(page).to have_selector '.flash', text: success_message
          end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Dialpeer', be_present, changes, be_present
        end
      end
    end

    context '"next_interval"' do
      before { check :Next_interval }
      context 'should have error:' do
        it "can't be blank and is not a number" do
          fill_in :next_interval, with: nil
          click_button :OK
          expect(page).to have_selector '.flash', text: "can't be blank"
          expect(page).to have_selector '.flash', text: 'is not a number'
        end

        it 'must be greater than zero' do
          fill_in :next_interval, with: 0
          click_button :OK
          expect(page).to have_selector '.flash', text: 'must be greater than 0'
        end

        it 'must be an integer' do
          fill_in :next_interval, with: 1.5
          click_button :OK
          expect(page).to have_selector '.flash', text: 'must be an integer'
        end
      end

      context 'should have success' do
        let(:changes) { { next_interval: '5' } }
        it 'must be an integer' do
          fill_in :next_interval, with: changes[:next_interval]
          expect do
            subject
            expect(page).to have_selector '.flash', text: success_message
          end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Dialpeer', be_present, changes, be_present
        end
      end
    end

    context '"next_rate"' do
      before { check :Next_rate }
      context 'should have error:' do
        it "can't be blank" do
          fill_in :next_rate, with: nil
          click_button :OK
          expect(page).to have_selector '.flash', text: "can't be blank"
        end

        it 'is not a number' do
          fill_in :next_rate, with: 'string'
          click_button :OK
          expect(page).to have_selector '.flash', text: 'is not a number'
        end
      end

      context 'should have success' do
        let(:changes) { { next_rate: '5' } }
        it 'change value lonely' do
          fill_in :next_rate, with: changes[:next_rate]
          expect do
            subject
            expect(page).to have_selector '.flash', text: success_message
          end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Dialpeer', be_present, changes, be_present
        end
      end
    end

    context '"connect_fee"' do
      before { check :Connect_fee }
      context 'should have error:' do
        it "can't be blank" do
          fill_in :connect_fee, with: nil
          click_button :OK
          expect(page).to have_selector '.flash', text: "can't be blank"
        end

        it 'is not a number' do
          fill_in :connect_fee, with: 'string'
          click_button :OK
          expect(page).to have_selector '.flash', text: 'is not a number'
        end
      end

      context 'should have success' do
        let(:changes) { { connect_fee: '5' } }
        it 'change value lonely' do
          fill_in :connect_fee, with: changes[:connect_fee]
          expect do
            subject
            expect(page).to have_selector '.flash', text: success_message
          end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Dialpeer', be_present, changes, be_present
        end
      end
    end

    context '"acd_limit"' do
      before { check :Acd_limit }
      context 'should have error:' do
        it "can't be blank and is not a number" do
          fill_in :acd_limit, with: nil
          click_button :OK
          expect(page).to have_selector '.flash', text: "can't be blank"
          expect(page).to have_selector '.flash', text: 'is not a number'
        end

        it 'must be greater than or equal to "0.0"' do
          fill_in :acd_limit, with: -1
          click_button :OK
          expect(page).to have_selector '.flash', text: 'must be greater than or equal to 0.0'
        end

        it 'must be less than or equal to "1.0"' do
          fill_in :acd_limit, with: 1.01
          click_button :OK
          expect(page).to have_selector '.flash', text: 'must be less than or equal to 1.0'
        end
      end

      context 'should have success' do
        let(:changes) { { acd_limit: '0.8' } }
        it 'change value lonely' do
          fill_in :acd_limit, with: changes[:acd_limit]
          expect do
            subject
            expect(page).to have_selector '.flash', text: success_message
          end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Dialpeer', be_present, changes, be_present
        end
      end
    end

    context '"short_calls_limit"' do
      before { check :Short_calls_limit }
      context 'should have error:' do
        it "can't be blank and is not a number" do
          fill_in :short_calls_limit, with: nil
          click_button :OK
          expect(page).to have_selector '.flash', text: "can't be blank"
          expect(page).to have_selector '.flash', text: 'is not a number'
        end

        it 'must be greater than or equal to "0.0"' do
          fill_in :short_calls_limit, with: -1
          click_button :OK
          expect(page).to have_selector '.flash', text: 'must be greater than or equal to 0.0'
        end

        it 'must be less than or equal to "1.0"' do
          fill_in :short_calls_limit, with: 1.01
          click_button :OK
          expect(page).to have_selector '.flash', text: 'must be less than or equal to 1.0'
        end
      end

      context 'should have success' do
        let(:changes) { { short_calls_limit: '0.8' } }
        it 'change value lonely' do
          fill_in :short_calls_limit, with: changes[:short_calls_limit]
          expect do
            subject
            expect(page).to have_selector '.flash', text: success_message
          end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Dialpeer', be_present, changes, be_present
        end
      end
    end

    context '"force_hit_rate"' do
      before { check :Force_hit_rate }
      context 'should have error:' do
        it 'is not a number' do
          fill_in :force_hit_rate, with: 'string'
          click_button :OK
          expect(page).to have_selector '.flash', text: 'is not a number'
        end

        it 'must be greater than or equal to "0.0"' do
          fill_in :force_hit_rate, with: -1
          click_button :OK
          expect(page).to have_selector '.flash', text: 'must be greater than or equal to 0.0'
        end

        it 'must be less than or equal to "1.0"' do
          fill_in :force_hit_rate, with: 1.01
          click_button :OK
          expect(page).to have_selector '.flash', text: 'must be less than or equal to 1.0'
        end
      end

      context 'should have success message' do
        let(:changes) { { force_hit_rate: '' } }
        it 'allow bank passed and scheduled job' do
          fill_in :force_hit_rate, with: changes[:force_hit_rate]
          expect do
            subject
            expect(page).to have_selector '.flash', text: success_message
          end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Dialpeer', be_present, changes, be_present
        end

        it 'change value lonely' do
          changes = { force_hit_rate: '0.8' }
          fill_in :force_hit_rate, with: changes[:force_hit_rate]
          expect do
            subject
            expect(page).to have_selector '.flash', text: success_message
          end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Dialpeer', be_present, changes, be_present
        end
      end
    end

    context '"priority"' do
      context 'should have error:' do
        it "can't be blank and is not a number" do
          check :Priority
          fill_in :priority, with: nil
          click_button :OK
          expect(page).to have_selector '.flash', text: "can't be blank"
          expect(page).to have_selector '.flash', text: 'is not a number'
        end
      end

      context 'should have success' do
        let(:changes) { { priority: '10' } }
        it 'change value lonely' do
          check :Priority
          fill_in :priority, with: changes[:priority]
          expect do
            subject
            expect(page).to have_selector '.flash', text: success_message
          end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Dialpeer', be_present, changes, be_present
        end
      end
    end

    context '"routing_group_id"' do
      let(:changes) { { routing_group_id: RoutingGroup.take!.id.to_s } }
      it 'should change value lonely' do
        check :Routing_group_id
        select RoutingGroup.take!.name, from: :routing_group_id
        expect do
          subject
          expect(page).to have_selector '.flash', text: success_message
        end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Dialpeer', be_present, changes, be_present
      end
    end

    context '"capacity"' do
      before { check :Capacity }
      context 'should have error:' do
        it 'is not a number' do
          fill_in :capacity, with: 'string'
          click_button :OK
          expect(page).to have_selector '.flash', text: 'is not a number'
        end

        it 'must be greater than zero' do
          fill_in :capacity, with: 0
          click_button :OK
          expect(page).to have_selector '.flash', text: 'must be greater than 0'
        end

        it 'less than or equal to' do
          fill_in :capacity, with: pg_max_smallint + 1
          click_button :OK
          expect(page).to have_selector '.flash', text: "less than or equal to #{pg_max_smallint}"
        end
      end

      context 'should have success' do
        let(:changes) { { capacity: '5' } }
        it 'change value lonely' do
          fill_in :capacity, with: changes[:capacity]
          expect do
            subject
            expect(page).to have_selector '.flash', text: success_message
          end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Dialpeer', be_present, changes, be_present
        end
      end
    end

    context '"account_id"' do
      context 'should have error:' do
        it 'Account and Vendor must be changed together' do
          check :Account_id
          select account.name, from: :account_id
          click_button :OK
          expect(page).to have_selector '.flash', text: 'must be changed together'
        end

        it 'account must be owned by selected vendor' do
          check :Vendor_id
          check :Account_id
          select account.name, from: :account_id
          select vendor.name, from: :vendor_id
          click_button :OK
          expect(page).to have_selector '.flash', text: 'Account must be owned by selected vendor'
        end
      end

      context 'should have success' do
        it 'change account_id and vendor_id lonely' do
          check :Vendor_id
          check :Account_id
          select account_vendors.name, from: :account_id
          select vendor_main.name, from: :vendor_id
          click_button :OK
        end
      end
    end

    context '"gateway_id":' do
      context 'should have error:' do
        it 'must be owned by selected vendor or be shared and must be tarmination' do
          check :Gateway_id
          check :Vendor_id
          select gateway_allow_t_f.name, from: :gateway_id
          select vendor.name, from: :vendor_id
          click_button :OK
          expect(page).to have_selector '.flash', text: 'Gateway must be owned by selected vendor or be shared'
          expect(page).to have_selector '.flash', text: 'Gateway must be allowed for termination'
        end

        it 'Gateway and Vendor must be changed together' do
          check :Gateway_id
          select gateway.name, from: :gateway_id
          click_button :OK
          expect(page).to have_selector '.flash', text: 'must be changed together'
        end
      end

      context 'should have success message' do
        it 'with shared gateway' do
          changes = { gateway_id: gateway_shared.id.to_s }
          check :Gateway_id
          select gateway_shared.name, from: :gateway_id
          expect do
            subject
            expect(page).to have_selector '.flash', text: success_message
          end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Dialpeer', be_present, changes, be_present
        end

        it 'change value lonely' do
          changes = {
            gateway_id: gateway_vendors.id.to_s,
            vendor_id: vendor_main.id.to_s,
            gateway_group_id: gateway_group_vendors.id.to_s,
            account_id: account_vendors.id.to_s
          }
          check :Gateway_id
          check :Vendor_id
          check :Gateway_group_id
          check :Account_id
          select gateway_vendors.name, from: :gateway_id
          select vendor_main.name, from: :vendor_id
          select gateway_group_vendors.name, from: :gateway_group_id
          select account_vendors.name, from: :account_id
          expect do
            subject
            expect(page).to have_selector '.flash', text: success_message
          end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Dialpeer', be_present, changes, be_present
        end
      end
    end

    context '"gateway_group"' do
      context 'should have error:' do
        it 'GatewayGroup and vendor must be changed together' do
          check :Gateway_group_id
          select gateway_group.name, from: :gateway_group_id
          click_button :OK
          expect(page).to have_selector '.flash', text: 'must be changed together'
        end

        it 'Gateway group must be owners by selected vendor' do
          check :Vendor_id
          select vendor_main.name, from: :vendor_id
          check :Gateway_group_id
          select gateway_group.name, from: :gateway_group_id
          check :Account_id
          select account_vendors.name, from: :account_id
          check :Gateway_id
          select gateway_shared.name, from: :gateway_id
          click_button :OK
          expect(page).to have_selector '.flash', text: 'Gateway group must be owners by selected vendor'
        end
      end

      context 'should have success' do
        it 'change value "gateway_group_id" and "vendor_id" lonely' do
          check :Gateway_group_id
          select gateway_group_vendors.name, from: :gateway_group_id
          check :Vendor_id
          select vendor_main.name, from: :vendor_id
          click_button :OK
        end
      end
    end

    context '"lcr_rate_multiplier"' do
      let(:changes) { { lcr_rate_multiplier: '2' } }
      it 'should change value lonely' do
        check :Lcr_rate_multiplier
        fill_in :lcr_rate_multiplier, with: changes[:lcr_rate_multiplier]
        expect do
          subject
          expect(page).to have_selector '.flash', text: success_message
        end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Dialpeer', be_present, changes, be_present
      end
    end

    context '"routeset_discriminator_id"' do
      let(:changes) { { routeset_discriminator_id: Routing::RoutesetDiscriminator.last!.id.to_s } }
      it 'should change value lonely' do
        check :Routeset_discriminator_id
        select Routing::RoutesetDiscriminator.last!.name, from: :routeset_discriminator_id
        expect do
          subject
          expect(page).to have_selector '.flash', text: success_message
        end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Dialpeer', be_present, changes, be_present
      end
    end

    context '"valid_from"' do
      before { check :Valid_from }
      context 'should have error:' do
        it "cant't be blank" do
          fill_in :valid_from, with: nil
          click_button :OK
          expect(page).to have_selector '.flash', text: "can't be blank"
        end

        it 'must be changed together' do
          fill_in :valid_from, with: '2020-02-20'
          click_button :OK
          expect(page).to have_selector '.flash', text: 'must be changed together'
        end

        it 'must be before or equal to $valid_till' do
          date_from = Time.now.utc
          date_till = 2.days.ago.utc
          check :Valid_till
          fill_in :valid_from, with: date_from.strftime('%Y-%m-%d')
          fill_in :valid_till, with: date_till.strftime('%Y-%m-%d')
          click_button :OK
          expect(page).to have_selector '.flash', text: 'must be before or equal to'
        end
      end

      context 'should have success' do
        let(:changes) { { valid_from: '2020-05-05', valid_till: '2020-05-20' } }
        it 'change value valid_till and valid_from lonely' do
          check :Valid_till
          fill_in :valid_from, with: changes[:valid_from]
          fill_in :valid_till, with: changes[:valid_till]
          expect do
            subject
            expect(page).to have_selector '.flash', text: success_message
          end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Dialpeer', be_present, changes, be_present
        end
      end
    end

    context '"valid_till"' do
      before { check :Valid_till }
      context 'should have error:' do
        it "cant't be blank" do
          fill_in :valid_till, with: nil
          click_button :OK
          expect(page).to have_selector '.flash', text: "can't be blank"
        end

        it 'must be changed together' do
          fill_in :valid_till, with: '2020-02-20'
          click_button :OK
          expect(page).to have_selector '.flash', text: 'must be changed together'
        end
      end

      context 'should have success' do
        let(:changes) { { valid_from: '2020-02-02', valid_till: '2020-02-20' } }
        it 'change value valid_till and valid_from lonely' do
          check :Valid_from
          fill_in :valid_from, with: changes[:valid_from]
          fill_in :valid_till, with: changes[:valid_till]
          expect do
            subject
            expect(page).to have_selector '.flash', text: success_message
          end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Dialpeer', be_present, changes, be_present
        end
      end
    end

    context '"asr_limit"' do
      before { check :Asr_limit }
      context 'should have error:' do
        it "can't be blank" do
          fill_in :asr_limit, with: nil
          click_button :OK
          expect(page).to have_selector '.flash', text: "can't be blank"
          expect(page).to have_selector '.flash', text: 'is not a number'
        end

        it 'must be greater than or equal to 0.0' do
          fill_in :asr_limit, with: -1
          click_button :OK
          expect(page).to have_selector '.flash', text: 'must be greater than or equal to 0.0'
        end

        it 'must be less than or equal to 1.0' do
          fill_in :asr_limit, with: 1.5
          click_button :OK
          expect(page).to have_selector '.flash', text: 'must be less than or equal to 1.0'
        end
      end

      context 'should have success' do
        let(:changes) { { asr_limit: '0.8' } }
        it 'change value lonely' do
          fill_in :asr_limit, with: changes[:asr_limit]
          expect do
            subject
            expect(page).to have_selector '.flash', text: success_message
          end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Dialpeer', be_present, changes, be_present
        end
      end
    end

    context '"src_name_rewrite_rule"' do
      let(:changes) { { src_name_rewrite_rule: 'string' } }
      it 'should change value lonely' do
        check :Src_name_rewrite_rule
        fill_in :src_name_rewrite_rule, with: changes[:src_name_rewrite_rule]
        expect do
          subject
          expect(page).to have_selector '.flash', text: success_message
        end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Dialpeer', be_present, changes, be_present
      end
    end

    context '"src_name_rewrite_result"' do
      let(:changes) { { src_name_rewrite_result: 'string' } }
      it 'should change value lonely' do
        check :Src_name_rewrite_result
        fill_in :src_name_rewrite_result, with: changes[:src_name_rewrite_result]
        expect do
          subject
          expect(page).to have_selector '.flash', text: success_message
        end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Dialpeer', be_present, changes, be_present
      end
    end

    context '"src_rewrite_rule"' do
      let(:changes) { { src_rewrite_rule: 'string' } }
      it 'should change value lonely' do
        check :Src_rewrite_rule
        fill_in :src_rewrite_rule, with: changes[:src_rewrite_rule]
        expect do
          subject
          expect(page).to have_selector '.flash', text: success_message
        end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Dialpeer', be_present, changes, be_present
      end
    end

    context '"src_rewrite_result"' do
      let(:changes) { { src_rewrite_result: 'string' } }
      it 'should change value lonely' do
        check :Src_rewrite_result
        fill_in :src_rewrite_result, with: changes[:src_rewrite_result]
        expect do
          subject
          expect(page).to have_selector '.flash', text: success_message
        end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Dialpeer', be_present, changes, be_present
      end
    end

    context '"dst_rewrite_rule"' do
      let(:changes) { { dst_rewrite_rule: 'string' } }
      it 'should change value lonely' do
        check :Dst_rewrite_rule
        fill_in :dst_rewrite_rule, with: 'string'
        expect do
          subject
          expect(page).to have_selector '.flash', text: success_message
        end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Dialpeer', be_present, changes, be_present
      end
    end

    context '"dst_rewrite_result"' do
      let(:changes) { { dst_rewrite_result: 'string' } }
      it 'should change value lonely' do
        check :Dst_rewrite_result
        fill_in :dst_rewrite_result, with: changes[:dst_rewrite_result]
        expect do
          subject
          expect(page).to have_selector '.flash', text: success_message
        end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Dialpeer', be_present, changes, be_present
      end
    end

    context 'all field' do
      let(:changes) {
        {
          enabled: true,
          prefix: 'string',
          dst_number_min_length: '10',
          dst_number_max_length: '20',
          routing_tag_mode_id: Routing::RoutingTagMode.last!.id.to_s,
          routing_group_id: Routing::RoutingTagMode.last!.id.to_s,
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
          routeset_discriminator_id: Routing::RoutesetDiscriminator.last!.id.to_s,
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
          dst_rewrite_result: '12'
        }
      }
      it 'should pass validation' do
        check :Enabled
        select :Yes, from: :enabled

        check :Prefix
        fill_in :prefix, with: 'string'

        check :Dst_number_min_length
        fill_in :dst_number_min_length, with: changes[:dst_number_min_length]

        check :Dst_number_max_length
        fill_in :dst_number_max_length, with: changes[:dst_number_max_length]

        check :Routing_tag_mode_id
        select Routing::RoutingTagMode.last!.name, from: :routing_tag_mode_id

        check :Routing_group_id
        select RoutingGroup.take!.name, from: :routing_group_id

        check :Priority
        fill_in :priority, with: changes[:priority]

        check :Force_hit_rate
        fill_in :force_hit_rate, with: changes[:force_hit_rate]

        check :Exclusive_route
        select :Yes, from: :exclusive_route

        check :Initial_interval
        fill_in :initial_interval, with: changes[:initial_interval]

        check :Initial_rate
        fill_in :initial_rate, with: changes[:initial_rate]

        check :Next_interval
        fill_in :next_interval, with: changes[:next_interval]

        check :Next_rate
        fill_in :next_rate, with: changes[:next_rate]

        check :Connect_fee
        fill_in :connect_fee, with: changes[:connect_fee]

        check :Lcr_rate_multiplier
        fill_in :lcr_rate_multiplier, with: changes[:lcr_rate_multiplier]

        check :Gateway_id
        select gateway_vendors.name, from: :gateway_id

        check :Gateway_group_id
        select gateway_group_vendors.name, from: :gateway_group_id

        check :Vendor_id
        select vendor_main.name, from: :vendor_id

        check :Account_id
        select account_vendors.name, from: :account_id

        check :Routeset_discriminator_id
        select Routing::RoutesetDiscriminator.last!.name, from: :routeset_discriminator_id

        check :Valid_from
        fill_in :valid_from, with: changes[:valid_from]

        check :Valid_till
        fill_in :valid_till, with: changes[:valid_till]

        check :Asr_limit
        fill_in :asr_limit, with: changes[:asr_limit]

        check :Acd_limit
        fill_in :acd_limit, with: changes[:acd_limit]

        check :Short_calls_limit
        fill_in :short_calls_limit, with: changes[:short_calls_limit]

        check :Capacity
        fill_in :capacity, with: changes[:capacity]

        check :Src_name_rewrite_rule
        fill_in :src_name_rewrite_rule, with: changes[:src_name_rewrite_rule]

        check :Src_name_rewrite_result
        fill_in :src_name_rewrite_result, with: changes[:src_name_rewrite_result]

        check :Src_rewrite_rule
        fill_in :src_rewrite_rule, with: changes[:src_rewrite_rule]

        check :Src_rewrite_result
        fill_in :src_rewrite_result, with: changes[:src_rewrite_result]

        check :Dst_rewrite_rule
        fill_in :dst_rewrite_rule, with: changes[:dst_rewrite_rule]

        check :Dst_rewrite_result
        fill_in :dst_rewrite_result, with: changes[:dst_rewrite_result]

        expect do
          subject
          expect(page).to have_selector '.flash', text: success_message
        end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Dialpeer', be_present, changes, be_present
      end
    end
  end
end
