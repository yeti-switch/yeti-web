# frozen_string_literal: true

# == Schema Information
#
# Table name: class4.lnp_databases_thinq
#
#  id         :integer(2)       not null, primary key
#  host       :string           not null
#  plain_http :boolean          default(FALSE), not null
#  port       :integer(4)
#  timeout    :integer(2)       default(300), not null
#  token      :string
#  username   :string
#

RSpec.describe Lnp::DatabaseThinq, type: :model do
  it 'validates correctly' do
    is_expected.to validate_numericality_of(:timeout).is_less_than_or_equal_to(ApplicationRecord::PG_MAX_SMALLINT)
    is_expected.to validate_presence_of(:host)
  end
end
