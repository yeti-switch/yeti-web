# frozen_string_literal: true

# == Schema Information
#
# Table name: sortings
#
#  id                :integer(4)       not null, primary key
#  description       :string
#  name              :string
#  use_static_routes :boolean          default(FALSE), not null
#

class Sorting < ActiveRecord::Base
  scope :with_static_routes, -> { where(use_static_routes: true) }
end
