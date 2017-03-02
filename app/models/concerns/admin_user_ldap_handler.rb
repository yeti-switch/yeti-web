module AdminUserLdapHandler
  extend ActiveSupport::Concern
  included do
    devise :ldap_authenticatable, :trackable
    before_save :get_ldap_email, unless: proc{|me| me.new_record?}
    before_validation :get_ldap_email, if: proc{|me| me.new_record?}
  end

  def get_ldap_email
    begin
      self.email = Devise::LDAP::Adapter.get_ldap_param(self.username, 'mail').try(:first)
    rescue Net::LDAP::LdapError => e
      #nothing
    end
  end

end