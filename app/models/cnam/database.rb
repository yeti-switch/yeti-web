# frozen_string_literal: true

# == Schema Information
#
# Table name: class4.cnam_databases
#
#  id                 :integer(2)       not null, primary key
#  database_type      :string           not null
#  drop_call_on_error :boolean          default(FALSE), not null
#  name               :string           not null
#  request_lua        :string
#  response_lua       :string
#  created_at         :timestamptz
#  database_id        :integer(2)       not null
#
# Indexes
#
#  cnam_databases_name_key  (name) UNIQUE
#
class Cnam::Database < ApplicationRecord
  self.table_name = 'class4.cnam_databases'

  module CONST
    TYPE_NAME_HTTP = 'Http'
    TYPE_HTTP = 'Cnam::DatabaseHttp'
    TYPES = {
      TYPE_HTTP => TYPE_NAME_HTTP
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
      d = fetch_sp("select lrn, tag from #{ApplicationRecord::ROUTING_SCHEMA}.cnam_resolve(?::smallint,?::json)",
                   id,
                   destination)[0]
      OpenStruct.new(d)
    end
  end
end
