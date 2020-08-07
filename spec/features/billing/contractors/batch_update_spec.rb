# frozen_string_literal: true

RSpec.describe BatchUpdateForm::Contractor, :js do
  include_context :login_as_admin
  let!(:_contractors) { FactoryBot.create_list :vendor, 3 }
  let!(:contractor_with_customers_auth) { FactoryBot.create :customer }
  let!(:customers_auth) { FactoryBot.create :customers_auth, customer: contractor_with_customers_auth }
  let(:success_message) { I18n.t 'flash.actions.batch_actions.batch_update.job_scheduled' }
  let!(:smtp) { FactoryBot.create :smtp_connection }

  before do
    visit contractors_path
    click_button 'Update batch'
    expect(page).to have_selector('.ui-dialog')
  end

  subject do
    fill_batch_form
    click_button 'OK'
  end

  let(:assign_params) do
    {
      enabled: false,
      vendor: false,
      customer: true,
      description: 'some text',
      address: 'address',
      phones: '+380978520001',
      smtp_connection_id: smtp.id.to_s
    }
  end

  let(:fill_batch_form) do
    if assign_params.key? :enabled
      check :Enabled
      select_by_value assign_params[:enabled], from: :enabled
    end

    if assign_params.key? :vendor
      check :Vendor
      select_by_value assign_params[:vendor], from: :vendor
    end

    if assign_params.key? :customer
      check :Customer
      select_by_value assign_params[:customer], from: :customer
    end

    if assign_params.key? :description
      check :Description
      fill_in :description, with: assign_params[:description]
    end

    if assign_params.key? :address
      check :Address
      fill_in :address, with: assign_params[:address]
    end

    if assign_params.key? :phones
      check :Phones
      fill_in :phones, with: assign_params[:phones]
    end

    if assign_params.key? :smtp_connection_id
      check :Smtp_connection_id
      select_by_value assign_params[:smtp_connection_id], from: :smtp_connection_id
    end
  end

  context 'check validations' do
    context 'when change :customer field from true to false' do
      let(:assign_params) { { vendor: true, customer: false } }

      it "should have error: can't be disabled when contractor used at customer auth" do
        subject
        expect(page).to have_selector '.flash', text: I18n.t('activerecord.errors.models.contractor.attributes.customer')
      end
    end

    context 'when all fields is filled with valid values' do
      it 'should pass validations with success message' do
        expect do
          subject
          expect(page).to have_selector '.flash', text: success_message
        end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Contractor', be_present, assign_params, be_present
      end
    end
  end
end
