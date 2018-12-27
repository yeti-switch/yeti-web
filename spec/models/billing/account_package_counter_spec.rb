require 'spec_helper'

describe Billing::AccountPackageCounter, type: :model do
  let(:account) { create(:account) }

  subject do
    described_class.new(account_id: account.id)
  end

  it { is_expected.to validate_presence_of(:account_id) }
  it { is_expected.to validate_uniqueness_of(:prefix).scoped_to(:account_id) }
end
