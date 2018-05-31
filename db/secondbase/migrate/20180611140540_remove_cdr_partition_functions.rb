class RemoveCdrPartitionFunctions < ActiveRecord::Migration[5.1]
  def up
    execute %q{
      DROP FUNCTION sys.cdrtable_tgr_reload();
      DROP FUNCTION sys.cdr_reindex(character varying, character varying);
      DROP FUNCTION sys.cdr_createtable(integer);
    }
  end

  def down
    execute %q{
      CREATE FUNCTION sys.cdrtable_tgr_reload() RETURNS void
          LANGUAGE plpgsql
          AS $_$
      DECLARE
      v_tbname varchar;
      v_sql1 varchar:='CREATE OR REPLACE FUNCTION cdr.cdr_i_tgf() RETURNS trigger AS $trg$
      BEGIN  [MEAT]
      RETURN NULL;
      END; $trg$ LANGUAGE plpgsql VOLATILE COST 100';
      --v_sql2 varchar:='ALTER FUNCTION cdrs.cdrs_i_tgf() OWNER TO accadmin;';
      v_tb_row record;
      v_meat varchar;
      v_prfx varchar;
      v_counter integer;
      BEGIN
              v_meat:='';
              v_counter:='1';
              PERFORM * FROM sys.cdr_tables WHERE active;
              IF NOT FOUND THEN
                  RAISE EXCEPTION 'no tables for write data';
              end IF;
              FOR v_tb_row IN SELECT * FROM sys.cdr_tables WHERE active ORDER BY date_start LOOP
                      IF v_counter=1 THEN
                              v_prfx='IF ';
                      ELSE
                              v_prfx='ELSIF ';
                      END IF;
                      v_meat:=v_meat||v_prfx||'( NEW.time_start >= '''||v_tb_row.date_start||' 00:00:00+00'' AND NEW.time_start < '''||v_tb_row.date_stop||' 00:00:00+00'' ) THEN INSERT INTO '||v_tb_row.name||' VALUES (NEW.*);'|| E'\n';
                      v_counter:=v_counter+1;
              END LOOP;
              v_meat:=v_meat||' ELSE '|| E'\n'||' RAISE EXCEPTION ''cdr.cdr_i_tg: time_start out of range.''; '||E'\n'||' END IF;';
              v_sql1:=REPLACE(v_sql1,'[MEAT]',v_meat);
              set standard_conforming_strings=on;
              EXECUTE v_sql1;
            --  EXECUTE v_sql2;
              RAISE NOTICE 'sys.cdrtable_tgr_reload: CDR trigger reloaded';
             -- RETURN 'OK';
      END;
      $_$;


      CREATE FUNCTION sys.cdr_reindex(i_schema character varying, i_tbname character varying) RETURNS void
          LANGUAGE plpgsql
          AS $$
      DECLARE
      v_c integer;
      v_sql varchar;
      v_indname varchar;
      BEGIN
              SELECT into v_c count(*) from pg_tables where schemaname=i_schema and tablename=i_tbname;
              IF v_c=0 THEN
                      RAISE EXCEPTION 'sys.cdr_reindex: table % not exist',i_tbname;
              ELSE
                      -- CHECK primary key
                      SELECT into v_indname conname from pg_catalog.pg_constraint  where conname like i_tbname||'_pkey%';
                      IF NOT FOUND THEN
                              v_sql:='ALTER TABLE '||i_tbname||' ADD PRIMARY KEY (id);';
                              EXECUTE v_sql;
                              RAISE NOTICE 'sys.cdr_reindex: % add primary key' ,i_tbname;
                      END IF;
      /*
                      -- UNIQUE index on out_call_id;
                      SELECT into v_indname indexname FROM pg_catalog.pg_indexes WHERE schemaname=i_schemae AND tablename=i_tbname AND indexdef LIKE '%(out_call_id)%';
                      IF NOT FOUND THEN
                              v_sql:='CREATE UNIQUE INDEX ON '||i_schemae||'.'||i_tbname||' USING btree (out_call_id);';
                              RAISE NOTICE 'sys.cdr_reindex: % add index out_call_id' ,i_tbname;
                              EXECUTE v_sql;
                      ELSE
                              v_sql:='CREATE UNIQUE INDEX ON '||i_schemae||'.'||i_tbname||' USING btree (out_call_id);';
                              EXECUTE v_sql;
                              v_sql:='DROP INDEX cdrs.'||v_indname;
                              EXECUTE v_sql;
                              RAISE NOTICE 'sys.cdr_reindex: % reindex out_call_id' ,i_tbname;
                      END IF;
      */
                      -- index on time_inviteprocessed;
                      SELECT into v_indname indexname FROM pg_catalog.pg_indexes WHERE schemaname=i_schema AND tablename=i_tbname AND indexdef LIKE '%(time_start)%';
                      IF NOT FOUND THEN
                              v_sql:='CREATE INDEX ON '||i_schema||'.'||i_tbname||' USING btree (time_start);';
                              EXECUTE v_sql;
                              RAISE NOTICE 'sys.cdr_reindex: % add index time_start' ,i_tbname;
                      ELSE
                              v_sql:='CREATE INDEX ON '||i_schema||'.'||i_tbname||' USING btree (time_start);';
                              EXECUTE v_sql;
                              v_sql:='DROP INDEX '||i_schema||'.'||v_indname;
                              EXECUTE v_sql;
                              RAISE NOTICE 'sys.cdr_reindex: % reindex time_invite' ,i_tbname;
                      END IF;

              END IF;
              RETURN ;
      END;
      $$;


      CREATE FUNCTION sys.cdr_createtable(i_offset integer) RETURNS void
          LANGUAGE plpgsql COST 10000
          AS $$
      DECLARE
      v_tbname varchar;
      v_ftbname varchar;
      v_tdate varchar;
      v_start varchar;
      v_end varchar;
      v_c integer;
      v_sql varchar;

      BEGIN
              -- get tablename for next month;
              v_tdate:=to_char(now()+'1 month'::interval - i_offset * '1 month'::interval ,'YYYYMM');
              v_start:=to_char(now()+'1 month'::interval - i_offset * '1 month'::interval ,'YYYY-MM-01');
              v_end:=to_char(now()+'2 month'::interval - i_offset * '1 month'::interval,'YYYY-MM-01');

              v_tbname:='cdr_'||v_tdate;
              v_ftbname:='cdr.'||v_tbname::varchar;

              -- CHECK if table exists
              SELECT into v_c count(*) from pg_tables where schemaname='cdr' and tablename=v_tbname;
              IF v_c>0 THEN
                      RAISE NOTICE 'sys.cdr_createtable: next table % already created',v_tbname;
                      RETURN;
              ELSE
                      v_sql:='CREATE TABLE '||v_ftbname||'(
                      CONSTRAINT '||v_tbname||'_time_start_check CHECK (
                              time_start >= '''||v_start||' 00:00:00+00''
                              AND time_start < '''||v_end||' 00:00:00+00''
                      )
                      ) INHERITS (cdr.cdr)';
                      EXECUTE v_sql;
                      v_sql:='ALTER TABLE '||v_ftbname||' ADD PRIMARY KEY(id)';
                      EXECUTE v_sql;
                      RAISE NOTICE 'sys.cdr_createtable: next table % creating started',v_tbname;
                      PERFORM sys.cdr_reindex('cdr',v_tbname);
                      -- update trigger
                      INSERT INTO sys.cdr_tables(date_start,date_stop,"name",writable,readable) VALUES (v_start,v_end,v_ftbname,'t','t');
                      PERFORM sys.cdrtable_tgr_reload();
              END IF;
      END;
      $$;
    }
  end
end
