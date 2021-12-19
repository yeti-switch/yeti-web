# frozen_string_literal: true

# == Schema Information
#
# Table name: class4.lnp_databases
#
#  id                                                                                   :integer(2)       not null, primary key
#  cache_ttl                                                                            :integer(4)       default(10800), not null
#  database_type(One of Lnp::DatabaseThinq, Lnp::DatabaseSipRedirect, Lnp::DatabaseCsv) :string
#  name                                                                                 :string           not null
#  created_at                                                                           :datetime
#  database_id                                                                          :integer(2)       not null
#
# Indexes
#
#  index_class4.lnp_databases_on_database_id_and_database_type  (database_id,database_type) UNIQUE
#  lnp_databases_name_key                                       (name) UNIQUE
#

class Lnp::Database < ApplicationRecord
  self.table_name = 'class4.lnp_databases'

  module CONST
    TYPE_NAME_THINQ = 'ThinQ'
    TYPE_NAME_SIP_REDIRECT = 'SIP 301/302 redirect'
    TYPE_NAME_CSV = 'CSV'
    TYPE_NAME_ALCAZAR = 'Alcazar REST API'
    TYPE_NAME_COURE_ANQ = 'Coure ANQ REST API'
    TYPE_THINQ = 'Lnp::DatabaseThinq'
    TYPE_SIP_REDIRECT = 'Lnp::DatabaseSipRedirect'
    TYPE_CSV = 'Lnp::DatabaseCsv'
    TYPE_ALCAZAR = 'Lnp::DatabaseAlcazar'
    TYPE_COURE_ANQ = 'Lnp::DatabaseCoureAnq'
    TYPES = {
      TYPE_THINQ => TYPE_NAME_THINQ,
      TYPE_SIP_REDIRECT => TYPE_NAME_SIP_REDIRECT,
      TYPE_CSV => TYPE_NAME_CSV,
      TYPE_ALCAZAR => TYPE_NAME_ALCAZAR,
      TYPE_COURE_ANQ => TYPE_NAME_COURE_ANQ
    }.freeze

    freeze
  end

  belongs_to :database, polymorphic: true, dependent: :delete
  accepts_nested_attributes_for :database

  # fix accepts_nested_attributes_for for polymorphic association
  def build_database(attrs = {})
    attributes = attrs.symbolize_keys
    klass = attributes[:type].safe_constantize
    raise ArgumentError, 'wrong type for database association' if klass.nil?

    self.database = klass.new attributes.except(:type)
  end

  # fix accepts_nested_attributes_for for polymorphic association
  def database_attributes=(attrs)
    # :id is excluded because we doesn't support replacing polymorphic association on update.
    attributes = attrs.symbolize_keys.except(:id)
    if new_record?
      build_database(attrs)
    else
      database.assign_attributes attributes.except(:type)
    end
  end

  validates :database, presence: true
  validates :cache_ttl, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: PG_MAX_INT, allow_nil: false, only_integer: true }
  validates :name, presence: true, uniqueness: true
  validates :database_id, uniqueness: { scope: :database_type }

  # we don't allow to replace database on update
  attr_readonly :database_id, :database_type

  def display_name
    "#{name} | #{id}"
  end

  def database_type_name
    CONST::TYPES[database_type]
  end

  def test_db(destination)
    transaction do
      fetch_sp_val("select * from #{ApplicationRecord::ROUTING_SCHEMA}.init(0,0)") # loading configuration
      d = fetch_sp("select lrn, tag from #{ApplicationRecord::ROUTING_SCHEMA}.lnp_resolve_tagged(?::smallint,?::varchar)",
                   id,
                   destination)[0]
      OpenStruct.new(d)
    end
  end
end
