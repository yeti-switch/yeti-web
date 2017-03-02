begin;
-- delete from sys.version where number=4;
-- drop schema reports cascade;

insert into sys.version(number,comment) values(4,'Traffic reports generation');


SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;


CREATE SCHEMA reports;


SET search_path = reports, pg_catalog;

--
-- TOC entry 655 (class 1255 OID 17202)
-- Name: cdr_custom_report(timestamp without time zone, timestamp without time zone, character varying, character varying); Type: FUNCTION; Schema: reports; Owner: -
--

CREATE FUNCTION cdr_custom_report(i_date_start timestamp without time zone, i_date_end timestamp without time zone, i_group_by character varying, i_filter character varying) RETURNS integer
    LANGUAGE plpgsql COST 10
    AS $$
DECLARE
    v_rid integer;
    v_sql varchar;
    v_keys varchar:='';
    v_i integer:=0;
    v_field varchar;
    v_filter varchar;
BEGIN
    INSERT INTO reports.cdr_custom_report(created_at,date_start,date_end,filter,group_by)
        values(now(),i_date_start,i_date_end,i_filter,i_group_by) RETURNING id INTO v_rid;

    For v_field in select * from regexp_split_to_table(i_group_by,',') LOOP
        v_i:=v_i+1;
        --IF regexp_match(v_field','w');
        v_keys:=v_keys||'key'||v_i::varchar||',';
    end loop;
    
    v_filter=COALESCE('AND '||NULLIF(i_filter,''),'');
    
    v_sql:='
        INSERT INTO cdr_custom_report_data(report_id,'||i_group_by||',agg_calls_count,agg_calls_duration,agg_customer_price,agg_vendor_price,agg_profit,agg_asr_origination,agg_asr_termination) 
            SELECT '||v_rid::varchar||','||i_group_by::varchar||',count(id),sum(duration),sum(customer_price),sum(vendor_price),sum(profit),1,1
            from cdr.cdr
            WHERE 
                time_start>='''||i_date_start::varchar||'''
                AND time_start<'''||i_date_end::varchar||''' '||v_filter||'
            GROUP BY '||i_group_by;
    RAISE WARNING 'SQL: %',v_sql;
    EXECUTE v_sql;
    RETURN v_rid;

END;
$$;


--
-- TOC entry 656 (class 1255 OID 17203)
-- Name: cdr_custom_report_remove(integer); Type: FUNCTION; Schema: reports; Owner: -
--

CREATE FUNCTION cdr_custom_report_remove(i_report_id integer) RETURNS void
    LANGUAGE plpgsql COST 3000
    AS $$
DECLARE

BEGIN
    delete from reports.cdr_custom_report_data where report_id=i_report_id;
    delete from reports.cdr_custom_report where id=i_report_id;
END;
$$;


--
-- TOC entry 657 (class 1255 OID 17204)
-- Name: cdr_interval_report(timestamp without time zone, timestamp without time zone, integer, integer, character varying, character varying, character varying); Type: FUNCTION; Schema: reports; Owner: -
--

CREATE FUNCTION cdr_interval_report(i_date_start timestamp without time zone, i_date_end timestamp without time zone, i_interval_length integer, i_agg_id integer, i_agg_by character varying, i_filter character varying, i_group_by character varying) RETURNS integer
    LANGUAGE plpgsql COST 3000
    AS $$
DECLARE
    v_rid integer;
    v_sql varchar;
    v_keys varchar:='';
    v_i integer:=0;
    v_field varchar;
    v_filter varchar;
    v_group_by varchar;
    v_agg varchar;
    v_tsp  varchar;
    v_tsp_ varchar;
BEGIN
    INSERT INTO reports.cdr_interval_report(created_at,date_start,date_end,
    filter,group_by,interval_length,aggregator_id,aggregate_by)
        values(now(),i_date_start,i_date_end,i_filter,i_group_by,i_interval_length,i_agg_id,i_agg_by) RETURNING id INTO v_rid;

    /* build aggregation function */
    select into v_agg "name"||'('||i_agg_by||')' from reports.cdr_interval_report_aggrerator where id=i_agg_id;
    IF NOT FOUND or v_agg is null THEN
        RAISE exception 'reports.cdr_interval_report: can`t build aggregate function';
    end if;

    --selecv_date_agg
    --floor( (UNIX_TIMESTAMP(date) + TIME_TO_SEC(time))/300)*300 as period

    v_tsp='(date_part(''epoch'',time_start)/date_part(''epoch'','''||i_interval_length||' minutes''::interval))::bigint';
    v_tsp_='timestamp ''epoch'' + ('''||i_interval_length||' minutes''::interval * (date_part(''epoch'',time_start)/date_part(''epoch'','''||i_interval_length||' minutes''::interval))::bigint)';

    --SELECT TIMESTAMP 'epoch' + 1195374767 * INTERVAL '1 second'.

    For v_field in select * from regexp_split_to_table(i_group_by,',') LOOP
        v_i:=v_i+1;
        --IF regexp_match(v_field','w');
        v_keys:=v_keys||'key'||v_i::varchar||',';
    end loop;


    v_group_by=COALESCE(', '||NULLIF(i_group_by,''),'');
    v_filter=COALESCE('AND '||NULLIF(i_filter,''),'');
    
    v_sql:='
        INSERT INTO reports.cdr_interval_report_data(report_id,timestamp'||v_group_by||',aggregated_value) 
        SELECT '||v_rid::varchar||','||v_tsp_||v_group_by||','||v_agg||'
            from cdr.cdr
            WHERE 
                time_start>='''||i_date_start::varchar||'''
                AND time_start<'''||i_date_end::varchar||''' '||v_filter||'
            GROUP BY '||v_tsp||v_group_by;
            
    RAISE WARNING 'SQL: %',v_sql;
    EXECUTE v_sql;
    RETURN v_rid;

END;
$$;


--
-- TOC entry 658 (class 1255 OID 17205)
-- Name: cdr_interval_report_remove(integer); Type: FUNCTION; Schema: reports; Owner: -
--

CREATE FUNCTION cdr_interval_report_remove(i_report_id integer) RETURNS void
    LANGUAGE plpgsql COST 3000
    AS $$
DECLARE

BEGIN
    delete from reports.cdr_interval_report_data where report_id=i_report_id;
    delete from reports.cdr_interval_report where id=i_report_id;
END;
$$;


SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 265 (class 1259 OID 17888)
-- Name: cdr_custom_report; Type: TABLE; Schema: reports; Owner: -; Tablespace: 
--

CREATE TABLE cdr_custom_report (
    id integer NOT NULL,
    date_start timestamp without time zone,
    date_end timestamp without time zone,
    filter character varying,
    group_by character varying,
    created_at timestamp without time zone
);


--
-- TOC entry 266 (class 1259 OID 17894)
-- Name: cdr_custom_report_data; Type: TABLE; Schema: reports; Owner: -; Tablespace: 
--

CREATE TABLE cdr_custom_report_data (
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
    vendor_billed boolean,
    customer_billed boolean,
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
    log_sip boolean,
    log_rtp boolean,
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
    dst_country_id integer,
    dst_network_id integer,
    id bigint NOT NULL,
    report_id integer NOT NULL,
    agg_calls_count bigint,
    agg_calls_duration bigint,
    agg_calls_acd numeric,
    agg_asr_origination numeric,
    agg_asr_termination numeric,
    agg_vendor_price numeric,
    agg_customer_price numeric,
    agg_profit numeric,
    legb_disconnect_code integer,
    legb_disconnect_reason character varying
);


--
-- TOC entry 267 (class 1259 OID 17900)
-- Name: cdr_custom_report_data_id_seq; Type: SEQUENCE; Schema: reports; Owner: -
--

CREATE SEQUENCE cdr_custom_report_data_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2991 (class 0 OID 0)
-- Dependencies: 267
-- Name: cdr_custom_report_data_id_seq; Type: SEQUENCE OWNED BY; Schema: reports; Owner: -
--

ALTER SEQUENCE cdr_custom_report_data_id_seq OWNED BY cdr_custom_report_data.id;


--
-- TOC entry 268 (class 1259 OID 17902)
-- Name: cdr_custom_report_id_seq; Type: SEQUENCE; Schema: reports; Owner: -
--

CREATE SEQUENCE cdr_custom_report_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2992 (class 0 OID 0)
-- Dependencies: 268
-- Name: cdr_custom_report_id_seq; Type: SEQUENCE OWNED BY; Schema: reports; Owner: -
--

ALTER SEQUENCE cdr_custom_report_id_seq OWNED BY cdr_custom_report.id;


--
-- TOC entry 269 (class 1259 OID 17904)
-- Name: cdr_interval_report; Type: TABLE; Schema: reports; Owner: -; Tablespace: 
--

CREATE TABLE cdr_interval_report (
    id integer NOT NULL,
    date_start timestamp without time zone NOT NULL,
    date_end timestamp without time zone NOT NULL,
    filter character varying,
    group_by character varying,
    created_at timestamp without time zone NOT NULL,
    interval_length integer NOT NULL,
    aggregator_id integer NOT NULL,
    aggregate_by character varying NOT NULL
);


--
-- TOC entry 270 (class 1259 OID 17910)
-- Name: cdr_interval_report_aggrerator; Type: TABLE; Schema: reports; Owner: -; Tablespace: 
--

CREATE TABLE cdr_interval_report_aggrerator (
    id integer NOT NULL,
    name character varying NOT NULL
);


--
-- TOC entry 271 (class 1259 OID 17916)
-- Name: cdr_interval_report_data; Type: TABLE; Schema: reports; Owner: -; Tablespace: 
--

CREATE TABLE cdr_interval_report_data (
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
    vendor_billed boolean,
    customer_billed boolean,
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
    log_sip boolean,
    log_rtp boolean,
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
    dst_country_id integer,
    dst_network_id integer,
    legb_disconnect_code integer,
    legb_disconnect_reason character varying,
    id bigint NOT NULL,
    report_id integer NOT NULL,
    "timestamp" timestamp without time zone,
    aggregated_value numeric
);


--
-- TOC entry 272 (class 1259 OID 17922)
-- Name: cdr_interval_report_data_id_seq; Type: SEQUENCE; Schema: reports; Owner: -
--

CREATE SEQUENCE cdr_interval_report_data_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2993 (class 0 OID 0)
-- Dependencies: 272
-- Name: cdr_interval_report_data_id_seq; Type: SEQUENCE OWNED BY; Schema: reports; Owner: -
--

ALTER SEQUENCE cdr_interval_report_data_id_seq OWNED BY cdr_interval_report_data.id;


--
-- TOC entry 273 (class 1259 OID 17924)
-- Name: cdr_interval_report_id_seq; Type: SEQUENCE; Schema: reports; Owner: -
--

CREATE SEQUENCE cdr_interval_report_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2994 (class 0 OID 0)
-- Dependencies: 273
-- Name: cdr_interval_report_id_seq; Type: SEQUENCE OWNED BY; Schema: reports; Owner: -
--

ALTER SEQUENCE cdr_interval_report_id_seq OWNED BY cdr_interval_report.id;


--
-- TOC entry 274 (class 1259 OID 17926)
-- Name: report_vendors; Type: TABLE; Schema: reports; Owner: -; Tablespace: 
--

CREATE TABLE report_vendors (
    id integer NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    start_date timestamp without time zone NOT NULL,
    end_date timestamp without time zone NOT NULL
);


--
-- TOC entry 275 (class 1259 OID 17930)
-- Name: report_vendors_data; Type: TABLE; Schema: reports; Owner: -; Tablespace: 
--

CREATE TABLE report_vendors_data (
    id bigint NOT NULL,
    report_id integer NOT NULL,
    calls_count bigint
);


--
-- TOC entry 276 (class 1259 OID 17933)
-- Name: report_vendors_data_id_seq; Type: SEQUENCE; Schema: reports; Owner: -
--

CREATE SEQUENCE report_vendors_data_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2995 (class 0 OID 0)
-- Dependencies: 276
-- Name: report_vendors_data_id_seq; Type: SEQUENCE OWNED BY; Schema: reports; Owner: -
--

ALTER SEQUENCE report_vendors_data_id_seq OWNED BY report_vendors_data.id;


--
-- TOC entry 277 (class 1259 OID 17935)
-- Name: report_vendors_id_seq; Type: SEQUENCE; Schema: reports; Owner: -
--

CREATE SEQUENCE report_vendors_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2996 (class 0 OID 0)
-- Dependencies: 277
-- Name: report_vendors_id_seq; Type: SEQUENCE OWNED BY; Schema: reports; Owner: -
--

ALTER SEQUENCE report_vendors_id_seq OWNED BY report_vendors.id;


--
-- TOC entry 2839 (class 2604 OID 18154)
-- Name: id; Type: DEFAULT; Schema: reports; Owner: -
--

ALTER TABLE ONLY cdr_custom_report ALTER COLUMN id SET DEFAULT nextval('cdr_custom_report_id_seq'::regclass);


--
-- TOC entry 2840 (class 2604 OID 18155)
-- Name: id; Type: DEFAULT; Schema: reports; Owner: -
--

ALTER TABLE ONLY cdr_custom_report_data ALTER COLUMN id SET DEFAULT nextval('cdr_custom_report_data_id_seq'::regclass);


--
-- TOC entry 2841 (class 2604 OID 18156)
-- Name: id; Type: DEFAULT; Schema: reports; Owner: -
--

ALTER TABLE ONLY cdr_interval_report ALTER COLUMN id SET DEFAULT nextval('cdr_interval_report_id_seq'::regclass);


--
-- TOC entry 2842 (class 2604 OID 18157)
-- Name: id; Type: DEFAULT; Schema: reports; Owner: -
--

ALTER TABLE ONLY cdr_interval_report_data ALTER COLUMN id SET DEFAULT nextval('cdr_interval_report_data_id_seq'::regclass);


--
-- TOC entry 2844 (class 2604 OID 18158)
-- Name: id; Type: DEFAULT; Schema: reports; Owner: -
--

ALTER TABLE ONLY report_vendors ALTER COLUMN id SET DEFAULT nextval('report_vendors_id_seq'::regclass);


--
-- TOC entry 2845 (class 2604 OID 18159)
-- Name: id; Type: DEFAULT; Schema: reports; Owner: -
--

ALTER TABLE ONLY report_vendors_data ALTER COLUMN id SET DEFAULT nextval('report_vendors_data_id_seq'::regclass);


--
-- TOC entry 2974 (class 0 OID 17888)
-- Dependencies: 265
-- Data for Name: cdr_custom_report; Type: TABLE DATA; Schema: reports; Owner: -
--



--
-- TOC entry 2975 (class 0 OID 17894)
-- Dependencies: 266
-- Data for Name: cdr_custom_report_data; Type: TABLE DATA; Schema: reports; Owner: -
--



--
-- TOC entry 2997 (class 0 OID 0)
-- Dependencies: 267
-- Name: cdr_custom_report_data_id_seq; Type: SEQUENCE SET; Schema: reports; Owner: -
--

SELECT pg_catalog.setval('cdr_custom_report_data_id_seq', 30, true);


--
-- TOC entry 2998 (class 0 OID 0)
-- Dependencies: 268
-- Name: cdr_custom_report_id_seq; Type: SEQUENCE SET; Schema: reports; Owner: -
--

SELECT pg_catalog.setval('cdr_custom_report_id_seq', 81, true);


--
-- TOC entry 2978 (class 0 OID 17904)
-- Dependencies: 269
-- Data for Name: cdr_interval_report; Type: TABLE DATA; Schema: reports; Owner: -
--



--
-- TOC entry 2979 (class 0 OID 17910)
-- Dependencies: 270
-- Data for Name: cdr_interval_report_aggrerator; Type: TABLE DATA; Schema: reports; Owner: -
--

INSERT INTO cdr_interval_report_aggrerator (id, name) VALUES (1, 'Sum');
INSERT INTO cdr_interval_report_aggrerator (id, name) VALUES (2, 'Count');
INSERT INTO cdr_interval_report_aggrerator (id, name) VALUES (3, 'Avg');
INSERT INTO cdr_interval_report_aggrerator (id, name) VALUES (4, 'Max');
INSERT INTO cdr_interval_report_aggrerator (id, name) VALUES (5, 'Min');


--
-- TOC entry 2980 (class 0 OID 17916)
-- Dependencies: 271
-- Data for Name: cdr_interval_report_data; Type: TABLE DATA; Schema: reports; Owner: -
--



--
-- TOC entry 2999 (class 0 OID 0)
-- Dependencies: 272
-- Name: cdr_interval_report_data_id_seq; Type: SEQUENCE SET; Schema: reports; Owner: -
--

SELECT pg_catalog.setval('cdr_interval_report_data_id_seq', 1, false);


--
-- TOC entry 3000 (class 0 OID 0)
-- Dependencies: 273
-- Name: cdr_interval_report_id_seq; Type: SEQUENCE SET; Schema: reports; Owner: -
--

SELECT pg_catalog.setval('cdr_interval_report_id_seq', 16, true);


--
-- TOC entry 2983 (class 0 OID 17926)
-- Dependencies: 274
-- Data for Name: report_vendors; Type: TABLE DATA; Schema: reports; Owner: -
--



--
-- TOC entry 2984 (class 0 OID 17930)
-- Dependencies: 275
-- Data for Name: report_vendors_data; Type: TABLE DATA; Schema: reports; Owner: -
--



--
-- TOC entry 3001 (class 0 OID 0)
-- Dependencies: 276
-- Name: report_vendors_data_id_seq; Type: SEQUENCE SET; Schema: reports; Owner: -
--

SELECT pg_catalog.setval('report_vendors_data_id_seq', 1, false);


--
-- TOC entry 3002 (class 0 OID 0)
-- Dependencies: 277
-- Name: report_vendors_id_seq; Type: SEQUENCE SET; Schema: reports; Owner: -
--

SELECT pg_catalog.setval('report_vendors_id_seq', 1, false);


--
-- TOC entry 2850 (class 2606 OID 18356)
-- Name: cdr_custom_report_data_pkey; Type: CONSTRAINT; Schema: reports; Owner: -; Tablespace: 
--

ALTER TABLE ONLY cdr_custom_report_data
    ADD CONSTRAINT cdr_custom_report_data_pkey PRIMARY KEY (id);


--
-- TOC entry 2848 (class 2606 OID 18358)
-- Name: cdr_custom_report_pkey; Type: CONSTRAINT; Schema: reports; Owner: -; Tablespace: 
--

ALTER TABLE ONLY cdr_custom_report
    ADD CONSTRAINT cdr_custom_report_pkey PRIMARY KEY (id);


--
-- TOC entry 2854 (class 2606 OID 18360)
-- Name: cdr_interval_report_aggrerator_name_key; Type: CONSTRAINT; Schema: reports; Owner: -; Tablespace: 
--

ALTER TABLE ONLY cdr_interval_report_aggrerator
    ADD CONSTRAINT cdr_interval_report_aggrerator_name_key UNIQUE (name);


--
-- TOC entry 2856 (class 2606 OID 18362)
-- Name: cdr_interval_report_aggrerator_pkey; Type: CONSTRAINT; Schema: reports; Owner: -; Tablespace: 
--

ALTER TABLE ONLY cdr_interval_report_aggrerator
    ADD CONSTRAINT cdr_interval_report_aggrerator_pkey PRIMARY KEY (id);


--
-- TOC entry 2858 (class 2606 OID 18364)
-- Name: cdr_interval_report_data_pkey; Type: CONSTRAINT; Schema: reports; Owner: -; Tablespace: 
--

ALTER TABLE ONLY cdr_interval_report_data
    ADD CONSTRAINT cdr_interval_report_data_pkey PRIMARY KEY (id);


--
-- TOC entry 2852 (class 2606 OID 18366)
-- Name: cdr_interval_report_pkey; Type: CONSTRAINT; Schema: reports; Owner: -; Tablespace: 
--

ALTER TABLE ONLY cdr_interval_report
    ADD CONSTRAINT cdr_interval_report_pkey PRIMARY KEY (id);


--
-- TOC entry 2862 (class 2606 OID 18368)
-- Name: report_vendors_data_pkey; Type: CONSTRAINT; Schema: reports; Owner: -; Tablespace: 
--

ALTER TABLE ONLY report_vendors_data
    ADD CONSTRAINT report_vendors_data_pkey PRIMARY KEY (id);


--
-- TOC entry 2860 (class 2606 OID 18370)
-- Name: report_vendors_pkey; Type: CONSTRAINT; Schema: reports; Owner: -; Tablespace: 
--

ALTER TABLE ONLY report_vendors
    ADD CONSTRAINT report_vendors_pkey PRIMARY KEY (id);


--
-- TOC entry 2846 (class 1259 OID 18462)
-- Name: cdr_custom_report_id_idx; Type: INDEX; Schema: reports; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX cdr_custom_report_id_idx ON cdr_custom_report USING btree (id) WHERE (id IS NOT NULL);


--
-- TOC entry 2863 (class 2606 OID 18660)
-- Name: cdr_custom_report_data_report_id_fkey; Type: FK CONSTRAINT; Schema: reports; Owner: -
--

ALTER TABLE ONLY cdr_custom_report_data
    ADD CONSTRAINT cdr_custom_report_data_report_id_fkey FOREIGN KEY (report_id) REFERENCES cdr_custom_report(id);


--
-- TOC entry 2864 (class 2606 OID 18665)
-- Name: cdr_interval_report_aggregator_id_fkey; Type: FK CONSTRAINT; Schema: reports; Owner: -
--

ALTER TABLE ONLY cdr_interval_report
    ADD CONSTRAINT cdr_interval_report_aggregator_id_fkey FOREIGN KEY (aggregator_id) REFERENCES cdr_interval_report_aggrerator(id);


--
-- TOC entry 2865 (class 2606 OID 18670)
-- Name: cdr_interval_report_data_report_id_fkey; Type: FK CONSTRAINT; Schema: reports; Owner: -
--

ALTER TABLE ONLY cdr_interval_report_data
    ADD CONSTRAINT cdr_interval_report_data_report_id_fkey FOREIGN KEY (report_id) REFERENCES cdr_interval_report(id);


--
-- TOC entry 2866 (class 2606 OID 18675)
-- Name: report_vendors_data_report_id_fkey; Type: FK CONSTRAINT; Schema: reports; Owner: -
--

ALTER TABLE ONLY report_vendors_data
    ADD CONSTRAINT report_vendors_data_report_id_fkey FOREIGN KEY (report_id) REFERENCES report_vendors(id);


-- Completed on 2014-11-10 11:55:35 EET

--
-- PostgreSQL database dump complete
--
commit;

