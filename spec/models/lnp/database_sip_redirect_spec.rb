# frozen_string_literal: true

# == Schema Information
#
# Table name: class4.lnp_databases_30x_redirect
#
#  id        :integer(2)       not null, primary key
#  host      :string           not null
#  port      :integer(4)
#  timeout   :integer(2)       default(300), not null
#  format_id :integer(2)       default(1), not null
#
# Foreign Keys
#
#  lnp_databases_30x_redirect_format_id_fkey  (format_id => lnp_databases_30x_redirect_formats.id)
#

RSpec.describe Lnp::DatabaseSipRedirect, type: :model do
  it 'validates correctly' do
    is_expected.to validate_numericality_of(:timeout).is_less_than_or_equal_to(ApplicationRecord::PG_MAX_SMALLINT)
    is_expected.to validate_presence_of(:host)
  end
end
