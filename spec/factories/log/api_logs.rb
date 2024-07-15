# frozen_string_literal: true

# == Schema Information
#
# Table name: logs.api_requests
#
#  id               :bigint(8)        not null, primary key
#  action           :string
#  controller       :string
#  db_duration      :float
#  meta             :jsonb
#  method           :string
#  page_duration    :float
#  params           :text
#  path             :string
#  remote_ip        :inet
#  request_body     :text
#  request_headers  :text
#  response_body    :text
#  response_headers :text
#  status           :integer(4)
#  tags             :string           default([]), is an Array
#  created_at       :timestamptz      not null
#
# Indexes
#
#  api_requests_created_at_idx  (created_at)
#  api_requests_id_idx          (id)
#

FactoryBot.define do
  factory :api_log, class: 'Log::ApiLog' do
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
    tags { [] }

    before(:create) do |record, _evaluator|
      Log::ApiLog.add_partition_for(record.created_at || Time.now.utc)
    end
  end
end
