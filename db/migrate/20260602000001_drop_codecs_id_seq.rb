# frozen_string_literal: true

class DropCodecsIdSeq < ActiveRecord::Migration[7.2]
  # Codec ids are always assigned by hand, so the id sequence is unused.
  def up
    execute %q{
      ALTER TABLE class4.codecs ALTER COLUMN id DROP DEFAULT;
      DROP SEQUENCE class4.codecs_id_seq;
    }
  end

  def down
    execute %q{
      CREATE SEQUENCE class4.codecs_id_seq
        START WITH 1
        INCREMENT BY 1
        NO MINVALUE
        NO MAXVALUE
        CACHE 1;
      ALTER SEQUENCE class4.codecs_id_seq OWNED BY class4.codecs.id;
      ALTER TABLE ONLY class4.codecs ALTER COLUMN id SET DEFAULT nextval('class4.codecs_id_seq'::regclass);
      SELECT pg_catalog.setval('class4.codecs_id_seq', (SELECT COALESCE(MAX(id), 1) FROM class4.codecs), true);
    }
  end
end
