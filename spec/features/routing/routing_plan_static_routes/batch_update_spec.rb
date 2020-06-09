# frozen_string_literal: true

RSpec.describe BatchUpdateForm::RoutingPlanStaticRoute, :js do
  include_context :login_as_admin
  let!(:_static_routes) { create_list :static_route, 3 }
  let(:success_message) { I18n.t 'flash.actions.batch_actions.batch_update.job_scheduled' }
  let!(:vendor) { create :vendor }
  let!(:routing_plan) { create :routing_plan, :with_static_routes }
  let(:pg_max_smallint) { Yeti::ActiveRecord::PG_MAX_SMALLINT }
  before do
    visit static_routes_path
    click_button 'Update batch'
  end

  subject { click_button :OK }

  context 'should check validates for the field:' do
    context '"routing_plan_id"' do
      let(:changes) { { routing_plan_id: routing_plan.id.to_s } }
      it 'should change value lonely' do
        check :Routing_plan_id
        select routing_plan.name, from: :routing_plan_id
        expect do
          subject
          expect(page).to have_selector '.flash', text: success_message
        end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Routing::RoutingPlanStaticRoute', be_present, changes, be_present
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

        it 'must be greater than zero' do
          fill_in :priority, with: 0
          click_button :OK
          expect(page).to have_selector '.flash', text: 'must be greater than 0'
        end

        it 'must be less or equal to' do
          fill_in :priority, with: pg_max_smallint + 1
          click_button :OK
          expect(page).to have_selector('.flash', text: "must be less than or equal to #{pg_max_smallint}")
        end

        it 'must be an integer' do
          fill_in :priority, with: 1.5
          click_button :OK
          expect(page).to have_selector '.flash', text: 'must be an integer'
        end
      end

      context 'should have success' do
        let(:changes) { { priority: '5' } }
        it 'change value lonely' do
          fill_in :priority, with: changes[:priority]
          expect do
            subject
            expect(page).to have_selector '.flash', text: success_message
          end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Routing::RoutingPlanStaticRoute', be_present, changes, be_present
        end
      end
    end

    context '"weight"' do
      before { check :Weight }
      context 'should have error:' do
        it "can't be blank and is not a number" do
          fill_in :weight, with: nil
          click_button :OK
          expect(page).to have_selector '.flash', text: "can't be blank"
          expect(page).to have_selector '.flash', text: 'is not a number'
        end

        it 'must be greater than zero' do
          fill_in :weight, with: 0
          click_button :OK
          expect(page).to have_selector '.flash', text: 'must be greater than 0'
        end

        it 'must be less or equal to' do
          fill_in :weight, with: pg_max_smallint + 1
          click_button :OK
          expect(page).to have_selector('.flash', text: "must be less than or equal to #{pg_max_smallint}")
        end

        it 'must be an integer' do
          fill_in :weight, with: 1.5
          click_button :OK
          expect(page).to have_selector '.flash', text: 'must be an integer'
        end
      end

      context 'should have success' do
        let(:changes) { { weight: '5' } }
        it 'change value lonely' do
          fill_in :weight, with: changes[:weight]
          expect do
            subject
            expect(page).to have_selector '.flash', text: success_message
          end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Routing::RoutingPlanStaticRoute', be_present, changes, be_present
        end
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
          end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Routing::RoutingPlanStaticRoute', be_present, changes, be_present
        end
      end
    end

    context '"vendor_id"' do
      let(:changes) { { vendor_id: vendor.id.to_s } }
      it 'should change value lonely' do
        check :Vendor_id
        select vendor.name, from: :vendor_id
        expect do
          subject
          expect(page).to have_selector '.flash', text: success_message
        end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Routing::RoutingPlanStaticRoute', be_present, changes, be_present
      end
    end

    it 'all fields should have success' do
      changes = {
        routing_plan_id: routing_plan.id.to_s,
        prefix: '_test',
        priority: '12',
        weight: '123',
        vendor_id: vendor.id.to_s
      }
      check :Routing_plan_id
      select routing_plan.name, from: :routing_plan_id

      check :Prefix
      fill_in :prefix, with: changes[:prefix]

      check :Priority
      fill_in :priority, with: changes[:priority]

      check :Weight
      fill_in :weight, with: changes[:weight]

      check :Vendor_id
      select vendor.name, from: :vendor_id

      expect do
        subject
        expect(page).to have_selector '.flash', text: success_message
      end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Routing::RoutingPlanStaticRoute', be_present, changes, be_present
    end
  end
end
