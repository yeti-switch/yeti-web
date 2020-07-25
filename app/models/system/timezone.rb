# frozen_string_literal: true

# == Schema Information
#
# Table name: sys.timezones
#
#  id         :integer(4)       not null, primary key
#  abbrev     :string
#  is_dst     :boolean
#  name       :string           not null
#  utc_offset :interval
#
# Indexes
#
#  timezones_name_key  (name) UNIQUE
#

class System::Timezone < Yeti::ActiveRecord
  self.table_name = 'sys.timezones'

  def display_name
    "#{name} | #{abbrev} | #{utc_offset}"
  end
end
