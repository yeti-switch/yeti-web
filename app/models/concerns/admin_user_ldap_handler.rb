module AdminUserLdapHandler
  extend ActiveSupport::Concern

  included do
    devise :ldap_authenticatable, :trackable
    before_save :get_ldap_email, unless: proc{|me| me.new_record? }
    before_validation :get_ldap_email, if: proc{|me| me.new_record? }
    include LdapPasswordHelper
  end

  def get_ldap_email
    begin
      new_email =  Devise::LDAP::Adapter.get_ldap_param(self.username, 'mail').try(:first)
      self.email = new_email if new_email
    rescue Net::LDAP::LdapError => e
      Rails.logger.error{ e.message }
      #nothing
    end
  end

  class_methods do
    def pepper
      Devise.pepper
    end
  end

  #should be included last
  module LdapPasswordHelper
    def authenticate(password)
      Devise::Encryptor.compare(AdminUser, self.encrypted_password, password)
    end

    def encrypt_password(password)
      ::BCrypt::Password.create(password, cost: Devise.stretches).to_s
    end

    def valid_ldap_authentication?(password)
      if super(password)
        #update encrypted_password for API needs
        self.encrypted_password = encrypt_password(password)
        true
      else
        false
      end
    end
  end


end
