begin;
--
-- PostgreSQL database dump
--

-- Dumped from database version 9.3.5
-- Dumped by pg_dump version 9.3.5
-- Started on 2014-10-13 13:57:42 EEST

SET statement_timeout = 0;
SET lock_timeout = 0;
--SET client_encoding = 'SQL_ASCII';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- TOC entry 14 (class 2615 OID 17001)
-- Name: billing; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA billing;


--
-- TOC entry 12 (class 2615 OID 16998)
-- Name: cdr; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA cdr;


--
-- TOC entry 13 (class 2615 OID 16999)
-- Name: event; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA event;


--
-- TOC entry 7 (class 2615 OID 16645)
-- Name: pgq; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA pgq;


--
-- TOC entry 10 (class 2615 OID 16947)
-- Name: pgq_coop; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA pgq_coop;


--
-- TOC entry 8 (class 2615 OID 16798)
-- Name: pgq_ext; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA pgq_ext;


--
-- TOC entry 9 (class 2615 OID 16849)
-- Name: pgq_node; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA pgq_node;


--
-- TOC entry 11 (class 2615 OID 16995)
-- Name: switch; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA switch;


--
-- TOC entry 15 (class 2615 OID 17044)
-- Name: sys; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA sys;


--
-- TOC entry 214 (class 3079 OID 11756)
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- TOC entry 2370 (class 0 OID 0)
-- Dependencies: 214
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = billing, pg_catalog;

--
-- TOC entry 751 (class 1247 OID 17004)
-- Name: interval_billing_data; Type: TYPE; Schema: billing; Owner: -
--

CREATE TYPE interval_billing_data AS (
	duration numeric,
	amount numeric
);


SET search_path = cdr, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 205 (class 1259 OID 17025)
-- Name: cdr; Type: TABLE; Schema: cdr; Owner: -; Tablespace: 
--

CREATE TABLE cdr (
    id bigint NOT NULL,
    customer_id integer,
    vendor_id integer,
    customer_acc_id integer,
    vendor_acc_id integer,
    customer_auth_id integer,
    destination_id integer,
    dialpeer_id integer,
    orig_gw_id integer,
    term_gw_id integer,
    routing_group_id integer,
    rateplan_id integer,
    destination_next_rate numeric,
    destination_fee numeric,
    dialpeer_next_rate numeric,
    dialpeer_fee numeric,
    time_limit character varying,
    internal_disconnect_code integer,
    internal_disconnect_reason character varying,
    disconnect_initiator_id integer,
    customer_price numeric,
    vendor_price numeric,
    duration integer,
    success boolean,
    vendor_billed boolean DEFAULT false,
    customer_billed boolean DEFAULT false,
    profit numeric,
    dst_prefix_in character varying,
    dst_prefix_out character varying,
    src_prefix_in character varying,
    src_prefix_out character varying,
    time_start timestamp without time zone,
    time_connect timestamp without time zone,
    time_end timestamp without time zone,
    sign_orig_ip character varying,
    sign_orig_port integer,
    sign_orig_local_ip character varying,
    sign_orig_local_port integer,
    sign_term_ip character varying,
    sign_term_port integer,
    sign_term_local_ip character varying,
    sign_term_local_port integer,
    orig_call_id character varying,
    term_call_id character varying,
    vendor_invoice_id integer,
    customer_invoice_id integer,
    local_tag character varying,
    dump_file character varying,
    destination_initial_rate numeric,
    dialpeer_initial_rate numeric,
    destination_initial_interval integer,
    destination_next_interval integer,
    dialpeer_initial_interval integer,
    dialpeer_next_interval integer,
    destination_rate_policy_id integer,
    routing_attempt integer,
    is_last_cdr boolean,
    lega_disconnect_code integer,
    lega_disconnect_reason character varying,
    pop_id integer,
    node_id integer,
    src_name_in character varying,
    src_name_out character varying,
    diversion_in character varying,
    diversion_out character varying,
    lega_rx_payloads character varying,
    lega_tx_payloads character varying,
    legb_rx_payloads character varying,
    legb_tx_payloads character varying,
    legb_disconnect_code integer,
    legb_disconnect_reason character varying,
    dump_level_id integer DEFAULT 0 NOT NULL,
    auth_orig_ip inet,
    auth_orig_port integer,
    lega_rx_bytes integer,
    lega_tx_bytes integer,
    legb_rx_bytes integer,
    legb_tx_bytes integer,
    global_tag character varying
);


SET search_path = billing, pg_catalog;

--
-- TOC entry 338 (class 1255 OID 17069)
-- Name: bill_cdr(cdr.cdr); Type: FUNCTION; Schema: billing; Owner: -
--

CREATE FUNCTION bill_cdr(i_cdr cdr.cdr) RETURNS cdr.cdr
    LANGUAGE plpgsql COST 10
    AS $$
DECLARE
    _v billing.interval_billing_data%rowtype;
BEGIN
    if i_cdr.duration>0 and i_cdr.success then  -- run billing.
        _v=billing.interval_billing(
            i_cdr.duration,
            i_cdr.destination_fee,
            i_cdr.destination_initial_rate,
            i_cdr.destination_next_rate,
            i_cdr.destination_initial_interval,
            i_cdr.destination_next_interval,
            0);
         i_cdr.customer_price=_v.amount;
         
         _v=billing.interval_billing(
            i_cdr.duration,
            i_cdr.dialpeer_fee,
            i_cdr.dialpeer_initial_rate,
            i_cdr.dialpeer_next_rate,
            i_cdr.dialpeer_initial_interval,
            i_cdr.dialpeer_next_interval,
            0);
         i_cdr.vendor_price=_v.amount;
         i_cdr.profit=i_cdr.customer_price-i_cdr.vendor_price;
         i_cdr.vendor_billed=true;
         i_cdr.customer_billed=true;
    else
        i_cdr.customer_price=0;
        i_cdr.vendor_price=0;
        i_cdr.profit=0;
        i_cdr.vendor_billed=false;
        i_cdr.customer_billed=false;
    end if;
    RETURN i_cdr;
END;
$$;


--
-- TOC entry 330 (class 1255 OID 17005)
-- Name: interval_billing(numeric, numeric, numeric, numeric, numeric, numeric, numeric); Type: FUNCTION; Schema: billing; Owner: -
--

CREATE FUNCTION interval_billing(i_duration numeric, i_connection_fee numeric, i_initial_rate numeric, i_next_rate numeric, i_initial_interval numeric, i_next_interval numeric, i_vat numeric DEFAULT 0) RETURNS interval_billing_data
    LANGUAGE plpgsql COST 10
    AS $$
DECLARE
    _v billing.interval_billing_data%rowtype;
BEGIN
    i_vat=COALESCE(i_vat,0);
    _v.amount=i_connection_fee+
            i_initial_interval*i_initial_rate::numeric/60 + -- initial interval billing
            (i_duration>i_initial_interval)::boolean::integer * -- next interval billing enabled
            CEIL((i_duration-i_initial_interval)::numeric/i_next_interval) *-- next interval count
            i_next_interval * --interval len
            i_next_rate::numeric/60; -- next interval rate per second

    _v.duration=i_initial_interval+(i_duration>i_initial_interval)::boolean::integer * CEIL((i_duration-i_initial_interval)::numeric/i_next_interval) *i_next_interval;

    RETURN _v;
END;
$$;


SET search_path = cdr, pg_catalog;

--
-- TOC entry 331 (class 1255 OID 17022)
-- Name: cdr_i_tgf(); Type: FUNCTION; Schema: cdr; Owner: -
--

CREATE FUNCTION cdr_i_tgf() RETURNS trigger
    LANGUAGE plpgsql
    AS $$ 
BEGIN  IF ( NEW.time_start >= DATE '2014-08-01' AND NEW.time_start < DATE '2014-09-01' ) THEN INSERT INTO cdr.cdr_201408 VALUES (NEW.*);
ELSIF ( NEW.time_start >= DATE '2014-09-01' AND NEW.time_start < DATE '2014-10-01' ) THEN INSERT INTO cdr.cdr_201409 VALUES (NEW.*);
ELSIF ( NEW.time_start >= DATE '2014-10-01' AND NEW.time_start < DATE '2014-11-01' ) THEN INSERT INTO cdr.cdr_201410 VALUES (NEW.*);
ELSIF ( NEW.time_start >= DATE '2014-11-01' AND NEW.time_start < DATE '2014-12-01' ) THEN INSERT INTO cdr.cdr_201411 VALUES (NEW.*);
 ELSE 
 RAISE EXCEPTION 'cdr.cdr_i_tg: time_start out of range.'; 
 END IF;  
RETURN NULL; 
END; $$;


SET search_path = event, pg_catalog;

--
-- TOC entry 326 (class 1255 OID 17000)
-- Name: billing_insert_event(text, anyelement); Type: FUNCTION; Schema: event; Owner: -
--

CREATE FUNCTION billing_insert_event(ev_type text, ev_data anyelement) RETURNS bigint
    LANGUAGE plpgsql
    AS $$
begin
    return pgq.insert_event('cdr_billing', ev_type, event.serialize(ev_data), null, null, null, null);
end;
$$;


--
-- TOC entry 335 (class 1255 OID 17072)
-- Name: serialize(anyelement); Type: FUNCTION; Schema: event; Owner: -
--

CREATE FUNCTION serialize(i_data anyelement) RETURNS text
    LANGUAGE plpgsql COST 10
    AS $$
DECLARE
    _s text;
BEGIN
    _s:=row_to_json(i_data,false);
    return _s;
END;
$$;


SET search_path = pgq, pg_catalog;

--
-- TOC entry 248 (class 1255 OID 16762)
-- Name: _grant_perms_from(text, text, text, text); Type: FUNCTION; Schema: pgq; Owner: -
--

CREATE FUNCTION _grant_perms_from(src_schema text, src_table text, dst_schema text, dst_table text) RETURNS integer
    LANGUAGE plpgsql STRICT
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq.grant_perms_from(1)
--
--      Copy grants from one table to another.
--      Workaround for missing GRANTS option for CREATE TABLE LIKE.
-- ----------------------------------------------------------------------
declare
    fq_table text;
    sql text;
    g record;
    q_grantee text;
begin
    fq_table := quote_ident(dst_schema) || '.' || quote_ident(dst_table);

    for g in
        select grantor, grantee, privilege_type, is_grantable
            from information_schema.table_privileges
            where table_schema = src_schema
                and table_name = src_table
    loop
        if g.grantee = 'PUBLIC' then
            q_grantee = 'public';
        else
            q_grantee = quote_ident(g.grantee);
        end if;
        sql := 'grant ' || g.privilege_type || ' on ' || fq_table
            || ' to ' || q_grantee;
        if g.is_grantable = 'YES' then
            sql := sql || ' with grant option';
        end if;
        execute sql;
    end loop;

    return 1;
end;
$$;


--
-- TOC entry 240 (class 1255 OID 16747)
-- Name: batch_event_sql(bigint); Type: FUNCTION; Schema: pgq; Owner: -
--

CREATE FUNCTION batch_event_sql(x_batch_id bigint) RETURNS text
    LANGUAGE plpgsql
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq.batch_event_sql(1)
--      Creates SELECT statement that fetches events for this batch.
--
-- Parameters:
--      x_batch_id    - ID of a active batch.
--
-- Returns:
--      SQL statement.
-- ----------------------------------------------------------------------

-- ----------------------------------------------------------------------
-- Algorithm description:
--      Given 2 snapshots, sn1 and sn2 with sn1 having xmin1, xmax1
--      and sn2 having xmin2, xmax2 create expression that filters
--      right txid's from event table.
--
--      Simplest solution would be
--      > WHERE ev_txid >= xmin1 AND ev_txid <= xmax2
--      >   AND NOT txid_visible_in_snapshot(ev_txid, sn1)
--      >   AND txid_visible_in_snapshot(ev_txid, sn2)
--
--      The simple solution has a problem with long transactions (xmin1 very low).
--      All the batches that happen when the long tx is active will need
--      to scan all events in that range.  Here is 2 optimizations used:
--
--      1)  Use [xmax1..xmax2] for range scan.  That limits the range to
--      txids that actually happened between two snapshots.  For txids
--      in the range [xmin1..xmax1] look which ones were actually
--      committed between snapshots and search for them using exact
--      values using IN (..) list.
--
--      2) As most TX are short, there could be lot of them that were
--      just below xmax1, but were committed before xmax2.  So look
--      if there are ID's near xmax1 and lower the range to include
--      them, thus decresing size of IN (..) list.
-- ----------------------------------------------------------------------
declare
    rec             record;
    sql             text;
    tbl             text;
    arr             text;
    part            text;
    select_fields   text;
    retry_expr      text;
    batch           record;
begin
    select s.sub_last_tick, s.sub_next_tick, s.sub_id, s.sub_queue,
           txid_snapshot_xmax(last.tick_snapshot) as tx_start,
           txid_snapshot_xmax(cur.tick_snapshot) as tx_end,
           last.tick_snapshot as last_snapshot,
           cur.tick_snapshot as cur_snapshot
        into batch
        from pgq.subscription s, pgq.tick last, pgq.tick cur
        where s.sub_batch = x_batch_id
          and last.tick_queue = s.sub_queue
          and last.tick_id = s.sub_last_tick
          and cur.tick_queue = s.sub_queue
          and cur.tick_id = s.sub_next_tick;
    if not found then
        raise exception 'batch not found';
    end if;

    -- load older transactions
    arr := '';
    for rec in
        -- active tx-es in prev_snapshot that were committed in cur_snapshot
        select id1 from
            txid_snapshot_xip(batch.last_snapshot) id1 left join
            txid_snapshot_xip(batch.cur_snapshot) id2 on (id1 = id2)
        where id2 is null
        order by 1 desc
    loop
        -- try to avoid big IN expression, so try to include nearby
        -- tx'es into range
        if batch.tx_start - 100 <= rec.id1 then
            batch.tx_start := rec.id1;
        else
            if arr = '' then
                arr := rec.id1::text;
            else
                arr := arr || ',' || rec.id1::text;
            end if;
        end if;
    end loop;

    -- must match pgq.event_template
    select_fields := 'select ev_id, ev_time, ev_txid, ev_retry, ev_type,'
        || ' ev_data, ev_extra1, ev_extra2, ev_extra3, ev_extra4';
    retry_expr :=  ' and (ev_owner is null or ev_owner = '
        || batch.sub_id::text || ')';

    -- now generate query that goes over all potential tables
    sql := '';
    for rec in
        select xtbl from pgq.batch_event_tables(x_batch_id) xtbl
    loop
        tbl := pgq.quote_fqname(rec.xtbl);
        -- this gets newer queries that definitely are not in prev_snapshot
        part := select_fields
            || ' from pgq.tick cur, pgq.tick last, ' || tbl || ' ev '
            || ' where cur.tick_id = ' || batch.sub_next_tick::text
            || ' and cur.tick_queue = ' || batch.sub_queue::text
            || ' and last.tick_id = ' || batch.sub_last_tick::text
            || ' and last.tick_queue = ' || batch.sub_queue::text
            || ' and ev.ev_txid >= ' || batch.tx_start::text
            || ' and ev.ev_txid <= ' || batch.tx_end::text
            || ' and txid_visible_in_snapshot(ev.ev_txid, cur.tick_snapshot)'
            || ' and not txid_visible_in_snapshot(ev.ev_txid, last.tick_snapshot)'
            || retry_expr;
        -- now include older tx-es, that were ongoing
        -- at the time of prev_snapshot
        if arr <> '' then
            part := part || ' union all '
                || select_fields || ' from ' || tbl || ' ev '
                || ' where ev.ev_txid in (' || arr || ')'
                || retry_expr;
        end if;
        if sql = '' then
            sql := part;
        else
            sql := sql || ' union all ' || part;
        end if;
    end loop;
    if sql = '' then
        raise exception 'could not construct sql for batch %', x_batch_id;
    end if;
    return sql || ' order by 1';
end;
$$;


--
-- TOC entry 241 (class 1255 OID 16749)
-- Name: batch_event_tables(bigint); Type: FUNCTION; Schema: pgq; Owner: -
--

CREATE FUNCTION batch_event_tables(x_batch_id bigint) RETURNS SETOF text
    LANGUAGE plpgsql
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq.batch_event_tables(1)
--
--     Returns set of table names where this batch events may reside.
--
-- Parameters:
--     x_batch_id    - ID of a active batch.
-- ----------------------------------------------------------------------
declare
    nr                    integer;
    tbl                   text;
    use_prev              integer;
    use_next              integer;
    batch                 record;
begin
    select
           txid_snapshot_xmin(last.tick_snapshot) as tx_min, -- absolute minimum
           txid_snapshot_xmax(cur.tick_snapshot) as tx_max, -- absolute maximum
           q.queue_data_pfx, q.queue_ntables,
           q.queue_cur_table, q.queue_switch_step1, q.queue_switch_step2
        into batch
        from pgq.tick last, pgq.tick cur, pgq.subscription s, pgq.queue q
        where cur.tick_id = s.sub_next_tick
          and cur.tick_queue = s.sub_queue
          and last.tick_id = s.sub_last_tick
          and last.tick_queue = s.sub_queue
          and s.sub_batch = x_batch_id
          and q.queue_id = s.sub_queue;
    if not found then
        raise exception 'Cannot find data for batch %', x_batch_id;
    end if;

    -- if its definitely not in one or other, look into both
    if batch.tx_max < batch.queue_switch_step1 then
        use_prev := 1;
        use_next := 0;
    elsif batch.queue_switch_step2 is not null
      and (batch.tx_min > batch.queue_switch_step2)
    then
        use_prev := 0;
        use_next := 1;
    else
        use_prev := 1;
        use_next := 1;
    end if;

    if use_prev then
        nr := batch.queue_cur_table - 1;
        if nr < 0 then
            nr := batch.queue_ntables - 1;
        end if;
        tbl := batch.queue_data_pfx || '_' || nr::text;
        return next tbl;
    end if;

    if use_next then
        tbl := batch.queue_data_pfx || '_' || batch.queue_cur_table::text;
        return next tbl;
    end if;

    return;
end;
$$;


--
-- TOC entry 273 (class 1255 OID 16787)
-- Name: batch_retry(bigint, integer); Type: FUNCTION; Schema: pgq; Owner: -
--

CREATE FUNCTION batch_retry(i_batch_id bigint, i_retry_seconds integer) RETURNS integer
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq.batch_retry(2)
--
--     Put whole batch into retry queue, to be processed again later.
--
-- Parameters:
--      i_batch_id      - ID of active batch.
--      i_retry_time    - Time when the event should be put back into queue
--
-- Returns:
--     number of events inserted
-- Calls:
--      None
-- Tables directly manipulated:
--      pgq.retry_queue
-- ----------------------------------------------------------------------
declare
    _retry timestamptz;
    _cnt   integer;
    _s     record;
begin
    _retry := current_timestamp + ((i_retry_seconds::text || ' seconds')::interval);

    select * into _s from pgq.subscription where sub_batch = i_batch_id;
    if not found then
        raise exception 'batch_retry: batch % not found', i_batch_id;
    end if;

    insert into pgq.retry_queue (ev_retry_after, ev_queue,
        ev_id, ev_time, ev_txid, ev_owner, ev_retry,
        ev_type, ev_data, ev_extra1, ev_extra2,
        ev_extra3, ev_extra4)
    select distinct _retry, _s.sub_queue,
           b.ev_id, b.ev_time, NULL::int8, _s.sub_id, coalesce(b.ev_retry, 0) + 1,
           b.ev_type, b.ev_data, b.ev_extra1, b.ev_extra2,
           b.ev_extra3, b.ev_extra4
      from pgq.get_batch_events(i_batch_id) b
           left join pgq.retry_queue rq
                  on (rq.ev_id = b.ev_id
                      and rq.ev_owner = _s.sub_id
                      and rq.ev_queue = _s.sub_queue)
      where rq.ev_id is null;

    GET DIAGNOSTICS _cnt = ROW_COUNT;
    return _cnt;
end;
$$;


--
-- TOC entry 255 (class 1255 OID 16768)
-- Name: create_queue(text); Type: FUNCTION; Schema: pgq; Owner: -
--

CREATE FUNCTION create_queue(i_queue_name text) RETURNS integer
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq.create_queue(1)
--
--      Creates new queue with given name.
--
-- Returns:
--      0 - queue already exists
--      1 - queue created
-- Calls:
--      pgq.grant_perms(i_queue_name);
--      pgq.ticker(i_queue_name);
--      pgq.tune_storage(i_queue_name);
-- Tables directly manipulated:
--      insert - pgq.queue
--      create - pgq.event_N () inherits (pgq.event_template)
--      create - pgq.event_N_0 .. pgq.event_N_M () inherits (pgq.event_N)
-- ----------------------------------------------------------------------
declare
    tblpfx   text;
    tblname  text;
    idxpfx   text;
    idxname  text;
    sql      text;
    id       integer;
    tick_seq text;
    ev_seq text;
    n_tables integer;
begin
    if i_queue_name is null then
        raise exception 'Invalid NULL value';
    end if;

    -- check if exists
    perform 1 from pgq.queue where queue_name = i_queue_name;
    if found then
        return 0;
    end if;

    -- insert event
    id := nextval('pgq.queue_queue_id_seq');
    tblpfx := 'pgq.event_' || id::text;
    idxpfx := 'event_' || id::text;
    tick_seq := 'pgq.event_' || id::text || '_tick_seq';
    ev_seq := 'pgq.event_' || id::text || '_id_seq';
    insert into pgq.queue (queue_id, queue_name,
            queue_data_pfx, queue_event_seq, queue_tick_seq)
        values (id, i_queue_name, tblpfx, ev_seq, tick_seq);

    select queue_ntables into n_tables from pgq.queue
        where queue_id = id;

    -- create seqs
    execute 'CREATE SEQUENCE ' || pgq.quote_fqname(tick_seq);
    execute 'CREATE SEQUENCE ' || pgq.quote_fqname(ev_seq);

    -- create data tables
    execute 'CREATE TABLE ' || pgq.quote_fqname(tblpfx) || ' () '
            || ' INHERITS (pgq.event_template)';
    for i in 0 .. (n_tables - 1) loop
        tblname := tblpfx || '_' || i::text;
        idxname := idxpfx || '_' || i::text || '_txid_idx';
        execute 'CREATE TABLE ' || pgq.quote_fqname(tblname) || ' () '
                || ' INHERITS (' || pgq.quote_fqname(tblpfx) || ')';
        execute 'ALTER TABLE ' || pgq.quote_fqname(tblname) || ' ALTER COLUMN ev_id '
                || ' SET DEFAULT nextval(' || quote_literal(ev_seq) || ')';
        execute 'create index ' || quote_ident(idxname) || ' on '
                || pgq.quote_fqname(tblname) || ' (ev_txid)';
    end loop;

    perform pgq.grant_perms(i_queue_name);

    perform pgq.ticker(i_queue_name);

    perform pgq.tune_storage(i_queue_name);

    return 1;
end;
$$;


--
-- TOC entry 262 (class 1255 OID 16774)
-- Name: current_event_table(text); Type: FUNCTION; Schema: pgq; Owner: -
--

CREATE FUNCTION current_event_table(x_queue_name text) RETURNS text
    LANGUAGE plpgsql
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq.current_event_table(1)
--
--      Return active event table for particular queue.
--      Event can be added to it without going via functions,
--      e.g. by COPY.
--
--      If queue is disabled and GUC session_replication_role <> 'replica'
--      then raises exception.
--
--      or expressed in a different way - an even table of a disabled queue
--      is returned only on replica
--
-- Note:
--      The result is valid only during current transaction.
--
-- Permissions:
--      Actual insertion requires superuser access.
--
-- Parameters:
--      x_queue_name    - Queue name.
-- ----------------------------------------------------------------------
declare
    res text;
    disabled boolean;
begin
    select queue_data_pfx || '_' || queue_cur_table::text,
           queue_disable_insert
        into res, disabled
        from pgq.queue where queue_name = x_queue_name;
    if not found then
        raise exception 'Event queue not found';
    end if;
    if disabled then
        if current_setting('session_replication_role') <> 'replica' then
            raise exception 'Writing to queue disabled';
        end if;
    end if;
    return res;
end;
$$;


--
-- TOC entry 257 (class 1255 OID 16770)
-- Name: drop_queue(text); Type: FUNCTION; Schema: pgq; Owner: -
--

CREATE FUNCTION drop_queue(x_queue_name text) RETURNS integer
    LANGUAGE plpgsql STRICT
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq.drop_queue(1)
--
--     Drop queue and all associated tables.
--     No consumers must be listening on the queue.
--
-- ----------------------------------------------------------------------
begin
    return pgq.drop_queue(x_queue_name, false);
end;
$$;


--
-- TOC entry 256 (class 1255 OID 16769)
-- Name: drop_queue(text, boolean); Type: FUNCTION; Schema: pgq; Owner: -
--

CREATE FUNCTION drop_queue(x_queue_name text, x_force boolean) RETURNS integer
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq.drop_queue(2)
--
--     Drop queue and all associated tables.
--
-- Parameters:
--      x_queue_name    - queue name
--      x_force         - ignore (drop) existing consumers
-- Returns:
--      1 - success
-- Calls:
--      pgq.unregister_consumer(queue_name, consumer_name)
--      perform pgq.ticker(i_queue_name);
--      perform pgq.tune_storage(i_queue_name);
-- Tables directly manipulated:
--      delete - pgq.queue
--      drop - pgq.event_N (), pgq.event_N_0 .. pgq.event_N_M 
-- ----------------------------------------------------------------------
declare
    tblname  text;
    q record;
    num integer;
begin
    -- check if exists
    select * into q from pgq.queue
        where queue_name = x_queue_name
        for update;
    if not found then
        raise exception 'No such event queue';
    end if;

    if x_force then
        perform pgq.unregister_consumer(queue_name, consumer_name)
           from pgq.get_consumer_info(x_queue_name);
    else
        -- check if no consumers
        select count(*) into num from pgq.subscription
            where sub_queue = q.queue_id;
        if num > 0 then
            raise exception 'cannot drop queue, consumers still attached';
        end if;
    end if;

    -- drop data tables
    for i in 0 .. (q.queue_ntables - 1) loop
        tblname := q.queue_data_pfx || '_' || i::text;
        execute 'DROP TABLE ' || pgq.quote_fqname(tblname);
    end loop;
    execute 'DROP TABLE ' || pgq.quote_fqname(q.queue_data_pfx);

    -- delete ticks
    delete from pgq.tick where tick_queue = q.queue_id;

    -- drop seqs
    -- FIXME: any checks needed here?
    execute 'DROP SEQUENCE ' || pgq.quote_fqname(q.queue_tick_seq);
    execute 'DROP SEQUENCE ' || pgq.quote_fqname(q.queue_event_seq);

    -- delete event
    delete from pgq.queue
        where queue_name = x_queue_name;

    return 1;
end;
$$;


--
-- TOC entry 272 (class 1255 OID 16786)
-- Name: event_retry(bigint, bigint, integer); Type: FUNCTION; Schema: pgq; Owner: -
--

CREATE FUNCTION event_retry(x_batch_id bigint, x_event_id bigint, x_retry_seconds integer) RETURNS integer
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq.event_retry(3b)
--
--     Put the event into retry queue, to be processed later again.
--
-- Parameters:
--      x_batch_id      - ID of active batch.
--      x_event_id      - event id
--      x_retry_seconds - Time when the event should be put back into queue
--
-- Returns:
--     1 - success
--     0 - event already in retry queue
-- Calls:
--      pgq.event_retry(3a)
-- Tables directly manipulated:
--      None
-- ----------------------------------------------------------------------
declare
    new_retry  timestamptz;
begin
    new_retry := current_timestamp + ((x_retry_seconds::text || ' seconds')::interval);
    return pgq.event_retry(x_batch_id, x_event_id, new_retry);
end;
$$;


--
-- TOC entry 271 (class 1255 OID 16785)
-- Name: event_retry(bigint, bigint, timestamp with time zone); Type: FUNCTION; Schema: pgq; Owner: -
--

CREATE FUNCTION event_retry(x_batch_id bigint, x_event_id bigint, x_retry_time timestamp with time zone) RETURNS integer
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq.event_retry(3a)
--
--     Put the event into retry queue, to be processed again later.
--
-- Parameters:
--      x_batch_id      - ID of active batch.
--      x_event_id      - event id
--      x_retry_time    - Time when the event should be put back into queue
--
-- Returns:
--     1 - success
--     0 - event already in retry queue
-- Calls:
--      None
-- Tables directly manipulated:
--      insert - pgq.retry_queue
-- ----------------------------------------------------------------------
begin
    insert into pgq.retry_queue (ev_retry_after, ev_queue,
        ev_id, ev_time, ev_txid, ev_owner, ev_retry, ev_type, ev_data,
        ev_extra1, ev_extra2, ev_extra3, ev_extra4)
    select x_retry_time, sub_queue,
           ev_id, ev_time, NULL, sub_id, coalesce(ev_retry, 0) + 1,
           ev_type, ev_data, ev_extra1, ev_extra2, ev_extra3, ev_extra4
      from pgq.get_batch_events(x_batch_id),
           pgq.subscription
     where sub_batch = x_batch_id
       and ev_id = x_event_id;
    if not found then
        raise exception 'event not found';
    end if;
    return 1;

-- dont worry if the event is already in queue
exception
    when unique_violation then
        return 0;
end;
$$;


--
-- TOC entry 242 (class 1255 OID 16750)
-- Name: event_retry_raw(text, text, timestamp with time zone, bigint, timestamp with time zone, integer, text, text, text, text, text, text); Type: FUNCTION; Schema: pgq; Owner: -
--

CREATE FUNCTION event_retry_raw(x_queue text, x_consumer text, x_retry_after timestamp with time zone, x_ev_id bigint, x_ev_time timestamp with time zone, x_ev_retry integer, x_ev_type text, x_ev_data text, x_ev_extra1 text, x_ev_extra2 text, x_ev_extra3 text, x_ev_extra4 text) RETURNS bigint
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq.event_retry_raw(12)
--
--      Allows full control over what goes to retry queue.
--
-- Parameters:
--      x_queue         - name of the queue
--      x_consumer      - name of the consumer
--      x_retry_after   - when the event should be processed again
--      x_ev_id         - event id
--      x_ev_time       - creation time
--      x_ev_retry      - retry count
--      x_ev_type       - user data
--      x_ev_data       - user data
--      x_ev_extra1     - user data
--      x_ev_extra2     - user data
--      x_ev_extra3     - user data
--      x_ev_extra4     - user data
--
-- Returns:
--      Event ID.
-- ----------------------------------------------------------------------
declare
    q record;
    id bigint;
