--
-- PostgreSQL database dump
--

-- Dumped from database version 9.4.13
-- Dumped by pg_dump version 9.4.13
-- Started on 2017-08-20 20:58:48 EEST

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = sys, pg_catalog;

--
-- TOC entry 2502 (class 0 OID 22319)
-- Dependencies: 293
-- Data for Name: call_duration_round_modes; Type: TABLE DATA; Schema: sys; Owner: yeti
--

INSERT INTO call_duration_round_modes VALUES (3, 'Always UP');
INSERT INTO call_duration_round_modes VALUES (2, 'Always DOWN');
INSERT INTO call_duration_round_modes VALUES (1, 'Math rules(up if >=0.5)');


--
-- TOC entry 2503 (class 0 OID 22325)
-- Dependencies: 294
-- Data for Name: cdr_tables; Type: TABLE DATA; Schema: sys; Owner: yeti
--

INSERT INTO cdr_tables VALUES (2, 'cdr.cdr_201408', true, true, '2014-08-01', '2014-09-01', true);
INSERT INTO cdr_tables VALUES (3, 'cdr.cdr_201409', true, true, '2014-09-01', '2014-10-01', true);
INSERT INTO cdr_tables VALUES (4, 'cdr.cdr_201410', true, true, '2014-10-01', '2014-11-01', true);
INSERT INTO cdr_tables VALUES (5, 'cdr.cdr_201411', true, true, '2014-11-01', '2014-12-01', true);
INSERT INTO cdr_tables VALUES (6, 'cdr.cdr_201710', true, true, '2017-10-01', '2017-11-01', true);
INSERT INTO cdr_tables VALUES (7, 'cdr.cdr_201709', true, true, '2017-09-01', '2017-10-01', true);
INSERT INTO cdr_tables VALUES (8, 'cdr.cdr_201708', true, true, '2017-08-01', '2017-09-01', true);


--
-- TOC entry 2514 (class 0 OID 0)
-- Dependencies: 295
-- Name: cdr_tables_id_seq; Type: SEQUENCE SET; Schema: sys; Owner: yeti
--

SELECT pg_catalog.setval('cdr_tables_id_seq', 8, true);


--
-- TOC entry 2505 (class 0 OID 22336)
-- Dependencies: 296
-- Data for Name: config; Type: TABLE DATA; Schema: sys; Owner: yeti
--

INSERT INTO config VALUES (1, 1);


--
-- TOC entry 2506 (class 0 OID 22340)
-- Dependencies: 297
-- Data for Name: version; Type: TABLE DATA; Schema: sys; Owner: yeti
--

