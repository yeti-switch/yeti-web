# frozen_string_literal: true

module Billing
  module Provisioning
    class Logging < Base
      def after_create
        Rails.logger.info "Service created service_id=#{service.id}"
      end

      def before_renew
        Rails.logger.info "Renew started service_id=#{service.id}"
      end

      def after_renew
        Rails.logger.info "Renew finished service_id=#{service.id}"
      end

      def after_success_renew
        Rails.logger.info "Service renewed service_id=#{service.id}, next_renew_at=#{service.renew_at}"
      end

      def after_failed_renew
        Rails.logger.info "Service failed to renew service_id=#{service.id}, account_balance=#{account.balance}"
      end
    end
  end
end
