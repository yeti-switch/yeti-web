# frozen_string_literal: true

# == Schema Information
#
# Table name: sys.smtp_connections
#
#  id            :integer          not null, primary key
#  name          :string           not null
#  host          :string           not null
#  port          :integer          default(25), not null
#  from_address  :string           not null
#  auth_user     :string
#  auth_password :string
#  global        :boolean          default(TRUE), not null
#

class System::SmtpConnection < Yeti::ActiveRecord
  self.table_name = 'sys.smtp_connections'

  has_paper_trail class_name: 'AuditLogItem'

  has_many :contractors, dependent: :restrict_with_error

  validates_presence_of :name, :host, :port, :from_address
  validates_format_of :from_address, with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
  validates_uniqueness_of :name

  def display_name
    name.to_s
  end

  def delivery_options
    {
      user_name: auth_user,
      password: auth_password,
      address: host,
      port: port
    }.reject { |_, v| v.blank? }
  end

  def from
    from_address
  end

  def self.global
    where(global: true).take
  end
end