begin
    select sub_id, queue_event_seq, sub_queue into q
      from pgq.consumer, pgq.queue, pgq.subscription
     where queue_name = x_queue
       and co_name = x_consumer
       and sub_consumer = co_id
       and sub_queue = queue_id;
    if not found then
        raise exception 'consumer not registered';
    end if;

    id := x_ev_id;
    if id is null then
        id := nextval(q.queue_event_seq);
    end if;

    insert into pgq.retry_queue (ev_retry_after, ev_queue,
            ev_id, ev_time, ev_owner, ev_retry,
            ev_type, ev_data, ev_extra1, ev_extra2, ev_extra3, ev_extra4)
    values (x_retry_after, q.sub_queue,
            id, x_ev_time, q.sub_id, x_ev_retry,
            x_ev_type, x_ev_data, x_ev_extra1, x_ev_extra2,
            x_ev_extra3, x_ev_extra4);

    return id;
end;
$$;


--
-- TOC entry 243 (class 1255 OID 16751)
-- Name: find_tick_helper(integer, bigint, timestamp with time zone, bigint, bigint, interval); Type: FUNCTION; Schema: pgq; Owner: -
--

CREATE FUNCTION find_tick_helper(i_queue_id integer, i_prev_tick_id bigint, i_prev_tick_time timestamp with time zone, i_prev_tick_seq bigint, i_min_count bigint, i_min_interval interval, OUT next_tick_id bigint, OUT next_tick_time timestamp with time zone, OUT next_tick_seq bigint) RETURNS record
    LANGUAGE plpgsql STABLE
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq.find_tick_helper(6)
--
--      Helper function for pgq.next_batch_custom() to do extended tick search.
-- ----------------------------------------------------------------------
declare
    sure    boolean;
    can_set boolean;
    t       record;
    cnt     int8;
    ival    interval;
begin
    -- first, fetch last tick of the queue
    select tick_id, tick_time, tick_event_seq into t
        from pgq.tick
        where tick_queue = i_queue_id
          and tick_id > i_prev_tick_id
        order by tick_queue desc, tick_id desc
        limit 1;
    if not found then
        return;
    end if;
    
    -- check whether batch would end up within reasonable limits
    sure := true;
    can_set := false;
    if i_min_count is not null then
        cnt = t.tick_event_seq - i_prev_tick_seq;
        if cnt >= i_min_count then
            can_set := true;
        end if;
        if cnt > i_min_count * 2 then
            sure := false;
        end if;
    end if;
    if i_min_interval is not null then
        ival = t.tick_time - i_prev_tick_time;
        if ival >= i_min_interval then
            can_set := true;
        end if;
        if ival > i_min_interval * 2 then
            sure := false;
        end if;
    end if;

    -- if last tick too far away, do large scan
    if not sure then
        select tick_id, tick_time, tick_event_seq into t
            from pgq.tick
            where tick_queue = i_queue_id
              and tick_id > i_prev_tick_id
              and ((i_min_count is not null and (tick_event_seq - i_prev_tick_seq) >= i_min_count)
                  or
                   (i_min_interval is not null and (tick_time - i_prev_tick_time) >= i_min_interval))
            order by tick_queue asc, tick_id asc
            limit 1;
        can_set := true;
    end if;
    if can_set then
        next_tick_id := t.tick_id;
        next_tick_time := t.tick_time;
        next_tick_seq := t.tick_event_seq;
    end if;
    return;
end;
$$;


--
-- TOC entry 274 (class 1255 OID 16788)
-- Name: finish_batch(bigint); Type: FUNCTION; Schema: pgq; Owner: -
--

CREATE FUNCTION finish_batch(x_batch_id bigint) RETURNS integer
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq.finish_batch(1)
--
--      Closes a batch.  No more operations can be done with events
--      of this batch.
--
-- Parameters:
--      x_batch_id      - id of batch.
--
-- Returns:
--      1 if batch was found, 0 otherwise.
-- Calls:
--      None
-- Tables directly manipulated:
--      update - pgq.subscription
-- ----------------------------------------------------------------------
begin
    update pgq.subscription
        set sub_active = now(),
            sub_last_tick = sub_next_tick,
            sub_next_tick = null,
            sub_batch = null
        where sub_batch = x_batch_id;
    if not found then
        raise warning 'finish_batch: batch % not found', x_batch_id;
        return 0;
    end if;

    return 1;
end;
$$;


--
-- TOC entry 250 (class 1255 OID 16764)
-- Name: force_tick(text); Type: FUNCTION; Schema: pgq; Owner: -
--

CREATE FUNCTION force_tick(i_queue_name text) RETURNS bigint
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq.force_tick(2)
--
--      Simulate lots of events happening to force ticker to tick.
--
--      Should be called in loop, with some delay until last tick
--      changes or too much time is passed.
--
--      Such function is needed because paraller calls of pgq.ticker() are
--      dangerous, and cannot be protected with locks as snapshot
--      is taken before locking.
--
-- Parameters:
--      i_queue_name     - Name of the queue
--
-- Returns:
--      Currently last tick id.
-- ----------------------------------------------------------------------
declare
    q  record;
    t  record;
begin
    -- bump seq and get queue id
    select queue_id,
           setval(queue_event_seq, nextval(queue_event_seq)
                                   + queue_ticker_max_count * 2 + 1000) as tmp
      into q from pgq.queue
     where queue_name = i_queue_name
       and not queue_external_ticker
       and not queue_ticker_paused;

    --if not found then
    --    raise notice 'queue not found or ticks not allowed';
    --end if;

    -- return last tick id
    select tick_id into t
      from pgq.tick, pgq.queue
     where tick_queue = queue_id and queue_name = i_queue_name
     order by tick_queue desc, tick_id desc limit 1;

    return t.tick_id;
end;
$$;


--
-- TOC entry 270 (class 1255 OID 16784)
-- Name: get_batch_cursor(bigint, text, integer); Type: FUNCTION; Schema: pgq; Owner: -
--

CREATE FUNCTION get_batch_cursor(i_batch_id bigint, i_cursor_name text, i_quick_limit integer, OUT ev_id bigint, OUT ev_time timestamp with time zone, OUT ev_txid bigint, OUT ev_retry integer, OUT ev_type text, OUT ev_data text, OUT ev_extra1 text, OUT ev_extra2 text, OUT ev_extra3 text, OUT ev_extra4 text) RETURNS SETOF record
    LANGUAGE plpgsql STRICT
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq.get_batch_cursor(3)
--
--      Get events in batch using a cursor.
--
-- Parameters:
--      i_batch_id      - ID of active batch.
--      i_cursor_name   - Name for new cursor
--      i_quick_limit   - Number of events to return immediately
--
-- Returns:
--      List of events.
-- Calls:
--      pgq.get_batch_cursor(4)
-- ----------------------------------------------------------------------
begin
    for ev_id, ev_time, ev_txid, ev_retry, ev_type, ev_data,
        ev_extra1, ev_extra2, ev_extra3, ev_extra4
    in
        select * from pgq.get_batch_cursor(i_batch_id,
            i_cursor_name, i_quick_limit, null)
    loop
        return next;
    end loop;
    return;
end;
$$;


--
-- TOC entry 269 (class 1255 OID 16783)
-- Name: get_batch_cursor(bigint, text, integer, text); Type: FUNCTION; Schema: pgq; Owner: -
--

CREATE FUNCTION get_batch_cursor(i_batch_id bigint, i_cursor_name text, i_quick_limit integer, i_extra_where text, OUT ev_id bigint, OUT ev_time timestamp with time zone, OUT ev_txid bigint, OUT ev_retry integer, OUT ev_type text, OUT ev_data text, OUT ev_extra1 text, OUT ev_extra2 text, OUT ev_extra3 text, OUT ev_extra4 text) RETURNS SETOF record
    LANGUAGE plpgsql
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq.get_batch_cursor(4)
--
--      Get events in batch using a cursor.
--
-- Parameters:
--      i_batch_id      - ID of active batch.
--      i_cursor_name   - Name for new cursor
--      i_quick_limit   - Number of events to return immediately
--      i_extra_where   - optional where clause to filter events
--
-- Returns:
--      List of events.
-- Calls:
--      pgq.batch_event_sql(i_batch_id) - internal function which generates SQL optimised specially for getting events in this batch
-- ----------------------------------------------------------------------
declare
    _cname  text;
    _sql    text;
begin
    if i_batch_id is null or i_cursor_name is null or i_quick_limit is null then
        return;
    end if;

    _cname := quote_ident(i_cursor_name);
    _sql := pgq.batch_event_sql(i_batch_id);

    -- apply extra where
    if i_extra_where is not null then
        _sql := replace(_sql, ' order by 1', '');
        _sql := 'select * from (' || _sql
            || ') _evs where ' || i_extra_where
            || ' order by 1';
    end if;

    -- create cursor
    execute 'declare ' || _cname || ' no scroll cursor for ' || _sql;

    -- if no events wanted, don't bother with execute
    if i_quick_limit <= 0 then
        return;
    end if;

    -- return first block of events
    for ev_id, ev_time, ev_txid, ev_retry, ev_type, ev_data,
        ev_extra1, ev_extra2, ev_extra3, ev_extra4
        in execute 'fetch ' || i_quick_limit::text || ' from ' || _cname
    loop
        return next;
    end loop;

    return;
end;
$$;


--
-- TOC entry 268 (class 1255 OID 16782)
-- Name: get_batch_events(bigint); Type: FUNCTION; Schema: pgq; Owner: -
--

CREATE FUNCTION get_batch_events(x_batch_id bigint, OUT ev_id bigint, OUT ev_time timestamp with time zone, OUT ev_txid bigint, OUT ev_retry integer, OUT ev_type text, OUT ev_data text, OUT ev_extra1 text, OUT ev_extra2 text, OUT ev_extra3 text, OUT ev_extra4 text) RETURNS SETOF record
    LANGUAGE plpgsql
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq.get_batch_events(1)
--
--      Get all events in batch.
--
-- Parameters:
--      x_batch_id      - ID of active batch.
--
-- Returns:
--      List of events.
-- ----------------------------------------------------------------------
declare
    sql text;
begin
    sql := pgq.batch_event_sql(x_batch_id);
    for ev_id, ev_time, ev_txid, ev_retry, ev_type, ev_data,
        ev_extra1, ev_extra2, ev_extra3, ev_extra4
        in execute sql
    loop
        return next;
    end loop;
    return;
end;
$$;


--
-- TOC entry 281 (class 1255 OID 16795)
-- Name: get_batch_info(bigint); Type: FUNCTION; Schema: pgq; Owner: -
--

CREATE FUNCTION get_batch_info(x_batch_id bigint, OUT queue_name text, OUT consumer_name text, OUT batch_start timestamp with time zone, OUT batch_end timestamp with time zone, OUT prev_tick_id bigint, OUT tick_id bigint, OUT lag interval, OUT seq_start bigint, OUT seq_end bigint) RETURNS record
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq.get_batch_info(1)
--
--      Returns detailed info about a batch.
--
-- Parameters:
--      x_batch_id      - id of a active batch.
--
-- Returns: ??? pls check
--      queue_name      - which queue this batch came from
--      consumer_name   - batch processed by
--      batch_start     - start time of batch
--      batch_end       - end time of batch
--      prev_tick_id    - start tick for this batch
--      tick_id         - end tick for this batch
--      lag             - now() - tick_id.time 
--      seq_start       - start event id for batch
--      seq_end         - end event id for batch
-- ----------------------------------------------------------------------
begin
    select q.queue_name, c.co_name,
           prev.tick_time, cur.tick_time,
           s.sub_last_tick, s.sub_next_tick,
           current_timestamp - cur.tick_time,
           prev.tick_event_seq, cur.tick_event_seq
        into queue_name, consumer_name, batch_start, batch_end,
             prev_tick_id, tick_id, lag, seq_start, seq_end
        from pgq.subscription s, pgq.tick cur, pgq.tick prev,
             pgq.queue q, pgq.consumer c
        where s.sub_batch = x_batch_id
          and prev.tick_id = s.sub_last_tick
          and prev.tick_queue = s.sub_queue
          and cur.tick_id = s.sub_next_tick
          and cur.tick_queue = s.sub_queue
          and q.queue_id = s.sub_queue
          and c.co_id = s.sub_consumer;
    return;
end;
$$;


--
-- TOC entry 277 (class 1255 OID 16791)
-- Name: get_consumer_info(); Type: FUNCTION; Schema: pgq; Owner: -
--

CREATE FUNCTION get_consumer_info(OUT queue_name text, OUT consumer_name text, OUT lag interval, OUT last_seen interval, OUT last_tick bigint, OUT current_batch bigint, OUT next_tick bigint, OUT pending_events bigint) RETURNS SETOF record
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq.get_consumer_info(0)
--
--      Returns info about all consumers on all queues.
--
-- Returns:
--      See pgq.get_consumer_info(2)
-- ----------------------------------------------------------------------
begin
    for queue_name, consumer_name, lag, last_seen,
        last_tick, current_batch, next_tick, pending_events
    in
        select f.queue_name, f.consumer_name, f.lag, f.last_seen,
               f.last_tick, f.current_batch, f.next_tick, f.pending_events
            from pgq.get_consumer_info(null, null) f
    loop
        return next;
    end loop;
    return;
end;
$$;


--
-- TOC entry 278 (class 1255 OID 16792)
-- Name: get_consumer_info(text); Type: FUNCTION; Schema: pgq; Owner: -
--

CREATE FUNCTION get_consumer_info(i_queue_name text, OUT queue_name text, OUT consumer_name text, OUT lag interval, OUT last_seen interval, OUT last_tick bigint, OUT current_batch bigint, OUT next_tick bigint, OUT pending_events bigint) RETURNS SETOF record
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq.get_consumer_info(1)
--
--      Returns info about all consumers on single queue.
--
-- Returns:
--      See pgq.get_consumer_info(2)
-- ----------------------------------------------------------------------
begin
    for queue_name, consumer_name, lag, last_seen,
        last_tick, current_batch, next_tick, pending_events
    in
        select f.queue_name, f.consumer_name, f.lag, f.last_seen,
               f.last_tick, f.current_batch, f.next_tick, f.pending_events
            from pgq.get_consumer_info(i_queue_name, null) f
    loop
        return next;
    end loop;
    return;
end;
$$;


--
-- TOC entry 279 (class 1255 OID 16793)
-- Name: get_consumer_info(text, text); Type: FUNCTION; Schema: pgq; Owner: -
--

CREATE FUNCTION get_consumer_info(i_queue_name text, i_consumer_name text, OUT queue_name text, OUT consumer_name text, OUT lag interval, OUT last_seen interval, OUT last_tick bigint, OUT current_batch bigint, OUT next_tick bigint, OUT pending_events bigint) RETURNS SETOF record
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq.get_consumer_info(2)
--
--      Get info about particular consumer on particular queue.
--
-- Parameters:
--      i_queue_name        - name of a queue. (null = all)
--      i_consumer_name     - name of a consumer (null = all)
--
-- Returns:
--      queue_name          - Queue name
--      consumer_name       - Consumer name
--      lag                 - How old are events the consumer is processing
--      last_seen           - When the consumer seen by pgq
--      last_tick           - Tick ID of last processed tick
--      current_batch       - Current batch ID, if one is active or NULL
--      next_tick           - If batch is active, then its final tick.
-- ----------------------------------------------------------------------
declare
    _pending_events bigint;
    _queue_id bigint;
begin
    for queue_name, consumer_name, lag, last_seen,
        last_tick, current_batch, next_tick, _pending_events, _queue_id
    in
        select q.queue_name, c.co_name,
               current_timestamp - t.tick_time,
               current_timestamp - s.sub_active,
               s.sub_last_tick, s.sub_batch, s.sub_next_tick,
               t.tick_event_seq, q.queue_id
          from pgq.queue q,
               pgq.consumer c,
               pgq.subscription s
               left join pgq.tick t
                 on (t.tick_queue = s.sub_queue and t.tick_id = s.sub_last_tick)
         where q.queue_id = s.sub_queue
           and c.co_id = s.sub_consumer
           and (i_queue_name is null or q.queue_name = i_queue_name)
           and (i_consumer_name is null or c.co_name = i_consumer_name)
         order by 1,2
    loop
        select t.tick_event_seq - _pending_events
            into pending_events
            from pgq.tick t
            where t.tick_queue = _queue_id
            order by t.tick_queue desc, t.tick_id desc
            limit 1;
        return next;
    end loop;
    return;
end;
$$;


--
-- TOC entry 275 (class 1255 OID 16789)
-- Name: get_queue_info(); Type: FUNCTION; Schema: pgq; Owner: -
--

CREATE FUNCTION get_queue_info(OUT queue_name text, OUT queue_ntables integer, OUT queue_cur_table integer, OUT queue_rotation_period interval, OUT queue_switch_time timestamp with time zone, OUT queue_external_ticker boolean, OUT queue_ticker_paused boolean, OUT queue_ticker_max_count integer, OUT queue_ticker_max_lag interval, OUT queue_ticker_idle_period interval, OUT ticker_lag interval, OUT ev_per_sec double precision, OUT ev_new bigint, OUT last_tick_id bigint) RETURNS SETOF record
    LANGUAGE plpgsql
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq.get_queue_info(0)
--
--      Get info about all queues.
--
-- Returns:
--      List of pgq.ret_queue_info records.
--     queue_name                  - queue name
--     queue_ntables               - number of tables in this queue
--     queue_cur_table             - ???
--     queue_rotation_period       - how often the event_N_M tables in this queue are rotated
--     queue_switch_time           - ??? when was this queue last rotated
--     queue_external_ticker       - ???
--     queue_ticker_paused         - ??? is ticker paused in this queue
--     queue_ticker_max_count      - max number of events before a tick is issued
--     queue_ticker_max_lag        - maks time without a tick
--     queue_ticker_idle_period    - how often the ticker should check this queue
--     ticker_lag                  - time from last tick
--     ev_per_sec                  - how many events per second this queue serves
--     ev_new                      - ???
--     last_tick_id                - last tick id for this queue
--
-- ----------------------------------------------------------------------
begin
    for queue_name, queue_ntables, queue_cur_table, queue_rotation_period,
        queue_switch_time, queue_external_ticker, queue_ticker_paused,
        queue_ticker_max_count, queue_ticker_max_lag, queue_ticker_idle_period,
        ticker_lag, ev_per_sec, ev_new, last_tick_id
    in select
        f.queue_name, f.queue_ntables, f.queue_cur_table, f.queue_rotation_period,
        f.queue_switch_time, f.queue_external_ticker, f.queue_ticker_paused,
        f.queue_ticker_max_count, f.queue_ticker_max_lag, f.queue_ticker_idle_period,
        f.ticker_lag, f.ev_per_sec, f.ev_new, f.last_tick_id
        from pgq.get_queue_info(null) f
    loop
        return next;
    end loop;
    return;
end;
$$;


--
-- TOC entry 276 (class 1255 OID 16790)
-- Name: get_queue_info(text); Type: FUNCTION; Schema: pgq; Owner: -
--

CREATE FUNCTION get_queue_info(i_queue_name text, OUT queue_name text, OUT queue_ntables integer, OUT queue_cur_table integer, OUT queue_rotation_period interval, OUT queue_switch_time timestamp with time zone, OUT queue_external_ticker boolean, OUT queue_ticker_paused boolean, OUT queue_ticker_max_count integer, OUT queue_ticker_max_lag interval, OUT queue_ticker_idle_period interval, OUT ticker_lag interval, OUT ev_per_sec double precision, OUT ev_new bigint, OUT last_tick_id bigint) RETURNS SETOF record
    LANGUAGE plpgsql
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq.get_queue_info(1)
--
--      Get info about particular queue.
--
-- Returns:
--      One pgq.ret_queue_info record.
--      contente same as forpgq.get_queue_info() 
-- ----------------------------------------------------------------------
declare
    _ticker_lag interval;
    _top_tick_id bigint;
    _ht_tick_id bigint;
    _top_tick_time timestamptz;
    _top_tick_event_seq bigint;
    _ht_tick_time timestamptz;
    _ht_tick_event_seq bigint;
    _queue_id integer;
    _queue_event_seq text;
begin
    for queue_name, queue_ntables, queue_cur_table, queue_rotation_period,
        queue_switch_time, queue_external_ticker, queue_ticker_paused,
        queue_ticker_max_count, queue_ticker_max_lag, queue_ticker_idle_period,
        _queue_id, _queue_event_seq
    in select
        q.queue_name, q.queue_ntables, q.queue_cur_table,
        q.queue_rotation_period, q.queue_switch_time,
        q.queue_external_ticker, q.queue_ticker_paused,
        q.queue_ticker_max_count, q.queue_ticker_max_lag,
        q.queue_ticker_idle_period,
        q.queue_id, q.queue_event_seq
        from pgq.queue q
        where (i_queue_name is null or q.queue_name = i_queue_name)
        order by q.queue_name
    loop
        -- most recent tick
        select (current_timestamp - t.tick_time),
               tick_id, t.tick_time, t.tick_event_seq
            into ticker_lag, _top_tick_id, _top_tick_time, _top_tick_event_seq
            from pgq.tick t
            where t.tick_queue = _queue_id
            order by t.tick_queue desc, t.tick_id desc
            limit 1;
        -- slightly older tick
        select ht.tick_id, ht.tick_time, ht.tick_event_seq
            into _ht_tick_id, _ht_tick_time, _ht_tick_event_seq
            from pgq.tick ht
            where ht.tick_queue = _queue_id
             and ht.tick_id >= _top_tick_id - 20
            order by ht.tick_queue asc, ht.tick_id asc
            limit 1;
        if _ht_tick_time < _top_tick_time then
            ev_per_sec = (_top_tick_event_seq - _ht_tick_event_seq) / extract(epoch from (_top_tick_time - _ht_tick_time));
        else
            ev_per_sec = null;
        end if;
        ev_new = pgq.seq_getval(_queue_event_seq) - _top_tick_event_seq;
        last_tick_id = _top_tick_id;
        return next;
    end loop;
    return;
end;
$$;


--
-- TOC entry 247 (class 1255 OID 16761)
-- Name: grant_perms(text); Type: FUNCTION; Schema: pgq; Owner: -
--

CREATE FUNCTION grant_perms(x_queue_name text) RETURNS integer
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq.grant_perms(1)
--
--      Make event tables readable by public.
--
-- Parameters:
--      x_queue_name        - Name of the queue.
--
-- Returns:
--      nothing
-- ----------------------------------------------------------------------
declare
    q           record;
    i           integer;
    pos         integer;
    tbl_perms   text;
    seq_perms   text;
    dst_schema  text;
    dst_table   text;
    part_table  text;
begin
    select * from pgq.queue into q
        where queue_name = x_queue_name;
    if not found then
        raise exception 'Queue not found';
    end if;

    -- split data table name to components
    pos := position('.' in q.queue_data_pfx);
    if pos > 0 then
        dst_schema := substring(q.queue_data_pfx for pos - 1);
        dst_table := substring(q.queue_data_pfx from pos + 1);
    else
        dst_schema := 'public';
        dst_table := q.queue_data_pfx;
    end if;

    -- tick seq, normal users don't need to modify it
    execute 'grant select on ' || pgq.quote_fqname(q.queue_tick_seq) || ' to public';

    -- event seq
    execute 'grant select on ' || pgq.quote_fqname(q.queue_event_seq) || ' to public';
    
    -- set grants on parent table
    perform pgq._grant_perms_from('pgq', 'event_template', dst_schema, dst_table);

    -- set grants on real event tables
    for i in 0 .. q.queue_ntables - 1 loop
        part_table := dst_table  || '_' || i::text;
        perform pgq._grant_perms_from('pgq', 'event_template', dst_schema, part_table);
    end loop;

    return 1;
end;
$$;


--
-- TOC entry 259 (class 1255 OID 16772)
-- Name: insert_event(text, text, text); Type: FUNCTION; Schema: pgq; Owner: -
--

CREATE FUNCTION insert_event(queue_name text, ev_type text, ev_data text) RETURNS bigint
    LANGUAGE plpgsql
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq.insert_event(3)
--
--      Insert a event into queue.
--
-- Parameters:
--      queue_name      - Name of the queue
--      ev_type         - User-specified type for the event
--      ev_data         - User data for the event
--
-- Returns:
--      Event ID
-- Calls:
--      pgq.insert_event(7)
-- ----------------------------------------------------------------------
begin
    return pgq.insert_event(queue_name, ev_type, ev_data, null, null, null, null);
end;
$$;


--
-- TOC entry 261 (class 1255 OID 16773)
-- Name: insert_event(text, text, text, text, text, text, text); Type: FUNCTION; Schema: pgq; Owner: -
--

CREATE FUNCTION insert_event(queue_name text, ev_type text, ev_data text, ev_extra1 text, ev_extra2 text, ev_extra3 text, ev_extra4 text) RETURNS bigint
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq.insert_event(7)
--
--      Insert a event into queue with all the extra fields.
--
-- Parameters:
--      queue_name      - Name of the queue
--      ev_type         - User-specified type for the event
--      ev_data         - User data for the event
--      ev_extra1       - Extra data field for the event
--      ev_extra2       - Extra data field for the event
--      ev_extra3       - Extra data field for the event
--      ev_extra4       - Extra data field for the event
--
-- Returns:
--      Event ID
-- Calls:
--      pgq.insert_event_raw(11)
-- Tables directly manipulated:
--      insert - pgq.insert_event_raw(11), a C function, inserts into current event_N_M table
-- ----------------------------------------------------------------------
begin
    return pgq.insert_event_raw(queue_name, null, now(), null, null,
            ev_type, ev_data, ev_extra1, ev_extra2, ev_extra3, ev_extra4);
end;
$$;


--
-- TOC entry 244 (class 1255 OID 16752)
-- Name: insert_event_raw(text, bigint, timestamp with time zone, integer, integer, text, text, text, text, text, text); Type: FUNCTION; Schema: pgq; Owner: -
--

CREATE FUNCTION insert_event_raw(queue_name text, ev_id bigint, ev_time timestamp with time zone, ev_owner integer, ev_retry integer, ev_type text, ev_data text, ev_extra1 text, ev_extra2 text, ev_extra3 text, ev_extra4 text) RETURNS bigint
    LANGUAGE c
    AS '$libdir/pgq_lowlevel', 'pgq_insert_event_raw';


--
-- TOC entry 283 (class 1255 OID 16797)
-- Name: logutriga(); Type: FUNCTION; Schema: pgq; Owner: -
--

CREATE FUNCTION logutriga() RETURNS trigger
    LANGUAGE c
    AS '$libdir/pgq_triggers', 'pgq_logutriga';


--
-- TOC entry 238 (class 1255 OID 16760)
-- Name: maint_operations(); Type: FUNCTION; Schema: pgq; Owner: -
--

CREATE FUNCTION maint_operations(OUT func_name text, OUT func_arg text) RETURNS SETOF record
    LANGUAGE plpgsql
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq.maint_operations(0)
--
--      Returns list of functions to call for maintenance.
--
--      The goal is to avoid hardcoding them into maintenance process.
--
-- Function signature:
--      Function should take either 1 or 0 arguments and return 1 if it wants
--      to be called immediately again, 0 if not.
--
-- Returns:
--      func_name   - Function to call
--      func_arg    - Optional argument to function (queue name)
-- ----------------------------------------------------------------------
declare
    ops text[];
    nrot int4;
begin
    -- rotate step 1
    nrot := 0;
    func_name := 'pgq.maint_rotate_tables_step1';
    for func_arg in
        select queue_name from pgq.queue
            where queue_rotation_period is not null
                and queue_switch_step2 is not null
                and queue_switch_time + queue_rotation_period < current_timestamp
            order by 1
    loop
        nrot := nrot + 1;
        return next;
    end loop;

    -- rotate step 2
    if nrot = 0 then
        select count(1) from pgq.queue
            where queue_rotation_period is not null
                and queue_switch_step2 is null
            into nrot;
    end if;
    if nrot > 0 then
        func_name := 'pgq.maint_rotate_tables_step2';
        func_arg := NULL;
        return next;
    end if;

    -- check if extra field exists
    perform 1 from pg_attribute
      where attrelid = 'pgq.queue'::regclass
        and attname = 'queue_extra_maint';
    if found then
        -- add extra ops
        for func_arg, ops in
            select q.queue_name, queue_extra_maint from pgq.queue q
             where queue_extra_maint is not null
             order by 1
        loop
            for i in array_lower(ops, 1) .. array_upper(ops, 1)
            loop
                func_name = ops[i];
                return next;
            end loop;
        end loop;
    end if;

    -- vacuum tables
    func_name := 'vacuum';
    for func_arg in
        select * from pgq.maint_tables_to_vacuum()
    loop
        return next;
    end loop;

    --
    -- pgq_node & londiste
    --
    -- although they belong to queue_extra_maint, they are
    -- common enough so its more effective to handle them here.
    --

    perform 1 from pg_proc p, pg_namespace n
      where p.pronamespace = n.oid
        and n.nspname = 'pgq_node'
        and p.proname = 'maint_watermark';
    if found then
        func_name := 'pgq_node.maint_watermark';
        for func_arg in
            select n.queue_name
              from pgq_node.node_info n
              where n.node_type = 'root'
        loop
            return next;
        end loop;

    end if;

    perform 1 from pg_proc p, pg_namespace n
      where p.pronamespace = n.oid
        and n.nspname = 'londiste'
        and p.proname = 'root_check_seqs';
    if found then
        func_name := 'londiste.root_check_seqs';
        for func_arg in
            select distinct s.queue_name
              from londiste.seq_info s, pgq_node.node_info n
              where s.local
                and n.node_type = 'root'
                and n.queue_name = s.queue_name
        loop
            return next;
        end loop;
    end if;

    perform 1 from pg_proc p, pg_namespace n
      where p.pronamespace = n.oid
        and n.nspname = 'londiste'
        and p.proname = 'periodic_maintenance';
    if found then
        func_name := 'londiste.periodic_maintenance';
        func_arg := NULL;
        return next;
    end if;

    return;
end;
$$;


--
-- TOC entry 234 (class 1255 OID 16756)
-- Name: maint_retry_events(); Type: FUNCTION; Schema: pgq; Owner: -
--

CREATE FUNCTION maint_retry_events() RETURNS integer
    LANGUAGE plpgsql
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq.maint_retry_events(0)
--
--      Moves retry events back to main queue.
--
--      It moves small amount at a time.  It should be called
--      until it returns 0
--
-- Returns:
--      Number of events processed.
-- ----------------------------------------------------------------------
declare
    cnt    integer;
    rec    record;
begin
    cnt := 0;

    -- allow only single event mover at a time, without affecting inserts
    lock table pgq.retry_queue in share update exclusive mode;

    for rec in
        select queue_name,
               ev_id, ev_time, ev_owner, ev_retry, ev_type, ev_data,
               ev_extra1, ev_extra2, ev_extra3, ev_extra4
          from pgq.retry_queue, pgq.queue
         where ev_retry_after <= current_timestamp
           and queue_id = ev_queue
         order by ev_retry_after
         limit 10
    loop
        cnt := cnt + 1;
        perform pgq.insert_event_raw(rec.queue_name,
                    rec.ev_id, rec.ev_time, rec.ev_owner, rec.ev_retry,
                    rec.ev_type, rec.ev_data, rec.ev_extra1, rec.ev_extra2,
                    rec.ev_extra3, rec.ev_extra4);
        delete from pgq.retry_queue
         where ev_owner = rec.ev_owner
           and ev_id = rec.ev_id;
    end loop;
    return cnt;
