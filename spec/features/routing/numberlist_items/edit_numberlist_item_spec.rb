# frozen_string_literal: true

require 'spec_helper'

describe 'Edit Nunberlist Item', type: :feature do
  include_context :login_as_admin

  context 'unset "Tag action value"' do
    include_examples :test_unset_tag_action_value,
                     controller_name: :routing_numberlist_items,
                     factory: :numberlist_item
  end
end
