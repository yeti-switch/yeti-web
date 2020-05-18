# frozen_string_literal: true

# == Schema Information
#
# Table name: api_requests
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

FactoryBot.define do
  factory :api_log, class: Log::ApiLog do
    path { '/api/rest/qweasd' }
    add_attribute(:method) { 'GET' }
    status { 204 }
    controller { 'QweAsdController' }
    action { 'index' }
    page_duration { 0 }
    db_duration { 0 }
    params { nil }
    request_body { nil }
    response_body { nil }
    request_headers { nil }
    response_headers { nil }

    before(:create) do |record, _evaluator|
      Log::ApiLog.add_partition_for(record.created_at || Time.now.utc)
    end
  end
end
