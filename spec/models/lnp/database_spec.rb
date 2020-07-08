# frozen_string_literal: true

# == Schema Information
#
# Table name: class4.lnp_databases
#
#  id                                                                                   :integer(2)       not null, primary key
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

RSpec.describe Lnp::Database, type: :model do
  it 'validates correctly' do
    is_expected.to validate_presence_of(:name)
  end
end