end;
$$;


--
-- TOC entry 235 (class 1255 OID 16757)
-- Name: maint_rotate_tables_step1(text); Type: FUNCTION; Schema: pgq; Owner: -
--

CREATE FUNCTION maint_rotate_tables_step1(i_queue_name text) RETURNS integer
    LANGUAGE plpgsql
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq.maint_rotate_tables_step1(1)
--
--      Rotate tables for one queue.
--
-- Parameters:
--      i_queue_name        - Name of the queue
--
-- Returns:
--      0
-- ----------------------------------------------------------------------
declare
    badcnt          integer;
    cf              record;
    nr              integer;
    tbl             text;
    lowest_tick_id  int8;
    lowest_xmin     int8;
begin
    -- check if needed and load record
    select * from pgq.queue into cf
        where queue_name = i_queue_name
          and queue_rotation_period is not null
          and queue_switch_step2 is not null
          and queue_switch_time + queue_rotation_period < current_timestamp
        for update;
    if not found then
        return 0;
    end if;

    -- if DB is in invalid state, stop
    if txid_current() < cf.queue_switch_step1 then
        raise exception 'queue % maint failure: step1=%, current=%',
                i_queue_name, cf.queue_switch_step1, txid_current();
    end if;

    -- find lowest tick for that queue
    select min(sub_last_tick) into lowest_tick_id
      from pgq.subscription
     where sub_queue = cf.queue_id;

    -- if some consumer exists
    if lowest_tick_id is not null then
        -- is the slowest one still on previous table?
        select txid_snapshot_xmin(tick_snapshot) into lowest_xmin
          from pgq.tick
         where tick_queue = cf.queue_id
           and tick_id = lowest_tick_id;
        if not found then
            raise exception 'queue % maint failure: tick % not found', i_queue_name, lowest_tick_id;
        end if;
        if lowest_xmin <= cf.queue_switch_step2 then
            return 0; -- skip rotation then
        end if;
    end if;

    -- nobody on previous table, we can rotate
    
    -- calc next table number and name
    nr := cf.queue_cur_table + 1;
    if nr = cf.queue_ntables then
        nr := 0;
    end if;
    tbl := cf.queue_data_pfx || '_' || nr::text;

    -- there may be long lock on the table from pg_dump,
    -- detect it and skip rotate then
    begin
        execute 'lock table ' || pgq.quote_fqname(tbl) || ' nowait';
        execute 'truncate ' || pgq.quote_fqname(tbl);
    exception
        when lock_not_available then
            -- cannot truncate, skipping rotate
            return 0;
    end;

    -- remember the moment
    update pgq.queue
        set queue_cur_table = nr,
            queue_switch_time = current_timestamp,
            queue_switch_step1 = txid_current(),
            queue_switch_step2 = NULL
        where queue_id = cf.queue_id;

    -- Clean ticks by using step2 txid from previous rotation.
    -- That should keep all ticks for all batches that are completely
    -- in old table.  This keeps them for longer than needed, but:
    -- 1. we want the pgq.tick table to be big, to avoid Postgres
    --    accitentally switching to seqscans on that.
    -- 2. that way we guarantee to consumers that they an be moved
    --    back on the queue at least for one rotation_period.
    --    (may help in disaster recovery)
    delete from pgq.tick
        where tick_queue = cf.queue_id
          and txid_snapshot_xmin(tick_snapshot) < cf.queue_switch_step2;

    return 0;
end;
$$;


--
-- TOC entry 236 (class 1255 OID 16758)
-- Name: maint_rotate_tables_step2(); Type: FUNCTION; Schema: pgq; Owner: -
--

CREATE FUNCTION maint_rotate_tables_step2() RETURNS integer
    LANGUAGE plpgsql
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq.maint_rotate_tables_step2(0)
--
--      Stores the txid when the rotation was visible.  It should be
--      called in separate transaction than pgq.maint_rotate_tables_step1()
-- ----------------------------------------------------------------------
begin
    update pgq.queue
       set queue_switch_step2 = txid_current()
     where queue_switch_step2 is null;
    return 0;
end;
$$;


--
-- TOC entry 237 (class 1255 OID 16759)
-- Name: maint_tables_to_vacuum(); Type: FUNCTION; Schema: pgq; Owner: -
--

CREATE FUNCTION maint_tables_to_vacuum() RETURNS SETOF text
    LANGUAGE plpgsql
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq.maint_tables_to_vacuum(0)
--
--      Returns list of tablenames that need frequent vacuuming.
--
--      The goal is to avoid hardcoding them into maintenance process.
--
-- Returns:
--      List of table names.
-- ----------------------------------------------------------------------
declare
    scm text;
    tbl text;
    fqname text;
begin
    -- assume autovacuum handles them fine
    if current_setting('autovacuum') = 'on' then
        return;
    end if;

    for scm, tbl in values
        ('pgq', 'subscription'),
        ('pgq', 'consumer'),
        ('pgq', 'queue'),
        ('pgq', 'tick'),
        ('pgq', 'retry_queue'),
        ('pgq_ext', 'completed_tick'),
        ('pgq_ext', 'completed_batch'),
        ('pgq_ext', 'completed_event'),
        ('pgq_ext', 'partial_batch'),
        --('pgq_node', 'node_location'),
        --('pgq_node', 'node_info'),
        ('pgq_node', 'local_state'),
        --('pgq_node', 'subscriber_info'),
        --('londiste', 'table_info'),
        ('londiste', 'seq_info'),
        --('londiste', 'applied_execute'),
        --('londiste', 'pending_fkeys'),
        ('txid', 'epoch'),
        ('londiste', 'completed')
    loop
        select n.nspname || '.' || t.relname into fqname
            from pg_class t, pg_namespace n
            where n.oid = t.relnamespace
                and n.nspname = scm
                and t.relname = tbl;
        if found then
            return next fqname;
        end if;
    end loop;
    return;
end;
$$;


--
-- TOC entry 252 (class 1255 OID 16779)
-- Name: next_batch(text, text); Type: FUNCTION; Schema: pgq; Owner: -
--

CREATE FUNCTION next_batch(i_queue_name text, i_consumer_name text) RETURNS bigint
    LANGUAGE plpgsql
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq.next_batch(2)
--
--      Old function that returns just batch_id.
--
-- Parameters:
--      i_queue_name        - Name of the queue
--      i_consumer_name     - Name of the consumer
--
-- Returns:
--      Batch ID or NULL if there are no more events available.
-- ----------------------------------------------------------------------
declare
    res int8;
begin
    select batch_id into res
        from pgq.next_batch_info(i_queue_name, i_consumer_name);
    return res;
end;
$$;


--
-- TOC entry 260 (class 1255 OID 16780)
-- Name: next_batch_custom(text, text, interval, integer, interval); Type: FUNCTION; Schema: pgq; Owner: -
--

CREATE FUNCTION next_batch_custom(i_queue_name text, i_consumer_name text, i_min_lag interval, i_min_count integer, i_min_interval interval, OUT batch_id bigint, OUT cur_tick_id bigint, OUT prev_tick_id bigint, OUT cur_tick_time timestamp with time zone, OUT prev_tick_time timestamp with time zone, OUT cur_tick_event_seq bigint, OUT prev_tick_event_seq bigint) RETURNS record
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq.next_batch_custom(5)
--
--      Makes next block of events active.  Block size can be tuned
--      with i_min_count, i_min_interval parameters.  Events age can
--      be tuned with i_min_lag.
--
--      If it returns NULL, there is no events available in queue.
--      Consumer should sleep then.
--
--      The values from event_id sequence may give hint how big the
--      batch may be.  But they are inexact, they do not give exact size.
--      Client *MUST NOT* use them to detect whether the batch contains any
--      events at all - the values are unfit for that purpose.
--
-- Note:
--      i_min_lag together with i_min_interval/i_min_count is inefficient.
--
-- Parameters:
--      i_queue_name        - Name of the queue
--      i_consumer_name     - Name of the consumer
--      i_min_lag           - Consumer wants events older than that
--      i_min_count         - Consumer wants batch to contain at least this many events
--      i_min_interval      - Consumer wants batch to cover at least this much time
--
-- Returns:
--      batch_id            - Batch ID or NULL if there are no more events available.
--      cur_tick_id         - End tick id.
--      cur_tick_time       - End tick time.
--      cur_tick_event_seq  - Value from event id sequence at the time tick was issued.
--      prev_tick_id        - Start tick id.
--      prev_tick_time      - Start tick time.
--      prev_tick_event_seq - value from event id sequence at the time tick was issued.
-- Calls:
--      pgq.insert_event_raw(11)
-- Tables directly manipulated:
--      update - pgq.subscription
-- ----------------------------------------------------------------------
declare
    errmsg          text;
    queue_id        integer;
    sub_id          integer;
    cons_id         integer;
begin
    select s.sub_queue, s.sub_consumer, s.sub_id, s.sub_batch,
            t1.tick_id, t1.tick_time, t1.tick_event_seq,
            t2.tick_id, t2.tick_time, t2.tick_event_seq
        into queue_id, cons_id, sub_id, batch_id,
             prev_tick_id, prev_tick_time, prev_tick_event_seq,
             cur_tick_id, cur_tick_time, cur_tick_event_seq
        from pgq.consumer c,
             pgq.queue q,
             pgq.subscription s
             left join pgq.tick t1
                on (t1.tick_queue = s.sub_queue
                    and t1.tick_id = s.sub_last_tick)
             left join pgq.tick t2
                on (t2.tick_queue = s.sub_queue
                    and t2.tick_id = s.sub_next_tick)
        where q.queue_name = i_queue_name
          and c.co_name = i_consumer_name
          and s.sub_queue = q.queue_id
          and s.sub_consumer = c.co_id;
    if not found then
        errmsg := 'Not subscriber to queue: '
            || coalesce(i_queue_name, 'NULL')
            || '/'
            || coalesce(i_consumer_name, 'NULL');
        raise exception '%', errmsg;
    end if;

    -- sanity check
    if prev_tick_id is null then
        raise exception 'PgQ corruption: Consumer % on queue % does not see tick %', i_consumer_name, i_queue_name, prev_tick_id;
    end if;

    -- has already active batch
    if batch_id is not null then
        return;
    end if;

    if i_min_interval is null and i_min_count is null then
        -- find next tick
        select tick_id, tick_time, tick_event_seq
            into cur_tick_id, cur_tick_time, cur_tick_event_seq
            from pgq.tick
            where tick_id > prev_tick_id
              and tick_queue = queue_id
            order by tick_queue asc, tick_id asc
            limit 1;
    else
        -- find custom tick
        select next_tick_id, next_tick_time, next_tick_seq
          into cur_tick_id, cur_tick_time, cur_tick_event_seq
          from pgq.find_tick_helper(queue_id, prev_tick_id,
                                    prev_tick_time, prev_tick_event_seq,
                                    i_min_count, i_min_interval);
    end if;

    if i_min_lag is not null then
        -- enforce min lag
        if now() - cur_tick_time < i_min_lag then
            cur_tick_id := NULL;
            cur_tick_time := NULL;
            cur_tick_event_seq := NULL;
        end if;
    end if;

    if cur_tick_id is null then
        -- nothing to do
        prev_tick_id := null;
        prev_tick_time := null;
        prev_tick_event_seq := null;
        return;
    end if;

    -- get next batch
    batch_id := nextval('pgq.batch_id_seq');
    update pgq.subscription
        set sub_batch = batch_id,
            sub_next_tick = cur_tick_id,
            sub_active = now()
        where sub_queue = queue_id
          and sub_consumer = cons_id;
    return;
end;
$$;


--
-- TOC entry 266 (class 1255 OID 16778)
-- Name: next_batch_info(text, text); Type: FUNCTION; Schema: pgq; Owner: -
--

CREATE FUNCTION next_batch_info(i_queue_name text, i_consumer_name text, OUT batch_id bigint, OUT cur_tick_id bigint, OUT prev_tick_id bigint, OUT cur_tick_time timestamp with time zone, OUT prev_tick_time timestamp with time zone, OUT cur_tick_event_seq bigint, OUT prev_tick_event_seq bigint) RETURNS record
    LANGUAGE plpgsql
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq.next_batch_info(2)
--
--      Makes next block of events active.
--
--      If it returns NULL, there is no events available in queue.
--      Consumer should sleep then.
--
--      The values from event_id sequence may give hint how big the
--      batch may be.  But they are inexact, they do not give exact size.
--      Client *MUST NOT* use them to detect whether the batch contains any
--      events at all - the values are unfit for that purpose.
--
-- Parameters:
--      i_queue_name        - Name of the queue
--      i_consumer_name     - Name of the consumer
--
-- Returns:
--      batch_id            - Batch ID or NULL if there are no more events available.
--      cur_tick_id         - End tick id.
--      cur_tick_time       - End tick time.
--      cur_tick_event_seq  - Value from event id sequence at the time tick was issued.
--      prev_tick_id        - Start tick id.
--      prev_tick_time      - Start tick time.
--      prev_tick_event_seq - value from event id sequence at the time tick was issued.
-- Calls:
--      pgq.next_batch_custom(5)
-- Tables directly manipulated:
--      None
-- ----------------------------------------------------------------------
begin
    select f.batch_id, f.cur_tick_id, f.prev_tick_id,
           f.cur_tick_time, f.prev_tick_time,
           f.cur_tick_event_seq, f.prev_tick_event_seq
        into batch_id, cur_tick_id, prev_tick_id, cur_tick_time, prev_tick_time,
             cur_tick_event_seq, prev_tick_event_seq
        from pgq.next_batch_custom(i_queue_name, i_consumer_name, NULL, NULL, NULL) f;
    return;
end;
$$;


--
-- TOC entry 254 (class 1255 OID 16767)
-- Name: quote_fqname(text); Type: FUNCTION; Schema: pgq; Owner: -
--

CREATE FUNCTION quote_fqname(i_name text) RETURNS text
    LANGUAGE plpgsql IMMUTABLE STRICT
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq.quote_fqname(1)
--
--      Quete fully-qualified object name for SQL.
--
--      First dot is taken as schema separator.
--
--      If schema is missing, 'public' is assumed.
--
-- Parameters:
--      i_name  - fully qualified object name.
--
-- Returns:
--      Quoted name.
-- ----------------------------------------------------------------------
declare
    res     text;
    pos     integer;
    s       text;
    n       text;
begin
    pos := position('.' in i_name);
    if pos > 0 then
        s := substring(i_name for pos - 1);
        n := substring(i_name from pos + 1);
    else
        s := 'public';
        n := i_name;
    end if;
    return quote_ident(s) || '.' || quote_ident(n);
end;
$$;


--
-- TOC entry 263 (class 1255 OID 16775)
-- Name: register_consumer(text, text); Type: FUNCTION; Schema: pgq; Owner: -
--

CREATE FUNCTION register_consumer(x_queue_name text, x_consumer_id text) RETURNS integer
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq.register_consumer(2)
--
--      Subscribe consumer on a queue.
--
--      From this moment forward, consumer will see all events in the queue.
--
-- Parameters:
--      x_queue_name        - Name of queue
--      x_consumer_name     - Name of consumer
--
-- Returns:
--      0  - if already registered
--      1  - if new registration
-- Calls:
--      pgq.register_consumer_at(3)
-- Tables directly manipulated:
--      None
-- ----------------------------------------------------------------------
begin
    return pgq.register_consumer_at(x_queue_name, x_consumer_id, NULL);
end;
$$;


--
-- TOC entry 264 (class 1255 OID 16776)
-- Name: register_consumer_at(text, text, bigint); Type: FUNCTION; Schema: pgq; Owner: -
--

CREATE FUNCTION register_consumer_at(x_queue_name text, x_consumer_name text, x_tick_pos bigint) RETURNS integer
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq.register_consumer_at(3)
--
--      Extended registration, allows to specify tick_id.
--
-- Note:
--      For usage in special situations.
--
-- Parameters:
--      x_queue_name        - Name of a queue
--      x_consumer_name     - Name of consumer
--      x_tick_pos          - Tick ID
--
-- Returns:
--      0/1 whether consumer has already registered.
-- Calls:
--      None
-- Tables directly manipulated:
--      update/insert - pgq.subscription
-- ----------------------------------------------------------------------
declare
    tmp         text;
    last_tick   bigint;
    x_queue_id          integer;
    x_consumer_id integer;
    queue integer;
    sub record;
begin
    select queue_id into x_queue_id from pgq.queue
        where queue_name = x_queue_name;
    if not found then
        raise exception 'Event queue not created yet';
    end if;

    -- get consumer and create if new
    select co_id into x_consumer_id from pgq.consumer
        where co_name = x_consumer_name;
    if not found then
        insert into pgq.consumer (co_name) values (x_consumer_name);
        x_consumer_id := currval('pgq.consumer_co_id_seq');
    end if;

    -- if particular tick was requested, check if it exists
    if x_tick_pos is not null then
        perform 1 from pgq.tick
            where tick_queue = x_queue_id
              and tick_id = x_tick_pos;
        if not found then
            raise exception 'cannot reposition, tick not found: %', x_tick_pos;
        end if;
    end if;

    -- check if already registered
    select sub_last_tick, sub_batch into sub
        from pgq.subscription
        where sub_consumer = x_consumer_id
          and sub_queue  = x_queue_id;
    if found then
        if x_tick_pos is not null then
            -- if requested, update tick pos and drop partial batch
            update pgq.subscription
                set sub_last_tick = x_tick_pos,
                    sub_batch = null,
                    sub_next_tick = null,
                    sub_active = now()
                where sub_consumer = x_consumer_id
                  and sub_queue = x_queue_id;
        end if;
        -- already registered
        return 0;
    end if;

    --  new registration
    if x_tick_pos is null then
        -- start from current tick
        select tick_id into last_tick from pgq.tick
            where tick_queue = x_queue_id
            order by tick_queue desc, tick_id desc
            limit 1;
        if not found then
            raise exception 'No ticks for this queue.  Please run ticker on database.';
        end if;
    else
        last_tick := x_tick_pos;
    end if;

    -- register
    insert into pgq.subscription (sub_queue, sub_consumer, sub_last_tick)
        values (x_queue_id, x_consumer_id, last_tick);
    return 1;
end;
$$;


--
-- TOC entry 251 (class 1255 OID 16765)
-- Name: seq_getval(text); Type: FUNCTION; Schema: pgq; Owner: -
--

CREATE FUNCTION seq_getval(i_seq_name text) RETURNS bigint
    LANGUAGE plpgsql STRICT
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq.seq_getval(1)
--
--      Read current last_val from seq, without affecting it.
--
-- Parameters:
--      i_seq_name     - Name of the sequence
--
-- Returns:
--      last value.
-- ----------------------------------------------------------------------
declare
    res     int8;
    fqname  text;
    pos     integer;
    s       text;
    n       text;
begin
    pos := position('.' in i_seq_name);
    if pos > 0 then
        s := substring(i_seq_name for pos - 1);
        n := substring(i_seq_name from pos + 1);
    else
        s := 'public';
        n := i_seq_name;
    end if;
    fqname := quote_ident(s) || '.' || quote_ident(n);

    execute 'select last_value from ' || fqname into res;
    return res;
end;
$$;


--
-- TOC entry 253 (class 1255 OID 16766)
-- Name: seq_setval(text, bigint); Type: FUNCTION; Schema: pgq; Owner: -
--

CREATE FUNCTION seq_setval(i_seq_name text, i_new_value bigint) RETURNS bigint
    LANGUAGE plpgsql STRICT
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq.seq_setval(2)
--
--      Like setval() but does not allow going back.
--
-- Parameters:
--      i_seq_name      - Name of the sequence
--      i_new_value     - new value
--
-- Returns:
--      current last value.
-- ----------------------------------------------------------------------
declare
    res     int8;
    fqname  text;
begin
    fqname := pgq.quote_fqname(i_seq_name);

    res := pgq.seq_getval(i_seq_name);
    if res < i_new_value then
        perform setval(fqname, i_new_value);
        return i_new_value;
    end if;
    return res;
end;
$$;


--
-- TOC entry 258 (class 1255 OID 16771)
-- Name: set_queue_config(text, text, text); Type: FUNCTION; Schema: pgq; Owner: -
--

CREATE FUNCTION set_queue_config(x_queue_name text, x_param_name text, x_param_value text) RETURNS integer
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq.set_queue_config(3)
--
--
--     Set configuration for specified queue.
--
-- Parameters:
--      x_queue_name    - Name of the queue to configure.
--      x_param_name    - Configuration parameter name.
--      x_param_value   - Configuration parameter value.
--  
-- Returns:
--     0 if event was already in queue, 1 otherwise.
-- Calls:
--      None
-- Tables directly manipulated:
--      update - pgq.queue
-- ----------------------------------------------------------------------
declare
    v_param_name    text;
begin
    -- discard NULL input
    if x_queue_name is null or x_param_name is null then
        raise exception 'Invalid NULL value';
    end if;

    -- check if queue exists
    perform 1 from pgq.queue where queue_name = x_queue_name;
    if not found then
        raise exception 'No such event queue';
    end if;

    -- check if valid parameter name
    v_param_name := 'queue_' || x_param_name;
    if v_param_name not in (
        'queue_ticker_max_count',
        'queue_ticker_max_lag',
        'queue_ticker_idle_period',
        'queue_ticker_paused',
        'queue_rotation_period',
        'queue_external_ticker')
    then
        raise exception 'cannot change parameter "%s"', x_param_name;
    end if;

    execute 'update pgq.queue set ' 
        || v_param_name || ' = ' || quote_literal(x_param_value)
        || ' where queue_name = ' || quote_literal(x_queue_name);

    return 1;
end;
$$;


--
-- TOC entry 282 (class 1255 OID 16796)
-- Name: sqltriga(); Type: FUNCTION; Schema: pgq; Owner: -
--

CREATE FUNCTION sqltriga() RETURNS trigger
    LANGUAGE c
    AS '$libdir/pgq_triggers', 'pgq_sqltriga';


--
-- TOC entry 233 (class 1255 OID 16755)
-- Name: ticker(); Type: FUNCTION; Schema: pgq; Owner: -
--

CREATE FUNCTION ticker() RETURNS bigint
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq.ticker(0)
--
--     Creates ticks for all unpaused queues which dont have external ticker.
--
-- Returns:
--     Number of queues that were processed.
-- ----------------------------------------------------------------------
declare
    res bigint;
    q record;
begin
    res := 0;
    for q in
        select queue_name from pgq.queue
            where not queue_external_ticker
                  and not queue_ticker_paused
            order by queue_name
    loop
        if pgq.ticker(q.queue_name) > 0 then
            res := res + 1;
        end if;
    end loop;
    return res;
end;
$$;


--
-- TOC entry 246 (class 1255 OID 16754)
-- Name: ticker(text); Type: FUNCTION; Schema: pgq; Owner: -
--

CREATE FUNCTION ticker(i_queue_name text) RETURNS bigint
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq.ticker(1)
--
--     Check if tick is needed for the queue and insert it.
--
--     For pgqadm usage.
--
-- Parameters:
--     i_queue_name     - Name of the queue
--
-- Returns:
--     Tick id or NULL if no tick was done.
-- ----------------------------------------------------------------------
declare
    res bigint;
    q record;
    state record;
    last2 record;
begin
    select queue_id, queue_tick_seq, queue_external_ticker,
            queue_ticker_max_count, queue_ticker_max_lag,
            queue_ticker_idle_period, queue_event_seq,
            pgq.seq_getval(queue_event_seq) as event_seq,
            queue_ticker_paused
        into q
        from pgq.queue where queue_name = i_queue_name;
    if not found then
        raise exception 'no such queue';
    end if;

    if q.queue_external_ticker then
        raise exception 'This queue has external tick source.';
    end if;

    if q.queue_ticker_paused then
        raise exception 'Ticker has been paused for this queue';
    end if;

    -- load state from last tick
    select now() - tick_time as lag,
           q.event_seq - tick_event_seq as new_events,
           tick_id, tick_time, tick_event_seq,
           txid_snapshot_xmax(tick_snapshot) as sxmax,
           txid_snapshot_xmin(tick_snapshot) as sxmin
        into state
        from pgq.tick
        where tick_queue = q.queue_id
        order by tick_queue desc, tick_id desc
        limit 1;

    if found then
        if state.sxmin > txid_current() then
            raise exception 'Invalid PgQ state: old xmin=%, old xmax=%, cur txid=%',
                            state.sxmin, state.sxmax, txid_current();
        end if;
        if state.new_events < 0 then
            raise warning 'Negative new_events?  old=% cur=%', state.tick_event_seq, q.event_seq;
        end if;
        if state.sxmax > txid_current() then
            raise warning 'Dubious PgQ state: old xmax=%, cur txid=%', state.sxmax, txid_current();
        end if;

        if state.new_events > 0 then
            -- there are new events, should we wait a bit?
            if state.new_events < q.queue_ticker_max_count
                and state.lag < q.queue_ticker_max_lag
            then
                return NULL;
            end if;
        else
            -- no new events, should we apply idle period?
            -- check previous event from the last one.
            select state.tick_time - tick_time as lag
                into last2
                from pgq.tick
                where tick_queue = q.queue_id
                    and tick_id < state.tick_id
                order by tick_queue desc, tick_id desc
                limit 1;
            if found then
                -- gradually decrease the tick frequency
                if (state.lag < q.queue_ticker_max_lag / 2)
                    or
                   (state.lag < last2.lag * 2
                    and state.lag < q.queue_ticker_idle_period)
                then
                    return NULL;
                end if;
            end if;
        end if;
    end if;

    insert into pgq.tick (tick_queue, tick_id, tick_event_seq)
        values (q.queue_id, nextval(q.queue_tick_seq), q.event_seq);

    return currval(q.queue_tick_seq);
end;
$$;


--
-- TOC entry 245 (class 1255 OID 16753)
-- Name: ticker(text, bigint, timestamp with time zone, bigint); Type: FUNCTION; Schema: pgq; Owner: -
--

CREATE FUNCTION ticker(i_queue_name text, i_tick_id bigint, i_orig_timestamp timestamp with time zone, i_event_seq bigint) RETURNS bigint
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq.ticker(3)
--
--     External ticker: Insert a tick with a particular tick_id and timestamp.
--
-- Parameters:
--     i_queue_name     - Name of the queue
--     i_tick_id        - Id of new tick.
--
-- Returns:
--     Tick id.
-- ----------------------------------------------------------------------
begin
    insert into pgq.tick (tick_queue, tick_id, tick_time, tick_event_seq)
    select queue_id, i_tick_id, i_orig_timestamp, i_event_seq
        from pgq.queue
        where queue_name = i_queue_name
          and queue_external_ticker
          and not queue_ticker_paused;
    if not found then
        raise exception 'queue not found or ticker disabled: %', i_queue_name;
    end if;

    -- make sure seqs stay current
    perform pgq.seq_setval(queue_tick_seq, i_tick_id),
            pgq.seq_setval(queue_event_seq, i_event_seq)
        from pgq.queue
        where queue_name = i_queue_name;

    return i_tick_id;
end;
$$;


--
-- TOC entry 249 (class 1255 OID 16763)
-- Name: tune_storage(text); Type: FUNCTION; Schema: pgq; Owner: -
--

CREATE FUNCTION tune_storage(i_queue_name text) RETURNS integer
    LANGUAGE plpgsql STRICT
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq.tune_storage(1)
--
--      Tunes storage settings for queue data tables
-- ----------------------------------------------------------------------
declare
    tbl  text;
    tbloid oid;
    q record;
    i int4;
    sql text;
    pgver int4;
begin
    pgver := current_setting('server_version_num');

    select * into q
      from pgq.queue where queue_name = i_queue_name;
    if not found then
        return 0;
    end if;

    for i in 0 .. (q.queue_ntables - 1) loop
        tbl := q.queue_data_pfx || '_' || i::text;

        -- set fillfactor
        sql := 'alter table ' || tbl || ' set (fillfactor = 100';

        -- autovacuum for 8.4+
        if pgver >= 80400 then
            sql := sql || ', autovacuum_enabled=off, toast.autovacuum_enabled =off';
        end if;
        sql := sql || ')';
        execute sql;

        -- autovacuum for 8.3
        if pgver < 80400 then
            tbloid := tbl::regclass::oid;
            delete from pg_catalog.pg_autovacuum where vacrelid = tbloid;
            insert into pg_catalog.pg_autovacuum values (tbloid, false, -1,-1,-1,-1,-1,-1,-1,-1);
        end if;
    end loop;

    return 1;
end;
$$;


--
-- TOC entry 265 (class 1255 OID 16777)
-- Name: unregister_consumer(text, text); Type: FUNCTION; Schema: pgq; Owner: -
--

CREATE FUNCTION unregister_consumer(x_queue_name text, x_consumer_name text) RETURNS integer
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq.unregister_consumer(2)
--
--      Unsubscriber consumer from the queue.  Also consumer's
--      retry events are deleted.
--
-- Parameters:
--      x_queue_name        - Name of the queue
--      x_consumer_name     - Name of the consumer
--
-- Returns:
--      number of (sub)consumers unregistered
-- Calls:
--      None
-- Tables directly manipulated:
--      delete - pgq.retry_queue
--      delete - pgq.subscription
-- ----------------------------------------------------------------------
declare
    x_sub_id integer;
    _sub_id_cnt integer;
    _consumer_id integer;
    _is_subconsumer boolean;
begin
    select s.sub_id, c.co_id,
           -- subconsumers can only have both null or both not null - main consumer for subconsumers has only one not null
           (s.sub_last_tick IS NULL AND s.sub_next_tick IS NULL) OR (s.sub_last_tick IS NOT NULL AND s.sub_next_tick IS NOT NULL)
      into x_sub_id, _consumer_id, _is_subconsumer
      from pgq.subscription s, pgq.consumer c, pgq.queue q
     where s.sub_queue = q.queue_id
       and s.sub_consumer = c.co_id
       and q.queue_name = x_queue_name
       and c.co_name = x_consumer_name
       for update of s;
    if not found then
        return 0;
    end if;

    -- consumer + subconsumer count
    select count(*) into _sub_id_cnt
        from pgq.subscription
       where sub_id = x_sub_id;

    -- delete only one subconsumer
    if _sub_id_cnt > 1 and _is_subconsumer then
        delete from pgq.subscription
              where sub_id = x_sub_id
                and sub_consumer = _consumer_id;

        return 1;
    else
        -- delete main consumer (including possible subconsumers)

        -- retry events
        delete from pgq.retry_queue
            where ev_owner = x_sub_id;

        -- this will drop subconsumers too
        delete from pgq.subscription
            where sub_id = x_sub_id;
    
        return _sub_id_cnt;
    end if;

end;
$$;


--
-- TOC entry 239 (class 1255 OID 16743)
-- Name: upgrade_schema(); Type: FUNCTION; Schema: pgq; Owner: -
--

CREATE FUNCTION upgrade_schema() RETURNS integer
    LANGUAGE plpgsql
    AS $$
