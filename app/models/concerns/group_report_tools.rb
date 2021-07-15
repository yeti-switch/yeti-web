# frozen_string_literal: true

module GroupReportTools
  extend ActiveSupport::Concern
  included do
    attr_accessor :group_by_fields
    class_attribute :report_items_class

    def group_by_fields=(group_ids)
      @group_by_fields = group_ids.reject(&:blank?)
      self.group_by = @group_by_fields.uniq.join(',')
    end

    def group_by_include?(key)
      group_by_arr.include?(key.to_sym)
    end

    def group_by_arr
      @group_by_arr ||= group_by.split(',').map(&:to_sym)
    end

    def belongs_to_relations
      @belongs_to_relations ||= begin
        group_by_keys = group_by_arr
        report_items_class.reflect_on_all_associations(:belongs_to)
                          .select { |name| group_by_keys.include?(name.foreign_key.to_sym) }
      end
    end

    def auto_includes
      belongs_to_relations.map(&:name)
    end

    #    def auto_columns
    #      auto_includes +  (group_by_arr - belongs_to_relations.map{|r| r.foreign_key })
    #    end

    def auto_columns
      #      attrs =  group_by_arr
      #      belongs_to_relations.each do |c|
      #        attrs.map!{ |e|
      #          e==c.foreign_key.to_sym ? c.name.to_sym : e
      #        }
      #      end
      #      attrs
      group_by_arr.map do |attribute_name|
        relation = belongs_to_relations.detect { |e| e.foreign_key.to_s == attribute_name.to_s }
        relation&.name&.to_sym || attribute_name
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
