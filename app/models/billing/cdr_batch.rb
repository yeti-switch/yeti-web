# frozen_string_literal: true

# == Schema Information
#
# Table name: billing.cdr_batches
#
#  id         :bigint(8)        not null, primary key
#  raw_data   :text
#  size       :integer(4)       not null
#  created_at :datetime         not null
#

class Billing::CdrBatch < ApplicationRecord
  self.table_name = 'billing.cdr_batches'
end
