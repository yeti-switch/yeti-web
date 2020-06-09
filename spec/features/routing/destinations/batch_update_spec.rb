# frozen_string_literal: true

RSpec.describe BatchUpdateForm::Destination, js: true do
  include_context :login_as_admin
  let!(:_destinations) { create_list :destination, 3 }
  let(:success_message) { I18n.t 'flash.actions.batch_actions.batch_update.job_scheduled' }
  let!(:rateplan) { Rateplan.take || create(:rateplan) }
  let!(:routing_tag_mode) { Routing::RoutingTagMode.take! }
  let!(:rate_policy) { DestinationRatePolicy.take! }
  let!(:profit_control_mode) { Routing::RateProfitControlMode.take! || create(:rate_profit_control_mode) }
  let(:date_now) { Time.now.utc.strftime('%Y-%m-%d') }
  before do
    visit destinations_path
    click_button 'Update batch'
  end

  subject { click_button :OK }

  context 'should check validates for the field:' do
    context '"enabled"' do
      let(:changes) { { enabled: true } }
      it 'should change lonely' do
        check :Enabled
        select :Yes, from: :enabled
        expect do
          subject
          expect(page).to have_selector '.flash', text: success_message
        end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Routing::Destination', be_present, changes, be_present
      end
    end

    context '"prefix"' do
      context 'should have error:' do
        it 'spaces are not allowed' do
          check :Prefix
          fill_in :prefix, with: 'with space'
          click_button :OK
          expect(page).to have_selector '.flash', text: 'spaces are not allowed'
        end
      end

      context 'should have success' do
        let(:changes) { { prefix: '_prefix_' } }
        it 'change value lonely' do
          check :Prefix
          fill_in :prefix, with: changes[:prefix]
          expect do
            subject
            expect(page).to have_selector '.flash', text: success_message
          end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Routing::Destination', be_present, changes, be_present
        end
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

        it 'must be greater than or equal to zero' do
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

        it 'must be less than max length' do
          check :Dst_number_max_length
          fill_in :dst_number_max_length, with: 5
          fill_in :dst_number_min_length, with: 50
          click_button :OK
          expect(page).to have_selector '.flash', text: 'must be less than 5'
        end
      end

      context 'should have success' do
        let(:changes) { { dst_number_min_length: '5', dst_number_max_length: '50' } }
        it 'should change dst_number_min_length and dst_number_max_length' do
          check :Dst_number_max_length
          fill_in :dst_number_min_length, with: changes[:dst_number_min_length]
          fill_in :dst_number_max_length, with: changes[:dst_number_max_length]
          expect do
            subject
            expect(page).to have_selector '.flash', text: success_message
          end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Routing::Destination', be_present, changes, be_present
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
        expect(page).to have_selector '.flash', text: 'must be less than or equal to'
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

    context '"valid_from" should have error:' do
      before { check :Valid_from }
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
        check :Valid_till
        fill_in :valid_from, with: '2020-01-10'
        fill_in :valid_till, with: '2020-01-08'
        click_button :OK
        expect(page).to have_selector '.flash', text: 'must be before or equal to'
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
        let(:changes) { { valid_from: '2020-02-20', valid_till: '2020-02-20' } }
        it 'change value valid_till and valid_from lonely with equal value' do
          check :Valid_from
          fill_in :valid_from, with: changes[:valid_from]
          fill_in :valid_till, with: changes[:valid_till]
          expect do
            subject
            expect(page).to have_selector '.flash', text: success_message
          end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Routing::Destination', be_present, changes, be_present
        end
      end
    end

    context '"rate_policy_id"' do
      let(:changes) { { rate_policy_id: rate_policy.id.to_s } }
      it 'should change value lonely' do
        check :Rate_policy_id
        select rate_policy.name, from: :rate_policy_id
        expect do
          subject
          expect(page).to have_selector '.flash', text: success_message
        end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Routing::Destination', be_present, changes, be_present
      end
    end

    context '"initial_rate"' do
      context 'should have error:' do
        it "can't be blank and is not a number" do
          check :Initial_rate
          fill_in :initial_rate, with: nil
          click_button :OK
          expect(page).to have_selector '.flash', text: 'is not a number'
          expect(page).to have_selector '.flash', text: "can't be blank"
        end
      end

      context 'should have success' do
        let(:changes) { { initial_rate: '5' } }
        it 'change value lonely' do
          check :Initial_rate
          fill_in :initial_rate, with: changes[:initial_rate]
          expect do
            subject
            expect(page).to have_selector '.flash', text: success_message
          end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Routing::Destination', be_present, changes, be_present
        end
      end
    end

    context '"next_rate"' do
      context 'should have error:' do
        it "can't be blank and is not a number" do
          check :Next_rate
          fill_in :next_rate, with: nil
          click_button :OK
          expect(page).to have_selector '.flash', text: 'is not a number'
          expect(page).to have_selector '.flash', text: "can't be blank"
        end
      end

      context 'should have success' do
        let(:changes) { { next_rate: '6' } }
        it 'change value lonely' do
          check :Next_rate
          fill_in :next_rate, with: changes[:next_rate]
          expect do
            subject
            expect(page).to have_selector '.flash', text: success_message
          end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Routing::Destination', be_present, changes, be_present
        end
      end
    end

    context '"initial_interval"' do
      before { check :Initial_interval }
      context 'should have error:' do
        it "can't be blank and is not a number" do
          fill_in :initial_interval, with: nil
          click_button :OK
          expect(page).to have_selector '.flash', text: 'is not a number'
          expect(page).to have_selector '.flash', text: "can't be blank"
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
        let(:changes) { { initial_interval: '5' } }
        it 'change value lonely' do
          fill_in :initial_interval, with: changes[:initial_interval]
          expect do
            subject
            expect(page).to have_selector '.flash', text: success_message
          end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Routing::Destination', be_present, changes, be_present
        end
      end
    end

    context '"next_interval"' do
      before { check :Next_interval }
      context 'should have error:' do
        it "can't be blank and is not a number" do
          fill_in :next_interval, with: nil
          click_button :OK
          expect(page).to have_selector '.flash', text: 'is not a number'
          expect(page).to have_selector '.flash', text: "can't be blank"
        end

        it 'must be an integer' do
          fill_in :next_interval, with: 1.5
          click_button :OK
          expect(page).to have_selector '.flash', text: 'must be an integer'
        end

        it 'must be greater than zero' do
          fill_in :next_interval, with: 0
          click_button :OK
          expect(page).to have_selector '.flash', text: 'must be greater than 0'
        end
      end

      context 'should have success' do
        let(:changes) { { next_interval: '5' } }
        it 'change value lonely' do
          fill_in :next_interval, with: changes[:next_interval]
          expect do
            subject
            expect(page).to have_selector '.flash', text: success_message
          end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Routing::Destination', be_present, changes, be_present
        end
      end
    end

    context '"connect_fee"' do
      before { check :Connect_fee }
      context 'should have error:' do
        it "can't be blank and is not a number" do
          fill_in :connect_fee, with: nil
          click_button :OK
          expect(page).to have_selector '.flash', text: 'is not a number'
          expect(page).to have_selector '.flash', text: "can't be blank"
        end

        it 'must be greater than or equal to zero' do
          fill_in :connect_fee, with: -1
          click_button :OK
          expect(page).to have_selector '.flash', text: 'must be greater than or equal to 0'
        end
      end

      context 'should have success' do
        let(:changes) { { connect_fee: '5' } }
        it 'change value lonely' do
          fill_in :connect_fee, with: 5
          expect do
            subject
            expect(page).to have_selector '.flash', text: success_message
          end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Routing::Destination', be_present, changes, be_present
        end
      end
    end

    context '"dp_margin_fixed"' do
      before { check :Dp_margin_fixed }
      context 'should have error:' do
        it "can't be blank and is not a number" do
          fill_in :dp_margin_fixed, with: nil
          click_button :OK
          expect(page).to have_selector '.flash', text: 'is not a number'
          expect(page).to have_selector '.flash', text: "can't be blank"
        end

        it 'must be greater than or equal to zero' do
          fill_in :dp_margin_fixed, with: -1
          click_button :OK
          expect(page).to have_selector '.flash', text: 'must be greater than or equal to 0'
        end
      end

      context 'should have success' do
        let(:changes) { { dp_margin_fixed: '5' } }
        it 'change value lonely' do
          fill_in :dp_margin_fixed, with: 5
          expect do
            subject
            expect(page).to have_selector '.flash', text: success_message
          end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Routing::Destination', be_present, changes, be_present
        end
      end
    end

    context '"dp_margin_percent"' do
      before { check :Dp_margin_percent }
      context 'should have error:' do
        it "can't be blank and is not a number" do
          fill_in :dp_margin_percent, with: nil
          click_button :OK
          expect(page).to have_selector '.flash', text: 'is not a number'
          expect(page).to have_selector '.flash', text: "can't be blank"
        end

        it 'must be greater than zero' do
          fill_in :dp_margin_percent, with: 0
          click_button :OK
          expect(page).to have_selector '.flash', text: 'must be greater than 0'
        end
      end

      context 'should have success' do
        let(:changes) { { dp_margin_percent: '5' } }
        it 'change value lonely' do
          fill_in :dp_margin_percent, with: changes[:dp_margin_percent]
          expect do
            subject
            expect(page).to have_selector '.flash', text: success_message
          end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Routing::Destination', be_present, changes, be_present
        end
      end
    end

    context '"asr_limit"' do
      before { check :Asr_limit }
      context 'should have error:' do
        it "can't be blank and is not a number" do
          fill_in :asr_limit, with: nil
          click_button :OK
          expect(page).to have_selector '.flash', text: 'is not a number'
          expect(page).to have_selector '.flash', text: "can't be blank"
        end

        it 'must be greater than or equal to 0.00' do
          fill_in :asr_limit, with: -1
          click_button :OK
          expect(page).to have_selector '.flash', text: 'must be greater than or equal to 0.0'
        end

        it 'must be less than or equal to 1.00' do
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
          end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Routing::Destination', be_present, changes, be_present
        end
      end
    end

    context '"acd_limit"' do
      before { check :Acd_limit }
      context 'should have error:' do
        it "can't be blank and is not a number" do
          fill_in :acd_limit, with: nil
          click_button :OK
          expect(page).to have_selector '.flash', text: 'is not a number'
          expect(page).to have_selector '.flash', text: "can't be blank"
        end

        it 'must be greater than or equal to 0' do
          fill_in :acd_limit, with: -1
          click_button :OK
          expect(page).to have_selector '.flash', text: 'must be greater than or equal to 0'
        end
      end

      context 'should have success' do
        let(:changes) { { acd_limit: '0.5' } }
        it 'change value lonely' do
          fill_in :acd_limit, with: changes[:acd_limit]
          expect do
            subject
            expect(page).to have_selector '.flash', text: success_message
          end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Routing::Destination', be_present, changes, be_present
        end
      end
    end

    context '"short_calls_limit"' do
      before { check :Short_calls_limit }
      context 'should have error:' do
        it "can't be blank and is not a number" do
          fill_in :short_calls_limit, with: nil
          click_button :OK
          expect(page).to have_selector '.flash', text: 'is not a number'
          expect(page).to have_selector '.flash', text: "can't be blank"
        end

        it 'must be greater than or equal to' do
          fill_in :short_calls_limit, with: -1
          click_button :OK
          expect(page).to have_selector '.flash', text: 'must be greater than or equal to'
        end
      end

      context 'should have success' do
        let(:changes) { { short_calls_limit: '1' } }
        it 'change value lonely' do
          fill_in :short_calls_limit, with: changes[:short_calls_limit]
          expect do
            subject
            expect(page).to have_selector '.flash', text: success_message
          end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Routing::Destination', be_present, changes, be_present
        end
      end
    end

    context '"routing_tag_mode_id"' do
      let(:changes) { { routing_tag_mode_id: routing_tag_mode.id.to_s } }
      it 'should change value lonely' do
        check :Routing_tag_mode_id
        select routing_tag_mode.name, from: :routing_tag_mode_id
        expect do
          subject
          expect(page).to have_selector '.flash', text: success_message
        end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Routing::Destination', be_present, changes, be_present
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
        end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Routing::Destination', be_present, changes, be_present
      end
    end

    context '"quality_alarm"' do
      let(:changes) { { quality_alarm: true } }
      it 'should change value lonely' do
        check :Quality_alarm
        select :Yes, from: :quality_alarm
        expect do
          subject
          expect(page).to have_selector '.flash', text: success_message
        end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Routing::Destination', be_present, changes, be_present
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
        end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Routing::Destination', be_present, changes, be_present
      end
    end

    context '"use_dp_intervals"' do
      let(:changes) { { use_dp_intervals: true } }
      it 'should change value lonely' do
        check :Use_dp_intervals
        select :Yes, from: :use_dp_intervals
        expect do
          subject
          expect(page).to have_selector '.flash', text: success_message
        end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Routing::Destination', be_present, changes, be_present
      end
    end

    context '"profit_control_mode_id"' do
      let(:changes) { { profit_control_mode_id: profit_control_mode.id.to_s } }
      it 'should change value lonely' do
        check :Profit_control_mode_id
        select profit_control_mode.name, from: :profit_control_mode_id
        expect do
          subject
          expect(page).to have_selector '.flash', text: success_message
        end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Routing::Destination', be_present, changes, be_present
      end
    end

    it 'all fields should have success and pass validates' do
      changes = {
        enabled: true,
        prefix: '_test',
        dst_number_min_length: '0',
        dst_number_max_length: '15',
        routing_tag_mode_id: routing_tag_mode.id.to_s,
        reject_calls: false,
        quality_alarm: true,
        rateplan_id: rateplan.id.to_s,
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
      check :Enabled
      select :Yes, from: :enabled

      check :Prefix
      fill_in :prefix, with: '_test'

      check :Dst_number_min_length
      fill_in :dst_number_min_length, with: changes[:dst_number_min_length]

      check :Dst_number_max_length
      fill_in :dst_number_max_length, with: changes[:dst_number_max_length]

      check :Routing_tag_mode_id
      select routing_tag_mode.name, from: :routing_tag_mode_id

      check :Reject_calls
      select :No, from: :reject_calls

      check :Quality_alarm
      select :Yes, from: :quality_alarm

      check :Rateplan_id
      select rateplan.name, from: :rateplan_id

      check :Valid_from
      fill_in :valid_from, with: changes[:valid_from]

      check :Valid_till
      fill_in :valid_till, with: changes[:valid_till]

      check :Rate_policy_id
      select rate_policy.name, from: :rate_policy_id

      check :Initial_interval
      fill_in :initial_interval, with: changes[:initial_interval]

      check :Initial_rate
      fill_in :initial_rate, with: changes[:initial_rate]

      check :Next_interval
      fill_in :next_interval, with: changes[:next_interval]

      check :Next_rate
      fill_in :next_rate, with: changes[:next_rate]

      check :Use_dp_intervals
      select :No, from: :use_dp_intervals

      check :Connect_fee
      fill_in :connect_fee, with: changes[:connect_fee]

      check :Profit_control_mode_id
      select profit_control_mode.name, from: :profit_control_mode_id

      check :Dp_margin_fixed
      fill_in :dp_margin_fixed, with: changes[:dp_margin_fixed]

      check :Dp_margin_percent
      fill_in :dp_margin_percent, with: changes[:dp_margin_percent]

      check :Asr_limit
      fill_in :asr_limit, with: changes[:asr_limit]

      check :Acd_limit
      fill_in :acd_limit, with: changes[:acd_limit]

      check :Short_calls_limit
      fill_in :short_calls_limit, with: changes[:short_calls_limit]

      expect do
        subject
        expect(page).to have_selector '.flash', text: success_message
      end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Routing::Destination', be_present, changes, be_present
    end
  end
end