-- updates table structure if necessary
declare
    cnt int4 = 0;
begin

    -- pgq.subscription.sub_last_tick: NOT NULL -> NULL
    perform 1 from information_schema.columns
      where table_schema = 'pgq'
        and table_name = 'subscription'
        and column_name ='sub_last_tick'
        and is_nullable = 'NO';
    if found then
        alter table pgq.subscription
            alter column sub_last_tick
            drop not null;
        cnt := cnt + 1;
    end if;

    -- create roles
    perform 1 from pg_catalog.pg_roles where rolname = 'pgq_reader';
    if not found then
        create role pgq_reader;
        cnt := cnt + 1;
    end if;
    perform 1 from pg_catalog.pg_roles where rolname = 'pgq_writer';
    if not found then
        create role pgq_writer;
        cnt := cnt + 1;
    end if;
    perform 1 from pg_catalog.pg_roles where rolname = 'pgq_admin';
    if not found then
        create role pgq_admin in role pgq_reader, pgq_writer;
        cnt := cnt + 1;
    end if;

    return cnt;
end;
$$;


--
-- TOC entry 280 (class 1255 OID 16794)
-- Name: version(); Type: FUNCTION; Schema: pgq; Owner: -
--

CREATE FUNCTION version() RETURNS text
    LANGUAGE plpgsql
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq.version(0)
--
--      Returns version string for pgq.  ATM it is based on SkyTools version
--      and only bumped when database code changes.
-- ----------------------------------------------------------------------
begin
    return '3.1.3';
end;
$$;


SET search_path = pgq_coop, pg_catalog;

--
-- TOC entry 328 (class 1255 OID 16954)
-- Name: finish_batch(bigint); Type: FUNCTION; Schema: pgq_coop; Owner: -
--

CREATE FUNCTION finish_batch(i_batch_id bigint) RETURNS integer
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq_coop.finish_batch(1)
--
--	Closes a batch.
--
-- Parameters:
--	i_batch_id	- id of the batch to be closed
--
-- Returns:
--	1 if success (batch was found), 0 otherwise
-- Calls:
--      None
-- Tables directly manipulated:
--      update - pgq.subscription
-- ----------------------------------------------------------------------
begin
    -- we are dealing with subconsumer, so nullify all tick info
    -- tick columns for master consumer contain adequate data
    update pgq.subscription
       set sub_active = now(),
           sub_last_tick = null,
           sub_next_tick = null,
           sub_batch = null
     where sub_batch = i_batch_id;
    if not found then
        raise warning 'coop_finish_batch: batch % not found', i_batch_id;
        return 0;
    else
        return 1;
    end if;
end;
$$;


--
-- TOC entry 323 (class 1255 OID 16950)
-- Name: next_batch(text, text, text); Type: FUNCTION; Schema: pgq_coop; Owner: -
--

CREATE FUNCTION next_batch(i_queue_name text, i_consumer_name text, i_subconsumer_name text) RETURNS bigint
    LANGUAGE plpgsql
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq_coop.next_batch(3)
--
--	Makes next block of events active
--
--	Result NULL means nothing to work with, for a moment
--
-- Parameters:
--	i_queue_name		- Name of the queue
--	i_consumer_name		- Name of the consumer
--	i_subconsumer_name	- Name of the subconsumer
--
-- Calls:
--      pgq.register_consumer(i_queue_name, i_consumer_name)
--      pgq.register_consumer(i_queue_name, _subcon_name);
--
-- Tables directly manipulated:
--      update - pgq.subscription
-- 
-- ----------------------------------------------------------------------
begin
    return pgq_coop.next_batch_custom(i_queue_name, i_consumer_name, i_subconsumer_name, NULL, NULL, NULL, NULL);
end;
$$;


--
-- TOC entry 324 (class 1255 OID 16951)
-- Name: next_batch(text, text, text, interval); Type: FUNCTION; Schema: pgq_coop; Owner: -
--

CREATE FUNCTION next_batch(i_queue_name text, i_consumer_name text, i_subconsumer_name text, i_dead_interval interval) RETURNS bigint
    LANGUAGE plpgsql
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq_coop.next_batch(4)
--
--	Makes next block of events active
--
--      If i_dead_interval is set, other subconsumers are checked for
--      inactivity.  If some subconsumer has active batch, but has
--      been inactive more than i_dead_interval, the batch is taken over.
--
--	Result NULL means nothing to work with, for a moment
--
-- Parameters:
--	i_queue_name		- Name of the queue
--	i_consumer_name		- Name of the consumer
--	i_subconsumer_name	- Name of the subconsumer
--      i_dead_interval         - Take over other subconsumer batch if inactive
-- ----------------------------------------------------------------------
begin
    return pgq_coop.next_batch_custom(i_queue_name, i_consumer_name, i_subconsumer_name, NULL, NULL, NULL, i_dead_interval);
end;
$$;


--
-- TOC entry 325 (class 1255 OID 16952)
-- Name: next_batch_custom(text, text, text, interval, integer, interval); Type: FUNCTION; Schema: pgq_coop; Owner: -
--

CREATE FUNCTION next_batch_custom(i_queue_name text, i_consumer_name text, i_subconsumer_name text, i_min_lag interval, i_min_count integer, i_min_interval interval) RETURNS bigint
    LANGUAGE plpgsql
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq_coop.next_batch_custom(6)
--
--      Makes next block of events active.  Block size can be tuned
--      with i_min_count, i_min_interval parameters.  Events age can
--      be tuned with i_min_lag.
--
--	Result NULL means nothing to work with, for a moment
--
-- Parameters:
--	i_queue_name		- Name of the queue
--	i_consumer_name		- Name of the consumer
--	i_subconsumer_name	- Name of the subconsumer
--      i_min_lag           - Consumer wants events older than that
--      i_min_count         - Consumer wants batch to contain at least this many events
--      i_min_interval      - Consumer wants batch to cover at least this much time
-- ----------------------------------------------------------------------
begin
    return pgq_coop.next_batch_custom(i_queue_name, i_consumer_name, i_subconsumer_name,
                                      i_min_lag, i_min_count, i_min_interval, NULL);
end;
$$;


--
-- TOC entry 327 (class 1255 OID 16953)
-- Name: next_batch_custom(text, text, text, interval, integer, interval, interval); Type: FUNCTION; Schema: pgq_coop; Owner: -
--

CREATE FUNCTION next_batch_custom(i_queue_name text, i_consumer_name text, i_subconsumer_name text, i_min_lag interval, i_min_count integer, i_min_interval interval, i_dead_interval interval) RETURNS bigint
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq_coop.next_batch_custom(7)
--
--      Makes next block of events active.  Block size can be tuned
--      with i_min_count, i_min_interval parameters.  Events age can
--      be tuned with i_min_lag.
--
--      If i_dead_interval is set, other subconsumers are checked for
--      inactivity.  If some subconsumer has active batch, but has
--      been inactive more than i_dead_interval, the batch is taken over.
--
--	Result NULL means nothing to work with, for a moment
--
-- Parameters:
--      i_queue_name        - Name of the queue
--      i_consumer_name     - Name of the consumer
--      i_subconsumer_name  - Name of the subconsumer
--      i_min_lag           - Consumer wants events older than that
--      i_min_count         - Consumer wants batch to contain at least this many events
--      i_min_interval      - Consumer wants batch to cover at least this much time
--      i_dead_interval     - Take over other subconsumer batch if inactive
-- Calls:
--      pgq.register_subconsumer(i_queue_name, i_consumer_name, i_subconsumer_name)
--      pgq.next_batch_custom(i_queue_name, i_consumer_name, i_min_lag, i_min_count, i_min_interval)
-- Tables directly manipulated:
--      update - pgq.subscription
-- ----------------------------------------------------------------------
declare
    _queue_id integer;
    _consumer_id integer;
    _subcon_id integer;
    _batch_id bigint;
    _prev_tick bigint;
    _cur_tick bigint;
    _sub_id integer;
    _dead record;
begin
    -- fetch master consumer details, lock the row
    select q.queue_id, c.co_id, s.sub_next_tick
        into _queue_id, _consumer_id, _cur_tick
        from pgq.queue q, pgq.consumer c, pgq.subscription s
        where q.queue_name = i_queue_name
          and c.co_name = i_consumer_name
          and s.sub_queue = q.queue_id
          and s.sub_consumer = c.co_id
        for update of s;
    if not found then
        perform pgq_coop.register_subconsumer(i_queue_name, i_consumer_name, i_subconsumer_name);
        -- fetch the data again
        select q.queue_id, c.co_id, s.sub_next_tick
            into _queue_id, _consumer_id, _cur_tick
            from pgq.queue q, pgq.consumer c, pgq.subscription s
            where q.queue_name = i_queue_name
              and c.co_name = i_consumer_name
              and s.sub_queue = q.queue_id
              and s.sub_consumer = c.co_id;
    end if;
    if _cur_tick is not null then
        raise exception 'main consumer has batch open?';
    end if;

    -- automatically register subconsumers
    perform 1 from pgq.subscription s, pgq.consumer c, pgq.queue q
        where q.queue_name = i_queue_name
          and s.sub_queue = q.queue_id
          and s.sub_consumer = c.co_id
          and c.co_name = i_consumer_name || '.' || i_subconsumer_name;
    if not found then
        perform pgq_coop.register_subconsumer(i_queue_name, i_consumer_name, i_subconsumer_name);
    end if;

    -- fetch subconsumer details
    select s.sub_batch, sc.co_id, s.sub_id
        into _batch_id, _subcon_id, _sub_id
        from pgq.subscription s, pgq.consumer sc
        where sub_queue = _queue_id
          and sub_consumer = sc.co_id
          and sc.co_name = i_consumer_name || '.' || i_subconsumer_name;
    if not found then
        raise exception 'subconsumer not found';
    end if;

    -- is there a batch already active
    if _batch_id is not null then
        update pgq.subscription set sub_active = now()
            where sub_queue = _queue_id
              and sub_consumer = _subcon_id;
        return _batch_id;
    end if;

    -- help dead comrade
    if i_dead_interval is not null then

        -- check if some other subconsumer has died
        select s.sub_batch, s.sub_consumer, s.sub_last_tick, s.sub_next_tick
            into _dead
            from pgq.subscription s
            where s.sub_queue = _queue_id
              and s.sub_id = _sub_id
              and s.sub_consumer <> _subcon_id
              and s.sub_consumer <> _consumer_id
              and sub_active < now() - i_dead_interval
            limit 1;

        if found then
            -- unregister old consumer
            delete from pgq.subscription
                where sub_queue = _queue_id
                  and sub_consumer = _dead.sub_consumer;

            -- if dead consumer had batch, copy it over and return
            if _dead.sub_batch is not null then
                update pgq.subscription
                    set sub_batch = _dead.sub_batch,
                        sub_last_tick = _dead.sub_last_tick,
                        sub_next_tick = _dead.sub_next_tick,
                        sub_active = now()
                    where sub_queue = _queue_id
                      and sub_consumer = _subcon_id;

                return _dead.sub_batch;
            end if;
        end if;
    end if;

    -- get a new batch for the main consumer
    select batch_id, cur_tick_id, prev_tick_id
        into _batch_id, _cur_tick, _prev_tick
        from pgq.next_batch_custom(i_queue_name, i_consumer_name, i_min_lag, i_min_count, i_min_interval);
    if _batch_id is null then
        return null;
    end if;

    -- close batch for main consumer
    update pgq.subscription
       set sub_batch = null,
           sub_active = now(),
           sub_last_tick = sub_next_tick,
           sub_next_tick = null
     where sub_queue = _queue_id
       and sub_consumer = _consumer_id;

    -- copy state into subconsumer row
    update pgq.subscription
        set sub_batch = _batch_id,
            sub_last_tick = _prev_tick,
            sub_next_tick = _cur_tick,
            sub_active = now()
        where sub_queue = _queue_id
          and sub_consumer = _subcon_id;

    return _batch_id;
end;
$$;


--
-- TOC entry 321 (class 1255 OID 16948)
-- Name: register_subconsumer(text, text, text); Type: FUNCTION; Schema: pgq_coop; Owner: -
--

CREATE FUNCTION register_subconsumer(i_queue_name text, i_consumer_name text, i_subconsumer_name text) RETURNS integer
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq_coop.register_subconsumer(3)
--
--	    Subscribe a subconsumer on a queue.
--
--      Subconsumer will be registered as another consumer on queue,
--      whose name will be i_consumer_name and i_subconsumer_name
--      combined.
--
-- Returns:
--	    0 - if already registered
--	    1 - if this is a new registration
--
-- Calls:
--      pgq.register_consumer(i_queue_name, i_consumer_name)
--      pgq.register_consumer(i_queue_name, _subcon_name);
--
-- Tables directly manipulated:
--      update - pgq.subscription
-- 
-- ----------------------------------------------------------------------
declare
    _subcon_name text; -- consumer + subconsumer
    _queue_id integer;
    _consumer_id integer;
    _subcon_id integer;
    _consumer_sub_id integer;
    _subcon_result integer;
    r record;
begin
    _subcon_name := i_consumer_name || '.' || i_subconsumer_name;

    -- make sure main consumer exists
    perform pgq.register_consumer(i_queue_name, i_consumer_name);

    -- just go and register the subconsumer as a regular consumer
    _subcon_result := pgq.register_consumer(i_queue_name, _subcon_name);

    -- if it is a new registration
    if _subcon_result = 1 then
        select q.queue_id, mainc.co_id as main_consumer_id,
               s.sub_id as main_consumer_sub_id,
               subc.co_id as sub_consumer_id
            into r
            from pgq.queue q, pgq.subscription s, pgq.consumer mainc, pgq.consumer subc
            where mainc.co_name = i_consumer_name
              and subc.co_name = _subcon_name
              and q.queue_name = i_queue_name
              and s.sub_queue = q.queue_id
              and s.sub_consumer = mainc.co_id;
        if not found then
            raise exception 'main consumer not found';
        end if;

        -- duplicate the sub_id of consumer to the subconsumer
        update pgq.subscription s
            set sub_id = r.main_consumer_sub_id,
                sub_last_tick = null,
                sub_next_tick = null
            where sub_queue = r.queue_id
              and sub_consumer = r.sub_consumer_id;
    end if;

    return _subcon_result;
end;
$$;


--
-- TOC entry 322 (class 1255 OID 16949)
-- Name: unregister_subconsumer(text, text, text, integer); Type: FUNCTION; Schema: pgq_coop; Owner: -
--

CREATE FUNCTION unregister_subconsumer(i_queue_name text, i_consumer_name text, i_subconsumer_name text, i_batch_handling integer) RETURNS integer
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq_coop.unregister_subconsumer(4)
--
--      Unregisters subconsumer from the queue.
--
--      If consumer has active batch, then behviour depends on
--      i_batch_handling parameter.
--
-- Values for i_batch_handling:
--      0 - Fail with an exception.
--      1 - Close the batch, ignoring the events.
--
-- Returns:
--	    0 - no consumer found
--      1 - consumer found and unregistered
--
-- Tables directly manipulated:
--      delete - pgq.subscription
--
-- ----------------------------------------------------------------------
declare
    _current_batch bigint;
    _queue_id integer;
    _subcon_id integer;
begin
    select q.queue_id, c.co_id, sub_batch
        into _queue_id, _subcon_id, _current_batch
        from pgq.queue q, pgq.consumer c, pgq.subscription s
        where c.co_name = i_consumer_name || '.' || i_subconsumer_name
          and q.queue_name = i_queue_name
          and s.sub_queue = q.queue_id
          and s.sub_consumer = c.co_id;
    if not found then
        return 0;
    end if;

    if _current_batch is not null then
        if i_batch_handling = 1 then
            -- ignore active batch
        else
            raise exception 'subconsumer has active batch';
        end if;
    end if;

    delete from pgq.subscription
        where sub_queue = _queue_id
          and sub_consumer = _subcon_id;

    return 1;
end;
$$;


--
-- TOC entry 329 (class 1255 OID 16955)
-- Name: version(); Type: FUNCTION; Schema: pgq_coop; Owner: -
--

CREATE FUNCTION version() RETURNS text
    LANGUAGE plpgsql
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq_coop.version(0)
--
--      Returns version string for pgq_coop.  ATM it is based on SkyTools version
--      and only bumped when database code changes.
-- ----------------------------------------------------------------------
begin
    return '3.1.1';
end;
$$;


SET search_path = pgq_ext, pg_catalog;

--
-- TOC entry 290 (class 1255 OID 16841)
-- Name: get_last_tick(text); Type: FUNCTION; Schema: pgq_ext; Owner: -
--

CREATE FUNCTION get_last_tick(a_consumer text) RETURNS bigint
    LANGUAGE plpgsql
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq_ext.get_last_tick(1)
--
--	Gets last completed tick for this consumer 
--
-- Parameters:
--      a_consumer - consumer name
--
-- Returns:
--	    tick_id - last completed tick 
-- Calls:
--      pgq_ext.get_last_tick(2)
-- Tables directly manipulated:
--      None
-- ----------------------------------------------------------------------
begin
    return pgq_ext.get_last_tick(a_consumer, '');
end;
$$;


--
-- TOC entry 289 (class 1255 OID 16840)
-- Name: get_last_tick(text, text); Type: FUNCTION; Schema: pgq_ext; Owner: -
--

CREATE FUNCTION get_last_tick(a_consumer text, a_subconsumer text) RETURNS bigint
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq_ext.get_last_tick(2)
--
--	Gets last completed tick for this consumer 
--
-- Parameters:
--      a_consumer - consumer name
--      a_subconsumer - subconsumer name
--
-- Returns:
--	    tick_id - last completed tick 
-- Calls:
--      None
-- Tables directly manipulated:
--      None
-- ----------------------------------------------------------------------
declare
    res   int8;
begin
    select last_tick_id into res
      from pgq_ext.completed_tick
     where consumer_id = a_consumer
       and subconsumer_id = a_subconsumer;
    return res;
end;
$$;


--
-- TOC entry 286 (class 1255 OID 16837)
-- Name: is_batch_done(text, bigint); Type: FUNCTION; Schema: pgq_ext; Owner: -
--

CREATE FUNCTION is_batch_done(a_consumer text, a_batch_id bigint) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq_ext.is_batch_done(2)
--
--	    Checks if a certain consumer has completed the batch 
--
-- Parameters:
--      a_consumer - consumer name
--      a_batch_id - a batch id
--
-- Returns:
--	    true if batch is done, else false 
-- Calls:
--      pgq_ext.is_batch_done(3)
-- Tables directly manipulated:
--      None
-- ----------------------------------------------------------------------
begin
    return pgq_ext.is_batch_done(a_consumer, '', a_batch_id);
end;
$$;


--
-- TOC entry 285 (class 1255 OID 16836)
-- Name: is_batch_done(text, text, bigint); Type: FUNCTION; Schema: pgq_ext; Owner: -
--

CREATE FUNCTION is_batch_done(a_consumer text, a_subconsumer text, a_batch_id bigint) RETURNS boolean
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq_ext.is_batch_done(3)
--
--	    Checks if a certain consumer and subconsumer have completed the batch 
--
-- Parameters:
--      a_consumer - consumer name
--      a_subconsumer - subconsumer name
--      a_batch_id - a batch id
--
-- Returns:
--	    true if batch is done, else false 
-- Calls:
--      None
-- Tables directly manipulated:
--      None
-- ----------------------------------------------------------------------
declare
    res   boolean;
begin
    select last_batch_id = a_batch_id
      into res from pgq_ext.completed_batch
     where consumer_id = a_consumer
       and subconsumer_id = a_subconsumer;
    if not found then
        return false;
    end if;
    return res;
end;
$$;


--
-- TOC entry 294 (class 1255 OID 16845)
-- Name: is_event_done(text, bigint, bigint); Type: FUNCTION; Schema: pgq_ext; Owner: -
--

CREATE FUNCTION is_event_done(a_consumer text, a_batch_id bigint, a_event_id bigint) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq_ext.is_event_done(3)
--
--	    Checks if a certain consumer has "done" and event
--      in a batch  
--
-- Parameters:
--      a_consumer - consumer name
--      a_batch_id - a batch id
--      a_event_id - an event id
--
-- Returns:
--	    true if event is done, else false 
-- Calls:
--      Nonpgq_ext.is_event_done(4)
-- Tables directly manipulated:
--      None
-- ----------------------------------------------------------------------
begin
    return pgq_ext.is_event_done(a_consumer, '', a_batch_id, a_event_id);
end;
$$;


--
-- TOC entry 293 (class 1255 OID 16844)
-- Name: is_event_done(text, text, bigint, bigint); Type: FUNCTION; Schema: pgq_ext; Owner: -
--

CREATE FUNCTION is_event_done(a_consumer text, a_subconsumer text, a_batch_id bigint, a_event_id bigint) RETURNS boolean
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq_ext.is_event_done(4)
--
--	    Checks if a certain consumer and subconsumer have "done" and event
--      in a batch  
--
-- Parameters:
--      a_consumer - consumer name
--      a_subconsumer - subconsumer name
--      a_batch_id - a batch id
--      a_event_id - an event id
--
-- Returns:
--	    true if event is done, else false 
-- Calls:
--      None
-- Tables directly manipulated:
--      None
-- ----------------------------------------------------------------------
declare
    res   bigint;
begin
    perform 1 from pgq_ext.completed_event
     where consumer_id = a_consumer
       and subconsumer_id = a_subconsumer
       and batch_id = a_batch_id
       and event_id = a_event_id;
    return found;
end;
$$;


--
-- TOC entry 288 (class 1255 OID 16839)
-- Name: set_batch_done(text, bigint); Type: FUNCTION; Schema: pgq_ext; Owner: -
--

CREATE FUNCTION set_batch_done(a_consumer text, a_batch_id bigint) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq_ext.set_batch_done(3)
--
--	    Marks a batch as "done"  for certain consumer 
--
-- Parameters:
--      a_consumer - consumer name
--      a_batch_id - a batch id
--
-- Returns:
--      false if it already was done
--	    true for successfully marking it as done 
-- Calls:
--      pgq_ext.set_batch_done(3)
-- Tables directly manipulated:
--      None
-- ----------------------------------------------------------------------
begin
    return pgq_ext.set_batch_done(a_consumer, '', a_batch_id);
end;
$$;


--
-- TOC entry 287 (class 1255 OID 16838)
-- Name: set_batch_done(text, text, bigint); Type: FUNCTION; Schema: pgq_ext; Owner: -
--

CREATE FUNCTION set_batch_done(a_consumer text, a_subconsumer text, a_batch_id bigint) RETURNS boolean
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq_ext.set_batch_done(3)
--
--	    Marks a batch as "done"  for certain consumer and subconsumer 
--
-- Parameters:
--      a_consumer - consumer name
--      a_subconsumer - subconsumer name
--      a_batch_id - a batch id
--
-- Returns:
--      false if it already was done
--	    true for successfully marking it as done 
-- Calls:
--      None
-- Tables directly manipulated:
--      update - pgq_ext.completed_batch
-- ----------------------------------------------------------------------
begin
    if pgq_ext.is_batch_done(a_consumer, a_subconsumer, a_batch_id) then
        return false;
    end if;

    if a_batch_id > 0 then
        update pgq_ext.completed_batch
           set last_batch_id = a_batch_id
         where consumer_id = a_consumer
           and subconsumer_id = a_subconsumer;
        if not found then
            insert into pgq_ext.completed_batch (consumer_id, subconsumer_id, last_batch_id)
                values (a_consumer, a_subconsumer, a_batch_id);
        end if;
    end if;

    return true;
end;
$$;


--
-- TOC entry 296 (class 1255 OID 16847)
-- Name: set_event_done(text, bigint, bigint); Type: FUNCTION; Schema: pgq_ext; Owner: -
--

CREATE FUNCTION set_event_done(a_consumer text, a_batch_id bigint, a_event_id bigint) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq_ext.set_event_done(3)
--
--	    Marks and event done in a batch for a certain consumer and subconsumer
--
-- Parameters:
--      a_consumer - consumer name
--      a_batch_id - a batch id
--      a_event_id - an event id
--
-- Returns:
--      false if already done
--	    true on success 
-- Calls:
--      pgq_ext.set_event_done(4)
-- Tables directly manipulated:
--      None
-- ----------------------------------------------------------------------
begin
    return pgq_ext.set_event_done(a_consumer, '', a_batch_id, a_event_id);
end;
$$;


--
-- TOC entry 295 (class 1255 OID 16846)
-- Name: set_event_done(text, text, bigint, bigint); Type: FUNCTION; Schema: pgq_ext; Owner: -
--

CREATE FUNCTION set_event_done(a_consumer text, a_subconsumer text, a_batch_id bigint, a_event_id bigint) RETURNS boolean
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq_ext.set_event_done(4)
--
--	    Marks and event done in a batch for a certain consumer and subconsumer
--
-- Parameters:
--      a_consumer - consumer name
--      a_subconsumer - subconsumer name
--      a_batch_id - a batch id
--      a_event_id - an event id
--
-- Returns:
--      false if already done
--	    true on success 
-- Calls:
--      None
-- Tables directly manipulated:
--      insert - pgq_ext.partial_batch
--      delete - pgq_ext.completed_event
--      update - pgq_ext.partial_batch
--      insert - pgq_ext.completed_event
-- ----------------------------------------------------------------------
declare
    old_batch bigint;
begin
    -- check if done
    perform 1 from pgq_ext.completed_event
     where consumer_id = a_consumer
       and subconsumer_id = a_subconsumer
       and batch_id = a_batch_id
       and event_id = a_event_id;
    if found then
        return false;
    end if;

    -- if batch changed, do cleanup
    select cur_batch_id into old_batch
        from pgq_ext.partial_batch
        where consumer_id = a_consumer
          and subconsumer_id = a_subconsumer;
    if not found then
        -- first time here
        insert into pgq_ext.partial_batch
            (consumer_id, subconsumer_id, cur_batch_id)
            values (a_consumer, a_subconsumer, a_batch_id);
    elsif old_batch <> a_batch_id then
        -- batch changed, that means old is finished on queue db
        -- thus the tagged events are not needed anymore
        delete from pgq_ext.completed_event
            where consumer_id = a_consumer
              and subconsumer_id = a_subconsumer
              and batch_id = old_batch;
        -- remember current one
        update pgq_ext.partial_batch
            set cur_batch_id = a_batch_id
            where consumer_id = a_consumer
              and subconsumer_id = a_subconsumer;
    end if;

    -- tag as done
    insert into pgq_ext.completed_event
        (consumer_id, subconsumer_id, batch_id, event_id)
        values (a_consumer, a_subconsumer, a_batch_id, a_event_id);

    return true;
end;
$$;


--
-- TOC entry 292 (class 1255 OID 16843)
-- Name: set_last_tick(text, bigint); Type: FUNCTION; Schema: pgq_ext; Owner: -
--

CREATE FUNCTION set_last_tick(a_consumer text, a_tick_id bigint) RETURNS integer
    LANGUAGE plpgsql
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq_ext.set_last_tick(2)
--
--	    records last completed tick for consumer,
--      removes row if a_tick_id is NULL 
--
-- Parameters:
--      a_consumer - consumer name
--      a_tick_id - a tick id
--
-- Returns:
--      1
-- Calls:
--      pgq_ext.set_last_tick(2)
-- Tables directly manipulated:
--      None
-- ----------------------------------------------------------------------
begin
    return pgq_ext.set_last_tick(a_consumer, '', a_tick_id);
end;
$$;


--
-- TOC entry 291 (class 1255 OID 16842)
-- Name: set_last_tick(text, text, bigint); Type: FUNCTION; Schema: pgq_ext; Owner: -
--

CREATE FUNCTION set_last_tick(a_consumer text, a_subconsumer text, a_tick_id bigint) RETURNS integer
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq_ext.set_last_tick(3)
--
--	    records last completed tick for consumer,
--      removes row if a_tick_id is NULL 
--
-- Parameters:
--      a_consumer - consumer name
--      a_subconsumer - subconsumer name
--      a_tick_id - a tick id
--
-- Returns:
--      1
-- Calls:
--      None
-- Tables directly manipulated:
--      delete - pgq_ext.completed_tick
--      update - pgq_ext.completed_tick
--      insert - pgq_ext.completed_tick 
-- ----------------------------------------------------------------------
begin
    if a_tick_id is null then
        delete from pgq_ext.completed_tick
         where consumer_id = a_consumer
           and subconsumer_id = a_subconsumer;
    else   
        update pgq_ext.completed_tick
           set last_tick_id = a_tick_id
         where consumer_id = a_consumer
           and subconsumer_id = a_subconsumer;
        if not found then
            insert into pgq_ext.completed_tick
                (consumer_id, subconsumer_id, last_tick_id)
                values (a_consumer, a_subconsumer, a_tick_id);
        end if;
    end if;

    return 1;
end;
$$;


--
-- TOC entry 284 (class 1255 OID 16831)
-- Name: upgrade_schema(); Type: FUNCTION; Schema: pgq_ext; Owner: -
--

CREATE FUNCTION upgrade_schema() RETURNS integer
    LANGUAGE plpgsql
    AS $$
-- updates table structure if necessary
-- ----------------------------------------------------------------------
-- Function: pgq_ext.upgrade_schema()
--
--	    Upgrades tables to have column subconsumer_id 
--
-- Parameters:
--      None
--
-- Returns:
--	    number of tables updated 
-- Calls:
--      None
-- Tables directly manipulated:
--      alter - pgq_ext.completed_batch
--      alter - pgq_ext.completed_tick
--      alter - pgq_ext.partial_batch
--      alter - pgq_ext.completed_event
-- ----------------------------------------------------------------------
declare
    cnt int4 = 0;
    tbl text;
    sql text;
