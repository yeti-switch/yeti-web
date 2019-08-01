# frozen_string_literal: true

Delayed::Worker.destroy_failed_jobs = false

Dir[File.join(Rails.root, 'lib', 'ext', '**', '*.rb')].each { |s| require s }
Dir[File.join(Rails.root, 'lib', 'active_record', '**', '*.rb')].each { |s| require s }
Dir[File.join(Rails.root, 'lib', 'active_admin', '**', '*.rb')].each { |s| require s }
Dir[File.join(Rails.root, 'lib', 'resource_dsl', '**', '*.rb')].each { |s| require s }

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
ActiveAdmin::ResourceDSL.send :include, ResourceDSL::BatchActionUpdate
ActiveAdmin::ResourceDSL.send :include, ResourceDSL::ActsAsAsyncDestroy
ActiveAdmin::ResourceDSL.send :include, ResourceDSL::ActsAsAsyncUpdate
ActiveAdmin::ResourceDSL.send :include, ResourceDSL::ActsAsDelayedJobLock
ActiveAdmin::ResourceDSL.send :include, ResourceDSL::ActsAsFilterByRoutingTagIds
ActiveAdmin::ResourceDSL.send :include, ResourceDSL::ActsAsBelongsTo
ActiveAdmin::ResourceDSL.send :include, ResourceDSL::WithDefaultParams

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

# ##patches for filters form for non AR objects
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
        context = begin
                    Ransack::Context.for klass
                  rescue StandardError
                    nil
                  end
        context.respond_to?(:ransackable_scope?) && context.ransackable_scope?(method.to_s, klass)
      end
    end
  end
end

ActiveAdminDatetimepicker::Base.default_datetime_picker_options = {
  defaultDate: proc { Time.current.strftime('%Y-%m-%d 00:00') }
}

# fix filtering by array contains
module Arel
  module Visitors
    class PostgreSQL
      private

      def visit_Arel_Nodes_Contains(o, collector)
        left_column = o.left.relation.send(:type_caster).send(:types).columns.find do |col|
          col.name == o.left.name.to_s || col.name == o.left.relation.name.to_s
        end

        if left_column && (left_column.type == :hstore || (left_column.respond_to?(:array) && left_column.array))
          infix_value o, collector, ' @> '
        else
          infix_value o, collector, ' >> '
        end
      end
    end
  end
end
