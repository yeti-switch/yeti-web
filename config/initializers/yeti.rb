Delayed::Worker.destroy_failed_jobs = false

Dir[File.join(Rails.root, "lib", "**", "*.rb")].each { |s| require s }

ActiveAdmin::ResourceDSL.send :include, ResourceDSL::ActsAsClone
ActiveAdmin::ResourceDSL.send :include, ResourceDSL::ActsAsStatus
ActiveAdmin::ResourceDSL.send :include, ResourceDSL::ActsAsAudit
ActiveAdmin::ResourceDSL.send :include, ResourceDSL::ActsAsSafeDestroy
ActiveAdmin::ResourceDSL.send :include, ResourceDSL::ActsAsStat
ActiveAdmin::ResourceDSL.send :include, ResourceDSL::ActsAsLock
ActiveAdmin::ResourceDSL.send :include, ResourceDSL::ActsAsExport
ActiveAdmin::ResourceDSL.send :include, ResourceDSL::ActsAsCdrStat
ActiveAdmin::ResourceDSL.send :include, ResourceDSL::ActsAsImport
ActiveAdmin::ResourceDSL.send :include, ResourceDSL::ActsAsImportPreview
ActiveAdmin::ResourceDSL.send :include, ResourceDSL::ActsAsBatchChangeable
ActiveAdmin::ResourceDSL.send :include, ResourceDSL::ReportScheduler
ActiveAdmin::ResourceController.send(:include, ActiveAdmin::PerPageExtension)

# ActiveAdmin::CSVBuilder.send(:include, Yeti::CSVBuilder)

module ActiveAdmin
  class CSVBuilder

    def build_row(resource, columns, options)
      columns.map do |column|
        ceil = call_method_or_proc_on(resource, column.data)
        ceil = ceil.display_name if ceil.respond_to?(:display_name)
        encode ceil, options
      end
    end
  end
end


ActiveAdmin::ResourceDSL.send :include, Rails.application.routes.url_helpers
ActiveAdmin::ResourceDSL.send :include, ApplicationHelper

###patches for filters form for non AR objects
module ActiveAdmin
  module Filters
    module FormtasticAddons
      def klass
        @object.try(:object).try(:klass)
      end

      def ransacker?
        klass.try(:_ransackers).try(:key?, method.to_s)
      end

      def scope?
        context = Ransack::Context.for klass rescue nil
        context.respond_to?(:ransackable_scope?) && context.ransackable_scope?(method.to_s, klass)
      end

    end
  end
end

#
ActiveAdminDatetimepicker::Base.default_datetime_picker_options = {
    defaultDate: proc { Time.current.strftime("%Y-%m-%d 00:00") }
}
