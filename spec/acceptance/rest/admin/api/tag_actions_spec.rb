# frozen_string_literal: true

require 'rspec_api_documentation/dsl'

RSpec.resource 'Routing TagAction' do
  include_context :acceptance_admin_user

  let(:collection) { Routing::TagAction.all }
  let(:record) { Routing::TagAction.take  }

  include_context :acceptance_index_show, type: 'tag-actions'
end