begin
    -- pgq_ext.completed_batch: subconsumer_id
    perform 1 from information_schema.columns
      where table_schema = 'pgq_ext'
        and table_name = 'completed_batch'
        and column_name = 'subconsumer_id';
    if not found then
        alter table pgq_ext.completed_batch
            add column subconsumer_id text;
        update pgq_ext.completed_batch
            set subconsumer_id = '';
        alter table pgq_ext.completed_batch
            alter column subconsumer_id set not null;
        alter table pgq_ext.completed_batch
            drop constraint completed_batch_pkey;
        alter table pgq_ext.completed_batch
            add constraint completed_batch_pkey
            primary key (consumer_id, subconsumer_id);
        cnt := cnt + 1;
    end if;

    -- pgq_ext.completed_tick: subconsumer_id
    perform 1 from information_schema.columns
      where table_schema = 'pgq_ext'
        and table_name = 'completed_tick'
        and column_name = 'subconsumer_id';
    if not found then
        alter table pgq_ext.completed_tick
            add column subconsumer_id text;
        update pgq_ext.completed_tick
            set subconsumer_id = '';
        alter table pgq_ext.completed_tick
            alter column subconsumer_id set not null;
        alter table pgq_ext.completed_tick
            drop constraint completed_tick_pkey;
        alter table pgq_ext.completed_tick
            add constraint completed_tick_pkey
            primary key (consumer_id, subconsumer_id);
        cnt := cnt + 1;
    end if;

    -- pgq_ext.partial_batch: subconsumer_id
    perform 1 from information_schema.columns
      where table_schema = 'pgq_ext'
        and table_name = 'partial_batch'
        and column_name = 'subconsumer_id';
    if not found then
        alter table pgq_ext.partial_batch
            add column subconsumer_id text;
        update pgq_ext.partial_batch
            set subconsumer_id = '';
        alter table pgq_ext.partial_batch
            alter column subconsumer_id set not null;
        alter table pgq_ext.partial_batch
            drop constraint partial_batch_pkey;
        alter table pgq_ext.partial_batch
            add constraint partial_batch_pkey
            primary key (consumer_id, subconsumer_id);
        cnt := cnt + 1;
    end if;

    -- pgq_ext.completed_event: subconsumer_id
    perform 1 from information_schema.columns
      where table_schema = 'pgq_ext'
        and table_name = 'completed_event'
        and column_name = 'subconsumer_id';
    if not found then
        alter table pgq_ext.completed_event
            add column subconsumer_id text;
        update pgq_ext.completed_event
            set subconsumer_id = '';
        alter table pgq_ext.completed_event
            alter column subconsumer_id set not null;
        alter table pgq_ext.completed_event
            drop constraint completed_event_pkey;
        alter table pgq_ext.completed_event
            add constraint completed_event_pkey
            primary key (consumer_id, subconsumer_id, batch_id, event_id);
        cnt := cnt + 1;
    end if;

    -- add default value to subconsumer_id column
    for tbl in
        select table_name
           from information_schema.columns
           where table_schema = 'pgq_ext'
             and table_name in ('completed_tick', 'completed_event', 'partial_batch', 'completed_batch')
             and column_name = 'subconsumer_id'
             and column_default is null
    loop
        sql := 'alter table pgq_ext.' || tbl
            || ' alter column subconsumer_id set default ' || quote_literal('');
        execute sql;
        cnt := cnt + 1;
    end loop;

    return cnt;
end;
$$;


--
-- TOC entry 267 (class 1255 OID 16848)
-- Name: version(); Type: FUNCTION; Schema: pgq_ext; Owner: -
--

CREATE FUNCTION version() RETURNS text
    LANGUAGE plpgsql
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq_ext.version(0)
--
--      Returns version string for pgq_ext.  ATM it is based SkyTools version
--      only bumped when database code changes.
-- ----------------------------------------------------------------------
begin
    return '3.1';
end;
$$;


SET search_path = pgq_node, pg_catalog;

--
-- TOC entry 315 (class 1255 OID 16940)
-- Name: change_consumer_provider(text, text, text); Type: FUNCTION; Schema: pgq_node; Owner: -
--

CREATE FUNCTION change_consumer_provider(i_queue_name text, i_consumer_name text, i_new_provider text, OUT ret_code integer, OUT ret_note text) RETURNS record
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq_node.change_consumer_provider(3)
--
--      Change provider for this consumer.
--
-- Parameters:
--      i_queue_name  - queue name
--      i_consumer_name  - consumer name
--      i_new_provider - node name for new provider
-- Returns:
--      ret_code - error code
--      200 - ok
--      404 - no such consumer or new node
--      ret_note - description
-- ----------------------------------------------------------------------
begin
    perform 1 from pgq_node.node_location
      where queue_name = i_queue_name
        and node_name = i_new_provider;
    if not found then
        select 404, 'New node not found: ' || i_new_provider
          into ret_code, ret_note;
        return;
    end if;

    update pgq_node.local_state
       set provider_node = i_new_provider,
           uptodate = false
     where queue_name = i_queue_name
       and consumer_name = i_consumer_name;
    if not found then
        select 404, 'Unknown consumer: ' || i_queue_name || '/' || i_consumer_name
          into ret_code, ret_note;
        return;
    end if;
    select 200, 'Consumer provider node set to : ' || i_new_provider
      into ret_code, ret_note;
    return;
end;
$$;


--
-- TOC entry 231 (class 1255 OID 16921)
-- Name: create_node(text, text, text, text, text, bigint, text); Type: FUNCTION; Schema: pgq_node; Owner: -
--

CREATE FUNCTION create_node(i_queue_name text, i_node_type text, i_node_name text, i_worker_name text, i_provider_name text, i_global_watermark bigint, i_combined_queue text, OUT ret_code integer, OUT ret_note text) RETURNS record
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq_node.create_node(7)
--
--      Initialize node.
--
-- Parameters:
--      i_node_name - cascaded queue name
--      i_node_type - node type
--      i_node_name - node name
--      i_worker_name - worker consumer name
--      i_provider_name - provider node name for non-root nodes
--      i_global_watermark - global lowest tick_id
--      i_combined_queue - merge-leaf: target queue
--
-- Returns:
--      200 - Ok
--      401 - node already initialized
--      ???? - maybe we coud use more error codes ?
--
-- Node Types:
--      root - master node
--      branch - subscriber node that can be provider to others
--      leaf - subscriber node that cannot be provider to others
-- Calls:
--      None
-- Tables directly manipulated:
--      None
-- ----------------------------------------------------------------------
declare
    _wm_consumer text;
    _global_wm bigint;
begin
    perform 1 from pgq_node.node_info where queue_name = i_queue_name;
    if found then
        select 401, 'Node already initialized' into ret_code, ret_note;
        return;
    end if;

    _wm_consumer := '.global_watermark';

    if i_node_type = 'root' then
        if coalesce(i_provider_name, i_global_watermark::text,
                    i_combined_queue) is not null then
            select 401, 'unexpected args for '||i_node_type into ret_code, ret_note;
            return;
        end if;

        perform pgq.create_queue(i_queue_name);
        perform pgq.register_consumer(i_queue_name, _wm_consumer);
        _global_wm := (select last_tick from pgq.get_consumer_info(i_queue_name, _wm_consumer));
    elsif i_node_type = 'branch' then
        if i_provider_name is null then
            select 401, 'provider not set for '||i_node_type into ret_code, ret_note;
            return;
        end if;
        if i_global_watermark is null then
            select 401, 'global watermark not set for '||i_node_type into ret_code, ret_note;
            return;
        end if;
        perform pgq.create_queue(i_queue_name);
        update pgq.queue
            set queue_external_ticker = true,
                queue_disable_insert = true
            where queue_name = i_queue_name;
        if i_global_watermark > 1 then
            perform pgq.ticker(i_queue_name, i_global_watermark, now(), 1);
        end if;
        perform pgq.register_consumer_at(i_queue_name, _wm_consumer, i_global_watermark);
        _global_wm := i_global_watermark;
    elsif i_node_type = 'leaf' then
        _global_wm := i_global_watermark;
        if i_combined_queue is not null then
            perform 1 from pgq.get_queue_info(i_combined_queue);
            if not found then
                select 401, 'non-existing queue on leaf side: '||i_combined_queue
                into ret_code, ret_note;
                return;
            end if;
        end if;
    else
        select 401, 'bad node type: '||i_node_type
          into ret_code, ret_note;
    end if;

    insert into pgq_node.node_info
      (queue_name, node_type, node_name,
       worker_name, combined_queue)
    values (i_queue_name, i_node_type, i_node_name,
       i_worker_name, i_combined_queue);

    if i_node_type <> 'root' then
        select f.ret_code, f.ret_note into ret_code, ret_note
          from pgq_node.register_consumer(i_queue_name, i_worker_name,
                    i_provider_name, _global_wm) f;
    else
        select f.ret_code, f.ret_note into ret_code, ret_note
          from pgq_node.register_consumer(i_queue_name, i_worker_name,
                    i_node_name, _global_wm) f;
    end if;
        if ret_code <> 200 then
            return;
        end if;

    select 200, 'Node "' || i_node_name || '" initialized for queue "'
           || i_queue_name || '" with type "' || i_node_type || '"'
        into ret_code, ret_note;
    return;
end;
$$;


--
-- TOC entry 302 (class 1255 OID 16928)
-- Name: demote_root(text, integer, text); Type: FUNCTION; Schema: pgq_node; Owner: -
--

CREATE FUNCTION demote_root(i_queue_name text, i_step integer, i_new_provider text, OUT ret_code integer, OUT ret_note text, OUT last_tick bigint) RETURNS record
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq_node.demote_root(3)
--
--      Multi-step root demotion to branch.
--
--      Must be be called for each step in sequence:
--
--      Step 1 - disable writing to queue.
--      Step 2 - wait until writers go away, do tick.
--      Step 3 - change type, register.
--
-- Parameters:
--      i_queue_name    - queue name
--      i_step          - step number
--      i_new_provider  - new provider node
-- Returns:
--      200 - success
--      404 - node not initialized for queue 
--      301 - node is not root
-- ----------------------------------------------------------------------
declare
    n_type      text;
    w_name      text;
    sql         text;
    ev_id       int8;
    ev_tbl      text;
begin
    select node_type, worker_name into n_type, w_name
        from pgq_node.node_info
        where queue_name = i_queue_name;
    if not found then
        select 404, 'Node not initialized for queue: ' || i_queue_name
          into ret_code, ret_note;
        return;
    end if;

    if n_type != 'root' then
        select 301, 'Node not root'
          into ret_code, ret_note;
        return;
    end if;
    if i_step > 1 then
        select queue_data_pfx
            into ev_tbl
            from pgq.queue
            where queue_name = i_queue_name
                and queue_disable_insert
                and queue_external_ticker;
        if not found then
            raise exception 'steps in wrong order';
        end if;
    end if;

    if i_step = 1 then
        update pgq.queue
            set queue_disable_insert = true,
                queue_external_ticker = true
            where queue_name = i_queue_name;
        if not found then
            select 404, 'Huh, no queue?: ' || i_queue_name
              into ret_code, ret_note;
            return;
        end if;
        select 200, 'Step 1: Writing disabled for: ' || i_queue_name
          into ret_code, ret_note;
    elsif i_step = 2 then
        set local session_replication_role = 'replica';

        -- lock parent table to stop updates, allow reading
        sql := 'lock table ' || ev_tbl || ' in exclusive mode';
        execute sql;
        

        select nextval(queue_tick_seq), nextval(queue_event_seq)
            into last_tick, ev_id
            from pgq.queue
            where queue_name = i_queue_name;

        perform pgq.ticker(i_queue_name, last_tick, now(), ev_id);

        select 200, 'Step 2: Inserted last tick: ' || i_queue_name
            into ret_code, ret_note;
    elsif i_step = 3 then
        -- change type, point worker to new provider
        select t.tick_id into last_tick
            from pgq.tick t, pgq.queue q
            where q.queue_name = i_queue_name
                and t.tick_queue = q.queue_id
            order by t.tick_queue desc, t.tick_id desc
            limit 1;
        update pgq_node.node_info
            set node_type = 'branch'
            where queue_name = i_queue_name;
        update pgq_node.local_state
            set provider_node = i_new_provider,
                last_tick_id = last_tick,
                uptodate = false
            where queue_name = i_queue_name
                and consumer_name = w_name;
        select 200, 'Step 3: Demoted root to branch: ' || i_queue_name
          into ret_code, ret_note;
    else
        raise exception 'incorrect step number';
    end if;
    return;
end;
$$;


--
-- TOC entry 232 (class 1255 OID 16922)
-- Name: drop_node(text, text); Type: FUNCTION; Schema: pgq_node; Owner: -
--

CREATE FUNCTION drop_node(i_queue_name text, i_node_name text, OUT ret_code integer, OUT ret_note text) RETURNS record
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq_node.drop_node(2)
--
--      Drop node. This needs to be run on all the members of a set
--      to properly get rid of the node.
--
-- Parameters:
--      i_queue_name - queue name
--      i_node_name - node_name
--
-- Returns:
--      ret_code - error code
--      ret_note - error description
--
-- Return Codes:
--      200 - Ok
--      304 - No such queue
--      406 - That is a provider
-- Calls:
--      None
-- Tables directly manipulated:
--      None
------------------------------------------------------------------------
declare
    _is_local   boolean;
    _is_prov    boolean;
begin
    select (n.node_name = i_node_name),
           (select s.provider_node = i_node_name
              from pgq_node.local_state s
              where s.queue_name = i_queue_name
                and s.consumer_name = n.worker_name)
        into _is_local, _is_prov
        from pgq_node.node_info n
        where n.queue_name = i_queue_name;

    if not found then
        -- proceed with cleaning anyway, as there schenarios
        -- where some data is left around
        _is_prov := false;
        _is_local := true;
    end if;

    -- drop local state
    if _is_local then
        delete from pgq_node.subscriber_info
         where queue_name = i_queue_name;

        delete from pgq_node.local_state
         where queue_name = i_queue_name;

        delete from pgq_node.node_info
         where queue_name = i_queue_name
            and node_name = i_node_name;

        perform pgq.drop_queue(queue_name, true)
           from pgq.queue where queue_name = i_queue_name;

        delete from pgq_node.node_location
         where queue_name = i_queue_name
           and node_name <> i_node_name;
    elsif _is_prov then
        select 405, 'Cannot drop provider node: ' || i_node_name into ret_code, ret_note;
        return;
    else
        perform pgq_node.unregister_subscriber(i_queue_name, i_node_name);
    end if;

    -- let the unregister_location send event if needed
    select f.ret_code, f.ret_note
        from pgq_node.unregister_location(i_queue_name, i_node_name) f
        into ret_code, ret_note;

    select 200, 'Node dropped: ' || i_node_name
        into ret_code, ret_note;
    return;
end;
$$;


--
-- TOC entry 301 (class 1255 OID 16927)
-- Name: get_consumer_info(text); Type: FUNCTION; Schema: pgq_node; Owner: -
--

CREATE FUNCTION get_consumer_info(i_queue_name text, OUT consumer_name text, OUT provider_node text, OUT last_tick_id bigint, OUT paused boolean, OUT uptodate boolean, OUT cur_error text) RETURNS SETOF record
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq_node.get_consumer_info(1)
--
--      Get consumer list that work on the local node.
--
-- Parameters:
--      i_queue_name  - cascaded queue name
--
-- Returns:
--      consumer_name   - cascaded consumer name
--      provider_node   - node from where the consumer reads from
--      last_tick_id    - last committed tick
--      paused          - if consumer is paused
--      uptodate        - if consumer is uptodate
--      cur_error       - failure reason
-- ----------------------------------------------------------------------
begin
    for consumer_name, provider_node, last_tick_id, paused, uptodate, cur_error in
        select s.consumer_name, s.provider_node, s.last_tick_id,
               s.paused, s.uptodate, s.cur_error
            from pgq_node.local_state s
            where s.queue_name = i_queue_name
            order by 1
    loop
        return next;
    end loop;
    return;
end;
$$;


--
-- TOC entry 308 (class 1255 OID 16939)
-- Name: get_consumer_state(text, text); Type: FUNCTION; Schema: pgq_node; Owner: -
--

CREATE FUNCTION get_consumer_state(i_queue_name text, i_consumer_name text, OUT ret_code integer, OUT ret_note text, OUT node_type text, OUT node_name text, OUT completed_tick bigint, OUT provider_node text, OUT provider_location text, OUT paused boolean, OUT uptodate boolean, OUT cur_error text) RETURNS record
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq_node.get_consumer_state(2)
--
--      Get info for cascaded consumer that targets local node.
--
-- Parameters:
--      i_node_name  - cascaded queue name
--      i_consumer_name - cascaded consumer name
--
-- Returns:
--      node_type - local node type
--      node_name - local node name
--      completed_tick - last committed tick
--      provider_node - provider node name
--      provider_location - connect string to provider node
--      paused - this node should not do any work
--      uptodate - if consumer has loaded last changes
--      cur_error - failure reason
-- ----------------------------------------------------------------------
begin
    select n.node_type, n.node_name
      into node_type, node_name
      from pgq_node.node_info n
    where n.queue_name = i_queue_name;
    if not found then
        select 404, 'Unknown queue: ' || i_queue_name
          into ret_code, ret_note;
        return;
    end if;
    select s.last_tick_id, s.provider_node, s.paused, s.uptodate, s.cur_error
      into completed_tick, provider_node, paused, uptodate, cur_error
      from pgq_node.local_state s
     where s.queue_name = i_queue_name
       and s.consumer_name = i_consumer_name;
    if not found then
        select 404, 'Unknown consumer: ' || i_queue_name || '/' || i_consumer_name
          into ret_code, ret_note;
        return;
    end if;
    select 100, 'Ok', p.node_location
      into ret_code, ret_note, provider_location
      from pgq_node.node_location p
     where p.queue_name = i_queue_name
      and p.node_name = provider_node;
    if not found then
        select 404, 'Unknown provider node: ' || i_queue_name || '/' || provider_node
          into ret_code, ret_note;
        return;
    end if;
    return;
end;
$$;


--
-- TOC entry 297 (class 1255 OID 16923)
-- Name: get_node_info(text); Type: FUNCTION; Schema: pgq_node; Owner: -
--

CREATE FUNCTION get_node_info(i_queue_name text, OUT ret_code integer, OUT ret_note text, OUT node_type text, OUT node_name text, OUT global_watermark bigint, OUT local_watermark bigint, OUT provider_node text, OUT provider_location text, OUT combined_queue text, OUT combined_type text, OUT worker_name text, OUT worker_paused boolean, OUT worker_uptodate boolean, OUT worker_last_tick bigint, OUT node_attrs text) RETURNS record
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq_node.get_node_info(1)
--
--      Get local node info for cascaded queue.
--
-- Parameters:
--      i_queue_name  - cascaded queue name
--
-- Returns:
--      node_type - local node type
--      node_name - local node name
--      global_watermark - queue's global watermark
--      local_watermark - queue's local watermark, for this and below nodes
--      provider_node - provider node name
--      provider_location - provider connect string
--      combined_queue - queue name for target set
--      combined_type - node type of target set
--      worker_name - consumer name that maintains this node
--      worker_paused - is worker paused
--      worker_uptodate - is worker seen the changes
--      worker_last_tick - last committed tick_id by worker
--      node_attrs - urlencoded dict of random attrs for worker (eg. sync_watermark)
-- ----------------------------------------------------------------------
declare
    sql text;
begin
    select 100, 'Ok', n.node_type, n.node_name,
           c.node_type, c.queue_name, w.provider_node, l.node_location,
           n.worker_name, w.paused, w.uptodate, w.last_tick_id,
           n.node_attrs
      into ret_code, ret_note, node_type, node_name,
           combined_type, combined_queue, provider_node, provider_location,
           worker_name, worker_paused, worker_uptodate, worker_last_tick,
           node_attrs
      from pgq_node.node_info n
           left join pgq_node.node_info c on (c.queue_name = n.combined_queue)
           left join pgq_node.local_state w on (w.queue_name = n.queue_name and w.consumer_name = n.worker_name)
           left join pgq_node.node_location l on (l.queue_name = w.queue_name and l.node_name = w.provider_node)
      where n.queue_name = i_queue_name;
    if not found then
        select 404, 'Unknown queue: ' || i_queue_name into ret_code, ret_note;
        return;
    end if;

    if node_type in ('root', 'branch') then
        select min(case when consumer_name = '.global_watermark' then null else last_tick end),
               min(case when consumer_name = '.global_watermark' then last_tick else null end)
          into local_watermark, global_watermark
          from pgq.get_consumer_info(i_queue_name);
        if local_watermark is null then
            select t.tick_id into local_watermark
              from pgq.tick t, pgq.queue q
             where t.tick_queue = q.queue_id
               and q.queue_name = i_queue_name
             order by 1 desc
             limit 1;
        end if;
    else
        local_watermark := worker_last_tick;
    end if;

    if node_type = 'root' then
        select tick_id from pgq.tick t, pgq.queue q
         where q.queue_name = i_queue_name
           and t.tick_queue = q.queue_id
         order by t.tick_queue desc, t.tick_id desc
         limit 1
         into worker_last_tick;
    end if;

    return;
end;
$$;


--
-- TOC entry 230 (class 1255 OID 16920)
-- Name: get_queue_locations(text); Type: FUNCTION; Schema: pgq_node; Owner: -
--

CREATE FUNCTION get_queue_locations(i_queue_name text, OUT node_name text, OUT node_location text, OUT dead boolean) RETURNS SETOF record
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq_node.get_queue_locations(1)
--
--      Get node list for the queue.
--
-- Parameters:
--      i_queue_name    - queue name
--
-- Returns:
--      node_name       - node name
--      node_location   - libpq connect string for the node
--      dead            - whether the node should be considered dead
-- ----------------------------------------------------------------------
begin
    for node_name, node_location, dead in
        select l.node_name, l.node_location, l.dead
          from pgq_node.node_location l
         where l.queue_name = i_queue_name
    loop
        return next;
    end loop;
    return;
end;
$$;


--
-- TOC entry 300 (class 1255 OID 16926)
-- Name: get_subscriber_info(text); Type: FUNCTION; Schema: pgq_node; Owner: -
--

CREATE FUNCTION get_subscriber_info(i_queue_name text, OUT node_name text, OUT worker_name text, OUT node_watermark bigint) RETURNS SETOF record
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq_node.get_subscriber_info(1)
--
--      Get subscriber list for the local node.
--
--      It may be out-of-date, due to in-progress
--      administrative change.
--      Node's local provider info ( pgq_node.get_node_info() or pgq_node.get_worker_state(1) )
--      is the authoritative source.
--
-- Parameters:
--      i_queue_name  - cascaded queue name
--
-- Returns:
--      node_name       - node name that uses current node as provider
--      worker_name     - consumer that maintains remote node
--      local_watermark - lowest tick_id on subscriber
-- ----------------------------------------------------------------------
declare
    _watermark_name text;
begin
    for node_name, worker_name, _watermark_name in
        select s.subscriber_node, s.worker_name, s.watermark_name
          from pgq_node.subscriber_info s
         where s.queue_name = i_queue_name
         order by 1
    loop
        select last_tick into node_watermark
            from pgq.get_consumer_info(i_queue_name, _watermark_name);
        return next;
    end loop;
    return;
end;
$$;


--
-- TOC entry 309 (class 1255 OID 16934)
-- Name: get_worker_state(text); Type: FUNCTION; Schema: pgq_node; Owner: -
--

CREATE FUNCTION get_worker_state(i_queue_name text, OUT ret_code integer, OUT ret_note text, OUT node_type text, OUT node_name text, OUT completed_tick bigint, OUT provider_node text, OUT provider_location text, OUT paused boolean, OUT uptodate boolean, OUT cur_error text, OUT worker_name text, OUT global_watermark bigint, OUT local_watermark bigint, OUT local_queue_top bigint, OUT combined_queue text, OUT combined_type text) RETURNS record
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq_node.get_worker_state(1)
--
--      Get info for consumer that maintains local node.
--
-- Parameters:
--      i_queue_name  - cascaded queue name
--
-- Returns:
--      node_type - local node type
--      node_name - local node name
--      completed_tick - last committed tick
--      provider_node - provider node name
--      provider_location - connect string to provider node
--      paused - this node should not do any work
--      uptodate - if consumer has loaded last changes
--      cur_error - failure reason

--      worker_name - consumer name that maintains this node
--      global_watermark - queue's global watermark
--      local_watermark - queue's local watermark, for this and below nodes
--      local_queue_top - last tick in local queue
--      combined_queue - queue name for target set
--      combined_type - node type of target setA
-- ----------------------------------------------------------------------
begin
    select n.node_type, n.node_name, n.worker_name, n.combined_queue
      into node_type, node_name, worker_name, combined_queue
      from pgq_node.node_info n
     where n.queue_name = i_queue_name;
    if not found then
        select 404, 'Unknown queue: ' || i_queue_name
          into ret_code, ret_note;
        return;
    end if;
    select s.last_tick_id, s.provider_node, s.paused, s.uptodate, s.cur_error
      into completed_tick, provider_node, paused, uptodate, cur_error
      from pgq_node.local_state s
     where s.queue_name = i_queue_name
       and s.consumer_name = worker_name;
    if not found then
        select 404, 'Unknown consumer: ' || i_queue_name || '/' || worker_name
          into ret_code, ret_note;
        return;
    end if;
    select 100, 'Ok', p.node_location
      into ret_code, ret_note, provider_location
      from pgq_node.node_location p
     where p.queue_name = i_queue_name
      and p.node_name = provider_node;
    if not found then
        select 404, 'Unknown provider node: ' || i_queue_name || '/' || provider_node
          into ret_code, ret_note;
        return;
    end if;

    if combined_queue is not null then
        select n.node_type into combined_type
          from pgq_node.node_info n
         where n.queue_name = get_worker_state.combined_queue;
        if not found then
            select 404, 'Combinde queue node not found: ' || combined_queue
              into ret_code, ret_note;
            return;
        end if;
    end if;

    if node_type in ('root', 'branch') then
        select min(case when consumer_name = '.global_watermark' then null else last_tick end),
               min(case when consumer_name = '.global_watermark' then last_tick else null end)
          into local_watermark, global_watermark
          from pgq.get_consumer_info(i_queue_name);
        if local_watermark is null then
            select t.tick_id into local_watermark
              from pgq.tick t, pgq.queue q
             where t.tick_queue = q.queue_id
               and q.queue_name = i_queue_name
             order by 1 desc
             limit 1;
        end if;

        select tick_id from pgq.tick t, pgq.queue q
         where q.queue_name = i_queue_name
           and t.tick_queue = q.queue_id
         order by t.tick_queue desc, t.tick_id desc
         limit 1 into local_queue_top;
    else
        local_watermark := completed_tick;
    end if;

    return;
end;
$$;


--
-- TOC entry 299 (class 1255 OID 16925)
-- Name: is_leaf_node(text); Type: FUNCTION; Schema: pgq_node; Owner: -
--

CREATE FUNCTION is_leaf_node(i_queue_name text) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq_node.is_leaf_node(1)
--
--      Checs if node is leaf.
--
-- Parameters:
--      i_queue_name  - queue name
-- Returns:
--      true - if this this the leaf node for queue 
-- ----------------------------------------------------------------------
declare
    res bool;
begin
    select n.node_type = 'leaf' into res
      from pgq_node.node_info n
      where n.queue_name = i_queue_name;
    if not found then
        raise exception 'queue does not exist: %', i_queue_name;
    end if;
    return res;
end;
$$;


--
-- TOC entry 298 (class 1255 OID 16924)
-- Name: is_root_node(text); Type: FUNCTION; Schema: pgq_node; Owner: -
--

CREATE FUNCTION is_root_node(i_queue_name text) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq_node.is_root_node(1)
--
--      Checs if node is root.
--
-- Parameters:
--      i_queue_name  - queue name
-- Returns:
--      true - if this this the root node for queue 
-- ----------------------------------------------------------------------
declare
    res bool;
begin
    select n.node_type = 'root' into res
      from pgq_node.node_info n
      where n.queue_name = i_queue_name;
    if not found then
        raise exception 'queue does not exist: %', i_queue_name;
    end if;
    return res;
end;
$$;


--
-- TOC entry 320 (class 1255 OID 16945)
-- Name: maint_watermark(text); Type: FUNCTION; Schema: pgq_node; Owner: -
--

CREATE FUNCTION maint_watermark(i_queue_name text) RETURNS integer
    LANGUAGE plpgsql
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq_node.maint_watermark(1)
--
--      Move global watermark on root node.
--
-- Returns:
--      0 - tells pgqd to call just once
-- ----------------------------------------------------------------------
declare
    _lag interval;
begin
    perform 1 from pgq_node.node_info
      where queue_name = i_queue_name
        and node_type = 'root'
      for update;
    if not found then
        return 0;
    end if;

    select lag into _lag from pgq.get_consumer_info(i_queue_name, '.global_watermark');
    if _lag >= '5 minutes'::interval then
        perform pgq_node.set_global_watermark(i_queue_name, NULL);
    end if;

    return 0;
end;
$$;


--
-- TOC entry 303 (class 1255 OID 16929)
-- Name: promote_branch(text); Type: FUNCTION; Schema: pgq_node; Owner: -
--

CREATE FUNCTION promote_branch(i_queue_name text, OUT ret_code integer, OUT ret_note text) RETURNS record
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq_node.promote_branch(1)
--
--      Promote branch node to root.
--
-- Parameters:
--      i_queue_name  - queue name
--
-- Returns:
--      200 - success
--      404 - node not initialized for queue 
--      301 - node is not branch
-- ----------------------------------------------------------------------
declare
    n_name      text;
    n_type      text;
    w_name      text;
    last_tick   bigint;
    sql         text;
begin
    select node_name, node_type, worker_name into n_name, n_type, w_name
        from pgq_node.node_info
        where queue_name = i_queue_name;
    if not found then
        select 404, 'Node not initialized for queue: ' || i_queue_name
          into ret_code, ret_note;
        return;
    end if;

    if n_type != 'branch' then
        select 301, 'Node not branch'
          into ret_code, ret_note;
        return;
    end if;

    update pgq.queue
        set queue_disable_insert = false,
            queue_external_ticker = false
        where queue_name = i_queue_name;

    -- change type, point worker to itself
    select t.tick_id into last_tick
        from pgq.tick t, pgq.queue q
        where q.queue_name = i_queue_name
            and t.tick_queue = q.queue_id
        order by t.tick_queue desc, t.tick_id desc
        limit 1;

    -- make tick seq larger than last tick
    perform pgq.seq_setval(queue_tick_seq, last_tick)
        from pgq.queue where queue_name = i_queue_name;

    update pgq_node.node_info
        set node_type = 'root'
        where queue_name = i_queue_name;

    update pgq_node.local_state
        set provider_node = n_name,
            last_tick_id = last_tick,
            uptodate = false
        where queue_name = i_queue_name
            and consumer_name = w_name;

    select 200, 'Branch node promoted to root'
      into ret_code, ret_note;

    return;
end;
$$;


--
-- TOC entry 312 (class 1255 OID 16937)
-- Name: register_consumer(text, text, text, bigint); Type: FUNCTION; Schema: pgq_node; Owner: -
--

CREATE FUNCTION register_consumer(i_queue_name text, i_consumer_name text, i_provider_node text, i_custom_tick_id bigint, OUT ret_code integer, OUT ret_note text) RETURNS record
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq_node.register_consumer(4)
--
--      Subscribe plain cascaded consumer to a target node.
--      That means it's planning to read from remote node
--      and write to local node.
--
-- Parameters:
--      i_queue_name - set name
--      i_consumer_name - cascaded consumer name
--      i_provider_node - node name
--      i_custom_tick_id - tick id
--
-- Returns:
--      ret_code - error code
--      200 - ok
--      201 - already registered
--      401 - no such queue
--      ret_note - description
-- ----------------------------------------------------------------------
declare
    n record;
    node_wm_name text;
    node_pos bigint;
