require 'spec_helper'

describe 'Edit Destination', type: :feature do
  include_context :login_as_admin

  context 'unset "Tag action value"' do
    include_examples :test_unset_routing_tag_ids,
                      controller_name: :destinations,
                      factory: :destination

  end

end
