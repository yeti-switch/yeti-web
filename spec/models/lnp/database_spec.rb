require 'spec_helper'

describe Lnp::Database, type: :model do
  it do
    should validate_numericality_of(:timeout).is_less_than_or_equal_to(Yeti::ActiveRecord::PG_MAX_SMALLINT)
  end
end
