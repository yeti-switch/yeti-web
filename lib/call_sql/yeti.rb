module CallSql
  class Yeti < Base
    _delegate_to_instance :table_full_size, :table_data_size

    def table_full_size(table_name)
      select_value('SELECT pg_total_relation_size(?)', table_name)
    end

    def table_data_size(table_name)
      select_value('SELECT pg_relation_size(?)', table_name)
    end

    private

    def model_klass
      ::Yeti::ActiveRecord
    end

  end
end
