# frozen_string_literal: true

RSpec.describe Log::ApiLog do
  describe '.create' do
    subject do
      FactoryGirl.create(:api_log)
    end

    it 'creates api_log' do
      expect { subject }.to change { described_class.count }.by(1)
      expect(subject).to be_persisted
      expect(subject.errors).to be_empty
    end
  end
end
