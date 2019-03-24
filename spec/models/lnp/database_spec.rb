# frozen_string_literal: true

# == Schema Information
#
# Table name: class4.lnp_databases
#
#  id            :integer          not null, primary key
#  name          :string           not null
#  created_at    :datetime
#  database_type :string
#  database_id   :integer          not null
#

require 'spec_helper'

describe Lnp::Database, type: :model do
  it 'validates correctly' do
    is_expected.to validate_presence_of(:name)
  end
end
