# frozen_string_literal: true

require 'spec_helper'

describe Lnp::DatabaseAlcazar, type: :model do
  it 'validates correctly' do
    is_expected.to validate_numericality_of(:timeout).is_less_than_or_equal_to(Yeti::ActiveRecord::PG_MAX_SMALLINT)
    is_expected.to validate_presence_of(:base_url)
    is_expected.to validate_presence_of(:username)
    is_expected.to validate_presence_of(:password)
    is_expected.to validate_presence_of(:country_code)
  end
end
