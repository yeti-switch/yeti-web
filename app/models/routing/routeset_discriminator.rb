# frozen_string_literal: true

# == Schema Information
#
# Table name: class4.routeset_discriminators
#
#  id   :integer          not null, primary key
#  name :string           not null
#

class Routing::RoutesetDiscriminator < Yeti::ActiveRecord
  self.table_name = 'class4.routeset_discriminators'

  has_many :dialpeers, class_name: 'Diapeer', foreign_key: :routeset_discriminator_id

  has_paper_trail class_name: 'AuditLogItem'

  validates_presence_of :name
  validates_uniqueness_of :name, allow_blank: false

  def display_name
    "#{name} | #{id}"
  end
end
