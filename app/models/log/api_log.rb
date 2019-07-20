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

class Log::ApiLog < ActiveRecord::Base
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
