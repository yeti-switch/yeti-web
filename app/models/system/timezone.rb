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

class System::Timezone < ApplicationRecord
  self.table_name = 'sys.timezones'

  # Rails 7 will use ActiveSupport::Duration type for interval by default.
  attribute :utc_offset, :string

  validates :name, presence: true, uniqueness: true

  def display_name
    "#{name} | #{abbrev} | #{utc_offset}"
  end

  def time_zone
    ActiveSupport::TimeZone.new(name)
  end
end
