# frozen_string_literal: true

RSpec.describe 'Index Customer Auths', type: :feature do
  subject do
    visit customers_auths_path(index_params)
    apply_filters!
  end

  include_context :login_as_admin

  let(:index_params) { {} }
  let(:apply_filters!) { nil }

  let!(:customer_auths) do
    create_list(:customers_auth, 2, :filled)
  end

  it 'shows correct table' do
    subject

    expect(page).to have_table_row count: customer_auths.size

    customer_auths.each do |customer_auth|
      within_table_row(id: customer_auth.id) do
        within_table_cell('ID') do
          expect(page).to have_link(
                            customer_auth.id.to_s,
                            exact: true,
                            href: customers_auth_path(customer_auth.id)
                          )
        end
      end
    end
  end

  context 'with filter by customer only', js: true do
    let(:apply_filters!) do
      within_filters do
        fill_in_tom_select 'Customer', with: customer.name, exact_label: true, ajax: true
      end
      click_submit('Filter')
    end

    let!(:customer) { create(:customer) }
    let!(:filtered_customer_auths) do
      create_list(:customers_auth, 2, :filled, customer: customer)
    end

    it 'shows only filtered rows' do
      subject

      expect(page).to have_table_row count: filtered_customer_auths.size
      filtered_customer_auths.each do |customer_auth|
        expect(page).to have_table_cell(column: 'ID', exact_text: customer_auth.id.to_s)
      end
    end
  end

  context 'with filter by customer and account', js: true do
    let(:apply_filters!) do
      within_filters do
        fill_in_tom_select 'Customer', with: customer.name, exact_label: true, ajax: true
        fill_in_tom_select 'Account', with: account.name, exact_label: true, ajax: true
      end
      click_submit('Filter')
    end

    let!(:customer) { create(:customer) }
    let!(:account) { create(:account, contractor: customer) }
    let!(:filtered_customer_auths) do
      create_list(:customers_auth, 2, :filled, customer: customer, account: account)
    end

    before do
      # ignored because belongs to another account
      create(:customers_auth, :filled, customer: customer)
    end

    it 'shows only filtered rows' do
      subject

      expect(page).to have_table_row count: filtered_customer_auths.size
      filtered_customer_auths.each do |customer_auth|
        expect(page).to have_table_cell(column: 'ID', exact_text: customer_auth.id.to_s)
      end
    end
  end

  context 'with filter by account only', js: true do
    let(:apply_filters!) do
      within_filters do
        fill_in_tom_select 'Account', with: account.name, exact_label: true, ajax: true
      end
      click_submit('Filter')
    end

    let!(:customer) { create(:customer) }
    let!(:account) { create(:account, contractor: customer) }
    let!(:filtered_customer_auths) do
      create_list(:customers_auth, 2, :filled, customer: customer, account: account)
    end

    before do
      # ignored because belongs to another account
      create(:customers_auth, :filled, customer: customer)
    end

    it 'shows only filtered rows' do
      subject

      expect(page).to have_table_row count: filtered_customer_auths.size
      filtered_customer_auths.each do |customer_auth|
        expect(page).to have_table_cell(column: 'ID', exact_text: customer_auth.id.to_s)
      end
    end
  end

  context 'with filter by customer and gateway', js: true do
    let(:apply_filters!) do
      within_filters do
        fill_in_tom_select 'Customer', with: customer.name, exact_label: true, ajax: true
        fill_in_tom_select 'Gateway', with: gateway.name, exact_label: true, ajax: true
      end
      click_submit('Filter')
    end

    let!(:customer) { create(:customer) }
    let!(:gateway) { create(:gateway, :with_incoming_auth, contractor: customer) }
    let!(:filtered_customer_auths) do
      create_list(:customers_auth, 2, :filled, customer: customer, gateway: gateway)
    end

    before do
      # ignored because belongs to another gateway
      create(:customers_auth, :filled, customer: customer)
    end

    it 'shows only filtered rows' do
      subject

      expect(page).to have_table_row count: filtered_customer_auths.size
      filtered_customer_auths.each do |customer_auth|
        expect(page).to have_table_cell(column: 'ID', exact_text: customer_auth.id.to_s)
      end
    end
  end

  context 'with filter by contractors gateway', js: true do
    let(:apply_filters!) do
      within_filters do
        fill_in_tom_select 'Gateway', with: gateway.name, exact_label: true, ajax: true
      end
      click_submit('Filter')
    end

    let!(:customer) { create(:customer) }
    let!(:gateway) { create(:gateway, :with_incoming_auth, contractor: customer) }
    let!(:filtered_customer_auths) do
      create_list(:customers_auth, 2, :filled, customer: customer, gateway: gateway)
    end

    before do
      # ignored because belongs to another gateway
      create(:customers_auth, :filled, customer: customer)
    end

    it 'shows only filtered rows' do
      subject

      expect(page).to have_table_row count: filtered_customer_auths.size
      filtered_customer_auths.each do |customer_auth|
        expect(page).to have_table_cell(column: 'ID', exact_text: customer_auth.id.to_s)
      end
    end
  end

  context 'with filter by shared gateway', js: true do
    let(:apply_filters!) do
      within_filters do
        fill_in_tom_select 'Gateway', with: gateway.name, exact_label: true, ajax: true
      end
      click_submit('Filter')
    end

    let!(:customer) { create(:customer) }
    let!(:another_customer) { create(:customer) }
    let!(:gateway) { create(:gateway, :with_incoming_auth, is_shared: true) }
    let!(:filtered_customer_auths) do
      [
        create(:customers_auth, :filled, customer: customer, gateway: gateway),
        create(:customers_auth, :filled, customer: another_customer, gateway: gateway)
      ]
    end

    before do
      # ignored because belongs to another gateway
      create(:customers_auth, :filled, customer: customer)
    end

    it 'shows only filtered rows' do
      subject

      expect(page).to have_table_row count: filtered_customer_auths.size
      filtered_customer_auths.each do |customer_auth|
        expect(page).to have_table_cell(column: 'ID', exact_text: customer_auth.id.to_s)
      end
    end
  end
end
