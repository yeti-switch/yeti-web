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

require 'spec_helper'

describe Lnp::DatabaseCoureAnq, type: :model do
  it 'validates correctly' do
    is_expected.to validate_numericality_of(:timeout).is_less_than_or_equal_to(Yeti::ActiveRecord::PG_MAX_SMALLINT)
    is_expected.to validate_presence_of(:base_url)
    is_expected.to validate_presence_of(:username)
    is_expected.to validate_presence_of(:password)
    is_expected.to validate_presence_of(:country_code)
  end
end
