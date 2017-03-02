# == Schema Information
#
# Table name: api_requests
#
#  id               :integer          not null, primary key
#  created_at       :datetime         not null
#  path             :string
#  method           :string
#  status           :integer
#  controller       :string
#  action           :string
#  page_duration    :float
#  db_duration      :float
#  params           :text
#  request_body     :text
#  response_body    :text
#  request_headers  :text
#  response_headers :text
#

class Log::ApiLog < ActiveRecord::Base
  self.table_name = 'api_requests'
  scope :failed, ->{ where('status >= ?', 400)  }

  def display_name
    self.id.to_s
  end
end
