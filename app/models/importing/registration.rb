# == Schema Information
#
# Table name: data_import.import_registrations
#
#  id               :integer          not null, primary key
#  o_id             :integer
#  name             :string
#  enabled          :boolean
#  pop_name         :string
#  pop_id           :integer
#  node_name        :string
#  node_id          :integer
#  domain           :string
#  username         :string
#  display_username :string
#  auth_user        :string
#  proxy            :string
#  contact          :string
#  auth_password    :string
#  expire           :integer
#  force_expire     :boolean
#  error_string     :string
#

class Importing::Registration < Importing::Base
  self.table_name = 'data_import.import_registrations'
  attr_accessor :file

  belongs_to :pop, class_name: '::Pop'
  belongs_to :node, class_name: '::Node'

  self.import_attributes = ['name', 'enabled',
                            'pop_id', 'node_id', 'domain',
                            'username', 'display_username',
                            'auth_user', 'auth_password', 'proxy', 'contact',
                            'expire', 'force_expire', 'retry_delay', 'max_attempts'
  ]

  self.import_class = ::Equipment::Registration

end
