# frozen_string_literal: true

# == Schema Information
#
# Table name: class4.numberlist_actions
#
#  id   :integer          not null, primary key
#  name :string           not null
#

class Routing::NumberlistAction < Yeti::ActiveRecord
  self.table_name = 'class4.numberlist_actions'
end
