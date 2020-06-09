# frozen_string_literal: true

RSpec.describe BatchUpdateForm::Contractor, :js do
  include_context :login_as_admin
  let!(:_contractors) { create_list :vendor, 3 }
  let!(:contractor_with_customers_auth) { create :customer }
  let!(:customers_auth) { create :customers_auth, customer: contractor_with_customers_auth }
  let(:success_message) { I18n.t 'flash.actions.batch_actions.batch_update.job_scheduled' }
  let!(:smtp) { create :smtp_connection }
  before do
    visit contractors_path
    click_button 'Update batch'
  end

  subject { click_button :OK }

  context 'should check validations for the field:' do
    context '"enabled"' do
      let(:changes) { { enabled: true } }
      it 'should change value lonely' do
        check :Enabled
        select :Yes, from: :enabled
        expect do
          subject
          expect(page).to have_selector '.flash', text: success_message
        end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Contractor', be_present, changes, be_present
      end
    end

    context '"vendor" should have error:' do
      it 'must be changed together' do
        check :Vendor
        select :Yes, from: :vendor
        click_button :OK
        expect(page).to have_selector '.flash', text: 'must be changed together'
      end
    end

    context '"customer"' do
      context 'should have error:' do
        it 'must be changed together' do
          check :Customer
          select :Yes, from: :customer
          click_button :OK
          expect(page).to have_selector '.flash', text: 'must be changed together'
        end

        it "Can't be disabled when contractor used at Customer auth" do
          # preparing
          # closing popup to select one contractor
          click_button :Cancel
          check "batch_action_item_#{contractor_with_customers_auth.id}"
          # open popup
          click_button 'Update batch'
          check :Vendor
          select :Yes, from: :vendor

          check :Customer
          select :No, from: :customer
          click_button :OK
          expect(page).to have_selector '.flash', text: "can't be disabled when contractor used at Customer auth"
        end
      end

      context 'should have success' do
        before do
          customers_auth.destroy
          contractor_with_customers_auth.destroy
        end
        let(:changes) { { vendor: true, customer: false } }
        it 'select boolean field "Customer" into No' do
          # preparing
          check :Vendor
          select :Yes, from: :vendor

          check :Customer
          select :No, from: :customer
          expect do
            subject
            expect(page).to have_selector '.flash', text: success_message
          end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Contractor', be_present, changes, be_present
        end
      end
    end

    context 'vendor or customer validation:' do
      let(:changes) { { vendor: false, customer: true } }
      it 'pass, because Customer selected' do
        check :Vendor
        select :No, from: :vendor
        check :Customer
        select :Yes, from: :customer
        expect do
          subject
          expect(page).to have_selector '.flash', text: success_message
        end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Contractor', be_present, changes, be_present
      end

      it 'failed, because both selected Yes' do
        check :Vendor
        select :Yes, from: :vendor
        check :Customer
        select :Yes, from: :customer
        click_button :OK

        expect(page).to have_selector '.flash', text: 'Contractor must be customer or vendor'
      end

      it 'failed, because both selected No' do
        check :Vendor
        select :No, from: :vendor
        check :Customer
        select :No, from: :customer
        click_button :OK

        expect(page).to have_selector '.flash', text: 'Contractor must be customer or vendor'
      end
    end

    context '"description"' do
      let(:changes) { { description: 'text' } }
      it 'should change value lonely' do
        check :Description
        fill_in :description, with: changes[:description]
        expect do
          subject
          expect(page).to have_selector '.flash', text: success_message
        end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Contractor', be_present, changes, be_present
      end
    end

    context '"address"' do
      let(:changes) { { address: 'address' } }
      it 'should change value lonely' do
        check :Address
        fill_in :address, with: changes[:address]
        expect do
          subject
          expect(page).to have_selector '.flash', text: success_message
        end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Contractor', be_present, changes, be_present
      end
    end

    context '"phones"' do
      let(:changes) { { phones: '+380978850011' } }
      it 'should change value lonely' do
        check :Phones
        fill_in :phones, with: changes[:phones]
        expect do
          subject
          expect(page).to have_selector '.flash', text: success_message
        end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Contractor', be_present, changes, be_present
      end
    end

    context '"smtp_connection_id"' do
      let(:changes) { { smtp_connection_id: smtp.id.to_s } }
      it 'should change value lonely' do
        check :Smtp_connection_id
        select smtp.name, from: :smtp_connection_id
        expect do
          subject
          expect(page).to have_selector '.flash', text: success_message
        end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Contractor', be_present, changes, be_present
      end
    end

    context 'all field' do
      let(:changes) {
        {
          enabled: false,
          vendor: false,
          customer: true,
          description: 'some text',
          address: 'address',
          phones: '+380978520001',
          smtp_connection_id: smtp.id.to_s
        }
      }
      it 'should pass all validations' do
        check :Enabled
        select :No, from: :enabled

        check :Vendor
        select :No, from: :vendor

        check :Customer
        select :Yes, from: :customer

        check :Description
        fill_in :description, with: changes[:description]

        check :Address
        fill_in :address, with: changes[:address]

        check :Phones
        fill_in :phones, with: changes[:phones]
        check :Smtp_connection_id

        select smtp.name, from: :smtp_connection_id
        expect do
          subject
          expect(page).to have_selector '.flash', text: success_message
        end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Contractor', be_present, changes, be_present
      end
    end
  end
end
