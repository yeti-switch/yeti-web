# frozen_string_literal: true

module AdminUserLdapHandler
  extend ActiveSupport::Concern

  included do
    devise :ldap_authenticatable, :trackable, :ip_allowable
    before_update :get_ldap_attributes
    before_validation :get_ldap_attributes, on: :create
    include LdapPasswordHelper
    class_attribute :default_ldap_roles, instance_writer: false
    self.default_ldap_roles = [RolePolicy.root_role]
  end

  def get_ldap_attributes
    new_email =  Devise::LDAP::Adapter.get_ldap_param(username, 'mail')&.first
    self.email = new_email if new_email
    new_roles =  Devise::LDAP::Adapter.get_ldap_param(username, 'roles')
    self.roles = new_roles ? Array.wrap(new_roles) : default_ldap_roles
  rescue Net::LDAP::Error => e
    Rails.logger.error { e.message }
    # nothing
  end

  def default_ldap_roles
    [root_role]
  end

  class_methods do
    def pepper
      Devise.pepper
    end
  end

  # should be included last
  module LdapPasswordHelper
    def authenticate(password)
      Devise::Encryptor.compare(AdminUser, encrypted_password, password)
    end

    def encrypt_password(password)
      ::BCrypt::Password.create(password, cost: Devise.stretches).to_s
    end

    def valid_ldap_authentication?(password)
      if super(password)
        # update encrypted_password for API needs
        self.encrypted_password = encrypt_password(password)
        true
      else
        false
      end
    end
  end
end
