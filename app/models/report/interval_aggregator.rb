# frozen_string_literal: true

# == Schema Information
#
# Table name: reports.cdr_interval_report_aggregator
#
#  id   :integer(4)       not null, primary key
#  name :string           not null
#
# Indexes
#
#  cdr_interval_report_aggregator_name_key  (name) UNIQUE
#

class Report::IntervalAggregator < Cdr::Base
  self.table_name = 'reports.cdr_interval_report_aggregator'
end
