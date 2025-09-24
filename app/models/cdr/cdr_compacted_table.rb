# frozen_string_literal: true

# == Schema Information
#
# Table name: sys.cdr_compacted_tables
#
#  id         :bigint(8)        not null, primary key
#  table_name :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_cdr_compacted_tables_on_table_name  (table_name) UNIQUE
#
module Cdr
  class CdrCompactedTable < Base
    self.table_name = 'sys.cdr_compacted_tables'

    validates :table_name, presence: true, uniqueness: true
  end
end
