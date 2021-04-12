# frozen_string_literal: true

RSpec.describe 'Active Calls Index', js: true do
  subject do
    stub_jrpc_show_calls!
    visit active_calls_path(visit_params)
  end

  include_context :login_as_admin
  include_context :stub_parallel_map

  let(:visit_params) do
    { q: { node_id_eq: node.id } }
  end
  let(:stub_jrpc_show_calls!) do
    stub_jrpc_request(node.rpc_endpoint, 'yeti.show.calls', []).and_return(
      calls_attributes.map(&:stringify_keys)
    )
  end

  let!(:node) { FactoryBot.create(:node) }
  let(:calls_attributes) do
    [
      FactoryBot.attributes_for(:active_call, :filled, node_id: node.id),
      FactoryBot.attributes_for(:active_call, :filled, node_id: node.id)
    ]
  end

  context 'with filter by node id' do
    before do
      # should be have jrpc requests
      FactoryBot.create(:node)
    end

    it 'renders table' do
      subject
      expect(page).to have_page_title('Active Calls')
      expect(page).to have_table_row(count: 2)
      expect(page).to have_table_cell column: 'Duration', text: calls_attributes.first[:duration].to_i
      expect(page).to have_table_cell column: 'Duration', text: calls_attributes.second[:duration].to_i
      expect(page).to_not have_flash_message(type: :error)
      expect(page).to_not have_flash_message(type: :warning)
    end
  end

  context 'with filter by Customer' do
    let(:visit_params) do
      { q: { customer_id_eq: customer.id } }
    end
    let!(:customer) { create(:customer) }
    let!(:another_customer) { create(:customer) }
    let(:calls_attributes) do
      [
        FactoryBot.attributes_for(:active_call, :filled, node_id: node.id, customer_id: customer.id),
        FactoryBot.attributes_for(:active_call, :filled, node_id: node.id, customer_id: another_customer.id)
      ]
    end

    it 'renders table' do
      subject
      expect(page).to have_page_title('Active Calls')
      expect(page).to have_table_row(count: 1)
      expect(page).to have_table_cell column: 'Customer', text: customer.id
      expect(page).to_not have_flash_message(type: :error)
      expect(page).to_not have_flash_message(type: :warning)
    end
  end

  context 'without filters' do
    let(:visit_params) { {} }
    let(:stub_jrpc_show_calls!) { nil }

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
