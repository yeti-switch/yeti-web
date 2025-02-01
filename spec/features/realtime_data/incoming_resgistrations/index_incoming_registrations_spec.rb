# frozen_string_literal: true

RSpec.describe 'Index Incoming Registrations', type: :feature do
  include_context :login_as_admin
  include_context :stub_parallel_map

  let!(:node) { FactoryBot.create(:node) }
  let(:record_attributes) { FactoryBot.attributes_for(:incoming_registration, :filled) }
  before do
    stub_jrpc_request(node.rpc_endpoint, 'registrar.show.aors', [])
      .and_return([record_attributes.stringify_keys])
    visit incoming_registrations_path
  end

  it 'has record' do
    expect(page).to have_css('.col-path', text: record_attributes[:path])
    expect(page).to_not have_css('flash-warning')
    expect(page).to_not have_css('flash-error')
  end
end
