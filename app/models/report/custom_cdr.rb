# frozen_string_literal: true

# == Schema Information
#
# Table name: reports.cdr_custom_report
#
#  id          :integer(4)       not null, primary key
#  completed   :boolean          default(FALSE), not null
#  date_end    :datetime
#  date_start  :datetime
#  filter      :string
#  group_by    :string           is an Array
#  send_to     :integer(4)       is an Array
#  created_at  :datetime
#  customer_id :integer(4)
#
# Indexes
#
#  cdr_custom_report_id_idx  (id) UNIQUE WHERE (id IS NOT NULL)
#

class Report::CustomCdr < Cdr::Base
  self.table_name = 'reports.cdr_custom_report'

  # *NOTE* Creation from user input should be performed only through CustomCdrReportForm
  # *NOTE* Creation from business logic should be performed only through CustomCdrReport::Create

  belongs_to :customer, class_name: 'Contractor', foreign_key: :customer_id, optional: true

  validates :group_by, :date_start, :date_end, presence: true

  include GroupReportTools
  setup_report_with(Report::CustomData)

  def display_name
    id.to_s
  end

  def group_by_arr
    @group_by_arr ||= group_by.map(&:to_sym)
  end
end
