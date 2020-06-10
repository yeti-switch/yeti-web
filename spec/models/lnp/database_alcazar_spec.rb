# frozen_string_literal: true

# == Schema Information
#
# Table name: class4.lnp_databases_alcazar
#
#  id          :integer          not null, primary key
#  host        :string           not null
#  port        :integer
#  timeout     :integer          default(300), not null
#  key         :string           not null
#  database_id :integer
#

RSpec.describe Lnp::DatabaseAlcazar, type: :model do
  it 'validates correctly' do
    is_expected.to validate_numericality_of(:timeout).is_less_than_or_equal_to(Yeti::ActiveRecord::PG_MAX_SMALLINT)
    is_expected.to validate_presence_of(:host)
    is_expected.to validate_presence_of(:key)
  end
end
