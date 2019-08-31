# frozen_string_literal: true

# == Schema Information
#
# Table name: class4.lnp_cache
#
#  id             :integer          not null, primary key
#  dst            :string           not null
#  lrn            :string           not null
#  created_at     :datetime
#  updated_at     :datetime
#  expires_at     :datetime
#  database_id    :integer
#  data           :string
#  tag            :string
#  routing_tag_id :integer
#

class Lnp::Cache < Yeti::ActiveRecord
  self.table_name = 'class4.lnp_cache'

  belongs_to :database, class_name: 'Lnp::Database', foreign_key: :database_id
  belongs_to :routing_tag, class_name: 'Routing::RoutingTag', foreign_key: :routing_tag_id
end
