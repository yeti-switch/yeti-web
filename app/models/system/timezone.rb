# frozen_string_literal: true

# == Schema Information
#
# Table name: sys.timezones
#
#  id         :integer          not null, primary key
#  name       :string           not null
#  abbrev     :string
#  utc_offset :interval
#  is_dst     :boolean
#

class System::Timezone < Yeti::ActiveRecord
  self.table_name = 'sys.timezones'

  def display_name
    "#{name} | #{abbrev} | #{utc_offset}"
  end
end