begin
    select node_type into n
      from pgq_node.node_info where queue_name = i_queue_name
       for update;
    if not found then
        select 404, 'Unknown queue: ' || i_queue_name into ret_code, ret_note;
        return;
    end if;
    perform 1 from pgq_node.local_state
      where queue_name = i_queue_name
        and consumer_name = i_consumer_name;
    if found then
        update pgq_node.local_state
           set provider_node = i_provider_node,
               last_tick_id = i_custom_tick_id
         where queue_name = i_queue_name
           and consumer_name = i_consumer_name;
        select 201, 'Consumer already registered: ' || i_queue_name
               || '/' || i_consumer_name  into ret_code, ret_note;
        return;
    end if;

    insert into pgq_node.local_state (queue_name, consumer_name, provider_node, last_tick_id)
           values (i_queue_name, i_consumer_name, i_provider_node, i_custom_tick_id);

    select 200, 'Consumer '||i_consumer_name||' registered on queue '||i_queue_name
        into ret_code, ret_note;
    return;
end;
$$;


--
-- TOC entry 228 (class 1255 OID 16918)
-- Name: register_location(text, text, text, boolean); Type: FUNCTION; Schema: pgq_node; Owner: -
--

CREATE FUNCTION register_location(i_queue_name text, i_node_name text, i_node_location text, i_dead boolean, OUT ret_code integer, OUT ret_note text) RETURNS record
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq_node.register_location(4)
--
--      Add new node location.
--
-- Parameters:
--      i_queue_name - queue name
--      i_node_name - node name
--      i_node_location - node connect string
--      i_dead - dead flag for node
--
-- Returns:
--      ret_code - error code
--      ret_note - error description
--
-- Return Codes:
--      200 - Ok
-- ----------------------------------------------------------------------
declare
    node record;
begin
    select node_type = 'root' as is_root into node
      from pgq_node.node_info where queue_name = i_queue_name
       for update;
    -- may return 0 rows

    perform 1 from pgq_node.node_location
     where queue_name = i_queue_name
       and node_name = i_node_name;
    if found then
        update pgq_node.node_location
           set node_location = coalesce(i_node_location, node_location),
               dead = i_dead
         where queue_name = i_queue_name
           and node_name = i_node_name;
    elsif i_node_location is not null then
        insert into pgq_node.node_location (queue_name, node_name, node_location, dead)
        values (i_queue_name, i_node_name, i_node_location, i_dead);
    end if;

    if node.is_root then
        perform pgq.insert_event(i_queue_name, 'pgq.location-info',
                                 i_node_name, i_queue_name, i_node_location, i_dead::text, null)
           from pgq_node.node_info n
         where n.queue_name = i_queue_name;
    end if;

    select 200, 'Location registered' into ret_code, ret_note;
    return;
end;
$$;


--
-- TOC entry 305 (class 1255 OID 16931)
-- Name: register_subscriber(text, text, text, bigint); Type: FUNCTION; Schema: pgq_node; Owner: -
--

CREATE FUNCTION register_subscriber(i_queue_name text, i_remote_node_name text, i_remote_worker_name text, i_custom_tick_id bigint, OUT ret_code integer, OUT ret_note text, OUT global_watermark bigint) RETURNS record
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq_node.register_subscriber(4)
--
--      Subscribe remote node to local node at custom position.
--      Should be used when changing provider for existing node.
--
-- Parameters:
--      i_node_name - set name
--      i_remote_node_name - node name
--      i_remote_worker_name - consumer name
--      i_custom_tick_id - tick id [optional]
--
-- Returns:
--      ret_code - error code
--      ret_note - description
--      global_watermark - minimal watermark
-- ----------------------------------------------------------------------
declare
    n record;
    node_wm_name text;
    node_pos bigint;
begin
    select node_type into n
      from pgq_node.node_info where queue_name = i_queue_name
       for update;
    if not found then
        select 404, 'Unknown queue: ' || i_queue_name into ret_code, ret_note;
        return;
    end if;
    select last_tick into global_watermark
      from pgq.get_consumer_info(i_queue_name, '.global_watermark');

    if n.node_type not in ('root', 'branch') then
        select 401, 'Cannot subscribe to ' || n.node_type || ' node'
          into ret_code, ret_note;
        return;
    end if;

    node_wm_name := '.' || i_remote_node_name || '.watermark';
    node_pos := coalesce(i_custom_tick_id, global_watermark);

    perform pgq.register_consumer_at(i_queue_name, node_wm_name, global_watermark);

    perform pgq.register_consumer_at(i_queue_name, i_remote_worker_name, node_pos);

    insert into pgq_node.subscriber_info (queue_name, subscriber_node, worker_name, watermark_name)
        values (i_queue_name, i_remote_node_name, i_remote_worker_name, node_wm_name);

    select 200, 'Subscriber registered: '||i_remote_node_name into ret_code, ret_note;
    return;
end;
$$;


--
-- TOC entry 318 (class 1255 OID 16943)
-- Name: set_consumer_completed(text, text, bigint); Type: FUNCTION; Schema: pgq_node; Owner: -
--

CREATE FUNCTION set_consumer_completed(i_queue_name text, i_consumer_name text, i_tick_id bigint, OUT ret_code integer, OUT ret_note text) RETURNS record
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq_node.set_consumer_completed(3)
--
--      Set last completed tick id for the cascaded consumer
--      that it has committed to local node.
--
-- Parameters:
--      i_queue_name - cascaded queue name
--      i_consumer_name - cascaded consumer name
--      i_tick_id   - tick id
-- Returns:
--      200 - ok
--      404 - consumer not known
-- ----------------------------------------------------------------------
begin
    update pgq_node.local_state
       set last_tick_id = i_tick_id,
           cur_error = NULL
     where queue_name = i_queue_name
       and consumer_name = i_consumer_name;
    if found then
        select 100, 'Consumer ' || i_consumer_name || ' compleded tick = ' || i_tick_id::text
            into ret_code, ret_note;
    else
        select 404, 'Consumer not known: '
               || i_queue_name || '/' || i_consumer_name
          into ret_code, ret_note;
    end if;
    return;
end;
$$;


--
-- TOC entry 319 (class 1255 OID 16944)
-- Name: set_consumer_error(text, text, text); Type: FUNCTION; Schema: pgq_node; Owner: -
--

CREATE FUNCTION set_consumer_error(i_queue_name text, i_consumer_name text, i_error_msg text, OUT ret_code integer, OUT ret_note text) RETURNS record
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq_node.set_consumer_error(3)
--
--      If batch processing fails, consumer can store it's last error in db.
-- Returns:
--      100 - ok
--      101 - consumer not known
-- ----------------------------------------------------------------------
begin
    update pgq_node.local_state
       set cur_error = i_error_msg
     where queue_name = i_queue_name
       and consumer_name = i_consumer_name;
    if found then
        select 100, 'Consumer ' || i_consumer_name || ' error = ' || i_error_msg
            into ret_code, ret_note;
    else
        select 101, 'Consumer not known, ignoring: '
               || i_queue_name || '/' || i_consumer_name
          into ret_code, ret_note;
    end if;
    return;
end;
$$;


--
-- TOC entry 317 (class 1255 OID 16942)
-- Name: set_consumer_paused(text, text, boolean); Type: FUNCTION; Schema: pgq_node; Owner: -
--

CREATE FUNCTION set_consumer_paused(i_queue_name text, i_consumer_name text, i_paused boolean, OUT ret_code integer, OUT ret_note text) RETURNS record
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq_node.set_consumer_paused(3)
--
--      Set consumer paused flag.
--
-- Parameters:
--      i_queue_name - cascaded queue name
--      i_consumer_name - cascaded consumer name
--      i_paused   - new flag state
-- Returns:
--      200 - ok
--      201 - already paused
--      404 - consumer not found
-- ----------------------------------------------------------------------
declare
    old_flag    boolean;
    word        text;
begin
    if i_paused then
        word := 'paused';
    else
        word := 'resumed';
    end if;

    select paused into old_flag
        from pgq_node.local_state
        where queue_name = i_queue_name
          and consumer_name = i_consumer_name
        for update;
    if not found then
        select 404, 'Unknown consumer: ' || i_consumer_name
            into ret_code, ret_note;
    elsif old_flag = i_paused then
        select 201, 'Consumer ' || i_consumer_name || ' already ' || word
            into ret_code, ret_note;
    else
        update pgq_node.local_state
            set paused = i_paused,
                uptodate = false
            where queue_name = i_queue_name
            and consumer_name = i_consumer_name;

        select 200, 'Consumer '||i_consumer_name||' tagged as '||word into ret_code, ret_note;
    end if;
    return;

end;
$$;


--
-- TOC entry 316 (class 1255 OID 16941)
-- Name: set_consumer_uptodate(text, text, boolean); Type: FUNCTION; Schema: pgq_node; Owner: -
--

CREATE FUNCTION set_consumer_uptodate(i_queue_name text, i_consumer_name text, i_uptodate boolean, OUT ret_code integer, OUT ret_note text) RETURNS record
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq_node.set_consumer_uptodate(3)
--
--      Set consumer uptodate flag.....
--
-- Parameters:
--      i_queue_name - queue name
--      i_consumer_name - consumer name
--      i_uptodate - new flag state
--
-- Returns:
--      200 - ok
--      404 - consumer not known
-- ----------------------------------------------------------------------
begin
    update pgq_node.local_state
       set uptodate = i_uptodate
     where queue_name = i_queue_name
       and consumer_name = i_consumer_name;
    if found then
        select 200, 'Consumer uptodate = ' || i_uptodate::int4::text
               into ret_code, ret_note;
    else
        select 404, 'Consumer not known: '
               || i_queue_name || '/' || i_consumer_name
          into ret_code, ret_note;
    end if;
    return;
end;
$$;


--
-- TOC entry 310 (class 1255 OID 16935)
-- Name: set_global_watermark(text, bigint); Type: FUNCTION; Schema: pgq_node; Owner: -
--

CREATE FUNCTION set_global_watermark(i_queue_name text, i_watermark bigint, OUT ret_code integer, OUT ret_note text) RETURNS record
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq_node.set_global_watermark(2)
--
--      Move global watermark on branch/leaf, publish on root.
--
-- Parameters:
--      i_queue_name    - queue name
--      i_watermark     - global tick_id that is processed everywhere.
--                        NULL on root, then local wm is published.
-- ----------------------------------------------------------------------
declare
    this        record;
    _wm         bigint;
    wm_consumer text;
begin
    wm_consumer = '.global_watermark';

    select node_type, queue_name, worker_name into this
        from pgq_node.node_info
        where queue_name = i_queue_name
        for update;
    if not found then
        select 404, 'Queue' || i_queue_name || ' not found'
          into ret_code, ret_note;
        return;
    end if;

    _wm = i_watermark;
    if this.node_type = 'root' then
        if i_watermark is null then
            select f.ret_code, f.ret_note, f.local_watermark
                into ret_code, ret_note, _wm
                from pgq_node.get_node_info(i_queue_name) f;
            if ret_code >= 300 then
                return;
            end if;
            if _wm is null then
                raise exception 'local_watermark=NULL from get_node_info()?';
            end if;
        end if;

        -- move watermark
        perform pgq.register_consumer_at(i_queue_name, wm_consumer, _wm);

        -- send event downstream
        perform pgq.insert_event(i_queue_name, 'pgq.global-watermark', _wm::text,
                                 i_queue_name, null, null, null);
        -- update root workers pos to avoid it getting stale
        update pgq_node.local_state
            set last_tick_id = _wm
            where queue_name = i_queue_name
                and consumer_name = this.worker_name;
    elsif this.node_type = 'branch' then
        if i_watermark is null then
            select 500, 'bad usage: wm=null on branch node'
                into ret_code, ret_note;
            return;
        end if;

        -- tick can be missing if we are processing
        -- old batches that set watermark outside
        -- current range
        perform 1 from pgq.tick t, pgq.queue q
          where q.queue_name = i_queue_name
            and t.tick_queue = q.queue_id
            and t.tick_id = _wm;
        if not found then
            select 200, 'Skipping global watermark update to ' || _wm::text
                into ret_code, ret_note;
            return;
        end if;

        -- move watermark
        perform pgq.register_consumer_at(i_queue_name, wm_consumer, _wm);
    else
        select 100, 'Ignoring global watermark in leaf'
            into ret_code, ret_note;
        return;
    end if;

    select 200, 'Global watermark set to ' || _wm::text
        into ret_code, ret_note;
    return;
end;
$$;


--
-- TOC entry 304 (class 1255 OID 16930)
-- Name: set_node_attrs(text, text); Type: FUNCTION; Schema: pgq_node; Owner: -
--

CREATE FUNCTION set_node_attrs(i_queue_name text, i_node_attrs text, OUT ret_code integer, OUT ret_note text) RETURNS record
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq_node.create_attrs(2)
--
--      Set node attributes.
--
-- Parameters:
--      i_node_name - cascaded queue name
--      i_node_attrs - urlencoded node attrs
--
-- Returns:
--      200 - ok
--      404 - node not found
-- ----------------------------------------------------------------------
begin
    update pgq_node.node_info
        set node_attrs = i_node_attrs
        where queue_name = i_queue_name;
    if not found then
        select 404, 'Node not found' into ret_code, ret_note;
        return;
    end if;

    select 200, 'Node attributes updated'
        into ret_code, ret_note;
    return;
end;
$$;


--
-- TOC entry 311 (class 1255 OID 16936)
-- Name: set_partition_watermark(text, text, bigint); Type: FUNCTION; Schema: pgq_node; Owner: -
--

CREATE FUNCTION set_partition_watermark(i_combined_queue_name text, i_part_queue_name text, i_watermark bigint, OUT ret_code integer, OUT ret_note text) RETURNS record
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq_node.set_partition_watermark(3)
--
--      Move merge-leaf position on combined-branch.
--
-- Parameters:
--      i_combined_queue_name - local combined queue name
--      i_part_queue_name     - local part queue name (merge-leaf)
--      i_watermark         - partition tick_id that came inside combined-root batch
--
-- Returns:
--      200 - success
--      201 - no partition queue
--      401 - worker registration not found
-- ----------------------------------------------------------------------
declare
    n record;
begin
    -- check if combined-branch exists
    select c.node_type, p.worker_name into n
        from pgq_node.node_info c, pgq_node.node_info p
        where p.queue_name = i_part_queue_name
          and c.queue_name = i_combined_queue_name
          and p.combined_queue = c.queue_name
          and p.node_type = 'leaf'
          and c.node_type = 'branch';
    if not found then
        select 201, 'Part-queue does not exist' into ret_code, ret_note;
        return;
    end if;

    update pgq_node.local_state
       set last_tick_id = i_watermark
     where queue_name = i_part_queue_name
       and consumer_name = n.worker_name;
    if not found then
        select 401, 'Worker registration not found' into ret_code, ret_note;
        return;
    end if;

    select 200, 'Ok' into ret_code, ret_note;
    return;
end;
$$;


--
-- TOC entry 307 (class 1255 OID 16933)
-- Name: set_subscriber_watermark(text, text, bigint); Type: FUNCTION; Schema: pgq_node; Owner: -
--

CREATE FUNCTION set_subscriber_watermark(i_queue_name text, i_node_name text, i_watermark bigint, OUT ret_code integer, OUT ret_note text) RETURNS record
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq_node.set_subscriber_watermark(3)
--
--      Notify provider about subscribers lowest watermark.
--
--      Called on provider at interval by each worker  
--
-- Parameters:
--      i_queue_name - cascaded queue name
--      i_node_name - subscriber node name
--      i_watermark - tick_id
--
-- Returns:
--      ret_code    - error code
--      ret_note    - description
-- ----------------------------------------------------------------------
declare
    n       record;
    wm_name text;
begin
    wm_name := '.' || i_node_name || '.watermark';
    select * into n from pgq.get_consumer_info(i_queue_name, wm_name);
    if not found then
        select 404, 'node '||i_node_name||' not subscribed to queue ', i_queue_name
            into ret_code, ret_note;
        return;
    end if;

    -- todo: check if wm sane?
    if i_watermark < n.last_tick then
        select 405, 'watermark must not be moved backwards'
            into ret_code, ret_note;
        return;
    elsif i_watermark = n.last_tick then
        select 100, 'watermark already set'
            into ret_code, ret_note;
        return;
    end if;

    perform pgq.register_consumer_at(i_queue_name, wm_name, i_watermark);

    select 200, wm_name || ' set to ' || i_watermark::text
        into ret_code, ret_note;
    return;
end;
$$;


--
-- TOC entry 313 (class 1255 OID 16938)
-- Name: unregister_consumer(text, text); Type: FUNCTION; Schema: pgq_node; Owner: -
--

CREATE FUNCTION unregister_consumer(i_queue_name text, i_consumer_name text, OUT ret_code integer, OUT ret_note text) RETURNS record
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq_node.unregister_consumer(2)
--
--      Unregister cascaded consumer from local node.
--
-- Parameters:
--      i_queue_name - cascaded queue name
--      i_consumer_name - cascaded consumer name
--
-- Returns:
--      ret_code - error code
--      200 - ok
--      404 - no such queue
--      ret_note - description
-- ----------------------------------------------------------------------
begin
    perform 1 from pgq_node.node_info where queue_name = i_queue_name
       for update;
    if not found then
        select 404, 'Unknown queue: ' || i_queue_name into ret_code, ret_note;
        return;
    end if;

    delete from pgq_node.local_state
      where queue_name = i_queue_name
        and consumer_name = i_consumer_name;

    select 200, 'Consumer '||i_consumer_name||' unregistered from '||i_queue_name
        into ret_code, ret_note;
    return;
end;
$$;


--
-- TOC entry 229 (class 1255 OID 16919)
-- Name: unregister_location(text, text); Type: FUNCTION; Schema: pgq_node; Owner: -
--

CREATE FUNCTION unregister_location(i_queue_name text, i_node_name text, OUT ret_code integer, OUT ret_note text) RETURNS record
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq_node.unregister_location(2)
--
--      Drop unreferenced node.
--
-- Parameters:
--      i_queue_name - queue name
--      i_node_name - node to drop
--
-- Returns:
--      ret_code - error code
--      ret_note - error description
--
-- Return Codes:
--      200 - Ok
--      301 - Location not found
--      403 - Cannot drop nodes own or parent location
-- ----------------------------------------------------------------------
declare
    _queue_name  text;
    _wm_consumer text;
    _global_wm   bigint;
    sub          record;
    node         record;
begin
    select n.node_name, n.node_type, s.provider_node
        into node
        from pgq_node.node_info n
        left join pgq_node.local_state s
        on (s.consumer_name = n.worker_name
            and s.queue_name = n.queue_name)
        where n.queue_name = i_queue_name;
    if found then
        if node.node_name = i_node_name then
            select 403, 'Cannot drop nodes own location' into ret_code, ret_note;
            return;
        end if;
        if node.provider_node = i_node_name then
            select 403, 'Cannot drop location of nodes parent' into ret_code, ret_note;
            return;
        end if;
    end if;

    --
    -- There may be obsolete subscriptions around
    -- drop them silently.
    --
    perform pgq_node.unregister_subscriber(i_queue_name, i_node_name);

    --
    -- Actual removal
    --
    delete from pgq_node.node_location
     where queue_name = i_queue_name
       and node_name = i_node_name;

    if found then
        select 200, 'Ok' into ret_code, ret_note;
    else
        select 301, 'Location not found: ' || i_queue_name || '/' || i_node_name
          into ret_code, ret_note;
    end if;

    if node.node_type = 'root' then
        perform pgq.insert_event(i_queue_name, 'pgq.unregister-location',
                                 i_node_name, i_queue_name, null, null, null)
           from pgq_node.node_info n
         where n.queue_name = i_queue_name;
    end if;

    return;
end;
$$;


--
-- TOC entry 306 (class 1255 OID 16932)
-- Name: unregister_subscriber(text, text); Type: FUNCTION; Schema: pgq_node; Owner: -
--

CREATE FUNCTION unregister_subscriber(i_queue_name text, i_remote_node_name text, OUT ret_code integer, OUT ret_note text) RETURNS record
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq_node.unregister_subscriber(2)
--
--      Unsubscribe remote node from local node.
--
-- Parameters:
--      i_queue_name - set name
--      i_remote_node_name - node name
--
-- Returns:
--      ret_code - error code
--      ret_note - description
-- ----------------------------------------------------------------------
declare
    n_wm_name text;
    worker_name text;
begin
    n_wm_name := '.' || i_remote_node_name || '.watermark';
    select s.worker_name into worker_name from pgq_node.subscriber_info s
        where queue_name = i_queue_name and subscriber_node = i_remote_node_name;
    if not found then
        select 304, 'Subscriber not found' into ret_code, ret_note;
        return;
    end if;

    perform pgq.unregister_consumer(i_queue_name, n_wm_name);
    perform pgq.unregister_consumer(i_queue_name, worker_name);

    delete from pgq_node.subscriber_info
        where queue_name = i_queue_name
            and subscriber_node = i_remote_node_name;

    select 200, 'Subscriber unregistered: '||i_remote_node_name
        into ret_code, ret_note;
    return;
end;
$$;


--
-- TOC entry 227 (class 1255 OID 16917)
-- Name: upgrade_schema(); Type: FUNCTION; Schema: pgq_node; Owner: -
--

CREATE FUNCTION upgrade_schema() RETURNS integer
    LANGUAGE plpgsql
    AS $$
-- updates table structure if necessary
declare
    cnt int4 = 0;
begin
    -- node_info.node_attrs
    perform 1 from information_schema.columns
      where table_schema = 'pgq_node'
        and table_name = 'node_info'
        and column_name = 'node_attrs';
    if not found then
        alter table pgq_node.node_info add column node_attrs text;
        cnt := cnt + 1;
    end if;

    return cnt;
end;
$$;


--
-- TOC entry 314 (class 1255 OID 16946)
-- Name: version(); Type: FUNCTION; Schema: pgq_node; Owner: -
--

CREATE FUNCTION version() RETURNS text
    LANGUAGE plpgsql
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq_node.version(0)
--
--      Returns version string for pgq_node.  ATM it is based on SkyTools version
--      and only bumped when database code changes.
-- ----------------------------------------------------------------------
begin
    return '3.1.3';
end;
$$;


SET search_path = switch, pg_catalog;

--
-- TOC entry 339 (class 1255 OID 17040)
-- Name: writecdr(boolean, integer, integer, integer, boolean, integer, character varying, integer, character varying, integer, character varying, integer, character varying, integer, bigint, bigint, bigint, integer, character varying, integer, integer, character varying, integer, character varying, character varying, character varying, character varying, character varying, integer, character varying, character varying, character varying, character varying, integer, integer, integer, integer, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, integer, integer, integer, integer, integer, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, inet, integer); Type: FUNCTION; Schema: switch; Owner: -
--

CREATE FUNCTION writecdr(i_is_master boolean, i_node_id integer, i_pop_id integer, i_routing_attempt integer, i_is_last_cdr boolean, i_time_limit integer, i_lega_local_ip character varying, i_lega_local_port integer, i_lega_remote_ip character varying, i_lega_remote_port integer, i_legb_local_ip character varying, i_legb_local_port integer, i_legb_remote_ip character varying, i_legb_remote_port integer, i_time_start bigint, i_time_connect bigint, i_time_end bigint, i_legb_disconnect_code integer, i_legb_disconnect_reason character varying, i_disconnect_initiator integer, i_internal_disconnect_code integer, i_internal_disconnect_reason character varying, i_lega_disconnect_code integer, i_lega_disconnect_reason character varying, i_orig_call_id character varying, i_term_call_id character varying, i_local_tag character varying, i_msg_logger_path character varying, i_dump_level_id integer, i_lega_rx_payloads character varying, i_lega_tx_payloads character varying, i_legb_rx_payloads character varying, i_legb_tx_payloads character varying, i_lega_rx_bytes integer, i_lega_tx_bytes integer, i_legb_rx_bytes integer, i_legb_tx_bytes integer, i_global_tag character varying, i_customer_id character varying, i_vendor_id character varying, i_customer_acc_id character varying, i_vendor_acc_id character varying, i_customer_auth_id character varying, i_destination_id character varying, i_dialpeer_id character varying, i_orig_gw_id character varying, i_term_gw_id character varying, i_routing_group_id character varying, i_rateplan_id character varying, i_destination_initial_rate character varying, i_destination_next_rate character varying, i_destination_initial_interval integer, i_destination_next_interval integer, i_destination_rate_policy_id integer, i_dialpeer_initial_interval integer, i_dialpeer_next_interval integer, i_dialpeer_next_rate character varying, i_destination_fee character varying, i_dialpeer_initial_rate character varying, i_dialpeer_fee character varying, i_dst_prefix_in character varying, i_dst_prefix_out character varying, i_src_prefix_in character varying, i_src_prefix_out character varying, i_src_name_in character varying, i_src_name_out character varying, i_diversion_in character varying, i_diversion_out character varying, i_auth_orig_ip inet, i_auth_orig_port integer) RETURNS integer
    LANGUAGE plpgsql SECURITY DEFINER COST 10
    AS $$
DECLARE
v_cdr cdr.cdr%rowtype;
v_nozerolen boolean;
BEGIN
-- feel cdr fields;

v_cdr.pop_id=i_pop_id;
v_cdr.node_id=i_node_id;

v_cdr.src_name_in:=i_src_name_in;
v_cdr.src_name_out:=i_src_name_out;

v_cdr.diversion_in:=i_diversion_in;
v_cdr.diversion_out:=i_diversion_out;

v_cdr.customer_id:=i_customer_id;
v_cdr.vendor_id:=i_vendor_id;
v_cdr.customer_acc_id:=i_customer_acc_id;
v_cdr.vendor_acc_id:=i_vendor_acc_id;
v_cdr.customer_auth_id:=i_customer_auth_id;
v_cdr.destination_id:=i_destination_id;
v_cdr.dialpeer_id:=i_dialpeer_id;
v_cdr.orig_gw_id:=i_orig_gw_id;
v_cdr.term_gw_id:=i_term_gw_id;
v_cdr.routing_group_id:=i_routing_group_id;
v_cdr.rateplan_id:=i_rateplan_id;

v_cdr.routing_attempt=i_routing_attempt;
v_cdr.is_last_cdr=i_is_last_cdr;

v_cdr.destination_initial_rate:=i_destination_initial_rate::numeric;
v_cdr.destination_next_rate:=i_destination_next_rate::numeric;
v_cdr.destination_initial_interval:=i_destination_initial_interval;
v_cdr.destination_next_interval:=i_destination_next_interval;
v_cdr.destination_fee:=i_destination_fee;
v_cdr.destination_rate_policy_id:=i_destination_rate_policy_id;

v_cdr.dialpeer_initial_rate:=i_dialpeer_initial_rate::numeric;
v_cdr.dialpeer_next_rate:=i_dialpeer_next_rate::numeric;
v_cdr.dialpeer_initial_interval:=i_dialpeer_initial_interval;
v_cdr.dialpeer_next_interval:=i_dialpeer_next_interval;
v_cdr.dialpeer_fee:=i_dialpeer_fee;

v_cdr.time_limit:=i_time_limit;
/* sockets addresses */
v_cdr.sign_orig_ip:=i_legA_remote_ip;
v_cdr.sign_orig_port=i_legA_remote_port;
v_cdr.sign_orig_local_ip:=i_legA_local_ip;
v_cdr.sign_orig_local_port=i_legA_local_port;
v_cdr.sign_term_ip:=i_legB_remote_ip;
v_cdr.sign_term_port:=NULLIF(i_legB_remote_port,0);
v_cdr.sign_term_local_ip:=i_legB_local_ip;
v_cdr.sign_term_local_port:=NULLIF(i_legB_local_port,0);

v_cdr.local_tag=i_local_tag;

v_cdr.time_start:=to_timestamp(i_time_start);
IF i_time_connect!=0::bigint THEN -- BUG in WEB interface
    v_cdr.time_connect:=to_timestamp(i_time_connect);
    v_cdr.duration:=i_time_end-i_time_connect;
    v_nozerolen:=true;
    v_cdr.success=true;
ELSE
    v_cdr.time_connect:=NULL;
    v_cdr.duration:=0;
    v_nozerolen:=false;
    v_cdr.success=false;
END IF;
v_cdr.time_end:=to_timestamp(i_time_end);

-- DC processing
v_cdr.legb_disconnect_code:=i_legb_disconnect_code;
v_cdr.legb_disconnect_reason:=i_legb_disconnect_reason;
v_cdr.disconnect_initiator_id:=i_disconnect_initiator;
v_cdr.internal_disconnect_code:=i_internal_disconnect_code;
v_cdr.internal_disconnect_reason:=i_internal_disconnect_reason;
v_cdr.lega_disconnect_code:=i_lega_disconnect_code;
v_cdr.lega_disconnect_reason:=i_lega_disconnect_reason;

v_cdr.src_prefix_in:=i_src_prefix_in;
v_cdr.src_prefix_out:=i_src_prefix_out;
v_cdr.dst_prefix_in:=i_dst_prefix_in;
v_cdr.dst_prefix_out:=i_dst_prefix_out;

v_cdr.orig_call_id=i_orig_call_id;
v_cdr.term_call_id=i_term_call_id;
v_cdr.dump_file:=i_msg_logger_path;
v_cdr.dump_level_id:=i_dump_level_id;

v_cdr.auth_orig_ip:=i_auth_orig_ip;
v_cdr.auth_orig_port:=i_auth_orig_port;

v_cdr.lega_rx_payloads:=i_legA_rx_payloads;
v_cdr.lega_tx_payloads:=i_legA_tx_payloads;
v_cdr.legb_rx_payloads:=i_legB_rx_payloads;
v_cdr.legb_tx_payloads:=i_legB_tx_payloads;

v_cdr.lega_rx_bytes:=i_legA_rx_bytes;
v_cdr.lega_tx_bytes:=i_legA_tx_bytes;
v_cdr.legb_rx_bytes:=i_legB_rx_bytes;
v_cdr.legb_tx_bytes:=i_legB_tx_bytes;
v_cdr.global_tag=i_global_tag;


    v_cdr.id:=nextval('cdr.cdr_id_seq'::regclass);
    v_cdr:=billing.bill_cdr(v_cdr);
    -- generate event to routing engine
    perform event.billing_insert_event('cdr_full',v_cdr);
    
    INSERT INTO cdr.cdr VALUES( v_cdr.*);
    RETURN 0;
END;
$$;


SET search_path = sys, pg_catalog;

--
-- TOC entry 337 (class 1255 OID 17059)
-- Name: cdr_createtable(integer); Type: FUNCTION; Schema: sys; Owner: -
--

CREATE FUNCTION cdr_createtable(i_offset integer) RETURNS void
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
                        time_start >= '''||v_start||'''::date
                        AND time_start < '''||v_end||'''::date
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


--
-- TOC entry 332 (class 1255 OID 17060)
-- Name: cdr_drop_table(character varying); Type: FUNCTION; Schema: sys; Owner: -
--

