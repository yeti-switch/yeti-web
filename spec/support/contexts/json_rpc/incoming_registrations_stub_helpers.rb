# frozen_string_literal: true

RSpec.shared_context :incoming_registrations_stub_helpers do
  let(:stub_incoming_registrations_collection) do
    expect_any_instance_of(Node).to receive(:incoming_registrations)
      .once
      .with(stub_incoming_registrations_collection_query)
      .and_return(incoming_registrations_collection.map(&:stringify_keys))
  end
  let(:stub_incoming_registrations_collection_query) do
    { auth_id: nil, empty_on_error: false }
  end

  let(:incoming_registrations_collection_qty) { 2 }
  let(:incoming_registrations_collection) do
    FactoryGirl.attributes_for_list(:incoming_registration, incoming_registrations_collection_qty, *incoming_registration_attrs)
  end
  let(:incoming_registration_attrs) { [:filled] }
end
