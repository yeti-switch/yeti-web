--
-- PostgreSQL database dump
--

-- Dumped from database version 9.4.13
-- Dumped by pg_dump version 9.4.13
-- Started on 2017-08-20 19:13:57 EEST

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = billing, pg_catalog;

--
-- TOC entry 3866 (class 0 OID 18429)
-- Dependencies: 269
-- Data for Name: accounts; Type: TABLE DATA; Schema: billing; Owner: yeti
--



--
-- TOC entry 3883 (class 0 OID 0)
-- Dependencies: 284
-- Name: accounts_id_seq; Type: SEQUENCE SET; Schema: billing; Owner: yeti
--

SELECT pg_catalog.setval('accounts_id_seq', 19, true);


--
-- TOC entry 3868 (class 0 OID 19043)
-- Dependencies: 285
-- Data for Name: cdr_batches; Type: TABLE DATA; Schema: billing; Owner: yeti
--



--
-- TOC entry 3869 (class 0 OID 19050)
-- Dependencies: 286
-- Data for Name: invoice_periods; Type: TABLE DATA; Schema: billing; Owner: yeti
--

INSERT INTO invoice_periods (id, name) VALUES (1, 'Daily');
INSERT INTO invoice_periods (id, name) VALUES (2, 'Weekly');
INSERT INTO invoice_periods (id, name) VALUES (4, 'Monthly');
INSERT INTO invoice_periods (id, name) VALUES (3, 'BiWeekly');
INSERT INTO invoice_periods (id, name) VALUES (5, 'BiWeekly. Split by new month');
INSERT INTO invoice_periods (id, name) VALUES (6, 'Weekly. Split by new month');


--
-- TOC entry 3884 (class 0 OID 0)
-- Dependencies: 287
-- Name: invoice_periods_id_seq; Type: SEQUENCE SET; Schema: billing; Owner: yeti
--

SELECT pg_catalog.setval('invoice_periods_id_seq', 7, true);


--
-- TOC entry 3871 (class 0 OID 19058)
-- Dependencies: 288
-- Data for Name: invoice_templates; Type: TABLE DATA; Schema: billing; Owner: yeti
--



--
-- TOC entry 3885 (class 0 OID 0)
-- Dependencies: 289
-- Name: invoices_templates_id_seq; Type: SEQUENCE SET; Schema: billing; Owner: yeti
--

SELECT pg_catalog.setval('invoices_templates_id_seq', 2, true);


--
-- TOC entry 3873 (class 0 OID 19066)
-- Dependencies: 290
-- Data for Name: payments; Type: TABLE DATA; Schema: billing; Owner: yeti
--



--
-- TOC entry 3886 (class 0 OID 0)
-- Dependencies: 291
-- Name: payments_id_seq; Type: SEQUENCE SET; Schema: billing; Owner: yeti
--

SELECT pg_catalog.setval('payments_id_seq', 30, true);


-- Completed on 2017-08-20 19:13:57 EEST

--
-- PostgreSQL database dump complete
--
