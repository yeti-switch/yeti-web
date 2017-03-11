# == Schema Information
#
# Table name: registrations
#
#  id               :integer          not null, primary key
#  name             :string           not null
#  enabled          :boolean          default(TRUE), not null
#  pop_id           :integer
#  node_id          :integer
#  domain           :string
#  username         :string           not null
#  display_username :string
#  auth_user        :string
#  proxy            :string
#  contact          :string
#  auth_password    :string
#  expire           :integer
#  force_expire     :boolean          default(FALSE), not null
#

class Equipment::Registration < Yeti::ActiveRecord

  validates_uniqueness_of :name, allow_blank: false
  validates_presence_of :name, :domain, :username, :retry_delay

  #validates_format_of :contact, :with => /\Asip:(.*)\z/
  validates :contact, :format => URI::regexp(%w(sip))

  validates_numericality_of :retry_delay, greater_than: 0, less_than: PG_MAX_SMALLINT, allow_nil: false, only_integer: true
  validates_numericality_of :max_attempts, greater_than: 0, less_than: PG_MAX_SMALLINT, allow_nil: true, only_integer: true

  belongs_to :pop
  belongs_to :node

  has_paper_trail class_name: 'AuditLogItem'

  def display_name
    "#{self.name} | #{self.id}"
  end

  include Yeti::ResourceStatus
  include Yeti::RegistrationReloader

end
