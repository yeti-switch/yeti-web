# frozen_string_literal: true

RSpec.describe 'Active Calls show' do
  let(:visit_show_page!) { visit active_call_path(record_id) }

  include_context :login_as_admin

  let!(:node) { create(:node) }
  let(:active_call_attributes) { FactoryBot.attributes_for(:active_call, :filled, node_id: node.id) }
  let(:active_call_attributes_second) { FactoryBot.attributes_for(:active_call, :filled, node_id: node.id) }
  let(:record_id) { "#{node.id}*#{active_call_attributes[:local_tag]}" }

  before do
    stub_jrpc_request(node.rpc_endpoint, 'yeti.show.calls', [active_call_attributes[:local_tag]])
      .and_return([active_call_attributes.stringify_keys, active_call_attributes_second.stringify_keys])
  end

  it 'renders show page when API returns an array for a attributes' do
    visit_show_page!

    expect(page).to have_http_status :ok
  end
end
