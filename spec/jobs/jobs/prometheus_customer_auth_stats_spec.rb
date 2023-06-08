# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Jobs::PrometheusCustomerAuthStats do
  subject do
    job.call
  end

  let(:job) { described_class.new(double) }

  pending 'TODO'
end
