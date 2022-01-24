# frozen_string_literal: true

# == Schema Information
#
# Table name: dump_level
#
#  id      :integer(4)       not null, primary key
#  log_rtp :boolean          default(FALSE), not null
#  log_sip :boolean          default(FALSE), not null
#  name    :string           not null
#
# Indexes
#
#  dump_level_name_key  (name) UNIQUE
#

class DumpLevel < ApplicationRecord
  self.table_name = 'dump_level'

  validates :name, presence: true, uniqueness: true
end
