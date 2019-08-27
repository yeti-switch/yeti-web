# frozen_string_literal: true

require 'spec_helper'

describe 'Index Active Calls', type: :feature do
  include_context :login_as_admin

  let!(:node) { FactoryGirl.create(:node) }
  let(:record_attributes) { FactoryGirl.attributes_for(:active_call, :filled) }
  before do
    stub_jrpc_request('show.calls', node.rpc_endpoint).and_return([record_attributes.stringify_keys])
    visit active_calls_path(q: { node_id_eq: node.id })
  end

  it 'has record' do
    expect(page).to have_css('.col-duration', text: record_attributes[:duration].to_i)
    expect(page).to_not have_css('flash-warning')
    expect(page).to_not have_css('flash-error')
  end
end
