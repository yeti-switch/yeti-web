# frozen_string_literal: true

RSpec.describe 'Index Payments', type: :feature, js: true do
  subject do
    visit payments_path
    filter_records!
  end

  include_context :login_as_admin
  let(:filter_records!) { nil }
  let!(:payments) do
    [
      create(:payment),
      create(:payment, :pending),
      create(:payment, :canceled)
    ]
  end

  it 'displays correct table' do
    subject
    expect(page).to have_table_row(count: payments.count)
    payments.each do |payment|
      within_table_row(id: payment.id) do
        expect(page).to have_table_cell(column: 'ID', exact_text: payment.id.to_s)
        expect(page).to have_table_cell(column: 'Account', exact_text: payment.account.display_name)
        expect(page).to have_table_cell(column: 'Type', exact_text: payment.type_name.upcase)
        expect(page).to have_table_cell(column: 'Status', exact_text: payment.status.upcase)
      end
    end
  end

  context 'with filter by Account' do
    let!(:account) { FactoryBot.create(:account) }
    let!(:filtered_payments) { create_list(:payment, 2, account:) }
    let(:filter_records!) do
      within_filters do
        fill_in_chosen 'Account', with: account.display_name, exact: true, ajax: true
      end
      click_on 'Filter'
    end

    before do
      another_account = FactoryBot.create(:account, :filled)
      create(:payment, account: another_account)
    end

    it 'displays filtered records' do
      subject

      expect(page).to have_table_row(count: filtered_payments.size)
      filtered_payments.each do |payment|
        within_table_row(id: payment.id) do
          expect(page).to have_table_cell(column: 'ID', exact_text: payment.id.to_s)
          expect(page).to have_table_cell(column: 'Account', exact_text: account.display_name)
        end
      end

      within_filters do
        expect(page).to have_field_chosen('Account', with: account.display_name)
      end
    end
  end

  context 'with filter by Status' do
    let(:filtered_payments) { [payments[1]] }
    let(:filter_records!) do
      within_filters do
        fill_in_chosen 'Status', with: 'pending'
      end
      click_on 'Filter'
    end

    it 'displays filtered records' do
      subject

      expect(page).to have_table_row(count: filtered_payments.size)
      filtered_payments.each do |payment|
        within_table_row(id: payment.id) do
          expect(page).to have_table_cell(column: 'ID', exact_text: payment.id.to_s)
          expect(page).to have_table_cell(column: 'Status', exact_text: 'PENDING')
        end
      end

      within_filters do
        expect(page).to have_field_chosen('Status', with: 'pending')
      end
    end
  end

  context 'with filter by Type' do
    let(:filtered_payments) { [payments[0]] }
    let(:filter_records!) do
      within_filters do
        fill_in_chosen 'Type', with: 'manual'
      end
      click_on 'Filter'
    end

    it 'displays filtered records' do
      subject

      expect(page).to have_table_row(count: filtered_payments.size)
      filtered_payments.each do |payment|
        within_table_row(id: payment.id) do
          expect(page).to have_table_cell(column: 'ID', exact_text: payment.id.to_s)
          expect(page).to have_table_cell(column: 'Type', exact_text: 'MANUAL')
        end
      end

      within_filters do
        expect(page).to have_field_chosen('Type', with: 'manual')
      end
    end
  end
end
