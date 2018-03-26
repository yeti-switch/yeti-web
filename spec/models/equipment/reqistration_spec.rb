# == Schema Information
#
# Table name: registrations
#
#  id                          :integer          not null, primary key
#  name                        :string           not null
#  enabled                     :boolean          default(TRUE), not null
#  pop_id                      :integer
#  node_id                     :integer
#  domain                      :string
#  username                    :string           not null
#  display_username            :string
#  auth_user                   :string
#  proxy                       :string
#  contact                     :string
#  auth_password               :string
#  expire                      :integer
#  force_expire                :boolean          default(FALSE), not null
#  retry_delay                 :integer          default(5), not null
#  max_attempts                :integer
#  transport_protocol_id       :integer          default(1), not null
#  proxy_transport_protocol_id :integer          default(1), not null
#


require 'spec_helper'

describe Equipment::Registration, type: :model do
  it do
    should validate_numericality_of(:retry_delay).is_less_than_or_equal_to(Yeti::ActiveRecord::PG_MAX_SMALLINT)
    should validate_numericality_of(:max_attempts).is_less_than_or_equal_to(Yeti::ActiveRecord::PG_MAX_SMALLINT)
  end
end
