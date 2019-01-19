# frozen_string_literal: true

# == Schema Information
#
# Table name: billing.cdr_batches
#
#  id         :integer          not null, primary key
#  created_at :datetime         not null
#  size       :integer          not null
#  raw_data   :text
#

class Billing::CdrBatch < Yeti::ActiveRecord
  self.table_name = 'billing.cdr_batches'
end
