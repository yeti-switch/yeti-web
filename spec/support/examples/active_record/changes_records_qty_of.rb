# frozen_string_literal: true

RSpec.shared_examples :changes_records_qty_of do |klass, by:|
  it "changes records qty of #{klass} by #{by}" do
    expect { subject }.to change { klass.count }.by(by)
  end
end
