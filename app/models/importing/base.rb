class Importing::Base < Yeti::ActiveRecord

  self.abstract_class = true

  # NOTE: can't use "scope", ref: https://github.com/rails/rails/issues/10658
  def self.success
    where error_string: nil
  end
  def self.with_errors
    where.not error_string: nil
  end
  def self.for_update
    where.not o_id: nil
  end
  def self.for_create
    where o_id: nil
  end

  class_attribute :import_attributes, :import_class

  ALLOWED_OPTIONS_KEYS = [:controller_info, :max_jobs_count, :job_number, :action]

  # Resolve foreign_keys and existing items relation(by unique names)
  def self.after_import_hook(unique_columns = [])
    self.resolve_belongs_to
    self.resolve_object_id(unique_columns)
  end


  def self.run_in_background(controller_info, action = nil)
    Importing::ImportingDelayedJob.create_jobs(self, {controller_info: controller_info, action: action})
  end


  def self.move_batch(options)
    options.assert_valid_keys(ALLOWED_OPTIONS_KEYS)
    PaperTrail.whodunnit = options[:controller_info][:whodunnit]
    PaperTrail.controller_info = options[:controller_info][:controller_info]
    query = self.where('id % ? = ?', options[:max_jobs_count], options[:job_number])
    query = query.send(options[:action]) if (options[:action])
    Yeti::ActiveRecord.transaction do
      query.find_in_batches do |batch|
        batch.each { |item| self.move_one!(item) }
      end
    end
  end


  # Update or Create real item from importing-data
  def self.move_one!(source_item)
    begin
      dst_item = source_item.o_id ?
          self.import_class.find(source_item.o_id) :
          self.import_class.new
#      dst_item.attributes = source_item.attributes.slice(*import_attributes)
      dst_item.attributes = source_item.attributes.slice(*import_attributes).delete_if { |_,v| v.nil? }
      dst_item.save!
      source_item.delete
    rescue ActiveRecord::RecordInvalid => e
      source_item.update_attribute(:error_string, e.message)
    end
  end


  def self.resolve_belongs_to
    associations = self.import_class.reflect_on_all_associations(:belongs_to)
    import_associations_names = self.reflect_on_all_associations(:belongs_to).map(&:name)
    associations.each do |association|
      if association.name.in? import_associations_names
        self.update_relations_for_each!(association.klass.table_name, association.name)
      end
    end
  end


  def self.resolve_object_id(unique_columns)
    self.for_update.update_all(o_id: nil)
    if unique_columns.any?
      self.update_relations_for_each!(self.import_class.table_name, :o, unique_columns)
    end
  end


  #
  # This method is a direct SQL, because ActiveRecord can't do
  # query like UPDATE+SET+FROM+WHERE, it skips "FROM"
  # "FROM" is crucial for this kind of queries
  #
  def self.update_relations_for_each!(relation_table_name, field, unique_columns = [])
    if unique_columns.any?
      condition_array = []
      unique_columns.each do |column_name|
        condition_array << "ta.#{column_name} = tb.#{column_name}"
      end
      condition = condition_array.join(' AND ')
    else
      condition = "ta.#{field}_name = tb.name"
    end
    sql = "UPDATE #{self.table_name} ta SET #{field}_id = tb.id FROM #{relation_table_name} tb WHERE #{condition}"
    Yeti::ActiveRecord.connection.execute(sql)
  end

end
