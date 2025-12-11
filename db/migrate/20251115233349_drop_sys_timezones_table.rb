# frozen_string_literal: true

class DropSysTimezonesTable < ActiveRecord::Migration[7.2]
  def up
    # Drop the sys.timezones table
    execute <<-SQL
      DROP TABLE IF EXISTS sys.timezones;
    SQL
  end

  def down
    # Recreate the table structure (data would need to be restored from seeds)
    execute <<-SQL
      CREATE TABLE sys.timezones (
        id serial PRIMARY KEY NOT NULL,
        name character varying NOT NULL,
        abbrev character varying,
        utc_offset interval,
        is_dst boolean
      );

      CREATE UNIQUE INDEX timezones_name_key ON sys.timezones USING btree (name);
    SQL


    execute <<-SQL
      INSERT INTO sys.timezones (name, utc_offset)
      SELECT
        name,
        make_interval(secs => EXTRACT(EPOCH FROM timezone_offset))
      FROM (
        SELECT
          tz.name,
          (current_timestamp AT TIME ZONE tz.name) - current_timestamp AS timezone_offset
        FROM (
          SELECT unnest(ARRAY[
            #{Yeti::TimeZoneHelper.all.map { |tz| ActiveRecord::Base.connection.quote(tz) }.join(",\n        ")}
          ]) AS name
        ) AS tz
      ) AS x;
      SQL
  end
end

