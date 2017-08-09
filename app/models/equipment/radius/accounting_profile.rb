# == Schema Information
#
# Table name: class4.radius_accounting_profiles
#
#  id                          :integer          not null, primary key
#  name                        :string           not null
#  server                      :string           not null
#  port                        :integer          not null
#  secret                      :string           not null
#  timeout                     :integer          default(100), not null
#  attempts                    :integer          default(2), not null
#  enable_start_accounting     :boolean          default(FALSE), not null
#  enable_interim_accounting   :boolean          default(FALSE), not null
#  interim_accounting_interval :integer          default(30), not null
#  enable_stop_accounting      :boolean          default(TRUE), not null
#

class Equipment::Radius::AccountingProfile < Yeti::ActiveRecord
  self.table_name='class4.radius_accounting_profiles'
  has_paper_trail class_name: 'AuditLogItem'

  has_many :stop_avps, class_name: 'Equipment::Radius::AccountingProfileStopAttribute', foreign_key: :profile_id, inverse_of: :profile , dependent: :destroy
  has_many :start_avps, class_name: 'Equipment::Radius::AccountingProfileStartAttribute', foreign_key: :profile_id, inverse_of: :profile , dependent: :destroy
  has_many :interim_avps, class_name: 'Equipment::Radius::AccountingProfileInterimAttribute', foreign_key: :profile_id, inverse_of: :profile , dependent: :destroy

  has_many :customers_auths, class_name: 'CustomersAuth', foreign_key: :radius_accounting_profile_id, dependent: :restrict_with_error
  has_many :gateways, class_name: 'Gateway', foreign_key: :radius_accounting_profile_id, dependent: :restrict_with_error


  accepts_nested_attributes_for :stop_avps, allow_destroy: true
  accepts_nested_attributes_for :interim_avps, allow_destroy: true
  accepts_nested_attributes_for :start_avps, allow_destroy: true

  TIMEOUT_MIN=1
  TIMEOUT_MAX=2000

  ATTEMPTS_MIN=1
  ATTEMPTS_MAX=10

  validates_uniqueness_of :name
  validates_presence_of :name, :server, :port, :secret, :timeout, :attempts

  validates_numericality_of :timeout, greater_than_or_equal_to: TIMEOUT_MIN, less_than_or_equal_to: TIMEOUT_MAX, allow_nil: true, only_integer: true
  validates_numericality_of :attempts, greater_than_or_equal_to: ATTEMPTS_MIN, less_than_or_equal_to: ATTEMPTS_MAX, allow_nil: true, only_integer: true
  validates_numericality_of :port, greater_than_or_equal_to: Yeti::ActiveRecord::L4_PORT_MIN, less_than_or_equal_to: Yeti::ActiveRecord::L4_PORT_MAX, allow_nil: true, only_integer: true

  before_save do
    Event.reload_radius_acc_profiles
  end

  after_destroy do
    Event.reload_radius_acc_profiles
  end

  def display_name
    "#{id} | #{name}"
  end

end
