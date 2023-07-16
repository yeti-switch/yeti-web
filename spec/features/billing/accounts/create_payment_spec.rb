# frozen_string_literal: true

RSpec.describe 'Account details Create Payment', type: :feature, js: true do
  subject do
    visit account_path(account.id)
    fill_in_form!
    submit_form!
  end

  include_context :login_as_admin

  let!(:account) { create(:account) }

  let(:submit_form!) do
    within_panel('Create Payment') do
      click_button 'Create Payment'
    end
  end
  let(:fill_in_form!) do
    within_panel('Create Payment') do
      fill_in 'Amount', with: '200.50'
      fill_in 'Notes', with: 'Some notes'
    end
  end

  it 'creates new payment successfully' do
    expect {
      subject
      expect(page).to have_flash_message('Payment created!', type: :notice)
    }.to change { Payment.count }.by(1)
                                 .and change { account.reload.balance }.by(200.50)

    expect(page).to have_current_path account_path(account.id)
    payment = Payment.last!
    expect(payment).to have_attributes(
                         status_id: Payment::CONST::STATUS_ID_COMPLETED,
                         account: account,
                         amount: 200.50,
                         notes: 'Some notes',
                         private_notes: nil
                       )
  end

  context 'without Amount' do
    let(:fill_in_form!) do
      within_panel('Create Payment') do
        fill_in 'Notes', with: 'Some notes'
      end
    end

    it 'does not create payment' do
      expect {
        subject
        expect(page).to have_flash_message("Payment creation failed: Amount can't be blank", type: :error)
      }.to change { Payment.count }.by(0)
                                   .and change { account.reload.balance }.by(0)

      expect(page).to have_current_path account_path(account.id)
    end
  end

  context 'with Amount 0' do
    let(:fill_in_form!) do
      within_panel('Create Payment') do
        fill_in 'Amount', with: 0
        fill_in 'Notes', with: 'Some notes'
      end
    end

    it 'does not create payment' do
      expect {
        subject
        expect(page).to have_flash_message('Payment creation failed: Amount must be other than 0', type: :error)
      }.to change { Payment.count }.by(0)
                                   .and change { account.reload.balance }.by(0)

      expect(page).to have_current_path account_path(account.id)
    end
  end
end
