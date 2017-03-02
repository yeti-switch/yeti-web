# == Schema Information
#
# Table name: admin_users
#
#  id                     :integer          not null, primary key
#  encrypted_password     :string(255)      default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0)
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  group                  :integer          default(0)
#  enabled                :boolean          default(TRUE)
#  username               :string           not null
#  ssh_key                :text
#  stateful_filters       :boolean          default(FALSE), not null
#  visible_columns        :json             default({}), not null
#  per_page               :json             default({}), not null
#  saved_filters          :json             default({}), not null
#

require 'test_helper'

class AdminUserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
