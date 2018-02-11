require 'spec_helper'

RSpec.describe Routing::RoutingTagDetectionRule, type: :model do

  context '#validations' do

    include_examples :test_model_with_tag_action

  end

end
