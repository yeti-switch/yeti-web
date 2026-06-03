# frozen_string_literal: true

class DropGuiBackgroundThreads < ActiveRecord::Migration[7.2]
  def up
    execute <<-SQL
      DROP TABLE gui.background_threads;
    SQL
  end

  def down
    execute <<-SQL
      CREATE TABLE gui.background_threads (
          id integer NOT NULL,
          name character varying,
          num integer,
          created_at timestamp with time zone,
          updated_at timestamp with time zone,
          data_count bigint,
          data_processed bigint,
          exception text
      );

      CREATE SEQUENCE gui.background_threads_id_seq
          START WITH 1
          INCREMENT BY 1
          NO MINVALUE
          NO MAXVALUE
          CACHE 1;

      ALTER SEQUENCE gui.background_threads_id_seq OWNED BY gui.background_threads.id;

      ALTER TABLE ONLY gui.background_threads ALTER COLUMN id SET DEFAULT nextval('gui.background_threads_id_seq'::regclass);

      ALTER TABLE ONLY gui.background_threads
          ADD CONSTRAINT background_threads_pkey PRIMARY KEY (id);
    SQL
  end
end
