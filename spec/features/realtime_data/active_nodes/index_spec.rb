# frozen_string_literal: true

RSpec.describe 'Active Calls Index', js: true do
  subject do
    visit realtime_data_active_nodes_path(visit_params)
  end

  include_context :login_as_admin

  let(:visit_params) { nil }
  let!(:nodes) { FactoryBot.create_list(:node, 2) }
  let!(:stub_jrpc_show_calls!) do
    stub_jrpc_request(nodes.first.rpc_endpoint, 'yeti.show.system.status', []).and_return(
      node_1_status
    )
    stub_jrpc_request(nodes.second.rpc_endpoint, 'yeti.show.system.status', []).and_return(
      node_2_status
    )
  end
  let(:node_1_status) do
    {
      count: 1,
      version: '0.0.1',
      shutdown_request_time: nil,
      sessions: 3,
      uptime: 600
    }
  end
  let(:node_2_status) do
    {
      count: 0,
      version: '0.0.2',
      shutdown_request_time: Time.now,
      sessions: 0,
      uptime: 1
    }
  end

  context 'when all nodes are up' do
    it 'renders table' do
      subject
      expect(page).to have_page_title('Active Nodes')
      expect(page).to have_table_row(count: 2)
      expect(page).to have_table_cell(column: 'Name', text: nodes.first.name, exact: true)
      expect(page).to have_table_cell(column: 'Name', text: nodes.second.name, exact: true)
    end

    include_examples :does_not_capture_error do
      let(:does_not_capture_error_subject) do
        subject
        expect(page).to have_page_title('Active Nodes')
      end
    end
  end

  context 'when one of nodes is down' do
    let!(:nodes) { FactoryBot.create_list(:node, 3) }
    let!(:stub_jrpc_show_calls!) do
      super()
      stub_jrpc_connect_error(nodes.third.rpc_endpoint)
    end

    it 'renders table' do
      subject
      expect(page).to have_page_title('Active Nodes')
      expect(page).to have_table_row(count: 3)
      expect(page).to have_table_cell(column: 'Name', text: nodes.first.name, exact: true)
      expect(page).to have_table_cell(column: 'Name', text: nodes.second.name, exact: true)
      expect(page).to have_table_cell(column: 'Name', text: nodes.third.name, exact: true)
    end

    include_examples :does_not_capture_error do
      let(:does_not_capture_error_subject) do
        subject
        expect(page).to have_page_title('Active Nodes')
      end
    end
  end

  context 'when all nodes are down' do
    let!(:stub_jrpc_show_calls!) do
      stub_jrpc_connect_error(nodes.first.rpc_endpoint)
      stub_jrpc_connect_error(nodes.second.rpc_endpoint)
    end

    it 'renders table' do
      subject
      expect(page).to have_page_title('Active Nodes')
      expect(page).to have_table_row(count: 2)
      expect(page).to have_table_cell(column: 'Name', text: nodes.first.name, exact: true)
      expect(page).to have_table_cell(column: 'Name', text: nodes.second.name, exact: true)
    end

    include_examples :does_not_capture_error do
      let(:does_not_capture_error_subject) do
        subject
        expect(page).to have_page_title('Active Nodes')
      end
    end
  end
end
