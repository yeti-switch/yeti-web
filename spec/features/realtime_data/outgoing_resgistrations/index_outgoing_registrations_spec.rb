# frozen_string_literal: true

require 'spec_helper'

describe 'Index Outgoing Registrations', type: :feature do
  include_context :login_as_admin

  let!(:node) { FactoryBot.create(:node) }
  let(:record_attributes) { FactoryBot.attributes_for(:outgoing_registration, :filled) }
  before do
    stub_jrpc_request('show.registrations', node.rpc_endpoint).and_return([record_attributes.stringify_keys])
    visit outgoing_registrations_path(q: { node_id_eq: node.id })
  end

  it 'has record' do
    expect(page).to have_css('.col-id', text: record_attributes[:id])
    expect(page).to_not have_css('flash-warning')
    expect(page).to_not have_css('flash-error')
  end
end
