# frozen_string_literal: true

RSpec.describe 'Create new Payment', type: :feature, js: true do
  subject do
    visit new_payment_path
    fill_in_form!
    submit_form!
  end

  include_context :login_as_admin

  let!(:account) { create(:account) }

  let(:submit_form!) do
    click_button 'Create Payment'
  end
  let(:fill_in_form!) do
    fill_in_chosen('Account', with: account.display_name, ajax: true)
    fill_in 'Amount', with: 100_500
    fill_in 'Notes', with: 'Some notes'
    fill_in 'Private notes', with: 'Some private notes'
  end

  it 'creates new payment successfully' do
    expect {
      subject
      expect(page).to have_flash_message('Payment was successfully created.', type: :notice)
    }.to change { Payment.count }.by(1)
                                 .and change { account.reload.balance }.by(100_500)

    payment = Payment.last!
    expect(page).to have_current_path payment_path(payment.id)
    expect(payment).to have_attributes(
      status_id: Payment::CONST::STATUS_ID_COMPLETED,
      account: account,
      amount: 100_500,
      notes: 'Some notes',
      private_notes: 'Some private notes'
    )
  end

  context 'without Amount' do
    let(:fill_in_form!) do
      fill_in_chosen('Account', with: account.display_name, ajax: true)
      fill_in 'Notes', with: 'Some notes'
      fill_in 'Private notes', with: 'Some private notes'
    end

    it 'does not create payment' do
      expect {
        subject
        expect(page).to have_semantic_error_texts("Amount can't be blank")
      }.to change { Payment.count }.by(0)
                                   .and change { account.reload.balance }.by(0)

      expect(page).to have_current_path payments_path
      expect(page).to have_field_chosen('Account', with: account.display_name)
    end
  end

  context 'with Amount 0' do
    let(:fill_in_form!) do
      fill_in_chosen('Account', with: account.display_name, ajax: true)
      fill_in 'Amount', with: 0
      fill_in 'Notes', with: 'Some notes'
      fill_in 'Private notes', with: 'Some private notes'
    end

    it 'does not create payment' do
      expect {
        subject
        expect(page).to have_semantic_error_texts('Amount must be other than 0')
      }.to change { Payment.count }.by(0)
                                   .and change { account.reload.balance }.by(0)

      expect(page).to have_current_path payments_path
      expect(page).to have_field_chosen('Account', with: account.display_name)
    end
  end
end
