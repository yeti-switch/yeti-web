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
INSERT INTO sys.jobs (id, name, last_duration, last_exception, last_run_at) VALUES (2, 'EventProcessor', NULL, NULL, NULL);
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
INSERT INTO sys.jobs (id, name, last_duration, last_exception, last_run_at) VALUES (16, 'DeleteBalanceNotifications', NULL, NULL, NULL);
INSERT INTO sys.jobs (id, name, last_duration, last_exception, last_run_at) VALUES (17, 'PrometheusCustomerAuthStats', NULL, NULL, NULL);

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


--
-- Data for Name: smtp_connections; Type: TABLE DATA; Schema: sys; Owner: senid
--



--
-- Data for Name: timezones; Type: TABLE DATA; Schema: sys; Owner: senid
--

INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1, 'UTC', 'UTC', '00:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (2, 'Africa/Abidjan', 'GMT', '00:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (3, 'Africa/Accra', 'GMT', '00:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (4, 'Africa/Addis_Ababa', 'EAT', '03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (5, 'Africa/Algiers', 'CET', '01:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (6, 'Africa/Asmara', 'EAT', '03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (7, 'Africa/Asmera', 'EAT', '03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (8, 'Africa/Bamako', 'GMT', '00:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (9, 'Africa/Bangui', 'WAT', '01:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (10, 'Africa/Banjul', 'GMT', '00:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (11, 'Africa/Bissau', 'GMT', '00:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (12, 'Africa/Blantyre', 'CAT', '02:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (13, 'Africa/Brazzaville', 'WAT', '01:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (14, 'Africa/Bujumbura', 'CAT', '02:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (15, 'Africa/Cairo', 'EET', '02:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (16, 'Africa/Casablanca', 'WEST', '01:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (17, 'Africa/Ceuta', 'CEST', '02:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (18, 'Africa/Conakry', 'GMT', '00:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (19, 'Africa/Dakar', 'GMT', '00:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (20, 'Africa/Dar_es_Salaam', 'EAT', '03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (21, 'Africa/Djibouti', 'EAT', '03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (22, 'Africa/Douala', 'WAT', '01:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (23, 'Africa/El_Aaiun', 'WEST', '01:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (24, 'Africa/Freetown', 'GMT', '00:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (25, 'Africa/Gaborone', 'CAT', '02:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (26, 'Africa/Harare', 'CAT', '02:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (27, 'Africa/Johannesburg', 'SAST', '02:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (28, 'Africa/Juba', 'EAT', '03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (29, 'Africa/Kampala', 'EAT', '03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (30, 'Africa/Khartoum', 'EAT', '03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (31, 'Africa/Kigali', 'CAT', '02:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (32, 'Africa/Kinshasa', 'WAT', '01:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (33, 'Africa/Lagos', 'WAT', '01:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (34, 'Africa/Libreville', 'WAT', '01:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (35, 'Africa/Lome', 'GMT', '00:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (36, 'Africa/Luanda', 'WAT', '01:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (37, 'Africa/Lubumbashi', 'CAT', '02:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (38, 'Africa/Lusaka', 'CAT', '02:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (39, 'Africa/Malabo', 'WAT', '01:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (40, 'Africa/Maputo', 'CAT', '02:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (41, 'Africa/Maseru', 'SAST', '02:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (42, 'Africa/Mbabane', 'SAST', '02:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (43, 'Africa/Mogadishu', 'EAT', '03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (44, 'Africa/Monrovia', 'GMT', '00:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (45, 'Africa/Nairobi', 'EAT', '03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (46, 'Africa/Ndjamena', 'WAT', '01:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (47, 'Africa/Niamey', 'WAT', '01:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (48, 'Africa/Nouakchott', 'GMT', '00:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (49, 'Africa/Ouagadougou', 'GMT', '00:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (50, 'Africa/Porto-Novo', 'WAT', '01:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (51, 'Africa/Sao_Tome', 'GMT', '00:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (52, 'Africa/Timbuktu', 'GMT', '00:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (53, 'Africa/Tripoli', 'EET', '02:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (54, 'Africa/Tunis', 'CET', '01:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (55, 'Africa/Windhoek', 'WAT', '01:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (56, 'America/Adak', 'HDT', '-09:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (57, 'America/Anchorage', 'AKDT', '-08:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (58, 'America/Anguilla', 'AST', '-04:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (59, 'America/Antigua', 'AST', '-04:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (60, 'America/Araguaina', '-03', '-03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (61, 'America/Argentina/Buenos_Aires', '-03', '-03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (62, 'America/Argentina/Catamarca', '-03', '-03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (63, 'America/Argentina/ComodRivadavia', '-03', '-03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (64, 'America/Argentina/Cordoba', '-03', '-03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (65, 'America/Argentina/Jujuy', '-03', '-03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (66, 'America/Argentina/La_Rioja', '-03', '-03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (67, 'America/Argentina/Mendoza', '-03', '-03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (68, 'America/Argentina/Rio_Gallegos', '-03', '-03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (69, 'America/Argentina/Salta', '-03', '-03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (70, 'America/Argentina/San_Juan', '-03', '-03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (71, 'America/Argentina/San_Luis', '-03', '-03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (72, 'America/Argentina/Tucuman', '-03', '-03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (73, 'America/Argentina/Ushuaia', '-03', '-03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (74, 'America/Aruba', 'AST', '-04:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (75, 'America/Asuncion', '-04', '-04:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (76, 'America/Atikokan', 'EST', '-05:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (77, 'America/Atka', 'HDT', '-09:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (78, 'America/Bahia', '-03', '-03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (79, 'America/Bahia_Banderas', 'CDT', '-05:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (80, 'America/Barbados', 'AST', '-04:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (81, 'America/Belem', '-03', '-03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (82, 'America/Belize', 'CST', '-06:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (83, 'America/Blanc-Sablon', 'AST', '-04:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (84, 'America/Boa_Vista', '-04', '-04:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (85, 'America/Bogota', '-05', '-05:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (86, 'America/Boise', 'MDT', '-06:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (87, 'America/Buenos_Aires', '-03', '-03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (88, 'America/Cambridge_Bay', 'MDT', '-06:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (89, 'America/Campo_Grande', '-04', '-04:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (90, 'America/Cancun', 'EST', '-05:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (91, 'America/Caracas', '-04', '-04:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (92, 'America/Catamarca', '-03', '-03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (93, 'America/Cayenne', '-03', '-03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (94, 'America/Cayman', 'EST', '-05:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (95, 'America/Chicago', 'CDT', '-05:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (96, 'America/Chihuahua', 'MDT', '-06:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (97, 'America/Coral_Harbour', 'EST', '-05:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (98, 'America/Cordoba', '-03', '-03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (99, 'America/Costa_Rica', 'CST', '-06:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (100, 'America/Creston', 'MST', '-07:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (101, 'America/Cuiaba', '-04', '-04:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (513, 'Japan', 'JST', '09:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (102, 'America/Curacao', 'AST', '-04:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (103, 'America/Danmarkshavn', 'GMT', '00:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (104, 'America/Dawson', 'PDT', '-07:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (105, 'America/Dawson_Creek', 'MST', '-07:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (106, 'America/Denver', 'MDT', '-06:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (107, 'America/Detroit', 'EDT', '-04:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (108, 'America/Dominica', 'AST', '-04:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (109, 'America/Edmonton', 'MDT', '-06:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (110, 'America/Eirunepe', '-05', '-05:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (111, 'America/El_Salvador', 'CST', '-06:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (112, 'America/Ensenada', 'PDT', '-07:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (113, 'America/Fortaleza', '-03', '-03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (114, 'America/Fort_Nelson', 'MST', '-07:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (115, 'America/Fort_Wayne', 'EDT', '-04:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (116, 'America/Glace_Bay', 'ADT', '-03:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (117, 'America/Godthab', '-02', '-02:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (118, 'America/Goose_Bay', 'ADT', '-03:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (119, 'America/Grand_Turk', 'AST', '-04:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (120, 'America/Grenada', 'AST', '-04:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (121, 'America/Guadeloupe', 'AST', '-04:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (122, 'America/Guatemala', 'CST', '-06:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (123, 'America/Guayaquil', '-05', '-05:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (124, 'America/Guyana', '-04', '-04:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (125, 'America/Halifax', 'ADT', '-03:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (126, 'America/Havana', 'CDT', '-04:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (127, 'America/Hermosillo', 'MST', '-07:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (128, 'America/Indiana/Indianapolis', 'EDT', '-04:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (129, 'America/Indiana/Knox', 'CDT', '-05:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (130, 'America/Indiana/Marengo', 'EDT', '-04:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (131, 'America/Indiana/Petersburg', 'EDT', '-04:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (132, 'America/Indianapolis', 'EDT', '-04:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (133, 'America/Indiana/Tell_City', 'CDT', '-05:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (134, 'America/Indiana/Vevay', 'EDT', '-04:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (135, 'America/Indiana/Vincennes', 'EDT', '-04:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (136, 'America/Indiana/Winamac', 'EDT', '-04:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (137, 'America/Inuvik', 'MDT', '-06:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (138, 'America/Iqaluit', 'EDT', '-04:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (139, 'America/Jamaica', 'EST', '-05:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (140, 'America/Jujuy', '-03', '-03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (141, 'America/Juneau', 'AKDT', '-08:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (142, 'America/Kentucky/Louisville', 'EDT', '-04:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (143, 'America/Kentucky/Monticello', 'EDT', '-04:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (144, 'America/Knox_IN', 'CDT', '-05:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (145, 'America/Kralendijk', 'AST', '-04:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (146, 'America/La_Paz', '-04', '-04:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (147, 'America/Lima', '-05', '-05:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (148, 'America/Los_Angeles', 'PDT', '-07:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (149, 'America/Louisville', 'EDT', '-04:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (150, 'America/Lower_Princes', 'AST', '-04:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (151, 'America/Maceio', '-03', '-03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (152, 'America/Managua', 'CST', '-06:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (153, 'America/Manaus', '-04', '-04:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (154, 'America/Marigot', 'AST', '-04:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (155, 'America/Martinique', 'AST', '-04:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (156, 'America/Matamoros', 'CDT', '-05:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (157, 'America/Mazatlan', 'MDT', '-06:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (158, 'America/Mendoza', '-03', '-03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (159, 'America/Menominee', 'CDT', '-05:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (160, 'America/Merida', 'CDT', '-05:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (161, 'America/Metlakatla', 'AKDT', '-08:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (162, 'America/Mexico_City', 'CDT', '-05:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (163, 'America/Miquelon', '-02', '-02:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (164, 'America/Moncton', 'ADT', '-03:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (165, 'America/Monterrey', 'CDT', '-05:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (166, 'America/Montevideo', '-03', '-03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (167, 'America/Montreal', 'EDT', '-04:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (168, 'America/Montserrat', 'AST', '-04:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (169, 'America/Nassau', 'EDT', '-04:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (170, 'America/New_York', 'EDT', '-04:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (171, 'America/Nipigon', 'EDT', '-04:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (172, 'America/Nome', 'AKDT', '-08:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (173, 'America/Noronha', '-02', '-02:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (174, 'America/North_Dakota/Beulah', 'CDT', '-05:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (175, 'America/North_Dakota/Center', 'CDT', '-05:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (176, 'America/North_Dakota/New_Salem', 'CDT', '-05:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (177, 'America/Ojinaga', 'MDT', '-06:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (178, 'America/Panama', 'EST', '-05:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (179, 'America/Pangnirtung', 'EDT', '-04:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (180, 'America/Paramaribo', '-03', '-03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (181, 'America/Phoenix', 'MST', '-07:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (182, 'America/Port-au-Prince', 'EDT', '-04:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (183, 'America/Porto_Acre', '-05', '-05:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (184, 'America/Port_of_Spain', 'AST', '-04:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (185, 'America/Porto_Velho', '-04', '-04:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (186, 'America/Puerto_Rico', 'AST', '-04:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (187, 'America/Punta_Arenas', '-03', '-03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (188, 'America/Rainy_River', 'CDT', '-05:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (189, 'America/Rankin_Inlet', 'CDT', '-05:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (190, 'America/Recife', '-03', '-03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (191, 'America/Regina', 'CST', '-06:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (192, 'America/Resolute', 'CDT', '-05:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (193, 'America/Rio_Branco', '-05', '-05:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (194, 'America/Rosario', '-03', '-03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (195, 'America/Santa_Isabel', 'PDT', '-07:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (196, 'America/Santarem', '-03', '-03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (197, 'America/Santiago', '-03', '-03:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (198, 'America/Santo_Domingo', 'AST', '-04:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (199, 'America/Sao_Paulo', '-03', '-03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (200, 'America/Scoresbysund', '+00', '00:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (201, 'America/Shiprock', 'MDT', '-06:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (202, 'America/Sitka', 'AKDT', '-08:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (203, 'America/St_Barthelemy', 'AST', '-04:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (204, 'America/St_Johns', 'NDT', '-02:30:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (205, 'America/St_Kitts', 'AST', '-04:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (206, 'America/St_Lucia', 'AST', '-04:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (207, 'America/St_Thomas', 'AST', '-04:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (208, 'America/St_Vincent', 'AST', '-04:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (209, 'America/Swift_Current', 'CST', '-06:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (210, 'America/Tegucigalpa', 'CST', '-06:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (211, 'America/Thule', 'ADT', '-03:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (212, 'America/Thunder_Bay', 'EDT', '-04:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (213, 'America/Tijuana', 'PDT', '-07:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (214, 'America/Toronto', 'EDT', '-04:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (215, 'America/Tortola', 'AST', '-04:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (216, 'America/Vancouver', 'PDT', '-07:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (217, 'America/Virgin', 'AST', '-04:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (218, 'America/Whitehorse', 'PDT', '-07:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (219, 'America/Winnipeg', 'CDT', '-05:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (220, 'America/Yakutat', 'AKDT', '-08:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (221, 'America/Yellowknife', 'MDT', '-06:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (222, 'Antarctica/Casey', '+11', '11:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (223, 'Antarctica/Davis', '+07', '07:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (224, 'Antarctica/DumontDUrville', '+10', '10:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (225, 'Antarctica/Macquarie', '+11', '11:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (226, 'Antarctica/Mawson', '+05', '05:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (227, 'Antarctica/McMurdo', 'NZST', '12:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (228, 'Antarctica/Palmer', '-03', '-03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (229, 'Antarctica/Rothera', '-03', '-03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (230, 'Antarctica/South_Pole', 'NZST', '12:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (231, 'Antarctica/Syowa', '+03', '03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (232, 'Antarctica/Troll', '+02', '02:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (233, 'Antarctica/Vostok', '+06', '06:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (234, 'Arctic/Longyearbyen', 'CEST', '02:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (235, 'Asia/Aden', '+03', '03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (236, 'Asia/Almaty', '+06', '06:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (237, 'Asia/Amman', 'EEST', '03:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (238, 'Asia/Anadyr', '+12', '12:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (239, 'Asia/Aqtau', '+05', '05:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (240, 'Asia/Aqtobe', '+05', '05:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (241, 'Asia/Ashgabat', '+05', '05:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (242, 'Asia/Ashkhabad', '+05', '05:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (243, 'Asia/Atyrau', '+05', '05:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (244, 'Asia/Baghdad', '+03', '03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (245, 'Asia/Bahrain', '+03', '03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (246, 'Asia/Baku', '+04', '04:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (247, 'Asia/Bangkok', '+07', '07:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (248, 'Asia/Barnaul', '+07', '07:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (249, 'Asia/Beirut', 'EEST', '03:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (250, 'Asia/Bishkek', '+06', '06:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (251, 'Asia/Brunei', '+08', '08:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (252, 'Asia/Calcutta', 'IST', '05:30:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (253, 'Asia/Chita', '+09', '09:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (254, 'Asia/Choibalsan', '+08', '08:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (255, 'Asia/Chongqing', 'CST', '08:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (256, 'Asia/Chungking', 'CST', '08:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (257, 'Asia/Colombo', '+0530', '05:30:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (258, 'Asia/Dacca', '+06', '06:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (259, 'Asia/Damascus', 'EEST', '03:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (260, 'Asia/Dhaka', '+06', '06:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (261, 'Asia/Dili', '+09', '09:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (262, 'Asia/Dubai', '+04', '04:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (263, 'Asia/Dushanbe', '+05', '05:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (264, 'Asia/Famagusta', '+03', '03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (265, 'Asia/Gaza', 'EEST', '03:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (266, 'Asia/Harbin', 'CST', '08:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (267, 'Asia/Hebron', 'EEST', '03:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (268, 'Asia/Ho_Chi_Minh', '+07', '07:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (269, 'Asia/Hong_Kong', 'HKT', '08:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (270, 'Asia/Hovd', '+07', '07:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (271, 'Asia/Irkutsk', '+08', '08:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (272, 'Asia/Istanbul', '+03', '03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (273, 'Asia/Jakarta', 'WIB', '07:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (274, 'Asia/Jayapura', 'WIT', '09:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (275, 'Asia/Jerusalem', 'IDT', '03:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (276, 'Asia/Kabul', '+0430', '04:30:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (277, 'Asia/Kamchatka', '+12', '12:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (278, 'Asia/Karachi', 'PKT', '05:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (279, 'Asia/Kashgar', '+06', '06:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (280, 'Asia/Kathmandu', '+0545', '05:45:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (281, 'Asia/Katmandu', '+0545', '05:45:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (282, 'Asia/Khandyga', '+09', '09:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (283, 'Asia/Kolkata', 'IST', '05:30:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (284, 'Asia/Krasnoyarsk', '+07', '07:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (285, 'Asia/Kuala_Lumpur', '+08', '08:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (286, 'Asia/Kuching', '+08', '08:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (287, 'Asia/Kuwait', '+03', '03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (288, 'Asia/Macao', 'CST', '08:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (289, 'Asia/Macau', 'CST', '08:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (290, 'Asia/Magadan', '+11', '11:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (291, 'Asia/Makassar', 'WITA', '08:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (292, 'Asia/Manila', '+08', '08:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (293, 'Asia/Muscat', '+04', '04:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (294, 'Asia/Nicosia', 'EEST', '03:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (295, 'Asia/Novokuznetsk', '+07', '07:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (296, 'Asia/Novosibirsk', '+07', '07:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (297, 'Asia/Omsk', '+06', '06:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (298, 'Asia/Oral', '+05', '05:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (299, 'Asia/Phnom_Penh', '+07', '07:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (300, 'Asia/Pontianak', 'WIB', '07:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (301, 'Asia/Pyongyang', 'KST', '08:30:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (302, 'Asia/Qatar', '+03', '03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (303, 'Asia/Qyzylorda', '+06', '06:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (304, 'Asia/Rangoon', '+0630', '06:30:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (305, 'Asia/Riyadh', '+03', '03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (306, 'Asia/Saigon', '+07', '07:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (307, 'Asia/Sakhalin', '+11', '11:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (308, 'Asia/Samarkand', '+05', '05:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (309, 'Asia/Seoul', 'KST', '09:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (310, 'Asia/Shanghai', 'CST', '08:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (311, 'Asia/Singapore', '+08', '08:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (312, 'Asia/Srednekolymsk', '+11', '11:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (313, 'Asia/Taipei', 'CST', '08:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (314, 'Asia/Tashkent', '+05', '05:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (315, 'Asia/Tbilisi', '+04', '04:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (316, 'Asia/Tehran', '+0430', '04:30:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (317, 'Asia/Tel_Aviv', 'IDT', '03:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (318, 'Asia/Thimbu', '+06', '06:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (319, 'Asia/Thimphu', '+06', '06:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (320, 'Asia/Tokyo', 'JST', '09:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (321, 'Asia/Tomsk', '+07', '07:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (322, 'Asia/Ujung_Pandang', 'WITA', '08:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (323, 'Asia/Ulaanbaatar', '+08', '08:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (324, 'Asia/Ulan_Bator', '+08', '08:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (325, 'Asia/Urumqi', '+06', '06:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (326, 'Asia/Ust-Nera', '+10', '10:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (327, 'Asia/Vientiane', '+07', '07:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (328, 'Asia/Vladivostok', '+10', '10:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (329, 'Asia/Yakutsk', '+09', '09:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (330, 'Asia/Yangon', '+0630', '06:30:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (331, 'Asia/Yekaterinburg', '+05', '05:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (332, 'Asia/Yerevan', '+04', '04:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (333, 'Atlantic/Azores', '+00', '00:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (334, 'Atlantic/Bermuda', 'ADT', '-03:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (335, 'Atlantic/Canary', 'WEST', '01:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (336, 'Atlantic/Cape_Verde', '-01', '-01:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (337, 'Atlantic/Faeroe', 'WEST', '01:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (338, 'Atlantic/Faroe', 'WEST', '01:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (339, 'Atlantic/Jan_Mayen', 'CEST', '02:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (340, 'Atlantic/Madeira', 'WEST', '01:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (341, 'Atlantic/Reykjavik', 'GMT', '00:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (342, 'Atlantic/South_Georgia', '-02', '-02:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (343, 'Atlantic/Stanley', '-03', '-03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (344, 'Atlantic/St_Helena', 'GMT', '00:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (345, 'Australia/ACT', 'AEST', '10:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (346, 'Australia/Adelaide', 'ACST', '09:30:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (347, 'Australia/Brisbane', 'AEST', '10:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (348, 'Australia/Broken_Hill', 'ACST', '09:30:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (349, 'Australia/Canberra', 'AEST', '10:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (350, 'Australia/Currie', 'AEST', '10:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (351, 'Australia/Darwin', 'ACST', '09:30:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (352, 'Australia/Eucla', '+0845', '08:45:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (353, 'Australia/Hobart', 'AEST', '10:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (354, 'Australia/LHI', '+1030', '10:30:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (355, 'Australia/Lindeman', 'AEST', '10:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (356, 'Australia/Lord_Howe', '+1030', '10:30:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (357, 'Australia/Melbourne', 'AEST', '10:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (358, 'Australia/North', 'ACST', '09:30:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (359, 'Australia/NSW', 'AEST', '10:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (360, 'Australia/Perth', 'AWST', '08:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (361, 'Australia/Queensland', 'AEST', '10:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (362, 'Australia/South', 'ACST', '09:30:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (363, 'Australia/Sydney', 'AEST', '10:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (364, 'Australia/Tasmania', 'AEST', '10:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (365, 'Australia/Victoria', 'AEST', '10:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (366, 'Australia/West', 'AWST', '08:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (367, 'Australia/Yancowinna', 'ACST', '09:30:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (368, 'Brazil/Acre', '-05', '-05:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (369, 'Brazil/DeNoronha', '-02', '-02:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (370, 'Brazil/East', '-03', '-03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (371, 'Brazil/West', '-04', '-04:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (372, 'Canada/Atlantic', 'ADT', '-03:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (373, 'Canada/Central', 'CDT', '-05:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (374, 'Canada/Eastern', 'EDT', '-04:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (375, 'Canada/East-Saskatchewan', 'CST', '-06:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (376, 'Canada/Mountain', 'MDT', '-06:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (377, 'Canada/Newfoundland', 'NDT', '-02:30:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (378, 'Canada/Pacific', 'PDT', '-07:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (379, 'Canada/Saskatchewan', 'CST', '-06:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (380, 'Canada/Yukon', 'PDT', '-07:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (381, 'CET', 'CEST', '02:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (382, 'Chile/Continental', '-03', '-03:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (383, 'Chile/EasterIsland', '-05', '-05:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (384, 'CST6CDT', 'CDT', '-05:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (385, 'Cuba', 'CDT', '-04:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (386, 'EET', 'EEST', '03:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (387, 'Egypt', 'EET', '02:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (388, 'Eire', 'IST', '01:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (389, 'EST', 'EST', '-05:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (390, 'EST5EDT', 'EDT', '-04:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (391, 'Etc/GMT', 'GMT', '00:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (392, 'Etc/GMT0', 'GMT', '00:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (393, 'Etc/GMT-0', 'GMT', '00:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (394, 'Etc/GMT+0', 'GMT', '00:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (395, 'Etc/GMT-1', '+01', '01:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (396, 'Etc/GMT+1', '-01', '-01:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (397, 'Etc/GMT-10', '+10', '10:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (398, 'Etc/GMT+10', '-10', '-10:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (399, 'Etc/GMT-11', '+11', '11:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (400, 'Etc/GMT+11', '-11', '-11:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (401, 'Etc/GMT-12', '+12', '12:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (402, 'Etc/GMT+12', '-12', '-12:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (403, 'Etc/GMT-13', '+13', '13:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (404, 'Etc/GMT-14', '+14', '14:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (405, 'Etc/GMT-2', '+02', '02:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (406, 'Etc/GMT+2', '-02', '-02:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (407, 'Etc/GMT-3', '+03', '03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (408, 'Etc/GMT+3', '-03', '-03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (409, 'Etc/GMT-4', '+04', '04:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (410, 'Etc/GMT+4', '-04', '-04:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (411, 'Etc/GMT-5', '+05', '05:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (412, 'Etc/GMT+5', '-05', '-05:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (413, 'Etc/GMT-6', '+06', '06:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (414, 'Etc/GMT+6', '-06', '-06:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (415, 'Etc/GMT-7', '+07', '07:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (416, 'Etc/GMT+7', '-07', '-07:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (417, 'Etc/GMT-8', '+08', '08:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (418, 'Etc/GMT+8', '-08', '-08:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (419, 'Etc/GMT-9', '+09', '09:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (420, 'Etc/GMT+9', '-09', '-09:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (421, 'Etc/Greenwich', 'GMT', '00:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (422, 'Etc/UCT', 'UCT', '00:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (423, 'Etc/Universal', 'UTC', '00:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (424, 'Etc/UTC', 'UTC', '00:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (425, 'Etc/Zulu', 'UTC', '00:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (426, 'Europe/Amsterdam', 'CEST', '02:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (427, 'Europe/Andorra', 'CEST', '02:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (428, 'Europe/Astrakhan', '+04', '04:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (429, 'Europe/Athens', 'EEST', '03:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (430, 'Europe/Belfast', 'BST', '01:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (431, 'Europe/Belgrade', 'CEST', '02:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (432, 'Europe/Berlin', 'CEST', '02:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (433, 'Europe/Bratislava', 'CEST', '02:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (434, 'Europe/Brussels', 'CEST', '02:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (435, 'Europe/Bucharest', 'EEST', '03:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (436, 'Europe/Budapest', 'CEST', '02:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (437, 'Europe/Busingen', 'CEST', '02:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (438, 'Europe/Chisinau', 'EEST', '03:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (439, 'Europe/Copenhagen', 'CEST', '02:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (440, 'Europe/Dublin', 'IST', '01:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (441, 'Europe/Gibraltar', 'CEST', '02:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (442, 'Europe/Guernsey', 'BST', '01:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (443, 'Europe/Helsinki', 'EEST', '03:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (444, 'Europe/Isle_of_Man', 'BST', '01:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (445, 'Europe/Istanbul', '+03', '03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (446, 'Europe/Jersey', 'BST', '01:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (447, 'Europe/Kaliningrad', 'EET', '02:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (448, 'Europe/Kiev', 'EEST', '03:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (449, 'Europe/Kirov', '+03', '03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (450, 'Europe/Lisbon', 'WEST', '01:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (451, 'Europe/Ljubljana', 'CEST', '02:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (452, 'Europe/London', 'BST', '01:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (453, 'Europe/Luxembourg', 'CEST', '02:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (454, 'Europe/Madrid', 'CEST', '02:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (455, 'Europe/Malta', 'CEST', '02:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (456, 'Europe/Mariehamn', 'EEST', '03:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (457, 'Europe/Minsk', '+03', '03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (458, 'Europe/Monaco', 'CEST', '02:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (459, 'Europe/Moscow', 'MSK', '03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (460, 'Europe/Nicosia', 'EEST', '03:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (461, 'Europe/Oslo', 'CEST', '02:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (462, 'Europe/Paris', 'CEST', '02:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (463, 'Europe/Podgorica', 'CEST', '02:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (464, 'Europe/Prague', 'CEST', '02:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (465, 'Europe/Riga', 'EEST', '03:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (466, 'Europe/Rome', 'CEST', '02:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (467, 'Europe/Samara', '+04', '04:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (468, 'Europe/San_Marino', 'CEST', '02:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (469, 'Europe/Sarajevo', 'CEST', '02:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (470, 'Europe/Saratov', '+04', '04:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (471, 'Europe/Simferopol', 'MSK', '03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (472, 'Europe/Skopje', 'CEST', '02:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (473, 'Europe/Sofia', 'EEST', '03:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (474, 'Europe/Stockholm', 'CEST', '02:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (475, 'Europe/Tallinn', 'EEST', '03:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (476, 'Europe/Tirane', 'CEST', '02:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (477, 'Europe/Tiraspol', 'EEST', '03:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (478, 'Europe/Ulyanovsk', '+04', '04:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (479, 'Europe/Uzhgorod', 'EEST', '03:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (480, 'Europe/Vaduz', 'CEST', '02:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (481, 'Europe/Vatican', 'CEST', '02:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (482, 'Europe/Vienna', 'CEST', '02:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (483, 'Europe/Vilnius', 'EEST', '03:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (484, 'Europe/Volgograd', '+03', '03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (485, 'Europe/Warsaw', 'CEST', '02:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (486, 'Europe/Zagreb', 'CEST', '02:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (487, 'Europe/Zaporozhye', 'EEST', '03:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (488, 'Europe/Zurich', 'CEST', '02:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (489, 'GB', 'BST', '01:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (490, 'GB-Eire', 'BST', '01:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (491, 'GMT', 'GMT', '00:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (492, 'GMT0', 'GMT', '00:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (493, 'GMT-0', 'GMT', '00:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (494, 'GMT+0', 'GMT', '00:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (495, 'Greenwich', 'GMT', '00:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (496, 'Hongkong', 'HKT', '08:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (497, 'HST', 'HST', '-10:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (498, 'Iceland', 'GMT', '00:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (499, 'Indian/Antananarivo', 'EAT', '03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (500, 'Indian/Chagos', '+06', '06:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (501, 'Indian/Christmas', '+07', '07:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (502, 'Indian/Cocos', '+0630', '06:30:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (503, 'Indian/Comoro', 'EAT', '03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (504, 'Indian/Kerguelen', '+05', '05:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (505, 'Indian/Mahe', '+04', '04:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (506, 'Indian/Maldives', '+05', '05:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (507, 'Indian/Mauritius', '+04', '04:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (508, 'Indian/Mayotte', 'EAT', '03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (509, 'Indian/Reunion', '+04', '04:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (510, 'Iran', '+0430', '04:30:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (511, 'Israel', 'IDT', '03:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (512, 'Jamaica', 'EST', '-05:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (514, 'Kwajalein', '+12', '12:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (515, 'Libya', 'EET', '02:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (516, 'localtime', 'EEST', '03:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (517, 'MET', 'MEST', '02:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (518, 'Mexico/BajaNorte', 'PDT', '-07:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (519, 'Mexico/BajaSur', 'MDT', '-06:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (520, 'Mexico/General', 'CDT', '-05:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (521, 'MST', 'MST', '-07:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (522, 'MST7MDT', 'MDT', '-06:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (523, 'Navajo', 'MDT', '-06:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (524, 'NZ', 'NZST', '12:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (525, 'NZ-CHAT', '+1245', '12:45:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (526, 'Pacific/Apia', '+13', '13:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (527, 'Pacific/Auckland', 'NZST', '12:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (528, 'Pacific/Bougainville', '+11', '11:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (529, 'Pacific/Chatham', '+1245', '12:45:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (530, 'Pacific/Chuuk', '+10', '10:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (531, 'Pacific/Easter', '-05', '-05:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (532, 'Pacific/Efate', '+11', '11:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (533, 'Pacific/Enderbury', '+13', '13:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (534, 'Pacific/Fakaofo', '+13', '13:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (535, 'Pacific/Fiji', '+12', '12:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (536, 'Pacific/Funafuti', '+12', '12:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (537, 'Pacific/Galapagos', '-06', '-06:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (538, 'Pacific/Gambier', '-09', '-09:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (539, 'Pacific/Guadalcanal', '+11', '11:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (540, 'Pacific/Guam', 'ChST', '10:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (541, 'Pacific/Honolulu', 'HST', '-10:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (542, 'Pacific/Johnston', 'HST', '-10:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (543, 'Pacific/Kiritimati', '+14', '14:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (544, 'Pacific/Kosrae', '+11', '11:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (545, 'Pacific/Kwajalein', '+12', '12:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (546, 'Pacific/Majuro', '+12', '12:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (547, 'Pacific/Marquesas', '-0930', '-09:30:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (548, 'Pacific/Midway', 'SST', '-11:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (549, 'Pacific/Nauru', '+12', '12:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (550, 'Pacific/Niue', '-11', '-11:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (551, 'Pacific/Norfolk', '+11', '11:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (552, 'Pacific/Noumea', '+11', '11:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (553, 'Pacific/Pago_Pago', 'SST', '-11:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (554, 'Pacific/Palau', '+09', '09:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (555, 'Pacific/Pitcairn', '-08', '-08:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (556, 'Pacific/Pohnpei', '+11', '11:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (557, 'Pacific/Ponape', '+11', '11:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (558, 'Pacific/Port_Moresby', '+10', '10:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (559, 'Pacific/Rarotonga', '-10', '-10:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (560, 'Pacific/Saipan', 'ChST', '10:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (561, 'Pacific/Samoa', 'SST', '-11:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (562, 'Pacific/Tahiti', '-10', '-10:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (563, 'Pacific/Tarawa', '+12', '12:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (564, 'Pacific/Tongatapu', '+13', '13:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (565, 'Pacific/Truk', '+10', '10:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (566, 'Pacific/Wake', '+12', '12:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (567, 'Pacific/Wallis', '+12', '12:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (568, 'Pacific/Yap', '+10', '10:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (569, 'Poland', 'CEST', '02:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (570, 'Portugal', 'WEST', '01:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (571, 'posix/Africa/Abidjan', 'GMT', '00:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (572, 'posix/Africa/Accra', 'GMT', '00:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (573, 'posix/Africa/Addis_Ababa', 'EAT', '03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (574, 'posix/Africa/Algiers', 'CET', '01:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (575, 'posix/Africa/Asmara', 'EAT', '03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (576, 'posix/Africa/Asmera', 'EAT', '03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (577, 'posix/Africa/Bamako', 'GMT', '00:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (578, 'posix/Africa/Bangui', 'WAT', '01:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (579, 'posix/Africa/Banjul', 'GMT', '00:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (580, 'posix/Africa/Bissau', 'GMT', '00:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (581, 'posix/Africa/Blantyre', 'CAT', '02:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (582, 'posix/Africa/Brazzaville', 'WAT', '01:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (583, 'posix/Africa/Bujumbura', 'CAT', '02:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (584, 'posix/Africa/Cairo', 'EET', '02:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (585, 'posix/Africa/Casablanca', 'WEST', '01:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (586, 'posix/Africa/Ceuta', 'CEST', '02:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (587, 'posix/Africa/Conakry', 'GMT', '00:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (588, 'posix/Africa/Dakar', 'GMT', '00:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (589, 'posix/Africa/Dar_es_Salaam', 'EAT', '03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (590, 'posix/Africa/Djibouti', 'EAT', '03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (591, 'posix/Africa/Douala', 'WAT', '01:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (592, 'posix/Africa/El_Aaiun', 'WEST', '01:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (593, 'posix/Africa/Freetown', 'GMT', '00:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (594, 'posix/Africa/Gaborone', 'CAT', '02:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (595, 'posix/Africa/Harare', 'CAT', '02:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (596, 'posix/Africa/Johannesburg', 'SAST', '02:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (597, 'posix/Africa/Juba', 'EAT', '03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (598, 'posix/Africa/Kampala', 'EAT', '03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (599, 'posix/Africa/Khartoum', 'EAT', '03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (600, 'posix/Africa/Kigali', 'CAT', '02:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (601, 'posix/Africa/Kinshasa', 'WAT', '01:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (602, 'posix/Africa/Lagos', 'WAT', '01:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (603, 'posix/Africa/Libreville', 'WAT', '01:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (604, 'posix/Africa/Lome', 'GMT', '00:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (605, 'posix/Africa/Luanda', 'WAT', '01:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (606, 'posix/Africa/Lubumbashi', 'CAT', '02:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (607, 'posix/Africa/Lusaka', 'CAT', '02:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (608, 'posix/Africa/Malabo', 'WAT', '01:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (609, 'posix/Africa/Maputo', 'CAT', '02:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (610, 'posix/Africa/Maseru', 'SAST', '02:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (611, 'posix/Africa/Mbabane', 'SAST', '02:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (612, 'posix/Africa/Mogadishu', 'EAT', '03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (613, 'posix/Africa/Monrovia', 'GMT', '00:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (614, 'posix/Africa/Nairobi', 'EAT', '03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (615, 'posix/Africa/Ndjamena', 'WAT', '01:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (616, 'posix/Africa/Niamey', 'WAT', '01:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (617, 'posix/Africa/Nouakchott', 'GMT', '00:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (618, 'posix/Africa/Ouagadougou', 'GMT', '00:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (619, 'posix/Africa/Porto-Novo', 'WAT', '01:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (620, 'posix/Africa/Sao_Tome', 'GMT', '00:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (621, 'posix/Africa/Timbuktu', 'GMT', '00:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (622, 'posix/Africa/Tripoli', 'EET', '02:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (623, 'posix/Africa/Tunis', 'CET', '01:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (624, 'posix/Africa/Windhoek', 'WAT', '01:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (625, 'posix/America/Adak', 'HDT', '-09:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (626, 'posix/America/Anchorage', 'AKDT', '-08:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (627, 'posix/America/Anguilla', 'AST', '-04:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (628, 'posix/America/Antigua', 'AST', '-04:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (629, 'posix/America/Araguaina', '-03', '-03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (630, 'posix/America/Argentina/Buenos_Aires', '-03', '-03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (631, 'posix/America/Argentina/Catamarca', '-03', '-03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (632, 'posix/America/Argentina/ComodRivadavia', '-03', '-03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (633, 'posix/America/Argentina/Cordoba', '-03', '-03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (634, 'posix/America/Argentina/Jujuy', '-03', '-03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (635, 'posix/America/Argentina/La_Rioja', '-03', '-03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (636, 'posix/America/Argentina/Mendoza', '-03', '-03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (637, 'posix/America/Argentina/Rio_Gallegos', '-03', '-03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (638, 'posix/America/Argentina/Salta', '-03', '-03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (639, 'posix/America/Argentina/San_Juan', '-03', '-03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (640, 'posix/America/Argentina/San_Luis', '-03', '-03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (641, 'posix/America/Argentina/Tucuman', '-03', '-03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (642, 'posix/America/Argentina/Ushuaia', '-03', '-03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (643, 'posix/America/Aruba', 'AST', '-04:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (644, 'posix/America/Asuncion', '-04', '-04:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (645, 'posix/America/Atikokan', 'EST', '-05:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (646, 'posix/America/Atka', 'HDT', '-09:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (647, 'posix/America/Bahia', '-03', '-03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (648, 'posix/America/Bahia_Banderas', 'CDT', '-05:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (649, 'posix/America/Barbados', 'AST', '-04:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (650, 'posix/America/Belem', '-03', '-03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (651, 'posix/America/Belize', 'CST', '-06:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (652, 'posix/America/Blanc-Sablon', 'AST', '-04:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (653, 'posix/America/Boa_Vista', '-04', '-04:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (654, 'posix/America/Bogota', '-05', '-05:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (655, 'posix/America/Boise', 'MDT', '-06:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (656, 'posix/America/Buenos_Aires', '-03', '-03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (657, 'posix/America/Cambridge_Bay', 'MDT', '-06:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (658, 'posix/America/Campo_Grande', '-04', '-04:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (659, 'posix/America/Cancun', 'EST', '-05:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (660, 'posix/America/Caracas', '-04', '-04:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (661, 'posix/America/Catamarca', '-03', '-03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (662, 'posix/America/Cayenne', '-03', '-03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (663, 'posix/America/Cayman', 'EST', '-05:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (664, 'posix/America/Chicago', 'CDT', '-05:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (665, 'posix/America/Chihuahua', 'MDT', '-06:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (666, 'posix/America/Coral_Harbour', 'EST', '-05:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (667, 'posix/America/Cordoba', '-03', '-03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (668, 'posix/America/Costa_Rica', 'CST', '-06:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (669, 'posix/America/Creston', 'MST', '-07:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (670, 'posix/America/Cuiaba', '-04', '-04:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (671, 'posix/America/Curacao', 'AST', '-04:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (672, 'posix/America/Danmarkshavn', 'GMT', '00:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (673, 'posix/America/Dawson', 'PDT', '-07:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (674, 'posix/America/Dawson_Creek', 'MST', '-07:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (675, 'posix/America/Denver', 'MDT', '-06:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (676, 'posix/America/Detroit', 'EDT', '-04:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (677, 'posix/America/Dominica', 'AST', '-04:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (678, 'posix/America/Edmonton', 'MDT', '-06:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (679, 'posix/America/Eirunepe', '-05', '-05:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (680, 'posix/America/El_Salvador', 'CST', '-06:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (681, 'posix/America/Ensenada', 'PDT', '-07:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (682, 'posix/America/Fortaleza', '-03', '-03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (683, 'posix/America/Fort_Nelson', 'MST', '-07:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (684, 'posix/America/Fort_Wayne', 'EDT', '-04:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (685, 'posix/America/Glace_Bay', 'ADT', '-03:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (686, 'posix/America/Godthab', '-02', '-02:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (687, 'posix/America/Goose_Bay', 'ADT', '-03:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (688, 'posix/America/Grand_Turk', 'AST', '-04:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (689, 'posix/America/Grenada', 'AST', '-04:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (690, 'posix/America/Guadeloupe', 'AST', '-04:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (691, 'posix/America/Guatemala', 'CST', '-06:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (692, 'posix/America/Guayaquil', '-05', '-05:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (693, 'posix/America/Guyana', '-04', '-04:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (694, 'posix/America/Halifax', 'ADT', '-03:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (695, 'posix/America/Havana', 'CDT', '-04:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (696, 'posix/America/Hermosillo', 'MST', '-07:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (697, 'posix/America/Indiana/Indianapolis', 'EDT', '-04:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (698, 'posix/America/Indiana/Knox', 'CDT', '-05:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (699, 'posix/America/Indiana/Marengo', 'EDT', '-04:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (700, 'posix/America/Indiana/Petersburg', 'EDT', '-04:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (701, 'posix/America/Indianapolis', 'EDT', '-04:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (702, 'posix/America/Indiana/Tell_City', 'CDT', '-05:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (703, 'posix/America/Indiana/Vevay', 'EDT', '-04:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (704, 'posix/America/Indiana/Vincennes', 'EDT', '-04:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (705, 'posix/America/Indiana/Winamac', 'EDT', '-04:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (706, 'posix/America/Inuvik', 'MDT', '-06:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (707, 'posix/America/Iqaluit', 'EDT', '-04:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (708, 'posix/America/Jamaica', 'EST', '-05:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (709, 'posix/America/Jujuy', '-03', '-03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (710, 'posix/America/Juneau', 'AKDT', '-08:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (711, 'posix/America/Kentucky/Louisville', 'EDT', '-04:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (712, 'posix/America/Kentucky/Monticello', 'EDT', '-04:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (713, 'posix/America/Knox_IN', 'CDT', '-05:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (714, 'posix/America/Kralendijk', 'AST', '-04:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (715, 'posix/America/La_Paz', '-04', '-04:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (716, 'posix/America/Lima', '-05', '-05:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (717, 'posix/America/Los_Angeles', 'PDT', '-07:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (718, 'posix/America/Louisville', 'EDT', '-04:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (719, 'posix/America/Lower_Princes', 'AST', '-04:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (720, 'posix/America/Maceio', '-03', '-03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (721, 'posix/America/Managua', 'CST', '-06:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (722, 'posix/America/Manaus', '-04', '-04:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (723, 'posix/America/Marigot', 'AST', '-04:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (724, 'posix/America/Martinique', 'AST', '-04:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (725, 'posix/America/Matamoros', 'CDT', '-05:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (726, 'posix/America/Mazatlan', 'MDT', '-06:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (727, 'posix/America/Mendoza', '-03', '-03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (728, 'posix/America/Menominee', 'CDT', '-05:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (729, 'posix/America/Merida', 'CDT', '-05:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (730, 'posix/America/Metlakatla', 'AKDT', '-08:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (731, 'posix/America/Mexico_City', 'CDT', '-05:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (732, 'posix/America/Miquelon', '-02', '-02:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (733, 'posix/America/Moncton', 'ADT', '-03:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (734, 'posix/America/Monterrey', 'CDT', '-05:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (735, 'posix/America/Montevideo', '-03', '-03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (736, 'posix/America/Montreal', 'EDT', '-04:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (737, 'posix/America/Montserrat', 'AST', '-04:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (738, 'posix/America/Nassau', 'EDT', '-04:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (739, 'posix/America/New_York', 'EDT', '-04:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (740, 'posix/America/Nipigon', 'EDT', '-04:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (741, 'posix/America/Nome', 'AKDT', '-08:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (742, 'posix/America/Noronha', '-02', '-02:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (743, 'posix/America/North_Dakota/Beulah', 'CDT', '-05:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (744, 'posix/America/North_Dakota/Center', 'CDT', '-05:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (745, 'posix/America/North_Dakota/New_Salem', 'CDT', '-05:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (746, 'posix/America/Ojinaga', 'MDT', '-06:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (747, 'posix/America/Panama', 'EST', '-05:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (748, 'posix/America/Pangnirtung', 'EDT', '-04:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (749, 'posix/America/Paramaribo', '-03', '-03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (750, 'posix/America/Phoenix', 'MST', '-07:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (751, 'posix/America/Port-au-Prince', 'EDT', '-04:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (752, 'posix/America/Porto_Acre', '-05', '-05:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (753, 'posix/America/Port_of_Spain', 'AST', '-04:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (754, 'posix/America/Porto_Velho', '-04', '-04:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (755, 'posix/America/Puerto_Rico', 'AST', '-04:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (756, 'posix/America/Punta_Arenas', '-03', '-03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (757, 'posix/America/Rainy_River', 'CDT', '-05:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (758, 'posix/America/Rankin_Inlet', 'CDT', '-05:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (759, 'posix/America/Recife', '-03', '-03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (760, 'posix/America/Regina', 'CST', '-06:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (761, 'posix/America/Resolute', 'CDT', '-05:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (762, 'posix/America/Rio_Branco', '-05', '-05:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (763, 'posix/America/Rosario', '-03', '-03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (764, 'posix/America/Santa_Isabel', 'PDT', '-07:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (765, 'posix/America/Santarem', '-03', '-03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (766, 'posix/America/Santiago', '-03', '-03:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (767, 'posix/America/Santo_Domingo', 'AST', '-04:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (768, 'posix/America/Sao_Paulo', '-03', '-03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (769, 'posix/America/Scoresbysund', '+00', '00:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (770, 'posix/America/Shiprock', 'MDT', '-06:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (771, 'posix/America/Sitka', 'AKDT', '-08:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (772, 'posix/America/St_Barthelemy', 'AST', '-04:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (773, 'posix/America/St_Johns', 'NDT', '-02:30:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (774, 'posix/America/St_Kitts', 'AST', '-04:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (775, 'posix/America/St_Lucia', 'AST', '-04:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (776, 'posix/America/St_Thomas', 'AST', '-04:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (777, 'posix/America/St_Vincent', 'AST', '-04:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (778, 'posix/America/Swift_Current', 'CST', '-06:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (779, 'posix/America/Tegucigalpa', 'CST', '-06:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (780, 'posix/America/Thule', 'ADT', '-03:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (781, 'posix/America/Thunder_Bay', 'EDT', '-04:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (782, 'posix/America/Tijuana', 'PDT', '-07:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (783, 'posix/America/Toronto', 'EDT', '-04:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (784, 'posix/America/Tortola', 'AST', '-04:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (785, 'posix/America/Vancouver', 'PDT', '-07:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (786, 'posix/America/Virgin', 'AST', '-04:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (787, 'posix/America/Whitehorse', 'PDT', '-07:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (788, 'posix/America/Winnipeg', 'CDT', '-05:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (789, 'posix/America/Yakutat', 'AKDT', '-08:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (790, 'posix/America/Yellowknife', 'MDT', '-06:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (791, 'posix/Antarctica/Casey', '+11', '11:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (792, 'posix/Antarctica/Davis', '+07', '07:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (793, 'posix/Antarctica/DumontDUrville', '+10', '10:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (794, 'posix/Antarctica/Macquarie', '+11', '11:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (795, 'posix/Antarctica/Mawson', '+05', '05:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (796, 'posix/Antarctica/McMurdo', 'NZST', '12:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (797, 'posix/Antarctica/Palmer', '-03', '-03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (798, 'posix/Antarctica/Rothera', '-03', '-03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (799, 'posix/Antarctica/South_Pole', 'NZST', '12:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (800, 'posix/Antarctica/Syowa', '+03', '03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (801, 'posix/Antarctica/Troll', '+02', '02:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (802, 'posix/Antarctica/Vostok', '+06', '06:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (803, 'posix/Arctic/Longyearbyen', 'CEST', '02:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (804, 'posix/Asia/Aden', '+03', '03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (805, 'posix/Asia/Almaty', '+06', '06:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (806, 'posix/Asia/Amman', 'EEST', '03:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (807, 'posix/Asia/Anadyr', '+12', '12:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (808, 'posix/Asia/Aqtau', '+05', '05:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (809, 'posix/Asia/Aqtobe', '+05', '05:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (810, 'posix/Asia/Ashgabat', '+05', '05:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (811, 'posix/Asia/Ashkhabad', '+05', '05:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (812, 'posix/Asia/Atyrau', '+05', '05:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (813, 'posix/Asia/Baghdad', '+03', '03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (814, 'posix/Asia/Bahrain', '+03', '03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (815, 'posix/Asia/Baku', '+04', '04:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (816, 'posix/Asia/Bangkok', '+07', '07:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (817, 'posix/Asia/Barnaul', '+07', '07:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (818, 'posix/Asia/Beirut', 'EEST', '03:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (819, 'posix/Asia/Bishkek', '+06', '06:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (820, 'posix/Asia/Brunei', '+08', '08:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (821, 'posix/Asia/Calcutta', 'IST', '05:30:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (822, 'posix/Asia/Chita', '+09', '09:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (823, 'posix/Asia/Choibalsan', '+08', '08:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (824, 'posix/Asia/Chongqing', 'CST', '08:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (825, 'posix/Asia/Chungking', 'CST', '08:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (826, 'posix/Asia/Colombo', '+0530', '05:30:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (827, 'posix/Asia/Dacca', '+06', '06:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (828, 'posix/Asia/Damascus', 'EEST', '03:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (829, 'posix/Asia/Dhaka', '+06', '06:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (830, 'posix/Asia/Dili', '+09', '09:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (831, 'posix/Asia/Dubai', '+04', '04:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (832, 'posix/Asia/Dushanbe', '+05', '05:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (833, 'posix/Asia/Famagusta', '+03', '03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (834, 'posix/Asia/Gaza', 'EEST', '03:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (835, 'posix/Asia/Harbin', 'CST', '08:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (836, 'posix/Asia/Hebron', 'EEST', '03:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (837, 'posix/Asia/Ho_Chi_Minh', '+07', '07:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (838, 'posix/Asia/Hong_Kong', 'HKT', '08:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (839, 'posix/Asia/Hovd', '+07', '07:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (840, 'posix/Asia/Irkutsk', '+08', '08:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (841, 'posix/Asia/Istanbul', '+03', '03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (842, 'posix/Asia/Jakarta', 'WIB', '07:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (843, 'posix/Asia/Jayapura', 'WIT', '09:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (844, 'posix/Asia/Jerusalem', 'IDT', '03:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (845, 'posix/Asia/Kabul', '+0430', '04:30:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (846, 'posix/Asia/Kamchatka', '+12', '12:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (847, 'posix/Asia/Karachi', 'PKT', '05:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (848, 'posix/Asia/Kashgar', '+06', '06:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (849, 'posix/Asia/Kathmandu', '+0545', '05:45:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (850, 'posix/Asia/Katmandu', '+0545', '05:45:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (851, 'posix/Asia/Khandyga', '+09', '09:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (852, 'posix/Asia/Kolkata', 'IST', '05:30:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (853, 'posix/Asia/Krasnoyarsk', '+07', '07:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (854, 'posix/Asia/Kuala_Lumpur', '+08', '08:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (855, 'posix/Asia/Kuching', '+08', '08:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (856, 'posix/Asia/Kuwait', '+03', '03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (857, 'posix/Asia/Macao', 'CST', '08:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (858, 'posix/Asia/Macau', 'CST', '08:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (859, 'posix/Asia/Magadan', '+11', '11:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (860, 'posix/Asia/Makassar', 'WITA', '08:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (861, 'posix/Asia/Manila', '+08', '08:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (862, 'posix/Asia/Muscat', '+04', '04:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (863, 'posix/Asia/Nicosia', 'EEST', '03:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (864, 'posix/Asia/Novokuznetsk', '+07', '07:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (865, 'posix/Asia/Novosibirsk', '+07', '07:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (866, 'posix/Asia/Omsk', '+06', '06:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (867, 'posix/Asia/Oral', '+05', '05:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (868, 'posix/Asia/Phnom_Penh', '+07', '07:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (869, 'posix/Asia/Pontianak', 'WIB', '07:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (870, 'posix/Asia/Pyongyang', 'KST', '08:30:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (871, 'posix/Asia/Qatar', '+03', '03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (872, 'posix/Asia/Qyzylorda', '+06', '06:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (873, 'posix/Asia/Rangoon', '+0630', '06:30:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (874, 'posix/Asia/Riyadh', '+03', '03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (875, 'posix/Asia/Saigon', '+07', '07:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (876, 'posix/Asia/Sakhalin', '+11', '11:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (877, 'posix/Asia/Samarkand', '+05', '05:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (878, 'posix/Asia/Seoul', 'KST', '09:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (879, 'posix/Asia/Shanghai', 'CST', '08:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (880, 'posix/Asia/Singapore', '+08', '08:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (881, 'posix/Asia/Srednekolymsk', '+11', '11:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (882, 'posix/Asia/Taipei', 'CST', '08:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (883, 'posix/Asia/Tashkent', '+05', '05:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (884, 'posix/Asia/Tbilisi', '+04', '04:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (885, 'posix/Asia/Tehran', '+0430', '04:30:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (886, 'posix/Asia/Tel_Aviv', 'IDT', '03:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (887, 'posix/Asia/Thimbu', '+06', '06:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (888, 'posix/Asia/Thimphu', '+06', '06:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (889, 'posix/Asia/Tokyo', 'JST', '09:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (890, 'posix/Asia/Tomsk', '+07', '07:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (891, 'posix/Asia/Ujung_Pandang', 'WITA', '08:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (892, 'posix/Asia/Ulaanbaatar', '+08', '08:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (893, 'posix/Asia/Ulan_Bator', '+08', '08:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (894, 'posix/Asia/Urumqi', '+06', '06:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (895, 'posix/Asia/Ust-Nera', '+10', '10:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (896, 'posix/Asia/Vientiane', '+07', '07:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (897, 'posix/Asia/Vladivostok', '+10', '10:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (898, 'posix/Asia/Yakutsk', '+09', '09:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (899, 'posix/Asia/Yangon', '+0630', '06:30:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (900, 'posix/Asia/Yekaterinburg', '+05', '05:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (901, 'posix/Asia/Yerevan', '+04', '04:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (902, 'posix/Atlantic/Azores', '+00', '00:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (903, 'posix/Atlantic/Bermuda', 'ADT', '-03:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (904, 'posix/Atlantic/Canary', 'WEST', '01:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (905, 'posix/Atlantic/Cape_Verde', '-01', '-01:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (906, 'posix/Atlantic/Faeroe', 'WEST', '01:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (907, 'posix/Atlantic/Faroe', 'WEST', '01:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (908, 'posix/Atlantic/Jan_Mayen', 'CEST', '02:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (909, 'posix/Atlantic/Madeira', 'WEST', '01:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (910, 'posix/Atlantic/Reykjavik', 'GMT', '00:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (911, 'posix/Atlantic/South_Georgia', '-02', '-02:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (912, 'posix/Atlantic/Stanley', '-03', '-03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (913, 'posix/Atlantic/St_Helena', 'GMT', '00:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (914, 'posix/Australia/ACT', 'AEST', '10:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (915, 'posix/Australia/Adelaide', 'ACST', '09:30:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (916, 'posix/Australia/Brisbane', 'AEST', '10:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (917, 'posix/Australia/Broken_Hill', 'ACST', '09:30:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (918, 'posix/Australia/Canberra', 'AEST', '10:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (919, 'posix/Australia/Currie', 'AEST', '10:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (920, 'posix/Australia/Darwin', 'ACST', '09:30:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (921, 'posix/Australia/Eucla', '+0845', '08:45:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (922, 'posix/Australia/Hobart', 'AEST', '10:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (923, 'posix/Australia/LHI', '+1030', '10:30:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (924, 'posix/Australia/Lindeman', 'AEST', '10:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (925, 'posix/Australia/Lord_Howe', '+1030', '10:30:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (926, 'posix/Australia/Melbourne', 'AEST', '10:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (927, 'posix/Australia/North', 'ACST', '09:30:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (928, 'posix/Australia/NSW', 'AEST', '10:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (929, 'posix/Australia/Perth', 'AWST', '08:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (930, 'posix/Australia/Queensland', 'AEST', '10:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (931, 'posix/Australia/South', 'ACST', '09:30:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (932, 'posix/Australia/Sydney', 'AEST', '10:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (933, 'posix/Australia/Tasmania', 'AEST', '10:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (934, 'posix/Australia/Victoria', 'AEST', '10:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (935, 'posix/Australia/West', 'AWST', '08:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (936, 'posix/Australia/Yancowinna', 'ACST', '09:30:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (937, 'posix/Brazil/Acre', '-05', '-05:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (938, 'posix/Brazil/DeNoronha', '-02', '-02:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (939, 'posix/Brazil/East', '-03', '-03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (940, 'posix/Brazil/West', '-04', '-04:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (941, 'posix/Canada/Atlantic', 'ADT', '-03:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (942, 'posix/Canada/Central', 'CDT', '-05:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (943, 'posix/Canada/Eastern', 'EDT', '-04:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (944, 'posix/Canada/East-Saskatchewan', 'CST', '-06:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (945, 'posix/Canada/Mountain', 'MDT', '-06:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (946, 'posix/Canada/Newfoundland', 'NDT', '-02:30:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (947, 'posix/Canada/Pacific', 'PDT', '-07:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (948, 'posix/Canada/Saskatchewan', 'CST', '-06:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (949, 'posix/Canada/Yukon', 'PDT', '-07:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (950, 'posix/CET', 'CEST', '02:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (951, 'posix/Chile/Continental', '-03', '-03:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (952, 'posix/Chile/EasterIsland', '-05', '-05:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (953, 'posix/CST6CDT', 'CDT', '-05:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (954, 'posix/Cuba', 'CDT', '-04:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (955, 'posix/EET', 'EEST', '03:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (956, 'posix/Egypt', 'EET', '02:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (957, 'posix/Eire', 'IST', '01:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (958, 'posix/EST', 'EST', '-05:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (959, 'posix/EST5EDT', 'EDT', '-04:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (960, 'posix/Etc/GMT', 'GMT', '00:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (961, 'posix/Etc/GMT0', 'GMT', '00:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (962, 'posix/Etc/GMT-0', 'GMT', '00:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (963, 'posix/Etc/GMT+0', 'GMT', '00:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (964, 'posix/Etc/GMT-1', '+01', '01:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (965, 'posix/Etc/GMT+1', '-01', '-01:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (966, 'posix/Etc/GMT-10', '+10', '10:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (967, 'posix/Etc/GMT+10', '-10', '-10:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (968, 'posix/Etc/GMT-11', '+11', '11:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (969, 'posix/Etc/GMT+11', '-11', '-11:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (970, 'posix/Etc/GMT-12', '+12', '12:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (971, 'posix/Etc/GMT+12', '-12', '-12:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (972, 'posix/Etc/GMT-13', '+13', '13:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (973, 'posix/Etc/GMT-14', '+14', '14:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (974, 'posix/Etc/GMT-2', '+02', '02:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (975, 'posix/Etc/GMT+2', '-02', '-02:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (976, 'posix/Etc/GMT-3', '+03', '03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (977, 'posix/Etc/GMT+3', '-03', '-03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (978, 'posix/Etc/GMT-4', '+04', '04:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (979, 'posix/Etc/GMT+4', '-04', '-04:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (980, 'posix/Etc/GMT-5', '+05', '05:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (981, 'posix/Etc/GMT+5', '-05', '-05:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (982, 'posix/Etc/GMT-6', '+06', '06:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (983, 'posix/Etc/GMT+6', '-06', '-06:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (984, 'posix/Etc/GMT-7', '+07', '07:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (985, 'posix/Etc/GMT+7', '-07', '-07:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (986, 'posix/Etc/GMT-8', '+08', '08:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (987, 'posix/Etc/GMT+8', '-08', '-08:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (988, 'posix/Etc/GMT-9', '+09', '09:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (989, 'posix/Etc/GMT+9', '-09', '-09:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (990, 'posix/Etc/Greenwich', 'GMT', '00:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (991, 'posix/Etc/UCT', 'UCT', '00:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (992, 'posix/Etc/Universal', 'UTC', '00:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (993, 'posix/Etc/UTC', 'UTC', '00:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (994, 'posix/Etc/Zulu', 'UTC', '00:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (995, 'posix/Europe/Amsterdam', 'CEST', '02:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (996, 'posix/Europe/Andorra', 'CEST', '02:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (997, 'posix/Europe/Astrakhan', '+04', '04:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (998, 'posix/Europe/Athens', 'EEST', '03:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (999, 'posix/Europe/Belfast', 'BST', '01:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1000, 'posix/Europe/Belgrade', 'CEST', '02:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1001, 'posix/Europe/Berlin', 'CEST', '02:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1002, 'posix/Europe/Bratislava', 'CEST', '02:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1003, 'posix/Europe/Brussels', 'CEST', '02:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1004, 'posix/Europe/Bucharest', 'EEST', '03:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1005, 'posix/Europe/Budapest', 'CEST', '02:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1006, 'posix/Europe/Busingen', 'CEST', '02:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1007, 'posix/Europe/Chisinau', 'EEST', '03:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1008, 'posix/Europe/Copenhagen', 'CEST', '02:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1009, 'posix/Europe/Dublin', 'IST', '01:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1010, 'posix/Europe/Gibraltar', 'CEST', '02:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1011, 'posix/Europe/Guernsey', 'BST', '01:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1012, 'posix/Europe/Helsinki', 'EEST', '03:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1013, 'posix/Europe/Isle_of_Man', 'BST', '01:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1014, 'posix/Europe/Istanbul', '+03', '03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1015, 'posix/Europe/Jersey', 'BST', '01:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1016, 'posix/Europe/Kaliningrad', 'EET', '02:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1017, 'posix/Europe/Kiev', 'EEST', '03:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1018, 'posix/Europe/Kirov', '+03', '03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1019, 'posix/Europe/Lisbon', 'WEST', '01:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1020, 'posix/Europe/Ljubljana', 'CEST', '02:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1021, 'posix/Europe/London', 'BST', '01:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1022, 'posix/Europe/Luxembourg', 'CEST', '02:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1023, 'posix/Europe/Madrid', 'CEST', '02:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1024, 'posix/Europe/Malta', 'CEST', '02:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1025, 'posix/Europe/Mariehamn', 'EEST', '03:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1026, 'posix/Europe/Minsk', '+03', '03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1027, 'posix/Europe/Monaco', 'CEST', '02:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1028, 'posix/Europe/Moscow', 'MSK', '03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1029, 'posix/Europe/Nicosia', 'EEST', '03:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1030, 'posix/Europe/Oslo', 'CEST', '02:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1031, 'posix/Europe/Paris', 'CEST', '02:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1032, 'posix/Europe/Podgorica', 'CEST', '02:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1033, 'posix/Europe/Prague', 'CEST', '02:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1034, 'posix/Europe/Riga', 'EEST', '03:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1035, 'posix/Europe/Rome', 'CEST', '02:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1036, 'posix/Europe/Samara', '+04', '04:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1037, 'posix/Europe/San_Marino', 'CEST', '02:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1038, 'posix/Europe/Sarajevo', 'CEST', '02:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1039, 'posix/Europe/Saratov', '+04', '04:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1040, 'posix/Europe/Simferopol', 'MSK', '03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1041, 'posix/Europe/Skopje', 'CEST', '02:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1042, 'posix/Europe/Sofia', 'EEST', '03:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1043, 'posix/Europe/Stockholm', 'CEST', '02:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1044, 'posix/Europe/Tallinn', 'EEST', '03:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1045, 'posix/Europe/Tirane', 'CEST', '02:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1046, 'posix/Europe/Tiraspol', 'EEST', '03:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1047, 'posix/Europe/Ulyanovsk', '+04', '04:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1048, 'posix/Europe/Uzhgorod', 'EEST', '03:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1049, 'posix/Europe/Vaduz', 'CEST', '02:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1050, 'posix/Europe/Vatican', 'CEST', '02:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1051, 'posix/Europe/Vienna', 'CEST', '02:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1052, 'posix/Europe/Vilnius', 'EEST', '03:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1053, 'posix/Europe/Volgograd', '+03', '03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1054, 'posix/Europe/Warsaw', 'CEST', '02:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1055, 'posix/Europe/Zagreb', 'CEST', '02:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1056, 'posix/Europe/Zaporozhye', 'EEST', '03:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1057, 'posix/Europe/Zurich', 'CEST', '02:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1058, 'posix/GB', 'BST', '01:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1059, 'posix/GB-Eire', 'BST', '01:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1060, 'posix/GMT', 'GMT', '00:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1061, 'posix/GMT0', 'GMT', '00:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1062, 'posix/GMT-0', 'GMT', '00:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1063, 'posix/GMT+0', 'GMT', '00:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1064, 'posix/Greenwich', 'GMT', '00:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1065, 'posix/Hongkong', 'HKT', '08:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1066, 'posix/HST', 'HST', '-10:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1067, 'posix/Iceland', 'GMT', '00:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1068, 'posix/Indian/Antananarivo', 'EAT', '03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1069, 'posix/Indian/Chagos', '+06', '06:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1070, 'posix/Indian/Christmas', '+07', '07:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1071, 'posix/Indian/Cocos', '+0630', '06:30:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1072, 'posix/Indian/Comoro', 'EAT', '03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1073, 'posix/Indian/Kerguelen', '+05', '05:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1074, 'posix/Indian/Mahe', '+04', '04:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1075, 'posix/Indian/Maldives', '+05', '05:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1076, 'posix/Indian/Mauritius', '+04', '04:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1077, 'posix/Indian/Mayotte', 'EAT', '03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1078, 'posix/Indian/Reunion', '+04', '04:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1079, 'posix/Iran', '+0430', '04:30:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1080, 'posix/Israel', 'IDT', '03:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1081, 'posix/Jamaica', 'EST', '-05:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1082, 'posix/Japan', 'JST', '09:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1083, 'posix/Kwajalein', '+12', '12:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1084, 'posix/Libya', 'EET', '02:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1085, 'posix/MET', 'MEST', '02:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1086, 'posix/Mexico/BajaNorte', 'PDT', '-07:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1087, 'posix/Mexico/BajaSur', 'MDT', '-06:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1088, 'posix/Mexico/General', 'CDT', '-05:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1089, 'posix/MST', 'MST', '-07:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1090, 'posix/MST7MDT', 'MDT', '-06:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1091, 'posix/Navajo', 'MDT', '-06:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1092, 'posix/NZ', 'NZST', '12:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1093, 'posix/NZ-CHAT', '+1245', '12:45:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1094, 'posix/Pacific/Apia', '+13', '13:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1095, 'posix/Pacific/Auckland', 'NZST', '12:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1096, 'posix/Pacific/Bougainville', '+11', '11:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1097, 'posix/Pacific/Chatham', '+1245', '12:45:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1098, 'posix/Pacific/Chuuk', '+10', '10:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1099, 'posix/Pacific/Easter', '-05', '-05:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1100, 'posix/Pacific/Efate', '+11', '11:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1101, 'posix/Pacific/Enderbury', '+13', '13:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1102, 'posix/Pacific/Fakaofo', '+13', '13:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1103, 'posix/Pacific/Fiji', '+12', '12:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1104, 'posix/Pacific/Funafuti', '+12', '12:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1105, 'posix/Pacific/Galapagos', '-06', '-06:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1106, 'posix/Pacific/Gambier', '-09', '-09:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1107, 'posix/Pacific/Guadalcanal', '+11', '11:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1108, 'posix/Pacific/Guam', 'ChST', '10:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1109, 'posix/Pacific/Honolulu', 'HST', '-10:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1110, 'posix/Pacific/Johnston', 'HST', '-10:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1111, 'posix/Pacific/Kiritimati', '+14', '14:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1112, 'posix/Pacific/Kosrae', '+11', '11:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1113, 'posix/Pacific/Kwajalein', '+12', '12:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1114, 'posix/Pacific/Majuro', '+12', '12:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1115, 'posix/Pacific/Marquesas', '-0930', '-09:30:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1116, 'posix/Pacific/Midway', 'SST', '-11:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1117, 'posix/Pacific/Nauru', '+12', '12:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1118, 'posix/Pacific/Niue', '-11', '-11:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1119, 'posix/Pacific/Norfolk', '+11', '11:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1120, 'posix/Pacific/Noumea', '+11', '11:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1121, 'posix/Pacific/Pago_Pago', 'SST', '-11:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1122, 'posix/Pacific/Palau', '+09', '09:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1123, 'posix/Pacific/Pitcairn', '-08', '-08:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1124, 'posix/Pacific/Pohnpei', '+11', '11:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1125, 'posix/Pacific/Ponape', '+11', '11:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1126, 'posix/Pacific/Port_Moresby', '+10', '10:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1127, 'posix/Pacific/Rarotonga', '-10', '-10:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1128, 'posix/Pacific/Saipan', 'ChST', '10:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1129, 'posix/Pacific/Samoa', 'SST', '-11:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1130, 'posix/Pacific/Tahiti', '-10', '-10:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1131, 'posix/Pacific/Tarawa', '+12', '12:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1132, 'posix/Pacific/Tongatapu', '+13', '13:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1133, 'posix/Pacific/Truk', '+10', '10:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1134, 'posix/Pacific/Wake', '+12', '12:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1135, 'posix/Pacific/Wallis', '+12', '12:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1136, 'posix/Pacific/Yap', '+10', '10:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1137, 'posix/Poland', 'CEST', '02:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1138, 'posix/Portugal', 'WEST', '01:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1139, 'posix/PRC', 'CST', '08:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1140, 'posix/PST8PDT', 'PDT', '-07:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1141, 'posix/ROC', 'CST', '08:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1142, 'posix/ROK', 'KST', '09:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1143, 'posixrules', 'EDT', '-04:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1144, 'posix/Singapore', '+08', '08:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1145, 'posix/SystemV/AST4', 'AST', '-04:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1146, 'posix/SystemV/AST4ADT', 'ADT', '-03:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1147, 'posix/SystemV/CST6', 'CST', '-06:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1148, 'posix/SystemV/CST6CDT', 'CDT', '-05:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1149, 'posix/SystemV/EST5', 'EST', '-05:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1150, 'posix/SystemV/EST5EDT', 'EDT', '-04:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1151, 'posix/SystemV/HST10', 'HST', '-10:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1152, 'posix/SystemV/MST7', 'MST', '-07:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1153, 'posix/SystemV/MST7MDT', 'MDT', '-06:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1154, 'posix/SystemV/PST8', '-08', '-08:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1155, 'posix/SystemV/PST8PDT', 'PDT', '-07:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1156, 'posix/SystemV/YST9', '-09', '-09:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1157, 'posix/SystemV/YST9YDT', 'AKDT', '-08:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1158, 'posix/Turkey', '+03', '03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1159, 'posix/UCT', 'UCT', '00:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1160, 'posix/Universal', 'UTC', '00:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1161, 'posix/US/Alaska', 'AKDT', '-08:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1162, 'posix/US/Aleutian', 'HDT', '-09:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1163, 'posix/US/Arizona', 'MST', '-07:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1164, 'posix/US/Central', 'CDT', '-05:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1165, 'posix/US/Eastern', 'EDT', '-04:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1166, 'posix/US/East-Indiana', 'EDT', '-04:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1167, 'posix/US/Hawaii', 'HST', '-10:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1168, 'posix/US/Indiana-Starke', 'CDT', '-05:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1169, 'posix/US/Michigan', 'EDT', '-04:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1170, 'posix/US/Mountain', 'MDT', '-06:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1171, 'posix/US/Pacific', 'PDT', '-07:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1172, 'posix/US/Pacific-New', 'PDT', '-07:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1173, 'posix/US/Samoa', 'SST', '-11:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1174, 'posix/UTC', 'UTC', '00:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1175, 'posix/WET', 'WEST', '01:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1176, 'posix/W-SU', 'MSK', '03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1177, 'posix/Zulu', 'UTC', '00:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1178, 'PRC', 'CST', '08:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1179, 'PST8PDT', 'PDT', '-07:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1180, 'ROC', 'CST', '08:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1181, 'ROK', 'KST', '09:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1182, 'Singapore', '+08', '08:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1183, 'SystemV/AST4', 'AST', '-04:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1184, 'SystemV/AST4ADT', 'ADT', '-03:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1185, 'SystemV/CST6', 'CST', '-06:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1186, 'SystemV/CST6CDT', 'CDT', '-05:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1187, 'SystemV/EST5', 'EST', '-05:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1188, 'SystemV/EST5EDT', 'EDT', '-04:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1189, 'SystemV/HST10', 'HST', '-10:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1190, 'SystemV/MST7', 'MST', '-07:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1191, 'SystemV/MST7MDT', 'MDT', '-06:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1192, 'SystemV/PST8', '-08', '-08:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1193, 'SystemV/PST8PDT', 'PDT', '-07:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1194, 'SystemV/YST9', '-09', '-09:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1195, 'SystemV/YST9YDT', 'AKDT', '-08:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1196, 'Turkey', '+03', '03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1197, 'UCT', 'UCT', '00:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1198, 'Universal', 'UTC', '00:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1199, 'US/Alaska', 'AKDT', '-08:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1200, 'US/Aleutian', 'HDT', '-09:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1201, 'US/Arizona', 'MST', '-07:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1202, 'US/Central', 'CDT', '-05:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1203, 'US/Eastern', 'EDT', '-04:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1204, 'US/East-Indiana', 'EDT', '-04:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1205, 'US/Hawaii', 'HST', '-10:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1206, 'US/Indiana-Starke', 'CDT', '-05:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1207, 'US/Michigan', 'EDT', '-04:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1208, 'US/Mountain', 'MDT', '-06:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1209, 'US/Pacific', 'PDT', '-07:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1210, 'US/Pacific-New', 'PDT', '-07:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1211, 'US/Samoa', 'SST', '-11:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1212, 'WET', 'WEST', '01:00:00', true);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1213, 'W-SU', 'MSK', '03:00:00', false);
INSERT INTO sys.timezones (id, name, abbrev, utc_offset, is_dst) VALUES (1214, 'Zulu', 'UTC', '00:00:00', false);


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
-- Name: events_id_seq; Type: SEQUENCE SET; Schema: sys; Owner: senid
--

SELECT pg_catalog.setval('sys.events_id_seq', 1, false);


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
-- Name: timezones_id_seq; Type: SEQUENCE SET; Schema: sys; Owner: senid
--

SELECT pg_catalog.setval('sys.timezones_id_seq', 1214, true);


--
-- PostgreSQL database dump complete
--

