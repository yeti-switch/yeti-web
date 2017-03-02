# == Schema Information
#
# Table name: reports.cdr_interval_report_aggrerator
#
#  id   :integer          not null, primary key
#  name :string           not null
#

class Report::IntervalAggregator < Cdr::Base
  self.table_name='reports.cdr_interval_report_aggrerator'



end
