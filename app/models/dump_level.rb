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

class DumpLevel < ActiveRecord::Base
  self.table_name = 'dump_level'
end
