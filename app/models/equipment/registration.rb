# frozen_string_literal: true

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

class Equipment::Registration < Yeti::ActiveRecord
  belongs_to :transport_protocol, class_name: 'Equipment::TransportProtocol', foreign_key: :transport_protocol_id
  belongs_to :proxy_transport_protocol, class_name: 'Equipment::TransportProtocol', foreign_key: :proxy_transport_protocol_id
  belongs_to :pop
  belongs_to :node

  validates :name, uniqueness: { allow_blank: false }
  validates :name, :domain, :username, :retry_delay, :transport_protocol, :proxy_transport_protocol, presence: true

  # validates_format_of :contact, :with => /\Asip:(.*)\z/
  validates :contact, format: URI::DEFAULT_PARSER.make_regexp(%w[sip])

  validates :retry_delay, numericality: { greater_than: 0, less_than_or_equal_to: PG_MAX_SMALLINT, allow_nil: false, only_integer: true }
  validates :max_attempts, numericality: { greater_than: 0, less_than_or_equal_to: PG_MAX_SMALLINT, allow_nil: true, only_integer: true }

  has_paper_trail class_name: 'AuditLogItem'

  def display_name
    "#{name} | #{id}"
  end

  include Yeti::ResourceStatus
  include Yeti::RegistrationReloader
end
