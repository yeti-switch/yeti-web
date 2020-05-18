# frozen_string_literal: true

require 'spec_helper'

describe 'Index Incoming Registrations', type: :feature do
  include_context :login_as_admin

  let!(:node) { FactoryBot.create(:node) }
  let(:record_attributes) { FactoryBot.attributes_for(:incoming_registration, :filled) }
  before do
    stub_jrpc_request('show.aors', node.rpc_endpoint).and_return([record_attributes.stringify_keys])
    allow(Node).to receive(:all).and_return([node])
    visit incoming_registrations_path
  end

  it 'has record' do
    expect(page).to have_css('.col-path', text: record_attributes[:path])
    expect(page).to_not have_css('flash-warning')
    expect(page).to_not have_css('flash-error')
  end
end
