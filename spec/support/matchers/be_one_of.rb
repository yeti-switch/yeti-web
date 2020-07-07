# frozen_string_literal: true

RSpec::Matchers.define :be_one_of do |*choices|
  match do |actual|
    choices.include?(actual)
  end
  description do
    "be one of #{choices.map(&:inspect).join(', ')}"
  end
end
