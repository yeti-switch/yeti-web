# frozen_string_literal: true

require 'shared_examples/shared_examples_for_importing_job'

RSpec.describe 'Importing::RoutingTagDetectionRule => Routing Tag Detection Rule delayed_job' do
  it_behaves_like 'Jobs for importing data' do
    include_context :init_importing_delayed_job do
      include_context :init_importing_routing_tag_detection_rule
      let(:preview_class) { Importing::RoutingTagDetectionRule }
    end
  end
end