CREATE FUNCTION cdr_drop_table(i_tbname character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
v_t record;
BEGIN
    SELECT INTO v_t * from sys.cdr_tables WHERE "name"=i_tbname;
    IF FOUND THEN
        if v_t.writable THEN
            RAISE EXCEPTION 'sys.cdr_drop_table: table used, cant drop.';
        ELSE
            EXECUTE 'DROP TABLE '||v_t.name;
            DELETE FROM sys.cdr_tables where id=v_t.id;
            PERFORM cdrtable_tgr_reload();
        END IF;
    END IF;
END;
$$;


--
-- TOC entry 333 (class 1255 OID 17061)
-- Name: cdr_export_data(character varying); Type: FUNCTION; Schema: sys; Owner: -
--

CREATE FUNCTION cdr_export_data(i_tbname character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_file varchar:='/var/spool/yeti-rs/';
BEGIN
    v_file:=v_file||i_tbname||'-'||now()::varchar;
    execute 'COPY '||i_tbname||' TO '''||v_file||''' WITH CSV HEADER QUOTE AS ''"'' FORCE QUOTE *';
END;
$$;


--
-- TOC entry 334 (class 1255 OID 17062)
-- Name: cdr_export_data(character varying, character varying); Type: FUNCTION; Schema: sys; Owner: -
--

CREATE FUNCTION cdr_export_data(i_tbname character varying, i_dir character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_file varchar;
BEGIN
    v_file:=i_dir||'/'||i_tbname||'-'||now()::varchar;
    execute 'COPY '||i_tbname||' TO '''||v_file||''' WITH CSV HEADER QUOTE AS ''"'' FORCE QUOTE *';
END;
$$;


--
-- TOC entry 340 (class 1255 OID 17099)
-- Name: cdr_reindex(character varying, character varying); Type: FUNCTION; Schema: sys; Owner: -
--

CREATE FUNCTION cdr_reindex(i_schema character varying, i_tbname character varying) RETURNS void
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


--
-- TOC entry 336 (class 1255 OID 17064)
-- Name: cdrtable_tgr_reload(); Type: FUNCTION; Schema: sys; Owner: -
--

CREATE FUNCTION cdrtable_tgr_reload() RETURNS void
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
        PERFORM * FROM sys.cdr_tables WHERE writable='t';
        IF NOT FOUND THEN
            RAISE EXCEPTION 'no tables for write data';
        end IF;
        FOR v_tb_row IN SELECT * FROM sys.cdr_tables WHERE writable='t' ORDER BY date_start LOOP
                IF v_counter=1 THEN
                        v_prfx='IF ';
                ELSE 
                        v_prfx='ELSIF ';
                END IF;
                v_meat:=v_meat||v_prfx||'( NEW.time_start >= DATE '''||v_tb_row.date_start||''' AND NEW.time_start < DATE '''||v_tb_row.date_stop||''' ) THEN INSERT INTO '||v_tb_row.name||' VALUES (NEW.*);'|| E'\n';
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


SET search_path = cdr, pg_catalog;

--
-- TOC entry 208 (class 1259 OID 17179)
-- Name: cdr_201408; Type: TABLE; Schema: cdr; Owner: -; Tablespace: 
--

CREATE TABLE cdr_201408 (
    CONSTRAINT cdr_201408_time_start_check CHECK (((time_start >= '2014-08-01'::date) AND (time_start < '2014-09-01'::date)))
)
INHERITS (cdr);


--
-- TOC entry 209 (class 1259 OID 17193)
-- Name: cdr_201409; Type: TABLE; Schema: cdr; Owner: -; Tablespace: 
--

CREATE TABLE cdr_201409 (
    CONSTRAINT cdr_201409_time_start_check CHECK (((time_start >= '2014-09-01'::date) AND (time_start < '2014-10-01'::date)))
)
INHERITS (cdr);


--
-- TOC entry 210 (class 1259 OID 17207)
-- Name: cdr_201410; Type: TABLE; Schema: cdr; Owner: -; Tablespace: 
--

CREATE TABLE cdr_201410 (
    CONSTRAINT cdr_201410_time_start_check CHECK (((time_start >= '2014-10-01'::date) AND (time_start < '2014-11-01'::date)))
)
INHERITS (cdr);


--
-- TOC entry 211 (class 1259 OID 17221)
-- Name: cdr_201411; Type: TABLE; Schema: cdr; Owner: -; Tablespace: 
--

CREATE TABLE cdr_201411 (
    CONSTRAINT cdr_201411_time_start_check CHECK (((time_start >= '2014-11-01'::date) AND (time_start < '2014-12-01'::date)))
)
INHERITS (cdr);


--
-- TOC entry 204 (class 1259 OID 17023)
-- Name: cdr_id_seq; Type: SEQUENCE; Schema: cdr; Owner: -
--

CREATE SEQUENCE cdr_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2371 (class 0 OID 0)
-- Dependencies: 204
-- Name: cdr_id_seq; Type: SEQUENCE OWNED BY; Schema: cdr; Owner: -
--

ALTER SEQUENCE cdr_id_seq OWNED BY cdr.id;


SET search_path = pgq, pg_catalog;

--
-- TOC entry 184 (class 1259 OID 16699)
-- Name: batch_id_seq; Type: SEQUENCE; Schema: pgq; Owner: -
--

CREATE SEQUENCE batch_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 180 (class 1259 OID 16648)
-- Name: consumer; Type: TABLE; Schema: pgq; Owner: -; Tablespace: 
--

CREATE TABLE consumer (
    co_id integer NOT NULL,
    co_name text NOT NULL
);


--
-- TOC entry 179 (class 1259 OID 16646)
-- Name: consumer_co_id_seq; Type: SEQUENCE; Schema: pgq; Owner: -
--

CREATE SEQUENCE consumer_co_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2372 (class 0 OID 0)
-- Dependencies: 179
-- Name: consumer_co_id_seq; Type: SEQUENCE OWNED BY; Schema: pgq; Owner: -
--

ALTER SEQUENCE consumer_co_id_seq OWNED BY consumer.co_id;


--
-- TOC entry 187 (class 1259 OID 16722)
-- Name: event_template; Type: TABLE; Schema: pgq; Owner: -; Tablespace: 
--

CREATE TABLE event_template (
    ev_id bigint NOT NULL,
    ev_time timestamp with time zone NOT NULL,
    ev_txid bigint DEFAULT txid_current() NOT NULL,
    ev_owner integer,
    ev_retry integer,
    ev_type text,
    ev_data text,
    ev_extra1 text,
    ev_extra2 text,
    ev_extra3 text,
    ev_extra4 text
);


--
-- TOC entry 199 (class 1259 OID 16961)
-- Name: event_1; Type: TABLE; Schema: pgq; Owner: -; Tablespace: 
--

CREATE TABLE event_1 (
)
INHERITS (event_template);


--
-- TOC entry 200 (class 1259 OID 16968)
-- Name: event_1_0; Type: TABLE; Schema: pgq; Owner: -; Tablespace: 
--

CREATE TABLE event_1_0 (
)
INHERITS (event_1)
WITH (fillfactor=100, autovacuum_enabled=off, toast.autovacuum_enabled=off);


--
-- TOC entry 201 (class 1259 OID 16977)
-- Name: event_1_1; Type: TABLE; Schema: pgq; Owner: -; Tablespace: 
--

CREATE TABLE event_1_1 (
)
INHERITS (event_1)
WITH (fillfactor=100, autovacuum_enabled=off, toast.autovacuum_enabled=off);


--
-- TOC entry 202 (class 1259 OID 16986)
-- Name: event_1_2; Type: TABLE; Schema: pgq; Owner: -; Tablespace: 
--

CREATE TABLE event_1_2 (
)
INHERITS (event_1)
WITH (fillfactor=100, autovacuum_enabled=off, toast.autovacuum_enabled=off);


--
-- TOC entry 198 (class 1259 OID 16959)
-- Name: event_1_id_seq; Type: SEQUENCE; Schema: pgq; Owner: -
--

CREATE SEQUENCE event_1_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 197 (class 1259 OID 16957)
-- Name: event_1_tick_seq; Type: SEQUENCE; Schema: pgq; Owner: -
--

CREATE SEQUENCE event_1_tick_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 182 (class 1259 OID 16661)
-- Name: queue; Type: TABLE; Schema: pgq; Owner: -; Tablespace: 
--

CREATE TABLE queue (
    queue_id integer NOT NULL,
    queue_name text NOT NULL,
    queue_ntables integer DEFAULT 3 NOT NULL,
    queue_cur_table integer DEFAULT 0 NOT NULL,
    queue_rotation_period interval DEFAULT '02:00:00'::interval NOT NULL,
    queue_switch_step1 bigint DEFAULT txid_current() NOT NULL,
    queue_switch_step2 bigint DEFAULT txid_current(),
    queue_switch_time timestamp with time zone DEFAULT now() NOT NULL,
    queue_external_ticker boolean DEFAULT false NOT NULL,
    queue_disable_insert boolean DEFAULT false NOT NULL,
    queue_ticker_paused boolean DEFAULT false NOT NULL,
    queue_ticker_max_count integer DEFAULT 500 NOT NULL,
    queue_ticker_max_lag interval DEFAULT '00:00:03'::interval NOT NULL,
    queue_ticker_idle_period interval DEFAULT '00:01:00'::interval NOT NULL,
    queue_per_tx_limit integer,
    queue_data_pfx text NOT NULL,
    queue_event_seq text NOT NULL,
    queue_tick_seq text NOT NULL
);


--
-- TOC entry 181 (class 1259 OID 16659)
-- Name: queue_queue_id_seq; Type: SEQUENCE; Schema: pgq; Owner: -
--

CREATE SEQUENCE queue_queue_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2373 (class 0 OID 0)
-- Dependencies: 181
-- Name: queue_queue_id_seq; Type: SEQUENCE OWNED BY; Schema: pgq; Owner: -
--

ALTER SEQUENCE queue_queue_id_seq OWNED BY queue.queue_id;


--
-- TOC entry 188 (class 1259 OID 16729)
-- Name: retry_queue; Type: TABLE; Schema: pgq; Owner: -; Tablespace: 
--

CREATE TABLE retry_queue (
    ev_retry_after timestamp with time zone NOT NULL,
    ev_queue integer NOT NULL,
    ev_id bigint NOT NULL,
    ev_time timestamp with time zone NOT NULL,
    ev_txid bigint,
    ev_owner integer NOT NULL,
    ev_retry integer,
    ev_type text,
    ev_data text,
    ev_extra1 text,
    ev_extra2 text,
    ev_extra3 text,
    ev_extra4 text
);


--
-- TOC entry 186 (class 1259 OID 16703)
-- Name: subscription; Type: TABLE; Schema: pgq; Owner: -; Tablespace: 
--

CREATE TABLE subscription (
    sub_id integer NOT NULL,
    sub_queue integer NOT NULL,
    sub_consumer integer NOT NULL,
    sub_last_tick bigint,
    sub_active timestamp with time zone DEFAULT now() NOT NULL,
    sub_batch bigint,
    sub_next_tick bigint
);


--
-- TOC entry 185 (class 1259 OID 16701)
-- Name: subscription_sub_id_seq; Type: SEQUENCE; Schema: pgq; Owner: -
--

CREATE SEQUENCE subscription_sub_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2374 (class 0 OID 0)
-- Dependencies: 185
-- Name: subscription_sub_id_seq; Type: SEQUENCE OWNED BY; Schema: pgq; Owner: -
--

ALTER SEQUENCE subscription_sub_id_seq OWNED BY subscription.sub_id;


--
-- TOC entry 183 (class 1259 OID 16684)
-- Name: tick; Type: TABLE; Schema: pgq; Owner: -; Tablespace: 
--

CREATE TABLE tick (
    tick_queue integer NOT NULL,
    tick_id bigint NOT NULL,
    tick_time timestamp with time zone DEFAULT now() NOT NULL,
    tick_snapshot txid_snapshot DEFAULT txid_current_snapshot() NOT NULL,
    tick_event_seq bigint NOT NULL
);


SET search_path = pgq_ext, pg_catalog;

--
-- TOC entry 190 (class 1259 OID 16807)
-- Name: completed_batch; Type: TABLE; Schema: pgq_ext; Owner: -; Tablespace: 
--

CREATE TABLE completed_batch (
    consumer_id text NOT NULL,
    subconsumer_id text DEFAULT ''::text NOT NULL,
    last_batch_id bigint NOT NULL
);


--
-- TOC entry 191 (class 1259 OID 16815)
-- Name: completed_event; Type: TABLE; Schema: pgq_ext; Owner: -; Tablespace: 
--

CREATE TABLE completed_event (
    consumer_id text NOT NULL,
    subconsumer_id text DEFAULT ''::text NOT NULL,
    batch_id bigint NOT NULL,
    event_id bigint NOT NULL
);


--
-- TOC entry 189 (class 1259 OID 16799)
-- Name: completed_tick; Type: TABLE; Schema: pgq_ext; Owner: -; Tablespace: 
--

CREATE TABLE completed_tick (
    consumer_id text NOT NULL,
    subconsumer_id text DEFAULT ''::text NOT NULL,
    last_tick_id bigint NOT NULL
);


--
-- TOC entry 192 (class 1259 OID 16823)
-- Name: partial_batch; Type: TABLE; Schema: pgq_ext; Owner: -; Tablespace: 
--

CREATE TABLE partial_batch (
    consumer_id text NOT NULL,
    subconsumer_id text DEFAULT ''::text NOT NULL,
    cur_batch_id bigint NOT NULL
);


SET search_path = pgq_node, pg_catalog;

--
-- TOC entry 195 (class 1259 OID 16874)
-- Name: local_state; Type: TABLE; Schema: pgq_node; Owner: -; Tablespace: 
--

CREATE TABLE local_state (
    queue_name text NOT NULL,
    consumer_name text NOT NULL,
    provider_node text NOT NULL,
    last_tick_id bigint NOT NULL,
    cur_error text,
    paused boolean DEFAULT false NOT NULL,
    uptodate boolean DEFAULT false NOT NULL
);


--
-- TOC entry 194 (class 1259 OID 16859)
-- Name: node_info; Type: TABLE; Schema: pgq_node; Owner: -; Tablespace: 
--

CREATE TABLE node_info (
    queue_name text NOT NULL,
    node_type text NOT NULL,
    node_name text NOT NULL,
    worker_name text,
    combined_queue text,
    node_attrs text,
    CONSTRAINT node_info_check CHECK (
CASE
    WHEN (node_type = 'root'::text) THEN ((worker_name IS NOT NULL) AND (combined_queue IS NULL))
    WHEN (node_type = 'branch'::text) THEN ((worker_name IS NOT NULL) AND (combined_queue IS NULL))
    WHEN (node_type = 'leaf'::text) THEN (worker_name IS NOT NULL)
    ELSE false
END),
    CONSTRAINT node_info_node_type_check CHECK ((node_type = ANY (ARRAY['root'::text, 'branch'::text, 'leaf'::text])))
);


--
-- TOC entry 193 (class 1259 OID 16850)
-- Name: node_location; Type: TABLE; Schema: pgq_node; Owner: -; Tablespace: 
--

CREATE TABLE node_location (
    queue_name text NOT NULL,
    node_name text NOT NULL,
    node_location text NOT NULL,
    dead boolean DEFAULT false NOT NULL
);


--
-- TOC entry 196 (class 1259 OID 16894)
-- Name: subscriber_info; Type: TABLE; Schema: pgq_node; Owner: -; Tablespace: 
--

CREATE TABLE subscriber_info (
    queue_name text NOT NULL,
    subscriber_node text NOT NULL,
    worker_name text NOT NULL,
    watermark_name text NOT NULL
);


SET search_path = sys, pg_catalog;

--
-- TOC entry 207 (class 1259 OID 17047)
-- Name: cdr_tables; Type: TABLE; Schema: sys; Owner: -; Tablespace: 
--

CREATE TABLE cdr_tables (
    id integer NOT NULL,
    name character varying NOT NULL,
    readable boolean DEFAULT true NOT NULL,
    writable boolean DEFAULT false NOT NULL,
    date_start character varying NOT NULL,
    date_stop character varying NOT NULL
);


--
-- TOC entry 206 (class 1259 OID 17045)
-- Name: cdr_tables_id_seq; Type: SEQUENCE; Schema: sys; Owner: -
--

CREATE SEQUENCE cdr_tables_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2375 (class 0 OID 0)
-- Dependencies: 206
-- Name: cdr_tables_id_seq; Type: SEQUENCE OWNED BY; Schema: sys; Owner: -
--

ALTER SEQUENCE cdr_tables_id_seq OWNED BY cdr_tables.id;


--
-- TOC entry 213 (class 1259 OID 17238)
-- Name: version; Type: TABLE; Schema: sys; Owner: -; Tablespace: 
--

CREATE TABLE version (
    id bigint NOT NULL,
    number integer NOT NULL,
    apply_date timestamp without time zone DEFAULT now() NOT NULL,
    comment character varying
);


--
-- TOC entry 212 (class 1259 OID 17236)
-- Name: version_id_seq; Type: SEQUENCE; Schema: sys; Owner: -
--

CREATE SEQUENCE version_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2376 (class 0 OID 0)
-- Dependencies: 212
-- Name: version_id_seq; Type: SEQUENCE OWNED BY; Schema: sys; Owner: -
--

ALTER SEQUENCE version_id_seq OWNED BY version.id;


SET search_path = cdr, pg_catalog;

--
-- TOC entry 2125 (class 2604 OID 17028)
-- Name: id; Type: DEFAULT; Schema: cdr; Owner: -
--

ALTER TABLE ONLY cdr ALTER COLUMN id SET DEFAULT nextval('cdr_id_seq'::regclass);


--
-- TOC entry 2132 (class 2604 OID 17182)
-- Name: id; Type: DEFAULT; Schema: cdr; Owner: -
--

ALTER TABLE ONLY cdr_201408 ALTER COLUMN id SET DEFAULT nextval('cdr_id_seq'::regclass);


--
-- TOC entry 2133 (class 2604 OID 17183)
-- Name: vendor_billed; Type: DEFAULT; Schema: cdr; Owner: -
--

ALTER TABLE ONLY cdr_201408 ALTER COLUMN vendor_billed SET DEFAULT false;


--
-- TOC entry 2134 (class 2604 OID 17184)
-- Name: customer_billed; Type: DEFAULT; Schema: cdr; Owner: -
--

ALTER TABLE ONLY cdr_201408 ALTER COLUMN customer_billed SET DEFAULT false;


--
-- TOC entry 2135 (class 2604 OID 17185)
-- Name: dump_level_id; Type: DEFAULT; Schema: cdr; Owner: -
--

ALTER TABLE ONLY cdr_201408 ALTER COLUMN dump_level_id SET DEFAULT 0;


--
-- TOC entry 2137 (class 2604 OID 17196)
-- Name: id; Type: DEFAULT; Schema: cdr; Owner: -
--

ALTER TABLE ONLY cdr_201409 ALTER COLUMN id SET DEFAULT nextval('cdr_id_seq'::regclass);


--
-- TOC entry 2138 (class 2604 OID 17197)
-- Name: vendor_billed; Type: DEFAULT; Schema: cdr; Owner: -
--

ALTER TABLE ONLY cdr_201409 ALTER COLUMN vendor_billed SET DEFAULT false;


--
-- TOC entry 2139 (class 2604 OID 17198)
-- Name: customer_billed; Type: DEFAULT; Schema: cdr; Owner: -
--

ALTER TABLE ONLY cdr_201409 ALTER COLUMN customer_billed SET DEFAULT false;


--
-- TOC entry 2140 (class 2604 OID 17199)
-- Name: dump_level_id; Type: DEFAULT; Schema: cdr; Owner: -
--

ALTER TABLE ONLY cdr_201409 ALTER COLUMN dump_level_id SET DEFAULT 0;


--
-- TOC entry 2142 (class 2604 OID 17210)
-- Name: id; Type: DEFAULT; Schema: cdr; Owner: -
--

ALTER TABLE ONLY cdr_201410 ALTER COLUMN id SET DEFAULT nextval('cdr_id_seq'::regclass);


--
-- TOC entry 2143 (class 2604 OID 17211)
-- Name: vendor_billed; Type: DEFAULT; Schema: cdr; Owner: -
--

ALTER TABLE ONLY cdr_201410 ALTER COLUMN vendor_billed SET DEFAULT false;


--
-- TOC entry 2144 (class 2604 OID 17212)
-- Name: customer_billed; Type: DEFAULT; Schema: cdr; Owner: -
--

ALTER TABLE ONLY cdr_201410 ALTER COLUMN customer_billed SET DEFAULT false;


--
-- TOC entry 2145 (class 2604 OID 17213)
-- Name: dump_level_id; Type: DEFAULT; Schema: cdr; Owner: -
--

ALTER TABLE ONLY cdr_201410 ALTER COLUMN dump_level_id SET DEFAULT 0;


--
-- TOC entry 2147 (class 2604 OID 17224)
-- Name: id; Type: DEFAULT; Schema: cdr; Owner: -
--

ALTER TABLE ONLY cdr_201411 ALTER COLUMN id SET DEFAULT nextval('cdr_id_seq'::regclass);


--
-- TOC entry 2148 (class 2604 OID 17225)
-- Name: vendor_billed; Type: DEFAULT; Schema: cdr; Owner: -
--

ALTER TABLE ONLY cdr_201411 ALTER COLUMN vendor_billed SET DEFAULT false;


--
-- TOC entry 2149 (class 2604 OID 17226)
-- Name: customer_billed; Type: DEFAULT; Schema: cdr; Owner: -
--

ALTER TABLE ONLY cdr_201411 ALTER COLUMN customer_billed SET DEFAULT false;


--
-- TOC entry 2150 (class 2604 OID 17227)
-- Name: dump_level_id; Type: DEFAULT; Schema: cdr; Owner: -
--

ALTER TABLE ONLY cdr_201411 ALTER COLUMN dump_level_id SET DEFAULT 0;


SET search_path = pgq, pg_catalog;

--
-- TOC entry 2090 (class 2604 OID 16651)
-- Name: co_id; Type: DEFAULT; Schema: pgq; Owner: -
--

ALTER TABLE ONLY consumer ALTER COLUMN co_id SET DEFAULT nextval('consumer_co_id_seq'::regclass);


--
-- TOC entry 2118 (class 2604 OID 16964)
-- Name: ev_txid; Type: DEFAULT; Schema: pgq; Owner: -
--

ALTER TABLE ONLY event_1 ALTER COLUMN ev_txid SET DEFAULT txid_current();


--
-- TOC entry 2120 (class 2604 OID 16975)
-- Name: ev_id; Type: DEFAULT; Schema: pgq; Owner: -
--

ALTER TABLE ONLY event_1_0 ALTER COLUMN ev_id SET DEFAULT nextval('event_1_id_seq'::regclass);


--
-- TOC entry 2119 (class 2604 OID 16971)
-- Name: ev_txid; Type: DEFAULT; Schema: pgq; Owner: -
--

ALTER TABLE ONLY event_1_0 ALTER COLUMN ev_txid SET DEFAULT txid_current();


--
-- TOC entry 2122 (class 2604 OID 16984)
-- Name: ev_id; Type: DEFAULT; Schema: pgq; Owner: -
--

ALTER TABLE ONLY event_1_1 ALTER COLUMN ev_id SET DEFAULT nextval('event_1_id_seq'::regclass);


--
-- TOC entry 2121 (class 2604 OID 16980)
-- Name: ev_txid; Type: DEFAULT; Schema: pgq; Owner: -
--

ALTER TABLE ONLY event_1_1 ALTER COLUMN ev_txid SET DEFAULT txid_current();


--
-- TOC entry 2124 (class 2604 OID 16993)
-- Name: ev_id; Type: DEFAULT; Schema: pgq; Owner: -
--

ALTER TABLE ONLY event_1_2 ALTER COLUMN ev_id SET DEFAULT nextval('event_1_id_seq'::regclass);


--
-- TOC entry 2123 (class 2604 OID 16989)
-- Name: ev_txid; Type: DEFAULT; Schema: pgq; Owner: -
--

ALTER TABLE ONLY event_1_2 ALTER COLUMN ev_txid SET DEFAULT txid_current();


--
-- TOC entry 2091 (class 2604 OID 16664)
-- Name: queue_id; Type: DEFAULT; Schema: pgq; Owner: -
--

ALTER TABLE ONLY queue ALTER COLUMN queue_id SET DEFAULT nextval('queue_queue_id_seq'::regclass);


--
-- TOC entry 2106 (class 2604 OID 16706)
-- Name: sub_id; Type: DEFAULT; Schema: pgq; Owner: -
--

ALTER TABLE ONLY subscription ALTER COLUMN sub_id SET DEFAULT nextval('subscription_sub_id_seq'::regclass);


SET search_path = sys, pg_catalog;

--
-- TOC entry 2129 (class 2604 OID 17050)
-- Name: id; Type: DEFAULT; Schema: sys; Owner: -
--

ALTER TABLE ONLY cdr_tables ALTER COLUMN id SET DEFAULT nextval('cdr_tables_id_seq'::regclass);


--
-- TOC entry 2152 (class 2604 OID 17241)
-- Name: id; Type: DEFAULT; Schema: sys; Owner: -
--

ALTER TABLE ONLY version ALTER COLUMN id SET DEFAULT nextval('version_id_seq'::regclass);


SET search_path = cdr, pg_catalog;

--
-- TOC entry 2355 (class 0 OID 17025)
-- Dependencies: 205
-- Data for Name: cdr; Type: TABLE DATA; Schema: cdr; Owner: -
--



--
-- TOC entry 2358 (class 0 OID 17179)
-- Dependencies: 208
-- Data for Name: cdr_201408; Type: TABLE DATA; Schema: cdr; Owner: -
--



--
-- TOC entry 2359 (class 0 OID 17193)
-- Dependencies: 209
-- Data for Name: cdr_201409; Type: TABLE DATA; Schema: cdr; Owner: -
--



--
-- TOC entry 2360 (class 0 OID 17207)
-- Dependencies: 210
-- Data for Name: cdr_201410; Type: TABLE DATA; Schema: cdr; Owner: -
--



--
-- TOC entry 2361 (class 0 OID 17221)
-- Dependencies: 211
-- Data for Name: cdr_201411; Type: TABLE DATA; Schema: cdr; Owner: -
--



--
-- TOC entry 2377 (class 0 OID 0)
-- Dependencies: 204
-- Name: cdr_id_seq; Type: SEQUENCE SET; Schema: cdr; Owner: -
--

SELECT pg_catalog.setval('cdr_id_seq', 639, true);


SET search_path = pgq, pg_catalog;

--
-- TOC entry 2378 (class 0 OID 0)
-- Dependencies: 184
-- Name: batch_id_seq; Type: SEQUENCE SET; Schema: pgq; Owner: -
--

SELECT pg_catalog.setval('batch_id_seq', 1, false);


--
-- TOC entry 2331 (class 0 OID 16648)
-- Dependencies: 180
-- Data for Name: consumer; Type: TABLE DATA; Schema: pgq; Owner: -
--

INSERT INTO consumer (co_id, co_name) VALUES (1, 'cdr_billing');


--
-- TOC entry 2379 (class 0 OID 0)
-- Dependencies: 179
-- Name: consumer_co_id_seq; Type: SEQUENCE SET; Schema: pgq; Owner: -
--

SELECT pg_catalog.setval('consumer_co_id_seq', 1, true);


--
-- TOC entry 2350 (class 0 OID 16961)
-- Dependencies: 199
-- Data for Name: event_1; Type: TABLE DATA; Schema: pgq; Owner: -
--



--
-- TOC entry 2351 (class 0 OID 16968)
-- Dependencies: 200
-- Data for Name: event_1_0; Type: TABLE DATA; Schema: pgq; Owner: -
--

INSERT INTO event_1_0 (ev_id, ev_time, ev_txid, ev_owner, ev_retry, ev_type, ev_data, ev_extra1, ev_extra2, ev_extra3, ev_extra4) VALUES (485, '2014-08-30 22:06:05.092339+03', 1454, NULL, NULL, 'cdr_full', '{"id":635,"customer_id":0,"vendor_id":0,"customer_acc_id":0,"vendor_acc_id":0,"customer_auth_id":0,"destination_id":0,"dialpeer_id":0,"orig_gw_id":0,"term_gw_id":0,"routing_group_id":0,"rateplan_id":0,"destination_next_rate":0,"destination_fee":0,"dialpeer_next_rate":0,"dialpeer_fee":0,"time_limit":"0","internal_disconnect_code":403,"internal_disconnect_reason":"Cant find customer or customer locked","disconnect_initiator_id":0,"customer_price":0,"vendor_price":0,"duration":0,"success":false,"vendor_billed":false,"customer_billed":false,"profit":0,"dst_prefix_in":"558005911013","dst_prefix_out":"558005911013","src_prefix_in":"213","src_prefix_out":"213","time_start":"2014-08-30 21:48:44","time_connect":null,"time_end":"2014-08-30 21:48:44","sign_orig_ip":"192.168.1.14","sign_orig_port":5060,"sign_orig_local_ip":"192.168.1.95","sign_orig_local_port":5060,"sign_term_ip":"","sign_term_port":null,"sign_term_local_ip":"","sign_term_local_port":null,"orig_call_id":"237210717","term_call_id":"","vendor_invoice_id":null,"customer_invoice_id":null,"local_tag":"","dump_file":"","destination_initial_rate":0,"dialpeer_initial_rate":0,"destination_initial_interval":60,"destination_next_interval":60,"dialpeer_initial_interval":60,"dialpeer_next_interval":60,"destination_rate_policy_id":1,"routing_attempt":1,"is_last_cdr":true,"lega_disconnect_code":403,"lega_disconnect_reason":"Cant find customer or customer locked","pop_id":1,"node_id":1,"src_name_in":"","src_name_out":"","diversion_in":null,"diversion_out":null,"lega_rx_payloads":"/","lega_tx_payloads":"/","legb_rx_payloads":"/","legb_tx_payloads":"/","legb_disconnect_code":0,"legb_disconnect_reason":"","dump_level_id":0,"auth_orig_ip":"192.168.1.14","auth_orig_port":5060,"lega_rx_bytes":0,"lega_tx_bytes":0,"legb_rx_bytes":0,"legb_tx_bytes":0,"global_tag":""}', NULL, NULL, NULL, NULL);
INSERT INTO event_1_0 (ev_id, ev_time, ev_txid, ev_owner, ev_retry, ev_type, ev_data, ev_extra1, ev_extra2, ev_extra3, ev_extra4) VALUES (486, '2014-08-30 22:06:07.344046+03', 1455, NULL, NULL, 'cdr_full', '{"id":636,"customer_id":0,"vendor_id":0,"customer_acc_id":0,"vendor_acc_id":0,"customer_auth_id":0,"destination_id":0,"dialpeer_id":0,"orig_gw_id":0,"term_gw_id":0,"routing_group_id":0,"rateplan_id":0,"destination_next_rate":0,"destination_fee":0,"dialpeer_next_rate":0,"dialpeer_fee":0,"time_limit":"0","internal_disconnect_code":403,"internal_disconnect_reason":"Cant find customer or customer locked","disconnect_initiator_id":0,"customer_price":0,"vendor_price":0,"duration":0,"success":false,"vendor_billed":false,"customer_billed":false,"profit":0,"dst_prefix_in":"558005911013","dst_prefix_out":"558005911013","src_prefix_in":"213","src_prefix_out":"213","time_start":"2014-08-30 21:54:21","time_connect":null,"time_end":"2014-08-30 21:54:21","sign_orig_ip":"192.168.1.14","sign_orig_port":5060,"sign_orig_local_ip":"192.168.1.95","sign_orig_local_port":5060,"sign_term_ip":"","sign_term_port":null,"sign_term_local_ip":"","sign_term_local_port":null,"orig_call_id":"27628157","term_call_id":"","vendor_invoice_id":null,"customer_invoice_id":null,"local_tag":"","dump_file":"","destination_initial_rate":0,"dialpeer_initial_rate":0,"destination_initial_interval":60,"destination_next_interval":60,"dialpeer_initial_interval":60,"dialpeer_next_interval":60,"destination_rate_policy_id":1,"routing_attempt":1,"is_last_cdr":true,"lega_disconnect_code":403,"lega_disconnect_reason":"Cant find customer or customer locked","pop_id":1,"node_id":1,"src_name_in":"","src_name_out":"","diversion_in":null,"diversion_out":null,"lega_rx_payloads":"/","lega_tx_payloads":"/","legb_rx_payloads":"/","legb_tx_payloads":"/","legb_disconnect_code":0,"legb_disconnect_reason":"","dump_level_id":0,"auth_orig_ip":"192.168.1.14","auth_orig_port":5060,"lega_rx_bytes":0,"lega_tx_bytes":0,"legb_rx_bytes":0,"legb_tx_bytes":0,"global_tag":""}', NULL, NULL, NULL, NULL);
INSERT INTO event_1_0 (ev_id, ev_time, ev_txid, ev_owner, ev_retry, ev_type, ev_data, ev_extra1, ev_extra2, ev_extra3, ev_extra4) VALUES (487, '2014-08-30 22:06:33.174271+03', 1463, NULL, NULL, 'cdr_full', '{"id":637,"customer_id":0,"vendor_id":0,"customer_acc_id":0,"vendor_acc_id":0,"customer_auth_id":0,"destination_id":0,"dialpeer_id":0,"orig_gw_id":0,"term_gw_id":0,"routing_group_id":0,"rateplan_id":0,"destination_next_rate":0,"destination_fee":0,"dialpeer_next_rate":0,"dialpeer_fee":0,"time_limit":"0","internal_disconnect_code":403,"internal_disconnect_reason":"Cant find customer or customer locked","disconnect_initiator_id":0,"customer_price":0,"vendor_price":0,"duration":0,"success":false,"vendor_billed":false,"customer_billed":false,"profit":0,"dst_prefix_in":"558005911013","dst_prefix_out":"558005911013","src_prefix_in":"213","src_prefix_out":"213","time_start":"2014-08-30 22:05:02","time_connect":null,"time_end":"2014-08-30 22:05:02","sign_orig_ip":"192.168.1.14","sign_orig_port":5060,"sign_orig_local_ip":"192.168.1.95","sign_orig_local_port":5060,"sign_term_ip":"","sign_term_port":null,"sign_term_local_ip":"","sign_term_local_port":null,"orig_call_id":"35210035","term_call_id":"","vendor_invoice_id":null,"customer_invoice_id":null,"local_tag":"","dump_file":"","destination_initial_rate":0,"dialpeer_initial_rate":0,"destination_initial_interval":60,"destination_next_interval":60,"dialpeer_initial_interval":60,"dialpeer_next_interval":60,"destination_rate_policy_id":1,"routing_attempt":1,"is_last_cdr":true,"lega_disconnect_code":403,"lega_disconnect_reason":"Cant find customer or customer locked","pop_id":1,"node_id":1,"src_name_in":"","src_name_out":"","diversion_in":null,"diversion_out":null,"lega_rx_payloads":"/","lega_tx_payloads":"/","legb_rx_payloads":"/","legb_tx_payloads":"/","legb_disconnect_code":0,"legb_disconnect_reason":"","dump_level_id":0,"auth_orig_ip":"192.168.1.14","auth_orig_port":5060,"lega_rx_bytes":0,"lega_tx_bytes":0,"legb_rx_bytes":0,"legb_tx_bytes":0,"global_tag":""}', NULL, NULL, NULL, NULL);
INSERT INTO event_1_0 (ev_id, ev_time, ev_txid, ev_owner, ev_retry, ev_type, ev_data, ev_extra1, ev_extra2, ev_extra3, ev_extra4) VALUES (488, '2014-08-30 23:10:16.295633+03', 1464, NULL, NULL, 'cdr_full', '{"id":638,"customer_id":0,"vendor_id":0,"customer_acc_id":0,"vendor_acc_id":0,"customer_auth_id":0,"destination_id":0,"dialpeer_id":0,"orig_gw_id":0,"term_gw_id":0,"routing_group_id":0,"rateplan_id":0,"destination_next_rate":0,"destination_fee":0,"dialpeer_next_rate":0,"dialpeer_fee":0,"time_limit":"0","internal_disconnect_code":403,"internal_disconnect_reason":"Cant find customer or customer locked","disconnect_initiator_id":0,"customer_price":0,"vendor_price":0,"duration":0,"success":false,"vendor_billed":false,"customer_billed":false,"profit":0,"dst_prefix_in":"558005911013","dst_prefix_out":"558005911013","src_prefix_in":"213","src_prefix_out":"213","time_start":"2014-08-30 23:08:46","time_connect":null,"time_end":"2014-08-30 23:08:46","sign_orig_ip":"192.168.1.14","sign_orig_port":5060,"sign_orig_local_ip":"192.168.1.95","sign_orig_local_port":5060,"sign_term_ip":"","sign_term_port":null,"sign_term_local_ip":"","sign_term_local_port":null,"orig_call_id":"602399956","term_call_id":"","vendor_invoice_id":null,"customer_invoice_id":null,"local_tag":"","dump_file":"","destination_initial_rate":0,"dialpeer_initial_rate":0,"destination_initial_interval":60,"destination_next_interval":60,"dialpeer_initial_interval":60,"dialpeer_next_interval":60,"destination_rate_policy_id":1,"routing_attempt":1,"is_last_cdr":true,"lega_disconnect_code":403,"lega_disconnect_reason":"Cant find customer or customer locked","pop_id":1,"node_id":1,"src_name_in":"","src_name_out":"","diversion_in":null,"diversion_out":null,"lega_rx_payloads":"/","lega_tx_payloads":"/","legb_rx_payloads":"/","legb_tx_payloads":"/","legb_disconnect_code":0,"legb_disconnect_reason":"","dump_level_id":0,"auth_orig_ip":"192.168.1.14","auth_orig_port":5060,"lega_rx_bytes":0,"lega_tx_bytes":0,"legb_rx_bytes":0,"legb_tx_bytes":0,"global_tag":""}', NULL, NULL, NULL, NULL);
INSERT INTO event_1_0 (ev_id, ev_time, ev_txid, ev_owner, ev_retry, ev_type, ev_data, ev_extra1, ev_extra2, ev_extra3, ev_extra4) VALUES (489, '2014-08-31 18:40:16.014391+03', 1465, NULL, NULL, 'cdr_full', '{"id":639,"customer_id":0,"vendor_id":0,"customer_acc_id":0,"vendor_acc_id":0,"customer_auth_id":0,"destination_id":0,"dialpeer_id":0,"orig_gw_id":0,"term_gw_id":0,"routing_group_id":0,"rateplan_id":0,"destination_next_rate":0,"destination_fee":0,"dialpeer_next_rate":0,"dialpeer_fee":0,"time_limit":"0","internal_disconnect_code":403,"internal_disconnect_reason":"Cant find customer or customer locked","disconnect_initiator_id":0,"customer_price":0,"vendor_price":0,"duration":0,"success":false,"vendor_billed":false,"customer_billed":false,"profit":0,"dst_prefix_in":"558005911013","dst_prefix_out":"558005911013","src_prefix_in":"213","src_prefix_out":"213","time_start":"2014-08-31 18:39:39","time_connect":null,"time_end":"2014-08-31 18:39:39","sign_orig_ip":"192.168.1.14","sign_orig_port":5060,"sign_orig_local_ip":"192.168.1.95","sign_orig_local_port":5060,"sign_term_ip":"","sign_term_port":null,"sign_term_local_ip":"","sign_term_local_port":null,"orig_call_id":"2119301475","term_call_id":"","vendor_invoice_id":null,"customer_invoice_id":null,"local_tag":"","dump_file":"","destination_initial_rate":0,"dialpeer_initial_rate":0,"destination_initial_interval":60,"destination_next_interval":60,"dialpeer_initial_interval":60,"dialpeer_next_interval":60,"destination_rate_policy_id":1,"routing_attempt":1,"is_last_cdr":true,"lega_disconnect_code":403,"lega_disconnect_reason":"Cant find customer or customer locked","pop_id":1,"node_id":1,"src_name_in":"","src_name_out":"","diversion_in":null,"diversion_out":null,"lega_rx_payloads":"/","lega_tx_payloads":"/","legb_rx_payloads":"/","legb_tx_payloads":"/","legb_disconnect_code":0,"legb_disconnect_reason":"","dump_level_id":0,"auth_orig_ip":"192.168.1.14","auth_orig_port":5060,"lega_rx_bytes":0,"lega_tx_bytes":0,"legb_rx_bytes":0,"legb_tx_bytes":0,"global_tag":""}', NULL, NULL, NULL, NULL);


--
-- TOC entry 2352 (class 0 OID 16977)
-- Dependencies: 201
-- Data for Name: event_1_1; Type: TABLE DATA; Schema: pgq; Owner: -
--



--
-- TOC entry 2353 (class 0 OID 16986)
-- Dependencies: 202
-- Data for Name: event_1_2; Type: TABLE DATA; Schema: pgq; Owner: -
--



--
-- TOC entry 2380 (class 0 OID 0)
-- Dependencies: 198
-- Name: event_1_id_seq; Type: SEQUENCE SET; Schema: pgq; Owner: -
--

SELECT pg_catalog.setval('event_1_id_seq', 489, true);


--
-- TOC entry 2381 (class 0 OID 0)
-- Dependencies: 197
-- Name: event_1_tick_seq; Type: SEQUENCE SET; Schema: pgq; Owner: -
--

SELECT pg_catalog.setval('event_1_tick_seq', 1, true);


--
-- TOC entry 2338 (class 0 OID 16722)
-- Dependencies: 187
-- Data for Name: event_template; Type: TABLE DATA; Schema: pgq; Owner: -
--



--
-- TOC entry 2333 (class 0 OID 16661)
-- Dependencies: 182
-- Data for Name: queue; Type: TABLE DATA; Schema: pgq; Owner: -
--

INSERT INTO queue (queue_id, queue_name, queue_ntables, queue_cur_table, queue_rotation_period, queue_switch_step1, queue_switch_step2, queue_switch_time, queue_external_ticker, queue_disable_insert, queue_ticker_paused, queue_ticker_max_count, queue_ticker_max_lag, queue_ticker_idle_period, queue_per_tx_limit, queue_data_pfx, queue_event_seq, queue_tick_seq) VALUES (1, 'cdr_billing', 3, 0, '02:00:00', 920, 920, '2014-08-15 15:16:57.963671+03', false, false, false, 500, '00:00:03', '00:01:00', NULL, 'pgq.event_1', 'pgq.event_1_id_seq', 'pgq.event_1_tick_seq');


--
-- TOC entry 2382 (class 0 OID 0)
-- Dependencies: 181
-- Name: queue_queue_id_seq; Type: SEQUENCE SET; Schema: pgq; Owner: -
--

SELECT pg_catalog.setval('queue_queue_id_seq', 1, true);


--
-- TOC entry 2339 (class 0 OID 16729)
-- Dependencies: 188
-- Data for Name: retry_queue; Type: TABLE DATA; Schema: pgq; Owner: -
--



--
-- TOC entry 2337 (class 0 OID 16703)
-- Dependencies: 186
-- Data for Name: subscription; Type: TABLE DATA; Schema: pgq; Owner: -
--



--
-- TOC entry 2383 (class 0 OID 0)
-- Dependencies: 185
-- Name: subscription_sub_id_seq; Type: SEQUENCE SET; Schema: pgq; Owner: -
--

SELECT pg_catalog.setval('subscription_sub_id_seq', 1, true);


--
-- TOC entry 2334 (class 0 OID 16684)
-- Dependencies: 183
-- Data for Name: tick; Type: TABLE DATA; Schema: pgq; Owner: -
--

INSERT INTO tick (tick_queue, tick_id, tick_time, tick_snapshot, tick_event_seq) VALUES (1, 1, '2014-08-15 15:16:57.963671+03', '920:920:', 1);


SET search_path = pgq_ext, pg_catalog;

--
-- TOC entry 2341 (class 0 OID 16807)
-- Dependencies: 190
-- Data for Name: completed_batch; Type: TABLE DATA; Schema: pgq_ext; Owner: -
--



--
-- TOC entry 2342 (class 0 OID 16815)
-- Dependencies: 191
-- Data for Name: completed_event; Type: TABLE DATA; Schema: pgq_ext; Owner: -
--



--
-- TOC entry 2340 (class 0 OID 16799)
-- Dependencies: 189
-- Data for Name: completed_tick; Type: TABLE DATA; Schema: pgq_ext; Owner: -
--



--
-- TOC entry 2343 (class 0 OID 16823)
-- Dependencies: 192
-- Data for Name: partial_batch; Type: TABLE DATA; Schema: pgq_ext; Owner: -
--



SET search_path = pgq_node, pg_catalog;

--
-- TOC entry 2346 (class 0 OID 16874)
-- Dependencies: 195
-- Data for Name: local_state; Type: TABLE DATA; Schema: pgq_node; Owner: -
--



--
-- TOC entry 2345 (class 0 OID 16859)
-- Dependencies: 194
-- Data for Name: node_info; Type: TABLE DATA; Schema: pgq_node; Owner: -
--



--
-- TOC entry 2344 (class 0 OID 16850)
-- Dependencies: 193
-- Data for Name: node_location; Type: TABLE DATA; Schema: pgq_node; Owner: -
--



--
-- TOC entry 2347 (class 0 OID 16894)
-- Dependencies: 196
-- Data for Name: subscriber_info; Type: TABLE DATA; Schema: pgq_node; Owner: -
--



SET search_path = sys, pg_catalog;

--
-- TOC entry 2357 (class 0 OID 17047)
-- Dependencies: 207
-- Data for Name: cdr_tables; Type: TABLE DATA; Schema: sys; Owner: -
--

INSERT INTO cdr_tables (id, name, readable, writable, date_start, date_stop) VALUES (2, 'cdr.cdr_201408', true, true, '2014-08-01', '2014-09-01');
INSERT INTO cdr_tables (id, name, readable, writable, date_start, date_stop) VALUES (3, 'cdr.cdr_201409', true, true, '2014-09-01', '2014-10-01');
INSERT INTO cdr_tables (id, name, readable, writable, date_start, date_stop) VALUES (4, 'cdr.cdr_201410', true, true, '2014-10-01', '2014-11-01');
INSERT INTO cdr_tables (id, name, readable, writable, date_start, date_stop) VALUES (5, 'cdr.cdr_201411', true, true, '2014-11-01', '2014-12-01');


--
-- TOC entry 2384 (class 0 OID 0)
-- Dependencies: 206
-- Name: cdr_tables_id_seq; Type: SEQUENCE SET; Schema: sys; Owner: -
--

SELECT pg_catalog.setval('cdr_tables_id_seq', 5, true);


--
-- TOC entry 2363 (class 0 OID 17238)
-- Dependencies: 213
-- Data for Name: version; Type: TABLE DATA; Schema: sys; Owner: -
--

INSERT INTO version (id, number, apply_date, comment) VALUES (1, 1, '2014-10-13 13:56:57.508299', 'Initial CDR db package');


--
-- TOC entry 2385 (class 0 OID 0)
-- Dependencies: 212
-- Name: version_id_seq; Type: SEQUENCE SET; Schema: sys; Owner: -
--

SELECT pg_catalog.setval('version_id_seq', 1, true);


SET search_path = cdr, pg_catalog;

--
-- TOC entry 2197 (class 2606 OID 17191)
-- Name: cdr_201408_pkey; Type: CONSTRAINT; Schema: cdr; Owner: -; Tablespace: 
--

ALTER TABLE ONLY cdr_201408
    ADD CONSTRAINT cdr_201408_pkey PRIMARY KEY (id);


--
-- TOC entry 2200 (class 2606 OID 17205)
-- Name: cdr_201409_pkey; Type: CONSTRAINT; Schema: cdr; Owner: -; Tablespace: 
--

ALTER TABLE ONLY cdr_201409
    ADD CONSTRAINT cdr_201409_pkey PRIMARY KEY (id);


--
-- TOC entry 2203 (class 2606 OID 17219)
-- Name: cdr_201410_pkey; Type: CONSTRAINT; Schema: cdr; Owner: -; Tablespace: 
--

ALTER TABLE ONLY cdr_201410
    ADD CONSTRAINT cdr_201410_pkey PRIMARY KEY (id);


--
-- TOC entry 2206 (class 2606 OID 17233)
-- Name: cdr_201411_pkey; Type: CONSTRAINT; Schema: cdr; Owner: -; Tablespace: 
--

ALTER TABLE ONLY cdr_201411
    ADD CONSTRAINT cdr_201411_pkey PRIMARY KEY (id);


--
-- TOC entry 2191 (class 2606 OID 17036)
-- Name: cdr_pkey; Type: CONSTRAINT; Schema: cdr; Owner: -; Tablespace: 
--

ALTER TABLE ONLY cdr
    ADD CONSTRAINT cdr_pkey PRIMARY KEY (id);


SET search_path = pgq, pg_catalog;

--
-- TOC entry 2155 (class 2606 OID 16658)
-- Name: consumer_name_uq; Type: CONSTRAINT; Schema: pgq; Owner: -; Tablespace: 
--

ALTER TABLE ONLY consumer
    ADD CONSTRAINT consumer_name_uq UNIQUE (co_name);


--
-- TOC entry 2157 (class 2606 OID 16656)
-- Name: consumer_pkey; Type: CONSTRAINT; Schema: pgq; Owner: -; Tablespace: 
--

ALTER TABLE ONLY consumer
    ADD CONSTRAINT consumer_pkey PRIMARY KEY (co_id);


--
-- TOC entry 2159 (class 2606 OID 16683)
-- Name: queue_name_uq; Type: CONSTRAINT; Schema: pgq; Owner: -; Tablespace: 
--

ALTER TABLE ONLY queue
    ADD CONSTRAINT queue_name_uq UNIQUE (queue_name);


--
-- TOC entry 2161 (class 2606 OID 16681)
-- Name: queue_pkey; Type: CONSTRAINT; Schema: pgq; Owner: -; Tablespace: 
--

ALTER TABLE ONLY queue
    ADD CONSTRAINT queue_pkey PRIMARY KEY (queue_id);


--
-- TOC entry 2169 (class 2606 OID 16736)
-- Name: rq_pkey; Type: CONSTRAINT; Schema: pgq; Owner: -; Tablespace: 
--

ALTER TABLE ONLY retry_queue
    ADD CONSTRAINT rq_pkey PRIMARY KEY (ev_owner, ev_id);


--
-- TOC entry 2165 (class 2606 OID 16711)
-- Name: subscription_batch_idx; Type: CONSTRAINT; Schema: pgq; Owner: -; Tablespace: 
--

ALTER TABLE ONLY subscription
    ADD CONSTRAINT subscription_batch_idx UNIQUE (sub_batch);


--
-- TOC entry 2167 (class 2606 OID 16709)
-- Name: subscription_pkey; Type: CONSTRAINT; Schema: pgq; Owner: -; Tablespace: 
--

ALTER TABLE ONLY subscription
    ADD CONSTRAINT subscription_pkey PRIMARY KEY (sub_queue, sub_consumer);


--
-- TOC entry 2163 (class 2606 OID 16693)
-- Name: tick_pkey; Type: CONSTRAINT; Schema: pgq; Owner: -; Tablespace: 
--

ALTER TABLE ONLY tick
    ADD CONSTRAINT tick_pkey PRIMARY KEY (tick_queue, tick_id);


SET search_path = pgq_ext, pg_catalog;

--
-- TOC entry 2174 (class 2606 OID 16814)
-- Name: completed_batch_pkey; Type: CONSTRAINT; Schema: pgq_ext; Owner: -; Tablespace: 
--

ALTER TABLE ONLY completed_batch
    ADD CONSTRAINT completed_batch_pkey PRIMARY KEY (consumer_id, subconsumer_id);


--
-- TOC entry 2176 (class 2606 OID 16822)
-- Name: completed_event_pkey; Type: CONSTRAINT; Schema: pgq_ext; Owner: -; Tablespace: 
--

ALTER TABLE ONLY completed_event
    ADD CONSTRAINT completed_event_pkey PRIMARY KEY (consumer_id, subconsumer_id, batch_id, event_id);


--
-- TOC entry 2172 (class 2606 OID 16806)
-- Name: completed_tick_pkey; Type: CONSTRAINT; Schema: pgq_ext; Owner: -; Tablespace: 
--

ALTER TABLE ONLY completed_tick
    ADD CONSTRAINT completed_tick_pkey PRIMARY KEY (consumer_id, subconsumer_id);


--
-- TOC entry 2178 (class 2606 OID 16830)
-- Name: partial_batch_pkey; Type: CONSTRAINT; Schema: pgq_ext; Owner: -; Tablespace: 
--

ALTER TABLE ONLY partial_batch
    ADD CONSTRAINT partial_batch_pkey PRIMARY KEY (consumer_id, subconsumer_id);


SET search_path = pgq_node, pg_catalog;

--
-- TOC entry 2184 (class 2606 OID 16883)
-- Name: local_state_pkey; Type: CONSTRAINT; Schema: pgq_node; Owner: -; Tablespace: 
--

ALTER TABLE ONLY local_state
    ADD CONSTRAINT local_state_pkey PRIMARY KEY (queue_name, consumer_name);


--
-- TOC entry 2182 (class 2606 OID 16868)
-- Name: node_info_pkey; Type: CONSTRAINT; Schema: pgq_node; Owner: -; Tablespace: 
--

ALTER TABLE ONLY node_info
    ADD CONSTRAINT node_info_pkey PRIMARY KEY (queue_name);


--
-- TOC entry 2180 (class 2606 OID 16858)
-- Name: node_location_pkey; Type: CONSTRAINT; Schema: pgq_node; Owner: -; Tablespace: 
--

ALTER TABLE ONLY node_location
    ADD CONSTRAINT node_location_pkey PRIMARY KEY (queue_name, node_name);


--
-- TOC entry 2186 (class 2606 OID 16901)
-- Name: subscriber_info_pkey; Type: CONSTRAINT; Schema: pgq_node; Owner: -; Tablespace: 
--

ALTER TABLE ONLY subscriber_info
    ADD CONSTRAINT subscriber_info_pkey PRIMARY KEY (queue_name, subscriber_node);


SET search_path = sys, pg_catalog;

--
-- TOC entry 2195 (class 2606 OID 17057)
-- Name: cdr_tables_pkey; Type: CONSTRAINT; Schema: sys; Owner: -; Tablespace: 
--

ALTER TABLE ONLY cdr_tables
    ADD CONSTRAINT cdr_tables_pkey PRIMARY KEY (id);


--
-- TOC entry 2209 (class 2606 OID 17249)
-- Name: version_number_key; Type: CONSTRAINT; Schema: sys; Owner: -; Tablespace: 
--

ALTER TABLE ONLY version
    ADD CONSTRAINT version_number_key UNIQUE (number);


--
-- TOC entry 2211 (class 2606 OID 17247)
-- Name: version_pkey; Type: CONSTRAINT; Schema: sys; Owner: -; Tablespace: 
--

ALTER TABLE ONLY version
    ADD CONSTRAINT version_pkey PRIMARY KEY (id);


SET search_path = cdr, pg_catalog;

--
-- TOC entry 2198 (class 1259 OID 17192)
-- Name: cdr_201408_time_start_idx; Type: INDEX; Schema: cdr; Owner: -; Tablespace: 
--

CREATE INDEX cdr_201408_time_start_idx ON cdr_201408 USING btree (time_start);


--
-- TOC entry 2201 (class 1259 OID 17206)
-- Name: cdr_201409_time_start_idx; Type: INDEX; Schema: cdr; Owner: -; Tablespace: 
--

CREATE INDEX cdr_201409_time_start_idx ON cdr_201409 USING btree (time_start);


--
-- TOC entry 2204 (class 1259 OID 17220)
-- Name: cdr_201410_time_start_idx; Type: INDEX; Schema: cdr; Owner: -; Tablespace: 
--

CREATE INDEX cdr_201410_time_start_idx ON cdr_201410 USING btree (time_start);


--
-- TOC entry 2207 (class 1259 OID 17234)
-- Name: cdr_201411_time_start_idx; Type: INDEX; Schema: cdr; Owner: -; Tablespace: 
--

CREATE INDEX cdr_201411_time_start_idx ON cdr_201411 USING btree (time_start);


--
-- TOC entry 2192 (class 1259 OID 17037)
-- Name: cdr_time_start_idx; Type: INDEX; Schema: cdr; Owner: -; Tablespace: 
--

CREATE INDEX cdr_time_start_idx ON cdr USING btree (time_start);


--
-- TOC entry 2193 (class 1259 OID 17038)
-- Name: cdr_vendor_invoice_id_idx; Type: INDEX; Schema: cdr; Owner: -; Tablespace: 
--

CREATE INDEX cdr_vendor_invoice_id_idx ON cdr USING btree (vendor_invoice_id);


SET search_path = pgq, pg_catalog;

--
-- TOC entry 2187 (class 1259 OID 16976)
-- Name: event_1_0_txid_idx; Type: INDEX; Schema: pgq; Owner: -; Tablespace: 
--

CREATE INDEX event_1_0_txid_idx ON event_1_0 USING btree (ev_txid);


--
-- TOC entry 2188 (class 1259 OID 16985)
-- Name: event_1_1_txid_idx; Type: INDEX; Schema: pgq; Owner: -; Tablespace: 
--

CREATE INDEX event_1_1_txid_idx ON event_1_1 USING btree (ev_txid);


--
-- TOC entry 2189 (class 1259 OID 16994)
-- Name: event_1_2_txid_idx; Type: INDEX; Schema: pgq; Owner: -; Tablespace: 
--

CREATE INDEX event_1_2_txid_idx ON event_1_2 USING btree (ev_txid);


--
-- TOC entry 2170 (class 1259 OID 16742)
-- Name: rq_retry_idx; Type: INDEX; Schema: pgq; Owner: -; Tablespace: 
--

CREATE INDEX rq_retry_idx ON retry_queue USING btree (ev_retry_after);


SET search_path = cdr, pg_catalog;

--
-- TOC entry 2222 (class 2620 OID 17039)
-- Name: cdr_i; Type: TRIGGER; Schema: cdr; Owner: -
--

CREATE TRIGGER cdr_i BEFORE INSERT ON cdr FOR EACH ROW EXECUTE PROCEDURE cdr_i_tgf();


SET search_path = pgq, pg_catalog;

--
-- TOC entry 2215 (class 2606 OID 16737)
-- Name: rq_queue_id_fkey; Type: FK CONSTRAINT; Schema: pgq; Owner: -
--

ALTER TABLE ONLY retry_queue
    ADD CONSTRAINT rq_queue_id_fkey FOREIGN KEY (ev_queue) REFERENCES queue(queue_id);


--
-- TOC entry 2214 (class 2606 OID 16717)
-- Name: sub_consumer_fkey; Type: FK CONSTRAINT; Schema: pgq; Owner: -
--

ALTER TABLE ONLY subscription
    ADD CONSTRAINT sub_consumer_fkey FOREIGN KEY (sub_consumer) REFERENCES consumer(co_id);


--
-- TOC entry 2213 (class 2606 OID 16712)
-- Name: sub_queue_fkey; Type: FK CONSTRAINT; Schema: pgq; Owner: -
--

ALTER TABLE ONLY subscription
    ADD CONSTRAINT sub_queue_fkey FOREIGN KEY (sub_queue) REFERENCES queue(queue_id);


--
-- TOC entry 2212 (class 2606 OID 16694)
-- Name: tick_queue_fkey; Type: FK CONSTRAINT; Schema: pgq; Owner: -
--

ALTER TABLE ONLY tick
    ADD CONSTRAINT tick_queue_fkey FOREIGN KEY (tick_queue) REFERENCES queue(queue_id);


SET search_path = pgq_node, pg_catalog;

--
-- TOC entry 2217 (class 2606 OID 16884)
-- Name: local_state_queue_name_fkey; Type: FK CONSTRAINT; Schema: pgq_node; Owner: -
--

ALTER TABLE ONLY local_state
    ADD CONSTRAINT local_state_queue_name_fkey FOREIGN KEY (queue_name) REFERENCES node_info(queue_name);


--
-- TOC entry 2218 (class 2606 OID 16889)
-- Name: local_state_queue_name_fkey1; Type: FK CONSTRAINT; Schema: pgq_node; Owner: -
--

ALTER TABLE ONLY local_state
    ADD CONSTRAINT local_state_queue_name_fkey1 FOREIGN KEY (queue_name, provider_node) REFERENCES node_location(queue_name, node_name);


--
-- TOC entry 2216 (class 2606 OID 16869)
-- Name: node_info_queue_name_fkey; Type: FK CONSTRAINT; Schema: pgq_node; Owner: -
--

ALTER TABLE ONLY node_info
    ADD CONSTRAINT node_info_queue_name_fkey FOREIGN KEY (queue_name, node_name) REFERENCES node_location(queue_name, node_name);


--
-- TOC entry 2219 (class 2606 OID 16902)
-- Name: subscriber_info_queue_name_fkey; Type: FK CONSTRAINT; Schema: pgq_node; Owner: -
--

ALTER TABLE ONLY subscriber_info
    ADD CONSTRAINT subscriber_info_queue_name_fkey FOREIGN KEY (queue_name, subscriber_node) REFERENCES node_location(queue_name, node_name);


--
-- TOC entry 2221 (class 2606 OID 16912)
-- Name: subscriber_info_watermark_name_fkey; Type: FK CONSTRAINT; Schema: pgq_node; Owner: -
--

ALTER TABLE ONLY subscriber_info
    ADD CONSTRAINT subscriber_info_watermark_name_fkey FOREIGN KEY (watermark_name) REFERENCES pgq.consumer(co_name);


--
-- TOC entry 2220 (class 2606 OID 16907)
-- Name: subscriber_info_worker_name_fkey; Type: FK CONSTRAINT; Schema: pgq_node; Owner: -
--

ALTER TABLE ONLY subscriber_info
    ADD CONSTRAINT subscriber_info_worker_name_fkey FOREIGN KEY (worker_name) REFERENCES pgq.consumer(co_name);


-- Completed on 2014-10-13 13:57:50 EEST

--
-- PostgreSQL database dump complete
--
commit;
