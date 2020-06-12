# frozen_string_literal: true

# == Schema Information
#
# Table name: class4.lnp_databases_30x_redirect
#
#  id      :integer          not null, primary key
#  host    :string           not null
#  port    :integer
#  timeout :integer          default(300), not null
#

RSpec.describe Lnp::DatabaseSipRedirect, type: :model do
  it 'validates correctly' do
    is_expected.to validate_numericality_of(:timeout).is_less_than_or_equal_to(Yeti::ActiveRecord::PG_MAX_SMALLINT)
    is_expected.to validate_presence_of(:host)
  end
end
