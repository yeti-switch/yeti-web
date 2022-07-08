# == Schema Information
#
# Table name: class4.cnam_databases_http
#
#  id      :integer(2)       not null, primary key
#  timeout :integer(2)       default(5), not null
#  url     :string           not null
#
class Cnam::DatabaseHttp < ApplicationRecord
  self.table_name = 'class4.cnam_databases_http'

  has_one :cnam_database, as: :database, class_name: 'Cnam::Database'

  validates :url, presence: true
  validates :timeout, allow_nil: true, numericality: {
    greater_than: 0,
    less_than_or_equal_to: PG_MAX_SMALLINT,
    only_integer: true
  }
end
