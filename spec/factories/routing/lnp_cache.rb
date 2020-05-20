# frozen_string_literal: true

# == Schema Information
#
# Table name: class4.lnp_cache
#
#  id          :integer          not null, primary key
#  dst         :string           not null
#  lrn         :string           not null
#  created_at  :datetime
#  updated_at  :datetime
#  expires_at  :datetime
#  database_id :integer
#  data        :string
#  tag         :string
#

FactoryBot.define do
  factory :lnp_cache, class: Lnp::Cache do
    dst { 'dst' }
    lrn { 'lrn' }
  end
end
