# frozen_string_literal: true

class Importing::Base < ApplicationRecord
  self.abstract_class = true

  class Error < StandardError
  end

  # NOTE: can't use "scope", ref: https://github.com/rails/rails/issues/10658
  def self.success
    where(error_string: nil)
  end

  def self.with_errors
    where.not(error_string: nil)
  end

  def self.for_update
    where.not(o_id: nil)
  end

  def self.for_create
    where(o_id: nil)
  end

  def self.not_ready_to_process
    where(is_changed: nil)
  end

  def self.ready_to_process
    where.not(is_changed: nil)
  end

  # @param klass [Class<ApplicationRecord>]
  def self.import_for(klass)
    self.import_class = klass

    # Association will represent record that will be replaced by importing record.
    belongs_to :import_object, class_name: "::#{klass.name}", foreign_key: :o_id, optional: true
  end

  def self.import_assoc_keys
    attrs = import_attributes || []
    attrs.select do |attr|
      attr = attr.to_s
      attr.end_with?('_id') && reflect_on_association(attr.gsub(/_id\z/, ''))
    end
  end

  class_attribute :import_attributes, :import_class, :strict_unique_attributes

  ALLOWED_OPTIONS_KEYS = %i[controller_info max_jobs_count job_number action].freeze

  # Resolve foreign_keys
  def self.after_import_hook
    resolve_belongs_to
  end

  def self.not_null_attributes
    import_class.columns.reject(&:null).map(&:name)
  end

  def self.run_in_background(controller_info, action = nil)
    raise Error, 'Apply Unique Columns must be executed before this action' if not_ready_to_process.any?

    Importing::ImportingDelayedJob.create_jobs(self, controller_info: controller_info, action: action)
  end

  def self.move_batch(options)
    options.assert_valid_keys(ALLOWED_OPTIONS_KEYS)
    PaperTrail.request.whodunnit = options[:controller_info][:whodunnit]
    PaperTrail.request.controller_info = options[:controller_info][:controller_info]
    query = where('id % ? = ?', options[:max_jobs_count], options[:job_number])
    query = query.where(is_changed: true)
    query = query.send(options[:action]) if options[:action]
    ApplicationRecord.transaction do
      query.find_in_batches do |batch|
        batch.each { |item| move_one!(item) }
      end
    end
  end

  # Update or Create real item from importing-data
  def self.move_one!(source_item)
    dst_item = source_item.o_id ?
        import_class.find(source_item.o_id) :
        import_class.new
    #      dst_item.attributes = source_item.attributes.slice(*import_attributes)
    dst_item.attributes = source_item.attributes.slice(*import_attributes).delete_if { |_, v| v.nil? }
    dst_item.save!
    source_item.delete
  rescue ActiveRecord::RecordInvalid => e
    source_item.update_attribute(:error_string, e.message)
  end

  def self.resolve_belongs_to
    associations = import_class.reflect_on_all_associations(:belongs_to)
    import_associations_names = reflect_on_all_associations(:belongs_to).map(&:name)
    associations.each do |association|
      if association.name.in? import_associations_names
        update_relations_for_each!(association.klass.table_name, association.name)
      end
    end
  end

  # Resolve existing items relation(by unique names)
  def self.resolve_object_id(unique_columns, extra_condition = nil)
    for_update.update_all(o_id: nil)
    ready_to_process.update_all(is_changed: nil)
    if unique_columns.any?
      update_relations_for_each!(import_class.table_name, :o, unique_columns, extra_condition)
    end
    apply_is_changed!
  end

  def self.apply_is_changed!
    changed_condition = calc_changed_conditions('orig_t', 'import_t')

    sql_matched = [
      "UPDATE #{table_name} import_t",
      "SET is_changed = (#{changed_condition})",
      "FROM #{import_class.table_name} orig_t",
      'WHERE import_t.o_id IS NOT NULL AND import_t.o_id = orig_t.id'
    ].join(' ')
    ApplicationRecord.connection.execute(sql_matched)

    sql_non_matched = "UPDATE #{table_name} SET is_changed = true WHERE is_changed IS NULL"
    ApplicationRecord.connection.execute(sql_non_matched)
  end

  def self.calc_changed_conditions(orig_table, import_table)
    diffs = import_attributes.map do |col|
      not_null_attributes.include?(col) ?
        "(#{import_table}.#{col} IS NULL OR #{orig_table}.#{col} <> #{import_table}.#{col})" :
        # We use "IS DISTINCT FROM" instead of "<>" because "NULL <> NULL" is "NULL".
        "#{orig_table}.#{col} IS DISTINCT FROM #{import_table}.#{col}"
    end
    diffs.join(' OR ')
  end

  #
  # This method is a direct SQL, because ActiveRecord can't do
  # query like UPDATE+SET+FROM+WHERE, it skips "FROM"
  # "FROM" is crucial for this kind of queries
  #
  def self.update_relations_for_each!(relation_table_name, field, unique_columns = [], extra_condition = nil)
    if unique_columns.any?
      condition_array = []
      unique_columns.each do |column_name|
        # We use "IS DISTINCT FROM" instead of "<>" because "NULL <> NULL" is "NULL".
        if not_null_attributes.include?(column_name)
          condition_array << "ta.#{column_name} = tb.#{column_name}"
        else
          condition_array << "ta.#{column_name} IS NOT DISTINCT FROM tb.#{column_name}"
        end
      end
      condition = condition_array.join(' AND ')
    else
      condition = "ta.#{field}_name = tb.name"
    end
    if extra_condition.present?
      condition = "#{condition} AND #{extra_condition}"
    end
    sql = "UPDATE #{table_name} ta SET #{field}_id = tb.id FROM #{relation_table_name} tb WHERE #{condition}"
    ApplicationRecord.connection.execute(sql)
  end

  # Use this method for resolving:
  #   routing_tag_names => routing_tag_ids
  #   tag_action_value_names => tag_action_value
  # Sorts routing_tag_ids in same way as RoutingTagsSort#call
  def self.resolve_array_of_tags(ids_column, names_column)
    sql = "
      UPDATE #{table_name} ta
      SET #{ids_column} = ARRAY(
            SELECT id::smallint
            FROM #{Routing::RoutingTag.table_name}
            WHERE name = ANY ( string_to_array(replace(ta.#{names_column}, ', ', ',')::varchar, ',')::varchar[] )
            ORDER BY id ASC
          )
      WHERE ta.#{ids_column} = '{}' AND ta.#{names_column} <> '';
    "
    ApplicationRecord.connection.execute(sql)
  end

  # Sorts routing_tag_ids in same way as RoutingTagsSort#call
  def self.resolve_null_tag(ids_column, names_column)
    sql = "
      UPDATE #{table_name} ta
      SET #{ids_column} = array_append(#{ids_column}, NULL)
      WHERE '#{Routing::RoutingTag::ANY_TAG}' = ANY(
              string_to_array(replace(ta.#{names_column}, ', ', ',')::varchar, ',')::varchar[]
            );
    "
    ApplicationRecord.connection.execute(sql)
  end

  def self.resolve_integer_constant(id_column, name_column, collection)
    collection.each do |cid, cname|
      sql = "UPDATE #{table_name} ta SET #{id_column} = #{cid} WHERE #{name_column} = '#{cname}'"
      ApplicationRecord.connection.execute(sql)
    end
  end
end
