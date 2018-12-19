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
#  enabled                :boolean          default(TRUE)
#  username               :string           not null
#  ssh_key                :text
#  stateful_filters       :boolean          default(FALSE), not null
#  visible_columns        :json             not null
#  per_page               :json             not null
#  saved_filters          :json             not null
#  roles                  :string           not null, is an Array
#

class AdminUser < ActiveRecord::Base
  include Yeti::ResourceStatus

  has_one :billing_contact, class_name: 'Billing::Contact', dependent: :destroy, autosave: true

  before_validation do
    self.roles = roles.reject(&:blank?) unless roles.nil?
  end

  validates_format_of :email, with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, if: :validate_email?
  validates :roles, presence: true

  after_save do
    contact = billing_contact || build_billing_contact
    contact.update!(email: self.email) if @email
  end

  before_destroy :check_if_last

  def self.from_token_request(request)
    name = request.params[:auth].kind_of?(Hash) && request.params[:auth][:username]
    name.present? ? find_by(username: name) : nil
  end

  def self.ldap?
    AdminUser.devise_modules.include?(:ldap_authenticatable)
  end

  def self.ldap_config
    File.join(Rails.root, "config", "ldap.yml")
  end

  def self.ldap_config_exists?
    File.exists?(self.ldap_config)
  end

  def self.available_roles
    list = (Rails.configuration.policy_roles.try!(:keys) || []).map(&:to_sym)
    list.push(RolePolicy.root_role) if RolePolicy.root_role.present?
    list
  end

  if ldap_config_exists?
    include AdminUserLdapHandler
  else
    include AdminUserDatabaseHandler
  end

  def email
    @email ||= billing_contact.try!(:email)
  end

  def email=(mail)
    @email = mail
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

  def active_for_authentication?
    super && self.enabled?
  end

  def validate_email?
    self.new_record? || @email.present?
  end

##### devise ####
  def email_required?
    false
  end

  def email_changed?
    false
  end

  # https://github.com/plataformatec/devise/issues/4542
  def will_save_change_to_email?
    false
  end

  protected

  def check_if_last
    if self.class.count.zero?
      errors.add(:base, "Last admin user can't  be deleted")
      throw(:abort)
    end
  end
end
