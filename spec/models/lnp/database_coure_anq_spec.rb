# frozen_string_literal: true

# == Schema Information
#
# Table name: class4.lnp_databases_coure_anq
#
#  id            :integer(2)       not null, primary key
#  base_url      :string           not null
#  country_code  :string           not null
#  operators_map :string
#  password      :string           not null
#  timeout       :integer(2)       default(300), not null
#  username      :string           not null
#

RSpec.describe Lnp::DatabaseCoureAnq, type: :model do
  it 'validates correctly' do
    is_expected.to validate_numericality_of(:timeout).is_less_than_or_equal_to(ApplicationRecord::PG_MAX_SMALLINT)
    is_expected.to validate_presence_of(:base_url)
    is_expected.to validate_presence_of(:username)
    is_expected.to validate_presence_of(:password)
    is_expected.to validate_presence_of(:country_code)
  end
end
