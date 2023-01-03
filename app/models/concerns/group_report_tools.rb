# frozen_string_literal: true

module GroupReportTools
  extend ActiveSupport::Concern
  included do
    class_attribute :report_items_class

    def group_by_include?(key)
      return false if group_by.blank?

      group_by.include?(key.to_s)
    end

    def belongs_to_relations
      @belongs_to_relations ||= begin
        report_items_class.reflect_on_all_associations(:belongs_to)
                          .select { |name| group_by_include?(name.foreign_key) }
      end
    end

    def auto_includes
      belongs_to_relations.map(&:name)
    end

    #    def auto_columns
    #      auto_includes +  (group_by.map(&:to_sym) - belongs_to_relations.map{|r| r.foreign_key })
    #    end

    def auto_columns(constant_columns = {})
      return [] if group_by.blank?

      group_by.map do |attribute_name|
        if constant_columns.key?(attribute_name)
          constant_columns[attribute_name]
        else
          relation = belongs_to_relations.detect { |e| e.foreign_key.to_s == attribute_name }
          [relation&.name&.to_sym || attribute_name.to_sym, relation&.name&.to_sym || attribute_name.to_sym]
        end
      end
    end

    def self.setup_report_with(child_class)
      self.report_items_class = child_class
      has_many :custom_items, class_name: child_class.to_s, foreign_key: :report_id, dependent: :delete_all do
        def with_includes
          preload(proxy_association.owner.auto_includes)
        end
      end
    end

    def report_records
      custom_items.with_includes
    end

    def csv_columns
      (auto_columns + report_items_class.report_columns.map(&:to_sym))
    end
  end
end
