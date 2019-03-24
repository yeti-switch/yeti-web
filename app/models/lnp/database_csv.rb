# frozen_string_literal: true

# == Schema Information
#
# Table name: class4.lnp_databases_csv
#
#  id            :integer          not null, primary key
#  csv_file_path :string
#

class Lnp::DatabaseCsv < Yeti::ActiveRecord
  self.table_name = 'class4.lnp_databases_csv'

  has_one :lnp_database, as: :database, class_name: 'Lnp::Database'
end
