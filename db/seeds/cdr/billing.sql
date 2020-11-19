--
-- PostgreSQL database dump
--

-- Dumped from database version 9.4.13
-- Dumped by pg_dump version 9.4.13
-- Started on 2017-08-20 20:42:11 EEST

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = billing, pg_catalog;

--
-- TOC entry 2516 (class 0 OID 21862)
-- Dependencies: 190
-- Data for Name: invoice_destinations; Type: TABLE DATA; Schema: billing; Owner: yeti
--



--
-- TOC entry 2534 (class 0 OID 0)
-- Dependencies: 191
-- Name: invoice_destinations_id_seq; Type: SEQUENCE SET; Schema: billing; Owner: yeti
--

SELECT pg_catalog.setval('invoice_destinations_id_seq', 1, false);


--
-- TOC entry 2518 (class 0 OID 21870)
-- Dependencies: 192
-- Data for Name: invoice_documents; Type: TABLE DATA; Schema: billing; Owner: yeti
--



--
-- TOC entry 2535 (class 0 OID 0)
-- Dependencies: 193
-- Name: invoice_documents_id_seq; Type: SEQUENCE SET; Schema: billing; Owner: yeti
--

SELECT pg_catalog.setval('invoice_documents_id_seq', 1, false);


--
-- TOC entry 2520 (class 0 OID 21878)
-- Dependencies: 194
-- Data for Name: invoice_networks; Type: TABLE DATA; Schema: billing; Owner: yeti
--



--
-- TOC entry 2536 (class 0 OID 0)
-- Dependencies: 195
-- Name: invoice_networks_id_seq; Type: SEQUENCE SET; Schema: billing; Owner: yeti
--

SELECT pg_catalog.setval('invoice_networks_id_seq', 1, false);


--
-- TOC entry 2522 (class 0 OID 21886)
-- Dependencies: 196
-- Data for Name: invoice_states; Type: TABLE DATA; Schema: billing; Owner: yeti
--

INSERT INTO invoice_states VALUES (3, 'New');
INSERT INTO invoice_states VALUES (2, 'Approved');
INSERT INTO invoice_states VALUES (1, 'Pending');


--
-- TOC entry 2523 (class 0 OID 21892)
-- Dependencies: 197
-- Data for Name: invoice_types; Type: TABLE DATA; Schema: billing; Owner: yeti
--

INSERT INTO invoice_types VALUES (1, 'Manual');
INSERT INTO invoice_types VALUES (2, 'Auto. Full period');
INSERT INTO invoice_types VALUES (3, 'Auto. Partial');


--
-- TOC entry 2524 (class 0 OID 21898)
-- Dependencies: 198
-- Data for Name: invoices; Type: TABLE DATA; Schema: billing; Owner: yeti
--



--
-- TOC entry 2537 (class 0 OID 0)
-- Dependencies: 199
-- Name: invoices_id_seq; Type: SEQUENCE SET; Schema: billing; Owner: yeti
--

SELECT pg_catalog.setval('invoices_id_seq', 1, false);


-- Completed on 2017-08-20 20:42:11 EEST

--
-- PostgreSQL database dump complete
--

