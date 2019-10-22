# frozen_string_literal: true

# == Schema Information
#
# Table name: logs.api_requests
#
#  id               :integer          not null, primary key
#  created_at       :datetime         not null
#  path             :string
#  method           :string
#  status           :integer
#  controller       :string
#  action           :string
#  page_duration    :float
#  db_duration      :float
#  params           :text
#  request_body     :text
#  response_body    :text
#  request_headers  :text
#  response_headers :text
#

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
