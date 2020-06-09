# frozen_string_literal: true

RSpec.describe BatchUpdateForm::Gateway, :js do
  include_context :login_as_admin
  let!(:_gateways) { create_list :gateway, 3 }
  let(:pg_max_smallint) { Yeti::ActiveRecord::PG_MAX_SMALLINT }
  let(:success_message) { I18n.t 'flash.actions.batch_actions.batch_update.job_scheduled' }
  before do
    visit gateways_path
    click_button 'Update batch'
  end

  subject { click_button :OK }

  context 'check validates for field:' do
    context '"enabled"' do
      let(:changes) { { enabled: false } }
      it 'should change lonely' do
        check :Enabled
        select :No, from: :enabled
        expect do
          subject
          expect(page).to have_selector '.flash', text: success_message
        end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Gateway', be_present, changes, be_present
      end
    end

    context '"priority"' do
      before { check :Priority }
      context 'should have error:' do
        it "can't be blank and is not a number" do
          fill_in :priority, with: nil
          click_button :OK
          expect(page).to have_selector '.flash', text: "can't be blank"
          expect(page).to have_selector '.flash', text: 'is not a number'
        end

        it 'must be an integer' do
          fill_in :priority, with: 'string'
          click_button :OK
          expect(page).to have_selector '.flash', text: 'is not a number'
        end

        it 'must be greater than 0' do
          fill_in :priority, with: 0
          click_button :OK
          expect(page).to have_selector '.flash', text: 'must be greater than 0'
        end

        it 'must be less than or equal to' do
          fill_in :priority, with: pg_max_smallint + 1
          click_button :OK
          expect(page).to have_selector '.flash', text: "must be less than or equal to #{pg_max_smallint}"
        end
      end

      context 'should have success' do
        let(:changes) { { priority: '1' } }
        it 'change value lonely' do
          fill_in :priority, with: changes[:priority]
          expect do
            subject
            expect(page).to have_selector '.flash', text: success_message
          end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Gateway', be_present, changes, be_present
        end
      end
    end

    context '"weight"' do
      before { check :Weight }
      context 'should have error:' do
        it "can't be blank and is not a number" do
          fill_in :weight, with: nil
          click_button :OK
          expect(page).to have_selector '.flash', text: 'is not a number'
          expect(page).to have_selector '.flash', text: "can't be blank"
        end

        it 'must be an integer' do
          fill_in :weight, with: 1.5
          click_button :OK
          expect(page).to have_selector '.flash', text: 'must be an integer'
        end

        it 'must be less than or equal to pg_max_smallint' do
          fill_in :weight, with: pg_max_smallint + 1
          click_button :OK
          expect(page).to have_selector '.flash', text: "must be less than or equal to #{pg_max_smallint}"
        end

        it 'must be greater than zero' do
          fill_in :weight, with: 0
          click_button :OK
          expect(page).to have_selector '.flash', text: 'must be greater than 0'
        end
      end

      context 'should have success' do
        let(:changes) { { weight: '5' } }
        it 'change value lonely' do
          fill_in :weight, with: changes[:weight]
          expect do
            subject
            expect(page).to have_selector '.flash', text: success_message
          end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Gateway', be_present, changes, be_present
        end
      end
    end

    context '"acd_limit"' do
      before { check :Acd_limit }
      context 'should have error:' do
        it "can't be blank is not a number" do
          fill_in :acd_limit, with: nil
          click_button :OK
          expect(page).to have_selector '.flash', text: 'is not a number'
          expect(page).to have_selector '.flash', text: "can't be blank"
        end

        it 'must be greater than or equal to zero' do
          fill_in :acd_limit, with: -1
          click_button :OK
          expect(page).to have_selector '.flash', text: 'must be greater than or equal to 0.0'
        end
      end

      context 'should have success' do
        let(:changes) { { acd_limit: '1' } }
        it 'change value lonely' do
          fill_in :acd_limit, with: changes[:acd_limit]
          expect do
            subject
            expect(page).to have_selector '.flash', text: success_message
          end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Gateway', be_present, changes, be_present
        end
      end
    end

    context '"asr_limit"' do
      before { check :Asr_limit }
      context 'should have error:' do
        it 'is not a number' do
          fill_in :asr_limit, with: nil
          click_button :OK
          expect(page).to have_selector '.flash', text: 'is not a number'
          expect(page).to have_selector '.flash', text: "can't be blank"
        end

        it 'less than or equal to 1.00' do
          fill_in :asr_limit, with: 1.5
          click_button :OK
          expect(page).to have_selector '.flash', text: 'less than or equal to 1.0'
        end

        it 'greater than or equal to 0.00' do
          fill_in :asr_limit, with: -1
          click_button :OK
          expect(page).to have_selector '.flash', text: 'greater than or equal to 0.0'
        end
      end

      context 'should have success' do
        let(:changes) { { asr_limit: '1' } }
        it 'change value lonely' do
          check :Asr_limit
          fill_in :asr_limit, with: changes[:asr_limit]
          expect do
            subject
            expect(page).to have_selector '.flash', text: success_message
          end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Gateway', be_present, changes, be_present
        end
      end
    end

    context '"short_calls_limit"' do
      before { check :Short_calls_limit }
      context 'should have error:' do
        it 'is nut a number' do
          fill_in :short_calls_limit, with: 'string'
          click_button :OK
          expect(page).to have_selector '.flash', text: 'is not a number'
        end

        it 'must be greater than or equal to 0.0' do
          fill_in :short_calls_limit, with: -1
          click_button :OK
          expect(page).to have_selector '.flash', text: 'must be greater than or equal to 0.0'
        end

        it 'must be less than or equal to 1.0' do
          fill_in :short_calls_limit, with: 1.5
          click_button :OK
          expect(page).to have_selector '.flash', text: 'must be less than or equal to 1.0'
        end
      end

      context 'should have success' do
        let(:changes) { { short_calls_limit: '1' } }
        it 'change value lonely' do
          fill_in :short_calls_limit, with: changes[:short_calls_limit]
          expect do
            subject
            expect(page).to have_selector '.flash', text: success_message
          end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Gateway', be_present, changes, be_present
        end
      end
    end

    context '"is_shared"' do
      let(:changes) { { is_shared: true } }
      it 'should change value lonely' do
        check :Is_shared
        select :Yes, from: :is_shared
        expect do
          subject
          expect(page).to have_selector '.flash', text: success_message
        end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Gateway', be_present, changes, be_present
      end
    end

    it 'all field should pass pass validations' do
      changes = {
        enabled: true,
        priority: '1',
        weight: '12',
        is_shared: false,
        acd_limit: '1',
        asr_limit: '1',
        short_calls_limit: '1'
      }
      check :Enabled
      select :Yes, from: :enabled

      check :Priority
      fill_in :priority, with: changes[:priority]

      check :Weight
      fill_in :weight, with: changes[:weight]

      check :Is_shared
      select :No, from: :is_shared

      check :Acd_limit
      fill_in :acd_limit, with: changes[:acd_limit]

      check :Asr_limit
      fill_in :asr_limit, with: changes[:asr_limit]

      check :Short_calls_limit
      fill_in :short_calls_limit, with: changes[:short_calls_limit]

      expect do
        subject
        expect(page).to have_selector '.flash', text: success_message
      end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Gateway', be_present, changes, be_present
    end
  end
end
