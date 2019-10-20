# frozen_string_literal: true

RSpec.shared_examples :raises_exception do |klass, msg = nil|
  it "raises <#{klass}>: #{msg}" do
    expect { subject }.to raise_error(klass, msg)
  end
end
