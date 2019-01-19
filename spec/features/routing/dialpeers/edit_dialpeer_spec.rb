# frozen_string_literal: true

require 'spec_helper'

describe 'Create new Dialpeer', type: :feature do
  include_context :login_as_admin

  context 'unset "Tag action value"' do
    include_examples :test_unset_routing_tag_ids,
                     controller_name: :dialpeers,
                     factory: :dialpeer
  end
end
