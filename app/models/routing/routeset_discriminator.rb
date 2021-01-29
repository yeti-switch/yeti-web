# frozen_string_literal: true

# == Schema Information
#
# Table name: class4.routeset_discriminators
#
#  id   :integer(2)       not null, primary key
#  name :string           not null
#
# Indexes
#
#  routeset_discriminators_name_key  (name) UNIQUE
#

class Routing::RoutesetDiscriminator < Yeti::ActiveRecord
  self.table_name = 'class4.routeset_discriminators'

  has_many :dialpeers, class_name: 'Diapeer', foreign_key: :routeset_discriminator_id

  include WithPaperTrail

  validates :name, presence: true
  validates :name, uniqueness: { allow_blank: false }

  def display_name
    "#{name} | #{id}"
  end
end
