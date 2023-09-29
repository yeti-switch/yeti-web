--
-- PostgreSQL database dump
--

-- Dumped from database version 9.4.13
-- Dumped by pg_dump version 9.4.13
-- Started on 2017-08-20 20:56:17 EEST

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = reports, pg_catalog;

--
-- TOC entry 2566 (class 0 OID 22119)
-- Dependencies: 233
-- Data for Name: cdr_custom_report; Type: TABLE DATA; Schema: reports; Owner: yeti
--



--
-- TOC entry 2567 (class 0 OID 22125)
-- Dependencies: 234
-- Data for Name: cdr_custom_report_data; Type: TABLE DATA; Schema: reports; Owner: yeti
--



--
-- TOC entry 2620 (class 0 OID 0)
-- Dependencies: 235
-- Name: cdr_custom_report_data_id_seq; Type: SEQUENCE SET; Schema: reports; Owner: yeti
--

SELECT pg_catalog.setval('cdr_custom_report_data_id_seq', 30, true);


--
-- TOC entry 2621 (class 0 OID 0)
-- Dependencies: 236
-- Name: cdr_custom_report_id_seq; Type: SEQUENCE SET; Schema: reports; Owner: yeti
--

SELECT pg_catalog.setval('cdr_custom_report_id_seq', 81, true);


--
-- TOC entry 2570 (class 0 OID 22135)
-- Dependencies: 237
-- Data for Name: cdr_custom_report_schedulers; Type: TABLE DATA; Schema: reports; Owner: yeti
--



--
-- TOC entry 2622 (class 0 OID 0)
-- Dependencies: 238
-- Name: cdr_custom_report_schedulers_id_seq; Type: SEQUENCE SET; Schema: reports; Owner: yeti
--

SELECT pg_catalog.setval('cdr_custom_report_schedulers_id_seq', 1, false);


--
-- TOC entry 2572 (class 0 OID 22143)
-- Dependencies: 239
-- Data for Name: cdr_interval_report; Type: TABLE DATA; Schema: reports; Owner: yeti
--



--
-- TOC entry 2573 (class 0 OID 22149)
-- Dependencies: 240
-- Data for Name: cdr_interval_report_aggregator; Type: TABLE DATA; Schema: reports; Owner: yeti
--

INSERT INTO cdr_interval_report_aggregator VALUES (1, 'Sum');
INSERT INTO cdr_interval_report_aggregator VALUES (2, 'Count');
INSERT INTO cdr_interval_report_aggregator VALUES (3, 'Avg');
INSERT INTO cdr_interval_report_aggregator VALUES (4, 'Max');
INSERT INTO cdr_interval_report_aggregator VALUES (5, 'Min');


--
-- TOC entry 2574 (class 0 OID 22155)
-- Dependencies: 241
-- Data for Name: cdr_interval_report_data; Type: TABLE DATA; Schema: reports; Owner: yeti
--



--
-- TOC entry 2623 (class 0 OID 0)
-- Dependencies: 242
-- Name: cdr_interval_report_data_id_seq; Type: SEQUENCE SET; Schema: reports; Owner: yeti
--

SELECT pg_catalog.setval('cdr_interval_report_data_id_seq', 1, false);


--
-- TOC entry 2624 (class 0 OID 0)
-- Dependencies: 243
-- Name: cdr_interval_report_id_seq; Type: SEQUENCE SET; Schema: reports; Owner: yeti
--

SELECT pg_catalog.setval('cdr_interval_report_id_seq', 16, true);


--
-- TOC entry 2577 (class 0 OID 22165)
-- Dependencies: 244
-- Data for Name: cdr_interval_report_schedulers; Type: TABLE DATA; Schema: reports; Owner: yeti
--



--
-- TOC entry 2625 (class 0 OID 0)
-- Dependencies: 245
-- Name: cdr_interval_report_schedulers_id_seq; Type: SEQUENCE SET; Schema: reports; Owner: yeti
--

SELECT pg_catalog.setval('cdr_interval_report_schedulers_id_seq', 1, false);


--
-- TOC entry 2579 (class 0 OID 22173)
-- Dependencies: 246
-- Data for Name: customer_traffic_report; Type: TABLE DATA; Schema: reports; Owner: yeti
--



--
-- TOC entry 2580 (class 0 OID 22176)
-- Dependencies: 247
-- Data for Name: customer_traffic_report_data_by_destination; Type: TABLE DATA; Schema: reports; Owner: yeti
--



