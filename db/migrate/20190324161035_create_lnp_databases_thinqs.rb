class CreateLnpDatabasesThinqs < ActiveRecord::Migration[5.2]
  def up
    # create new tables
    execute <<-SQL
      CREATE TABLE class4.lnp_databases_thinq (
        id smallserial primary key,
        host varchar, -- not null
        port integer,
        timeout smallint not null default 300,
        username varchar,
        token varchar,
        database_id integer
      );

      CREATE TABLE class4.lnp_databases_30x_redirect (
        id smallserial primary key,
        host varchar, -- not null
        port integer,
        timeout smallint not null default 300,
        database_id integer
      );

      CREATE TABLE class4.lnp_databases_csv (
        id smallserial primary key,
        csv_file_path varchar,
        database_id integer
      );

      ALTER TABLE class4.lnp_databases
        ADD COLUMN database_type varchar,
        ADD COLUMN database_id smallserial;

      COMMENT ON COLUMN class4.lnp_databases.database_type
        IS 'One of Lnp::DatabaseThinq, Lnp::DatabaseSipRedirect, Lnp::DatabaseCsv';
    SQL

    # Lnp::DatabaseDriver::THINQ
    execute <<-SQL
      INSERT INTO class4.lnp_databases_thinq
      (host, port, timeout, username, token, database_id)
      SELECT host, port, timeout, thinq_username AS username, thinq_token AS token, id AS database_id
      FROM class4.lnp_databases WHERE driver_id = 2;
    SQL
    execute <<-SQL
      UPDATE class4.lnp_databases parent SET
      database_type = 'Lnp::DatabaseThinq', database_id = child.id
      FROM class4.lnp_databases_thinq child
      WHERE child.database_id = parent.id;
    SQL

    # Lnp::DatabaseDriver::SIP
    execute <<-SQL
      INSERT INTO class4.lnp_databases_30x_redirect
      (host, port, timeout, database_id)
      SELECT host, port, timeout, id AS database_id
      FROM class4.lnp_databases WHERE driver_id = 1;
    SQL
    execute <<-SQL
      UPDATE class4.lnp_databases parent SET
      database_type = 'Lnp::DatabaseSipRedirect', database_id = child.id
      FROM class4.lnp_databases_30x_redirect child
      WHERE child.database_id = parent.id;
    SQL

    # Lnp::DatabaseDriver::INMEMORY
    execute <<-SQL
      INSERT INTO class4.lnp_databases_csv
      (csv_file_path, database_id)
      SELECT csv_file AS csv_file_path, id AS database_id
      FROM class4.lnp_databases WHERE driver_id = 3;
    SQL
    execute <<-SQL
      UPDATE class4.lnp_databases parent SET
      database_type = 'Lnp::DatabaseCsv', database_id = child.id
      FROM class4.lnp_databases_csv child
      WHERE child.database_id = parent.id;
    SQL

    # restore not null
    execute <<-SQL
      ALTER TABLE class4.lnp_databases_thinq ALTER COLUMN host SET NOT NULL;
      ALTER TABLE class4.lnp_databases_30x_redirect ALTER COLUMN host SET NOT NULL;
    SQL

    # drop old columns and table
    execute <<-SQL
      -- driver_id don't needed anymore because we can determine type by database_type column
      ALTER TABLE class4.lnp_databases
        DROP COLUMN host,
        DROP COLUMN port,
        DROP COLUMN driver_id,
        DROP COLUMN thinq_token,
        DROP COLUMN thinq_username,
        DROP COLUMN timeout,
        DROP COLUMN csv_file;

      DROP TABLE sys.lnp_database_drivers;

      -- these column were needed only for data migration
      ALTER TABLE class4.lnp_databases_thinq DROP COLUMN database_id;
      ALTER TABLE class4.lnp_databases_30x_redirect DROP COLUMN database_id;
      ALTER TABLE class4.lnp_databases_csv DROP COLUMN database_id;
    SQL
  end

  def down
    # restore lnp_database_drivers
    execute <<-SQL
      CREATE TABLE sys.lnp_database_drivers (
        id integer primary_key,
        name string not null,
        description text
      );

      INSERT INTO sys.lnp_database_drivers VALUES
      (1, 'SIP 301/302 redirect', NULL),
      (2, 'ThinQ', NULL),
      (3, 'CSV', NULL);
    SQL

    # restore columns
    execute <<-SQL
      ALTER TABLE class4.lnp_databases
        ADD COLUMN host character varying, -- not null
        ADD COLUMN port integer,
        ADD COLUMN driver_id smallint, -- not null
        ADD COLUMN thinq_token character varying,
        ADD COLUMN thinq_username character varying,
        ADD COLUMN timeout smallint DEFAULT 300 NOT NULL,
        ADD COLUMN csv_file character varying;

      ALTER TABLE ONLY class4.lnp_databases
        ADD CONSTRAINT lnp_databases_driver_id_fkey FOREIGN KEY (driver_id) REFERENCES sys.lnp_database_drivers(id);
    SQL

    # fill thinq
    execute <<-SQL
      UPDATE class4.lnp_databases parent SET
        host = child.host,
        port = child.port,
        driver_id = 2,
        thinq_token = child.token,
        thinq_username = child.username,
        timeout = child.timeout
      FROM class4.lnp_databases_thinq child
      WHERE parent.database_id = child.id
        AND database_type = 'Lnp::DatabaseThinq';
    SQL

    # fill sip redirect
    execute <<-SQL
      UPDATE class4.lnp_databases parent SET
        host = child.host,
        port = child.port,
        driver_id = 1,
        timeout = child.timeout
      FROM class4.lnp_databases_30x_redirect child
      WHERE parent.database_id = child.id
        AND database_type = 'Lnp::DatabaseSipRedirect';
    SQL

    # fill csv
    execute <<-SQL
      UPDATE class4.lnp_databases parent SET
        csv_file = child.csv_file_path,
        driver_id = 3
      FROM class4.lnp_databases_csv child
      WHERE parent.database_id = child.id
        AND database_type = 'Lnp::DatabaseCsv';
    SQL

    # restore not null
    execute <<-SQL
      ALTER TABLE class4.lnp_databases
        ALTER COLUMN host SET NOT NULL,
        ALTER COLUMN driver_id SET NOT NULL;
    SQL

    # drop columns and tables
    execute <<-SQL
      ALTER TABLE class4.lnp_databases
        DROP COLUMN database_id,
        DROP COLUMN database_type;

      DROP TABLE class4.lnp_databases_thinq;
      DROP TABLE class4.lnp_databases_30x_redirect;
      DROP TABLE class4.lnp_databases_csv;
    SQL
  end
end
