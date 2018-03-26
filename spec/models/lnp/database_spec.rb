# == Schema Information
#
# Table name: class4.lnp_databases
#
#  id             :integer          not null, primary key
#  name           :string           not null
#  host           :string           not null
#  port           :integer
#  driver_id      :integer          not null
#  created_at     :datetime
#  thinq_token    :string
#  thinq_username :string
#  timeout        :integer          default(300), not null
#  csv_file       :string
#

require 'spec_helper'

describe Lnp::Database, type: :model do
  it do
    should validate_numericality_of(:timeout).is_less_than_or_equal_to(Yeti::ActiveRecord::PG_MAX_SMALLINT)
  end
end
