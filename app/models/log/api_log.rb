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

class Log::ApiLog < ApplicationRecord
  self.table_name = 'logs.api_requests'
  self.primary_key = :id

  include Partitionable
  self.pg_partition_name = 'PgPartition::Yeti'
  self.pg_partition_interval_type = PgPartition::INTERVAL_DAY
  self.pg_partition_depth_past = 3
  self.pg_partition_depth_future = 3

  scope :failed, -> { where('status >= ?', 400) }

  def display_name
    id.to_s
  end
end
