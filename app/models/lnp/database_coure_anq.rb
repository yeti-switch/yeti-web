# frozen_string_literal: true

# == Schema Information
#
# Table name: class4.lnp_databases_coure_anq
#
#  id            :integer          not null, primary key
#  database_id   :integer
#  base_url      :string           not null
#  timeout       :integer          default(300), not null
#  username      :string           not null
#  password      :string           not null
#  country_code  :string           not null
#  operators_map :string
#

class Lnp::DatabaseCoureAnq < Yeti::ActiveRecord
  self.table_name = 'class4.lnp_databases_coure_anq'

  # ~ Sample
  # ~ http://anqtestapi.nms.com.ng/api/json/LookUpNumber/GsmPortStatus?username=xxxxxx@anq.com&password=xxcf
  # ~ c&ServiceType=4&numbersToLookUp=08075597646&country=234

  has_one :lnp_database, as: :database, class_name: 'Lnp::Database'

  validates :base_url, :username, :password, :country_code, presence: true
  validates :timeout, allow_nil: true, numericality: {
    greater_than: 0,
    less_than_or_equal_to: PG_MAX_SMALLINT,
    only_integer: true
  }
end
