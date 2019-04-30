# frozen_string_literal: true

require 'spec_helper'
require 'rspec_api_documentation/dsl'

resource 'Routing TagAction' do
  include_context :acceptance_admin_user

  let(:collection) { Routing::TagAction.all }
  let(:record) { Routing::TagAction.take  }

  include_context :acceptance_index_show, namespace: 'routing',
                                          type: 'tag-actions',
                                          resource: Api::Rest::Admin::Routing::TagActionResource
end
