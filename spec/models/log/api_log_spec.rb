# frozen_string_literal: true

# == Schema Information
#
# Table name: logs.api_requests
#
#  id               :bigint(8)        not null, primary key
#  action           :string
#  controller       :string
#  db_duration      :float
#  method           :string
#  page_duration    :float
#  params           :text
#  path             :string
#  request_body     :text
#  request_headers  :text
#  response_body    :text
#  response_headers :text
#  status           :integer(4)
#  created_at       :datetime         not null
#
# Indexes
#
#  api_requests_created_at_idx  (created_at)
#  api_requests_id_idx          (id)
#

RSpec.describe Log::ApiLog do
  describe '.create' do
    subject do
      FactoryBot.create(:api_log)
    end

    it 'creates api_log' do
      expect { subject }.to change { described_class.count }.by(1)
      expect(subject).to be_persisted
      expect(subject.errors).to be_empty
    end
  end
end
