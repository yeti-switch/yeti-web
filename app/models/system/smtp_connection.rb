# frozen_string_literal: true

# == Schema Information
#
# Table name: sys.smtp_connections
#
#  id            :integer(4)       not null, primary key
#  auth_password :string
#  auth_type     :string           default("plain"), not null
#  auth_user     :string
#  from_address  :string           not null
#  global        :boolean          default(TRUE), not null
#  host          :string           not null
#  name          :string           not null
#  port          :integer(4)       default(25), not null
#
# Indexes
#
#  smtp_connections_name_key  (name) UNIQUE
#

class System::SmtpConnection < Yeti::ActiveRecord
  self.table_name = 'sys.smtp_connections'

  module CONST
    AUTH_TYPES = %w[plain login cram_md5].freeze

    freeze
  end

  has_paper_trail class_name: 'AuditLogItem'

  has_many :contractors, dependent: :restrict_with_error

  validates :name, :host, :port, :from_address, presence: true
  validates :from_address, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i }
  validates :name, uniqueness: true
  validates :auth_type, inclusion: { in: CONST::AUTH_TYPES }

  def display_name
    name.to_s
  end

  def delivery_options
    {
      user_name: auth_user,
      password: auth_password,
      authentication: auth_type.to_sym,
      address: host,
      port: port
    }.reject { |_, v| v.blank? }
  end

  def from
    from_address
  end

  def self.global
    find_by(global: true)
  end
end
