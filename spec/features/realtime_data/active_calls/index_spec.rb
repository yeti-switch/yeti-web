# frozen_string_literal: true

RSpec.describe 'Active Calls Index', js: true do
  subject do
    stub_jrpc_show_calls!
    visit active_calls_path(visit_params)
    filter_records!
  end

  include_context :login_as_admin
  include_context :stub_parallel_map

  let(:visit_params) { nil }
  let(:stub_jrpc_show_calls!) do
    stub_jrpc_request(node.rpc_endpoint, 'yeti.show.calls', []).and_return(
      calls_attributes.map(&:stringify_keys)
    )
  end

  let!(:node) { FactoryBot.create(:node) }

  context 'when filter by Node' do
    let(:filter_records!) do
      within_filters do
        fill_in_chosen 'Node', with: node.name
        click_submit('Filter')
      end
    end
    let(:calls_attributes) do
      [
        FactoryBot.attributes_for(:active_call, :filled, node_id: node.id),
        FactoryBot.attributes_for(:active_call, :filled, node_id: node.id)
      ]
    end

    before { FactoryBot.create(:node) }

    it 'renders table' do
      subject
      expect(page).to have_page_title('Active Calls')
      expect(page).to have_field_chosen('Node', with: node.id)
      expect(page).to have_table_row(count: 2)
      expect(page).to have_table_cell column: 'duration', text: calls_attributes.first[:duration].to_i
      expect(page).to have_table_cell column: 'duration', text: calls_attributes.second[:duration].to_i
    end
  end

  context 'when filter by Customer' do
    let(:filter_records!) do
      within_filters do
        fill_in_chosen 'Customer', with: customer.name, ajax: true
        click_submit('Filter')
      end
    end
    let(:calls_attributes) do
      [
        FactoryBot.attributes_for(:active_call, :filled, node_id: node.id, customer_id: customer.id),
        FactoryBot.attributes_for(:active_call, :filled, node_id: node.id, customer_id: another_customer.id)
      ]
    end

    let!(:customer) { create(:customer) }
    let!(:another_customer) { create(:customer) }

    it 'renders table' do
      subject
      expect(page).to have_page_title('Active Calls')
      expect(page).to have_field_chosen('Customer', with: customer.id)
      expect(page).to have_table_row(count: 1)
      expect(page).to have_table_cell column: 'customer', text: customer.id
    end
  end

  context 'when filter by Vendor Account' do
    let(:filter_records!) do
      within_filters do
        fill_in_chosen 'Vendor Account', with: account.name, ajax: true
        click_submit('Filter')
      end
    end
    let(:calls_attributes) do
      [
        FactoryBot.attributes_for(:active_call, :filled, vendor_acc_id: account.id),
        FactoryBot.attributes_for(:active_call, :filled, vendor_acc_id: another_account.id)
      ]
    end

    let!(:account) { create(:account) }
    let!(:another_account) { create(:account) }

    it 'renders filtered results' do
      subject
      expect(page).to have_page_title('Active Calls')
      expect(page).to have_field_chosen('Vendor Account', with: account.id)
      expect(page).to have_table_row(count: 1)
      expect(page).to have_table_cell column: 'duration', text: calls_attributes.first[:duration].to_i
    end
  end

  context 'when filter by Customer Account' do
    let(:filter_records!) do
      within_filters do
        fill_in_chosen 'Customer Account', with: account.name, ajax: true
        click_submit('Filter')
      end
    end
    let(:calls_attributes) do
      [
        FactoryBot.attributes_for(:active_call, :filled, customer_acc_id: account.id),
        FactoryBot.attributes_for(:active_call, :filled, customer_acc_id: another_account.id)
      ]
    end

    let!(:account) { create(:account) }
    let!(:another_account) { create(:account) }

    it 'renders filtered results' do
      subject
      expect(page).to have_page_title('Active Calls')
      expect(page).to have_field_chosen('Customer Account', with: account.id)
      expect(page).to have_table_row(count: 1)
      expect(page).to have_table_cell column: 'duration', text: calls_attributes.first[:duration].to_i
    end
  end

  context 'without filters' do
    let(:visit_params) { {} }
    let(:stub_jrpc_show_calls!) { nil }
    let(:filter_records!) { nil }

    it 'renders no table' do
      subject
      expect(page).to have_page_title('Active Calls')
      expect(page).to have_selector('.blank_slate', text: 'Please, specify at least 1 filter')
      expect(page).to_not have_flash_message(type: :error)
      expect(page).to_not have_flash_message(type: :warning)
      expect(page).to_not have_table
    end
  end
end
