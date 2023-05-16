# frozen_string_literal: true

# == Schema Information
#
# Table name: report_vendors
#
#  id         :integer(4)       not null, primary key
#  end_date   :timestamptz      not null
#  start_date :timestamptz      not null
#  created_at :timestamptz      not null
#

class ReportVendor < ApplicationRecord
end
