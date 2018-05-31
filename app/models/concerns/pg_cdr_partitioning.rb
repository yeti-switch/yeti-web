module PgCdrPartitioning

  class Partition
    attr_accessor :connection, :date_from, :date_to, :name, :table_name

    def initialize(connection:, date_from:)
      self.connection = connection
      self.date_from = date_from.beginning_of_month
      self.date_to = date_from.next_month.beginning_of_month
      self.name = "cdr_" + date_from.strftime('%Y%m')
      self.table_name = "cdr.#{name}"
    end

    def create
      connection.execute %Q{
        CREATE TABLE #{table_name} (
          CONSTRAINT #{name}_time_start_check CHECK (
            time_start >= '#{date_from.to_s(:db)} 00:00:00+00'
              AND time_start < '#{date_to.to_s(:db)} 00:00:00+00'
          )
        ) INHERITS (cdr.cdr);
      }
    end

    def add_partition_info(info_table)
      connection.execute %Q{
        INSERT INTO #{info_table}(date_start, date_stop, name, writable, readable) VALUES ('#{date_from.to_s(:db)}', '#{date_to.to_s(:db)}', '#{table_name}', 't', 't');
      }
    end

    def reindex
      add_primary_key unless primary_key?
      time_start_index = column_index(:time_start)

      if time_start_index.present?
        connection.remove_index(table_name, name: time_start_index.name)
      end
      connection.add_index(table_name, :time_start, using: 'btree')
    end

    def exists?
      connection.table_exists?(table_name)
    end

    private

    def primary_key?
      connection.index_exists?(table_name, :id, unique: true)
    end

    def column_index(column_name)
      connection.indexes(table_name).detect do |ind|
        ind.columns.include?(column_name)
      end
    end

    def add_primary_key
      connection.execute %Q{
        ALTER TABLE #{table_name} ADD PRIMARY KEY (id);
      }
    end
  end


  def create_partition(date_from)
    party = Partition.new(connection: connection, date_from: date_from)
    unless party.exists?
      party.create
      party.reindex
      party.add_partition_info(table_name)
      reload_cdr_i_tgf
    end
  end

  def reload_cdr_i_tgf
    cases = active.order(:date_start).map do |t|
      "(NEW.time_start >= '#{t.date_start} 00:00:00+00' AND NEW.time_start < '#{t.date_stop} 00:00:00+00') THEN
          INSERT INTO #{t.name} VALUES (NEW.*);"
    end

    connection.execute %Q{
      CREATE OR REPLACE FUNCTION cdr.cdr_i_tgf() RETURNS trigger AS $trg$
      BEGIN
        IF #{ cases.join("\n        ELSIF ")  }
        ELSE
          RAISE EXCEPTION 'cdr.cdr_i_tg: time_start out of range.';
        END IF;
      RETURN NULL;
      END; $trg$
      LANGUAGE plpgsql VOLATILE COST 100;
    } if cases.any?
  end

end
