# frozen_string_literal: true

# == Schema Information
#
# Table name: sortings
#
#  id                :integer          not null, primary key
#  name              :string
#  description       :string
#  use_static_routes :boolean          default(FALSE), not null
#

class Sorting < ActiveRecord::Base
  scope :with_static_routes, -> { where(use_static_routes: true) }
end
