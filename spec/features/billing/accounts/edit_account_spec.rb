# frozen_string_literal: true

RSpec.describe 'Update Account', type: :feature, js: true do
  subject do
    click_submit('Update Account')
  end

  include_context :login_as_admin
  let(:before_visit!) {}
  let!(:account) { create(:account, :filled) }
  before do
    before_visit!
    visit edit_account_path(account.id)
  end

  context 'with name change' do
    before do
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
    before do
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
end
