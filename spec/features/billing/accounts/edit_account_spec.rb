# frozen_string_literal: true

RSpec.describe 'Update Account', type: :feature, js: true do
  subject do
    visit edit_account_path(account.id)
    fill_form!
    click_submit('Update Account')
  end

  include_context :login_as_admin
  let!(:account) { create(:account, :filled, :vendor_weekly, account_attrs) }
  let(:account_attrs) { {} }

  context 'without changes' do
    let(:fill_form!) { nil }
    let!(:contact) { FactoryBot.create(:contact, contractor: account.contractor) }
    let(:account_attrs) do
      super().merge balance_low_threshold: 10,
                    balance_high_threshold: 20,
                    send_balance_notifications_to: [contact.id]
    end

    it 'does not update anything' do
      expect {
        subject
        expect(page).to have_flash_message('Account was successfully updated.', type: :notice)
      }.not_to change {
        account.reload
        [
          account.attributes.except('updated_at'),
          account.balance_notification_setting.attributes.except('updated_at')
        ]
      }
      expect(account.balance_notification_setting).to have_attributes(
                                                        low_threshold: 10,
                                                        high_threshold: 20,
                                                        send_to: [contact.id]
                                                      )
    end
  end

  context 'with name change' do
    let(:fill_form!) do
      fill_in 'Name', with: 'New acc name'
    end

    it 'updates account' do
      expect {
        subject
        expect(page).to have_flash_message('Account was successfully updated.', type: :notice)
      }.to change { Account.count }.by(0)

      expect(page).to have_current_path account_path(account.id)

      expect(account.reload).to have_attributes(
                                  name: 'New acc name'
                                )
    end
  end

  context 'with invoice ref templates change' do
    let(:fill_form!) do
      fill_in 'Customer invoice ref template', with: 'cust-$id'
      fill_in 'Vendor invoice ref template', with: 'vend-$id'
    end

    it 'updates account' do
      expect {
        subject
        expect(page).to have_flash_message('Account was successfully updated.', type: :notice)
      }.to change { Account.count }.by(0)

      expect(page).to have_current_path account_path(account.id)

      expect(account.reload).to have_attributes(
                                  customer_invoice_ref_template: 'cust-$id',
                                  vendor_invoice_ref_template: 'vend-$id'
                                )
    end
  end

  context 'when customer and vendor invoice period enable' do
    let(:fill_form!) do
      chosen_deselect_value 'Customer invoice period'
      chosen_deselect_value 'Vendor invoice period'
    end

    it 'updates account' do
      subject
      expect(page).to have_flash_message('Account was successfully updated.', type: :notice)
      expect(page).to have_current_path account_path(account.id)
      expect(account.reload).to have_attributes(
                                  customer_invoice_period: nil,
                                  vendor_invoice_period: nil
                                )
    end
  end

  context 'with balance_low_threshold < balance_high_threshold' do
    let(:fill_form!) do
      fill_in 'Balance low threshold', with: '90.01'
      fill_in 'Balance high threshold', with: '100.02'
    end

    it 'updates account' do
      expect {
        subject
        expect(page).to have_flash_message('Account was successfully updated.', type: :notice)
      }.to change { Account.count }.by(0)

      expect(page).to have_current_path account_path(account.id)

      account.reload
      expect(account.balance_notification_setting).to have_attributes(
                                                        low_threshold: 90.01.to_d,
                                                        high_threshold: 100.02.to_d
                                                      )
    end
  end

  context 'with send_balance_notifications_to' do
    let!(:contact) { FactoryBot.create(:contact, contractor: account.contractor) }
    let(:fill_form!) do
      fill_in_chosen 'Send balance notifications to', with: contact.email, multiple: true
    end

    it 'updates account' do
      expect {
        subject
        expect(page).to have_flash_message('Account was successfully updated.', type: :notice)
      }.to change { Account.count }.by(0)

      expect(page).to have_current_path account_path(account.id)

      account.reload
      expect(account.balance_notification_setting).to have_attributes(
                                                        send_to: [contact.id]
                                                      )
    end
  end

  context 'with balance_low_threshold = balance_high_threshold' do
    let(:fill_form!) do
      fill_in 'Balance low threshold', with: '90.01'
      fill_in 'Balance high threshold', with: '90.01'
    end

    it 'shows validation errors' do
      expect do
        subject
        expect(page).to have_semantic_error_texts(
                          'Balance low threshold must be less than Balance high threshold'
                        )
      end.not_to change { account.reload.attributes }
    end
  end

  context 'with balance_low_threshold > balance_high_threshold' do
    let(:fill_form!) do
      fill_in 'Balance low threshold', with: '91'
      fill_in 'Balance high threshold', with: '90'
    end

    it 'shows validation errors' do
      expect do
        subject
        expect(page).to have_semantic_error_texts(
                          'Balance low threshold must be less than Balance high threshold'
                        )
      end.not_to change { account.reload.attributes }
    end
  end
end
