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

class Log::ApiLog < ApplicationRecord
  self.table_name = 'logs.api_requests'
  self.primary_key = :id

  include Partitionable
  self.pg_partition_name = 'PgPartition::Yeti'
  self.pg_partition_interval_type = PgPartition::INTERVAL_DAY
  self.pg_partition_depth_past = 3
  self.pg_partition_depth_future = 3

  scope :failed, -> { where('status >= ?', 400) }
  scope :tag_eq, ->(value) { where.any(tags: value) }
  scope :remote_ip_eq_inet, lambda { |value|
    begin
      remote_ip = IPAddr.new(value).to_s
      remote_ip ? where(remote_ip:) : none
    rescue IPAddr::InvalidAddressError => _e
      none
    end
  }

  def display_name
    id.to_s
  end

  def self.ransackable_scopes(_auth_object = nil)
    %i[remote_ip_eq_inet tag_eq]
  end
end
