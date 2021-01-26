# frozen_string_literal: true

module ActiveRecordExtension
  def self.included(base)
    class << base
      prepend(ClassMethods)
    end
  end

  module ClassMethods
    def inherited(subclass)
      super

      begin
        # Paper trail should be enabled by default even if the class is not declared in the config.
        # Object modification (actions :update, :touch) will not cause log saving if the class was declared with a 'false' value in the config.
        options = {}
        options[:class_name] = 'AuditLogItem' if defined?(AuditLogItem)
        options[:on] = [:create, :destroy] if Rails.configuration.audit[subclass.name&.gsub('::', '/')] == false
        subclass.send(:has_paper_trail, options) if %w[AuditLogItem PaperTrail::Version].exclude?(subclass.name)
      rescue StandardError => e
        logger.error(e.message)
      end
    end
  end
end

ActiveRecord::Base.send(:include, ActiveRecordExtension)