--
-- TOC entry 2626 (class 0 OID 0)
-- Dependencies: 248
-- Name: customer_traffic_report_data_by_destination_id_seq; Type: SEQUENCE SET; Schema: reports; Owner: yeti
--

SELECT pg_catalog.setval('customer_traffic_report_data_by_destination_id_seq', 1, false);


--
-- TOC entry 2582 (class 0 OID 22184)
-- Dependencies: 249
-- Data for Name: customer_traffic_report_data_by_vendor; Type: TABLE DATA; Schema: reports; Owner: yeti
--



--
-- TOC entry 2583 (class 0 OID 22190)
-- Dependencies: 250
-- Data for Name: customer_traffic_report_data_full; Type: TABLE DATA; Schema: reports; Owner: yeti
--



--
-- TOC entry 2627 (class 0 OID 0)
-- Dependencies: 251
-- Name: customer_traffic_report_data_full_id_seq; Type: SEQUENCE SET; Schema: reports; Owner: yeti
--

SELECT pg_catalog.setval('customer_traffic_report_data_full_id_seq', 1, false);


--
-- TOC entry 2628 (class 0 OID 0)
-- Dependencies: 252
-- Name: customer_traffic_report_data_id_seq; Type: SEQUENCE SET; Schema: reports; Owner: yeti
--

SELECT pg_catalog.setval('customer_traffic_report_data_id_seq', 1, false);


--
-- TOC entry 2629 (class 0 OID 0)
-- Dependencies: 253
-- Name: customer_traffic_report_id_seq; Type: SEQUENCE SET; Schema: reports; Owner: yeti
--

SELECT pg_catalog.setval('customer_traffic_report_id_seq', 1, false);


--
-- TOC entry 2587 (class 0 OID 22202)
-- Dependencies: 254
-- Data for Name: customer_traffic_report_schedulers; Type: TABLE DATA; Schema: reports; Owner: yeti
--



--
-- TOC entry 2630 (class 0 OID 0)
-- Dependencies: 255
-- Name: customer_traffic_report_schedulers_id_seq; Type: SEQUENCE SET; Schema: reports; Owner: yeti
--

SELECT pg_catalog.setval('customer_traffic_report_schedulers_id_seq', 1, false);


--
-- TOC entry 2593 (class 0 OID 22221)
-- Dependencies: 260
-- Data for Name: scheduler_periods; Type: TABLE DATA; Schema: reports; Owner: yeti
--

INSERT INTO scheduler_periods VALUES (1, 'Hourly');
INSERT INTO scheduler_periods VALUES (2, 'Daily');
INSERT INTO scheduler_periods VALUES (3, 'Weekly');
INSERT INTO scheduler_periods VALUES (4, 'BiWeekly');
INSERT INTO scheduler_periods VALUES (5, 'Monthly');


--
-- TOC entry 2594 (class 0 OID 22227)
-- Dependencies: 261
-- Data for Name: vendor_traffic_report; Type: TABLE DATA; Schema: reports; Owner: yeti
--



--
-- TOC entry 2595 (class 0 OID 22230)
-- Dependencies: 262
-- Data for Name: vendor_traffic_report_data; Type: TABLE DATA; Schema: reports; Owner: yeti
--



--
-- TOC entry 2633 (class 0 OID 0)
-- Dependencies: 263
-- Name: vendor_traffic_report_data_id_seq; Type: SEQUENCE SET; Schema: reports; Owner: yeti
--

SELECT pg_catalog.setval('vendor_traffic_report_data_id_seq', 1, false);


--
-- TOC entry 2634 (class 0 OID 0)
-- Dependencies: 264
-- Name: vendor_traffic_report_id_seq; Type: SEQUENCE SET; Schema: reports; Owner: yeti
--

SELECT pg_catalog.setval('vendor_traffic_report_id_seq', 1, false);


--
-- TOC entry 2598 (class 0 OID 22240)
-- Dependencies: 265
-- Data for Name: vendor_traffic_report_schedulers; Type: TABLE DATA; Schema: reports; Owner: yeti
--



--
-- TOC entry 2635 (class 0 OID 0)
-- Dependencies: 266
-- Name: vendor_traffic_report_schedulers_id_seq; Type: SEQUENCE SET; Schema: reports; Owner: yeti
--

SELECT pg_catalog.setval('vendor_traffic_report_schedulers_id_seq', 1, false);


-- Completed on 2017-08-20 20:56:17 EEST

--
-- PostgreSQL database dump complete
--

