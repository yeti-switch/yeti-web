module PgEvent

  def self.included(base)
    base.send :extend, ClassMethods
  end

  module ClassMethods
     def has_pg_queue(name)
       class_attribute :pg_queue_name
       self.pg_queue_name = name
       send :include, InstanceMethods
       after_create  :pg_record_create
       after_destroy :pg_record_destroy
       after_update  :pg_record_update

     end

     def pgq_insert_event(queue_name, ev_type, ev_data)
       result = self.connection.select_value("SELECT pgq.insert_event(#{connection.quote(queue_name)}, #{connection.quote(ev_type)}, #{connection.quote(ev_data)})")
       result ? result.to_i : nil
     end
  end

  module InstanceMethods


    private

    def pg_record_create
      pg_event!(:create)
    end

    def pg_record_destroy
      pg_event!(:destroy)
    end

    def pg_record_update
      pg_event!(:update)
    end

    def pg_event!(type)
      self.class.pgq_insert_event(pg_queue_name, type.to_s, self.attributes.to_json)
    end

  end
end