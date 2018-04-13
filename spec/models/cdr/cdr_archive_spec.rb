require 'spec_helper'

RSpec.describe Cdr::CdrArchive, type: :model do

  describe 'default ORDER BY' do
    subject { described_class.all.to_sql }

    it 'default ORDER is time_start DESC' do
      expect(subject).to end_with('ORDER BY time_start desc')
    end
  end
end
