# frozen_string_literal: true

require 'devise'

Warden::Manager.after_set_user do |record, warden, options|
  proxy = Devise::Hooks::Proxy.new(warden)
  scope = options[:scope]
  env = warden.request.env
  remote_ip = warden.request.remote_ip

  if record&.respond_to?(:ip_allowed?) && warden.authenticated?(scope) &&
     !env['devise.skip_ip_allowable'] && !record.ip_allowed?(remote_ip)

    Devise.sign_out_all_scopes ? proxy.sign_out : proxy.sign_out(scope)
    throw :warden, scope: scope, message: :ip_not_allowed
  end
end

module Devise
  module Models
    module IpAllowable
      extend ActiveSupport::Concern

      def ip_allowed?(remote_ip)
        return true if allowed_ips.blank?

        allowed_ips.any? { |ip_address| IPAddr.new(ip_address).include?(remote_ip) }
      end
    end
  end
end

Devise.add_module :ip_allowable, model: 'devise/models/ip_allowable'