INSERT INTO version VALUES (1, 1, '2014-10-13 13:56:57.508299+03', 'Initial CDR db package');
INSERT INTO version VALUES (2, 2, '2017-08-14 12:58:39.391834+03', 'New billing event format');
INSERT INTO version VALUES (3, 3, '2017-08-14 12:58:39.835261+03', 'Country/Network prefixes');
INSERT INTO version VALUES (4, 4, '2017-08-14 12:58:39.957124+03', 'Traffic reports generation');
INSERT INTO version VALUES (5, 5, '2017-08-14 12:58:40.55976+03', 'Additional rtp counters in CDR');
INSERT INTO version VALUES (6, 6, '2017-08-14 12:58:40.695044+03', 'JSON serialization for  rtp counters. Need for switch version >= 138');
INSERT INTO version VALUES (7, 7, '2017-08-14 12:58:40.834548+03', 'CDR tables fix.');
INSERT INTO version VALUES (8, 8, '2017-08-14 12:58:41.394636+03', 'Invoices fix');
INSERT INTO version VALUES (9, 9, '2017-08-14 12:58:41.780102+03', 'Writing exteneded call statistic');
INSERT INTO version VALUES (10, 10, '2017-08-14 12:58:42.070991+03', 'Call statistic aggregation');
INSERT INTO version VALUES (11, 11, '2017-08-14 12:58:42.35461+03', 'Traffic amount statistic for accounts');
INSERT INTO version VALUES (12, 12, '2017-08-14 12:58:42.658154+03', 'Customer reports');
INSERT INTO version VALUES (13, 13, '2017-08-14 12:58:42.912174+03', 'Migration to timestamp with timezone');
INSERT INTO version VALUES (14, 14, '2017-08-14 12:58:45.561229+03', 'Vendor reports');
INSERT INTO version VALUES (15, 15, '2017-08-14 12:58:45.935495+03', 'Invoices,Static routes');
INSERT INTO version VALUES (16, 16, '2017-08-14 12:58:46.381962+03', 'CDR partitioning FIX');
INSERT INTO version VALUES (17, 17, '2017-08-14 12:58:46.601519+03', 'Call length rounding');
INSERT INTO version VALUES (18, 18, '2017-08-14 12:58:46.879751+03', 'Reports refactoring');
INSERT INTO version VALUES (19, 19, '2017-08-14 12:58:47.013441+03', 'Realtime stats fix');
INSERT INTO version VALUES (20, 20, '2017-08-14 12:58:47.127422+03', 'Schedulers for reports');
INSERT INTO version VALUES (21, 21, '2017-08-14 12:58:47.621126+03', 'LNP configuration and billing fixes');
INSERT INTO version VALUES (22, 22, '2017-08-14 12:58:47.787497+03', 'PDD distribution time');
INSERT INTO version VALUES (23, 23, '2017-08-14 12:58:47.904414+03', 'PDD distribution time');
INSERT INTO version VALUES (24, 24, '2017-08-14 12:58:48.091898+03', 'PDF document storage');
INSERT INTO version VALUES (25, 25, '2017-08-14 12:58:48.2028+03', 'Statistic fix');
INSERT INTO version VALUES (26, 26, '2017-08-14 12:58:48.31968+03', 'Invoices fix');
INSERT INTO version VALUES (27, 27, '2017-08-14 12:58:48.436146+03', 'New CDR writing');
INSERT INTO version VALUES (28, 28, '2017-08-14 12:58:48.553298+03', 'Calls duration for invoice');
INSERT INTO version VALUES (29, 29, '2017-08-14 12:58:48.855308+03', 'CDR timing fixes');
INSERT INTO version VALUES (30, 30, '2017-08-14 12:58:48.985693+03', 'Reports refactoring');
INSERT INTO version VALUES (31, 31, '2017-08-14 12:58:49.113264+03', 'Reports refactoring');
INSERT INTO version VALUES (32, 32, '2017-08-14 12:58:49.36197+03', 'Invoices refactoring');
INSERT INTO version VALUES (33, 33, '2017-08-14 12:58:49.478725+03', 'Invoice types');
INSERT INTO version VALUES (34, 34, '2017-08-14 12:58:49.670779+03', 'Reports refactoring');
INSERT INTO version VALUES (35, 35, '2017-08-14 12:58:49.786689+03', 'Reports schedulers fix');
INSERT INTO version VALUES (36, 36, '2017-08-14 12:58:49.903589+03', 'Stats for destinations');
INSERT INTO version VALUES (37, 37, '2017-08-14 12:58:50.019387+03', 'fix types');
INSERT INTO version VALUES (38, 38, '2017-08-14 12:58:50.262579+03', 'resources/active resources fields for node 206');
INSERT INTO version VALUES (39, 39, '2017-08-14 12:58:50.38437+03', 'remove old CDR SP');
INSERT INTO version VALUES (40, 40, '2017-08-14 12:58:50.491447+03', 'Audio recording flag');
INSERT INTO version VALUES (41, 41, '2017-08-14 12:58:50.608382+03', 'failed resources');
INSERT INTO version VALUES (42, 42, '2017-08-14 12:58:50.742199+03', 'Support for new SEMS. DTMF events');
INSERT INTO version VALUES (43, 43, '2017-08-14 12:58:50.886696+03', 'Support for from/to/ruri domains');
INSERT INTO version VALUES (44, 44, '2017-08-14 12:58:51.016701+03', 'Remove DTMF logging');
INSERT INTO version VALUES (45, 45, '2017-08-14 12:58:51.142005+03', 'Routing_tag');
INSERT INTO version VALUES (46, 46, '2017-08-14 12:58:51.284443+03', 'Transport protocols');
INSERT INTO version VALUES (47, 47, '2017-08-14 12:58:51.416808+03', 'Additional invoice grouping');
INSERT INTO version VALUES (48, 48, '2017-08-14 12:58:51.599968+03', 'Save system versions');
INSERT INTO version VALUES (49, 49, '2017-08-14 12:58:51.725328+03', 'More fields for CDR data type');


--
-- TOC entry 2515 (class 0 OID 0)
-- Dependencies: 298
-- Name: version_id_seq; Type: SEQUENCE SET; Schema: sys; Owner: yeti
--

SELECT pg_catalog.setval('version_id_seq', 49, true);


-- Completed on 2017-08-20 20:58:48 EEST

--
-- PostgreSQL database dump complete
--

