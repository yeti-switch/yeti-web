--
-- PostgreSQL database dump
--

-- Dumped from database version 11.5 (Debian 11.5-3.pgdg100+1)
-- Dumped by pg_dump version 11.5 (Debian 11.5-3.pgdg100+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Data for Name: cdr_tables; Type: TABLE DATA; Schema: sys; Owner: senid
--

INSERT INTO sys.cdr_tables (id, name, readable, writable, date_start, date_stop) VALUES (13, 'class4.cdrs_201303', true, true, '2013-03-01', '2013-04-01');
INSERT INTO sys.cdr_tables (id, name, readable, writable, date_start, date_stop) VALUES (14, 'class4.cdrs_201302', true, true, '2013-02-01', '2013-03-01');
INSERT INTO sys.cdr_tables (id, name, readable, writable, date_start, date_stop) VALUES (15, 'class4.cdrs_201301', true, true, '2013-01-01', '2013-02-01');
INSERT INTO sys.cdr_tables (id, name, readable, writable, date_start, date_stop) VALUES (16, 'class4.cdrs_201308', true, true, '2013-08-01', '2013-09-01');
INSERT INTO sys.cdr_tables (id, name, readable, writable, date_start, date_stop) VALUES (17, 'class4.cdrs_201306', true, true, '2013-06-01', '2013-07-01');
INSERT INTO sys.cdr_tables (id, name, readable, writable, date_start, date_stop) VALUES (18, 'class4.cdrs_201307', true, true, '2013-07-01', '2013-08-01');
INSERT INTO sys.cdr_tables (id, name, readable, writable, date_start, date_stop) VALUES (19, 'class4.cdrs_201309', true, true, '2013-09-01', '2013-10-01');
INSERT INTO sys.cdr_tables (id, name, readable, writable, date_start, date_stop) VALUES (20, 'class4.cdrs_201311', true, true, '2013-11-01', '2013-12-01');
INSERT INTO sys.cdr_tables (id, name, readable, writable, date_start, date_stop) VALUES (21, 'class4.cdrs_201312', true, true, '2013-12-01', '2014-01-01');
INSERT INTO sys.cdr_tables (id, name, readable, writable, date_start, date_stop) VALUES (22, 'class4.cdrs_201401', true, true, '2014-01-01', '2014-02-01');
INSERT INTO sys.cdr_tables (id, name, readable, writable, date_start, date_stop) VALUES (23, 'class4.cdrs_201310', true, true, '2013-10-01', '2013-11-01');
INSERT INTO sys.cdr_tables (id, name, readable, writable, date_start, date_stop) VALUES (24, 'class4.cdrs_201403', true, true, '2014-03-01', '2014-04-01');
INSERT INTO sys.cdr_tables (id, name, readable, writable, date_start, date_stop) VALUES (25, 'class4.cdrs_201402', true, true, '2014-02-01', '2014-03-01');
INSERT INTO sys.cdr_tables (id, name, readable, writable, date_start, date_stop) VALUES (26, 'class4.cdrs_201405', true, true, '2014-05-01', '2014-06-01');
INSERT INTO sys.cdr_tables (id, name, readable, writable, date_start, date_stop) VALUES (27, 'class4.cdrs_201404', true, true, '2014-04-01', '2014-05-01');
INSERT INTO sys.cdr_tables (id, name, readable, writable, date_start, date_stop) VALUES (28, 'class4.cdrs_201406', true, true, '2014-06-01', '2014-07-01');
INSERT INTO sys.cdr_tables (id, name, readable, writable, date_start, date_stop) VALUES (29, 'class4.cdrs_201407', true, true, '2014-07-01', '2014-08-01');
INSERT INTO sys.cdr_tables (id, name, readable, writable, date_start, date_stop) VALUES (30, 'class4.cdrs_201408', true, true, '2014-08-01', '2014-09-01');


--
-- Data for Name: delayed_jobs; Type: TABLE DATA; Schema: sys; Owner: senid
--



--
-- Data for Name: pops; Type: TABLE DATA; Schema: sys; Owner: senid
--



--
-- Data for Name: nodes; Type: TABLE DATA; Schema: sys; Owner: senid
--



--
-- Data for Name: events; Type: TABLE DATA; Schema: sys; Owner: senid
--



--
-- Data for Name: guiconfig; Type: TABLE DATA; Schema: sys; Owner: senid
--

INSERT INTO sys.guiconfig (rows_per_page, id, cdr_unload_dir, cdr_unload_uri, max_records, import_max_threads, import_helpers_dir, active_calls_require_filter, registrations_require_filter, active_calls_show_chart, active_calls_autorefresh_enable, max_call_duration, random_disconnect_enable, random_disconnect_length, drop_call_if_lnp_fail, short_call_length, termination_stats_window, lnp_cache_ttl, quality_control_min_calls, quality_control_min_duration, lnp_e2e_timeout, web_url) VALUES ('30,50,100', 1, '/tmp', 'https://127.0.0.1/tmexport', 100500, 4, '/tmp/yeti-xml2rates', true, true, false, false, 7200, false, 7000, false, 15, 24, 10800, 100, 3600, 1000, 'http://127.0.0.1');


--
-- Data for Name: jobs; Type: TABLE DATA; Schema: sys; Owner: senid
--

INSERT INTO sys.jobs (id, name, last_duration, last_exception, last_run_at) VALUES (1, 'CdrPartitioning', NULL, NULL, NULL);
INSERT INTO sys.jobs (id, name, last_duration, last_exception, last_run_at) VALUES (3, 'CdrBatchCleaner', NULL, NULL, NULL);
INSERT INTO sys.jobs (id, name, last_duration, last_exception, last_run_at) VALUES (4, 'PartitionRemoving', NULL, NULL, NULL);
INSERT INTO sys.jobs (id, name, last_duration, last_exception, last_run_at) VALUES (5, 'CallsMonitoring', NULL, NULL, NULL);
INSERT INTO sys.jobs (id, name, last_duration, last_exception, last_run_at) VALUES (6, 'StatsClean', NULL, NULL, NULL);
INSERT INTO sys.jobs (id, name, last_duration, last_exception, last_run_at) VALUES (7, 'StatsAggregation', NULL, NULL, NULL);
INSERT INTO sys.jobs (id, name, last_duration, last_exception, last_run_at) VALUES (8, 'Invoice', NULL, NULL, NULL);
INSERT INTO sys.jobs (id, name, last_duration, last_exception, last_run_at) VALUES (9, 'ReportScheduler', NULL, NULL, NULL);
INSERT INTO sys.jobs (id, name, last_duration, last_exception, last_run_at) VALUES (10, 'TerminationQualityCheck', NULL, NULL, NULL);
INSERT INTO sys.jobs (id, name, last_duration, last_exception, last_run_at) VALUES (11, 'DialpeerRatesApply', NULL, NULL, NULL);
INSERT INTO sys.jobs (id, name, last_duration, last_exception, last_run_at) VALUES (12, 'AccountBalanceNotify', NULL, NULL, NULL);
INSERT INTO sys.jobs (id, name, last_duration, last_exception, last_run_at) VALUES (13, 'SyncDatabaseTables', NULL, NULL, NULL);
INSERT INTO sys.jobs (id, name, last_duration, last_exception, last_run_at) VALUES (14, 'DeleteExpiredDestinations', NULL, NULL, NULL);
INSERT INTO sys.jobs (id, name, last_duration, last_exception, last_run_at) VALUES (15, 'DeleteExpiredDialpeers', NULL, NULL, NULL);
INSERT INTO sys.jobs (id, name, last_duration, last_exception, last_run_at) VALUES (16, 'DeleteAppliedRateManagementPricelists', NULL, NULL, NULL);
INSERT INTO sys.jobs (id, name, last_duration, last_exception, last_run_at) VALUES (17, 'DeleteBalanceNotifications', NULL, NULL, NULL);
INSERT INTO sys.jobs (id, name, last_duration, last_exception, last_run_at) VALUES (18, 'PrometheusCustomerAuthStats', NULL, NULL, NULL);
INSERT INTO sys.jobs (id, name, last_duration, last_exception, last_run_at) VALUES (19, 'ServiceRenew', NULL, NULL, NULL);
INSERT INTO sys.jobs (id, name, last_duration, last_exception, last_run_at) VALUES (20, 'CdrCompaction', NULL, NULL, NULL);
INSERT INTO sys.jobs (id, name, last_duration, last_exception, last_run_at) VALUES (21, 'Scheduler', NULL, NULL, NULL);


--
-- Data for Name: lnp_resolvers; Type: TABLE DATA; Schema: sys; Owner: senid
--



--
-- Data for Name: load_balancers; Type: TABLE DATA; Schema: sys; Owner: senid
--



--
-- Data for Name: lua_scripts; Type: TABLE DATA; Schema: sys; Owner: senid
--



--
-- Data for Name: network_types; Type: TABLE DATA; Schema: sys; Owner: senid
--

INSERT INTO sys.network_types (id, name, uuid) VALUES (1, 'Unknown', '77d64fb2-f321-11e9-a714-5ce0c502dfdc');
INSERT INTO sys.network_types (id, name, uuid) VALUES (2, 'Landline', '706ab0ee-f258-11ed-b425-00ffaa112233');
INSERT INTO sys.network_types (id, name, uuid) VALUES (3, 'Mobile', '706ab648-f258-11ed-b425-00ffaa112233');
INSERT INTO sys.network_types (id, name, uuid) VALUES (4, 'National', '706ab80a-f258-11ed-b425-00ffaa112233');
INSERT INTO sys.network_types (id, name, uuid) VALUES (5, 'Shared Cost', '706ab9b8-f258-11ed-b425-00ffaa112233');
INSERT INTO sys.network_types (id, name, uuid) VALUES (6, 'Toll-Free', '706abb48-f258-11ed-b425-00ffaa112233');
INSERT INTO sys.network_types (id, name, uuid) VALUES (7, 'Special Services', '706abcce-f258-11ed-b425-00ffaa112233');


--
-- Data for Name: sensor_levels; Type: TABLE DATA; Schema: sys; Owner: senid
--

INSERT INTO sys.sensor_levels (id, name) VALUES (1, 'Signaling');
INSERT INTO sys.sensor_levels (id, name) VALUES (2, 'RTP');
INSERT INTO sys.sensor_levels (id, name) VALUES (3, 'Signaling+RTP');


--
-- Data for Name: sensor_modes; Type: TABLE DATA; Schema: sys; Owner: senid
--

INSERT INTO sys.sensor_modes (id, name) VALUES (1, 'IP-IP encapsulation');
INSERT INTO sys.sensor_modes (id, name) VALUES (2, 'IP-Ethernet encapsulation');
INSERT INTO sys.sensor_modes (id, name) VALUES (3, 'HEPv3');


--
-- Data for Name: states; Type: TABLE DATA; Schema: sys; Owner: senid
--

INSERT INTO sys.states (key, value) VALUES ('customers_auth', 1);
INSERT INTO sys.states (key, value) VALUES ('stir_shaken_trusted_certificates', 1);
INSERT INTO sys.states (key, value) VALUES ('stir_shaken_trusted_repositories', 1);
INSERT INTO sys.states (key, value) VALUES ('stir_shaken_rcd_profiles', 1);

INSERT INTO sys.states (key, value) VALUES ('load_balancers', 1);

INSERT INTO sys.states(key,value) VALUES('sensors',1);
INSERT INTO sys.states(key,value) VALUES('translations',1);
INSERT INTO sys.states(key,value) VALUES('codec_groups',1);
INSERT INTO sys.states(key,value) VALUES('registrations',1);
INSERT INTO sys.states(key,value) VALUES('radius_authorization_profiles',1);
INSERT INTO sys.states(key,value) VALUES('radius_accounting_profiles',1);
INSERT INTO sys.states(key,value) VALUES('auth_credentials',1);
INSERT INTO sys.states(key,value) VALUES('options_probers',1);

INSERT INTO sys.states(key,value) VALUES('stir_shaken_signing_certificates',1);
insert into sys.states(key,value) values('gateways_cache', 1);

--
-- Name: active_currencies_id_seq; Type: SEQUENCE SET; Schema: sys; Owner: senid
--

SELECT pg_catalog.setval('sys.active_currencies_id_seq', 1, false);


--
-- Name: api_access_id_seq; Type: SEQUENCE SET; Schema: sys; Owner: senid
--

SELECT pg_catalog.setval('sys.api_access_id_seq', 1, false);


--
-- Name: api_log_config_id_seq; Type: SEQUENCE SET; Schema: sys; Owner: senid
--

SELECT pg_catalog.setval('sys.api_log_config_id_seq', 6, true);


--
-- Name: cdr_exports_id_seq; Type: SEQUENCE SET; Schema: sys; Owner: senid
--

SELECT pg_catalog.setval('sys.cdr_exports_id_seq', 1, false);


--
-- Name: cdrtables_id_seq; Type: SEQUENCE SET; Schema: sys; Owner: senid
--

SELECT pg_catalog.setval('sys.cdrtables_id_seq', 30, true);


--
-- Name: countries_id_seq; Type: SEQUENCE SET; Schema: sys; Owner: senid
--

SELECT pg_catalog.setval('sys.countries_id_seq', 273, true);


--
-- Name: currencies_id_seq; Type: SEQUENCE SET; Schema: sys; Owner: senid
--

SELECT pg_catalog.setval('sys.currencies_id_seq', 1, false);


--
-- Name: delayed_jobs_id_seq; Type: SEQUENCE SET; Schema: sys; Owner: senid
--

SELECT pg_catalog.setval('sys.delayed_jobs_id_seq', 1, false);


--
-- Name: guiconfig_id_seq; Type: SEQUENCE SET; Schema: sys; Owner: senid
--

SELECT pg_catalog.setval('sys.guiconfig_id_seq', 1, true);


--
-- Name: jobs_id_seq; Type: SEQUENCE SET; Schema: sys; Owner: senid
--

SELECT pg_catalog.setval('sys.jobs_id_seq', 16, true);


--
-- Name: lnp_resolvers_id_seq; Type: SEQUENCE SET; Schema: sys; Owner: senid
--

SELECT pg_catalog.setval('sys.lnp_resolvers_id_seq', 1, false);


--
-- Name: load_balancers_id_seq; Type: SEQUENCE SET; Schema: sys; Owner: senid
--

SELECT pg_catalog.setval('sys.load_balancers_id_seq', 1, false);


--
-- Name: lua_scripts_id_seq; Type: SEQUENCE SET; Schema: sys; Owner: senid
--

SELECT pg_catalog.setval('sys.lua_scripts_id_seq', 1, false);


--
-- Name: network_prefixes_id_seq; Type: SEQUENCE SET; Schema: sys; Owner: senid
--

SELECT pg_catalog.setval('sys.network_prefixes_id_seq', 34728, true);


--
-- Name: network_types_id_seq; Type: SEQUENCE SET; Schema: sys; Owner: senid
--

SELECT pg_catalog.setval('sys.network_types_id_seq', 7, true);


--
-- Name: networks_id_seq; Type: SEQUENCE SET; Schema: sys; Owner: senid
--

SELECT pg_catalog.setval('sys.networks_id_seq', 1643, true);


--
-- Name: sensors_id_seq; Type: SEQUENCE SET; Schema: sys; Owner: senid
--

SELECT pg_catalog.setval('sys.sensors_id_seq', 1, false);


--
-- Name: smtp_connections_id_seq; Type: SEQUENCE SET; Schema: sys; Owner: senid
--

SELECT pg_catalog.setval('sys.smtp_connections_id_seq', 1, false);

--
-- PostgreSQL database dump complete
--

