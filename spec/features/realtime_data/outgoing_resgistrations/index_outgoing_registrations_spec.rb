# frozen_string_literal: true

require 'spec_helper'

describe 'Index Outgoing Registrations', type: :feature do
  include_context :login_as_admin

  let!(:node) { FactoryBot.create(:node) }
  let!(:pop) { FactoryBot.create(:pop) }
  let(:record_attributes) do
    FactoryBot.attributes_for(:outgoing_registration, :filled, pop_id: pop.id, node_id: node.id)
  end
  before do
    stub_jrpc_request('show.registrations', node.rpc_endpoint).and_return([record_attributes.stringify_keys])
    visit outgoing_registrations_path(q: { node_id_eq: node.id })
  end

  it 'has record' do
    expect(page).to have_css('.col-id', text: record_attributes[:id])
    expect(page).to have_css('.col-pop a', text: pop.name)
    expect(page).to have_css('.col-node a', text: node.name)
    expect(page).to have_css('.col-last_reply_contacts', text: record_attributes[:last_reply_contacts])
    expect(page).to have_css('.col-last_request_contact', text: record_attributes[:last_request_contact])
    expect(page).to_not have_css('flash-warning')
    expect(page).to_not have_css('flash-error')
  end

  context 'when registration has no attributes' do
    let(:record_attributes) { { id: 123 } }

    it 'has record' do
      expect(page).to have_css('.col-id', text: record_attributes[:id])
      expect(page).to have_css('.col-pop', exact_text: '')
      expect(page).to have_css('.col-node', exact_text: '')
      expect(page).to have_css('.col-last_reply_contacts', exact_text: '')
      expect(page).to have_css('.col-last_request_contact', exact_text: '')
      expect(page).to_not have_css('flash-warning')
      expect(page).to_not have_css('flash-error')
    end
  end
end
