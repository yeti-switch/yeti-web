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

class AdminUser < ActiveRecord::Base


  before_destroy :check_if_last

  include Yeti::ResourceStatus
  has_one :billing_contact, class_name: 'Billing::Contact', dependent: :destroy, autosave: true

  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, unless:  proc{self.persisted? && email.blank?  }

  def self.ldap_config
    File.join(Rails.root, "config", "ldap.yml")
  end

  def self.ldap_config_exists?
    File.exists?(self.ldap_config)
  end

  def email
    @email ||= billing_contact.try!(:email)
  end

  def email=(mail)
    @email = mail
  end

  after_save do
    contact = billing_contact || build_billing_contact
    contact.update!(email: self.email) if @email
  end

  def display_name
    self.username
  end

  def customized_update(params)
    if params[:password].present? or params[:password_confirmation].present?
      update_with_password params
    else
      attrs = params.except(:password, :password_confirmation)
      if respond_to?(:update_without_password)
        update_without_password attrs #db auth
      else
        update(attrs) #ldap
      end
    end
  end

  def update_with_password(params, *options)
    if params[:password].blank?
      params.delete(:password)
      params.delete(:password_confirmation) if params[:password_confirmation].blank?
    end
    update_attributes(params, *options)
    clean_up_passwords
  end

  def root?
    self.group == 1
  end

  def active_for_authentication?
    super && self.enabled?
  end

  if ldap_config_exists?
    include AdminUserLdapHandler

  else
    include AdminUserDatabaseHandler
  end

  def self.ldap?
    AdminUser.devise_modules.include?(:ldap_authenticatable)
  end



##### devise ####
  def email_required?
    false
  end

  def email_changed?
    false
  end

  protected
  def check_if_last
    if self.class.count <= 1
      errors.add(:base, "Last admin user can't  be deleted")
      false
    end
  end


end


