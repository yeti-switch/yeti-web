# frozen_string_literal: true

require 'rspec_api_documentation/dsl'

RSpec.resource 'Routing Area' do
  include_context :acceptance_admin_user

  let(:collection) { create_list(:area, 2) }
  let(:record) { collection.first }

  include_context :acceptance_index_show, namespace: 'routing', type: 'areas'
end
