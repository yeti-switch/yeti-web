# frozen_string_literal: true

RSpec.describe 'Active Calls Batch actions', js: true do
  subject do
    visit active_calls_path(visit_params)
    select_records!
    click_batch_action!
  end

  include_context :login_as_admin
  include_context :stub_parallel_map

  let!(:node) { FactoryBot.create(:node) }
  let(:visit_params) do
    { q: { node_id_eq: node.id } }
  end
  let(:select_records!) do
    table_select_all
  end
  let(:click_batch_action!) { nil }
  let!(:jrpc_connection_stub) do
    stub_jrpc_connect(node.rpc_endpoint)
  end
  let!(:stub_jrpc_show_calls!) do
    stub_jrpc_request(jrpc_connection_stub, 'yeti.show.calls', []).ordered.and_return(
      calls_attributes.map(&:stringify_keys)
    )
  end
  let(:calls_attributes) do
    Array.new(10) do
      FactoryBot.attributes_for(:active_call, :filled, node_id: node.id)
    end
  end

  before do
    FactoryBot.create(:node)
  end

  context 'Terminate Selected' do
    let(:click_batch_action!) do
      click_batch_action('Terminate Selected')
      confirm_modal_dialog
    end
    let(:calls_to_disconnect) { calls_attributes }
    let!(:stub_disconnect_calls) do
      calls_to_disconnect.each do |attrs|
        local_tag = attrs[:local_tag]
        stub_jrpc_request(jrpc_connection_stub, 'yeti.request.call.disconnect', [local_tag]).ordered.and_return(nil)
      end
    end

    before do
      # stub jrpc show calls after disconnect to render index page
      stub_jrpc_request(jrpc_connection_stub, 'yeti.show.calls', []).ordered.and_return([])
    end

    it 'terminates selected active calls' do
      subject
      expect(page).to have_flash_message('Terminated!', type: :notice)
    end

    context 'when select only 2 calls' do
      let(:select_records!) do
        [
          "#{node.id}*#{calls_attributes.first[:local_tag]}",
          "#{node.id}*#{calls_attributes.last[:local_tag]}"
        ].each do |id|
          within_table_row(id: id) { page.find('.resource_selection_cell').click }
        end
      end
      let(:calls_to_disconnect) do
        [calls_attributes.first, calls_attributes.last]
      end

      it 'terminates selected active calls' do
        subject
        expect(page).to have_flash_message('Terminated!', type: :notice)
      end
    end
  end
end
