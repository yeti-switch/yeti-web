--
-- PostgreSQL database dump
--

-- Dumped from database version 13.12 (Debian 13.12-1.pgdg110+1)
-- Dumped by pg_dump version 13.12 (Debian 13.12-1.pgdg110+1)

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
-- Data for Name: invoices; Type: TABLE DATA; Schema: billing; Owner: senid
--



--
-- Data for Name: invoice_documents; Type: TABLE DATA; Schema: billing; Owner: senid
--



--
-- Data for Name: invoice_originated_destinations; Type: TABLE DATA; Schema: billing; Owner: senid
--



--
-- Data for Name: invoice_originated_networks; Type: TABLE DATA; Schema: billing; Owner: senid
--



--
-- Data for Name: invoice_terminated_destinations; Type: TABLE DATA; Schema: billing; Owner: senid
--



--
-- Data for Name: invoice_terminated_networks; Type: TABLE DATA; Schema: billing; Owner: senid
--



--
-- Name: invoice_documents_id_seq; Type: SEQUENCE SET; Schema: billing; Owner: senid
--

SELECT pg_catalog.setval('billing.invoice_documents_id_seq', 1, false);


--
-- Name: invoice_originated_destinations_id_seq; Type: SEQUENCE SET; Schema: billing; Owner: senid
--

SELECT pg_catalog.setval('billing.invoice_originated_destinations_id_seq', 1, false);


--
-- Name: invoice_originated_networks_id_seq; Type: SEQUENCE SET; Schema: billing; Owner: senid
--

SELECT pg_catalog.setval('billing.invoice_originated_networks_id_seq', 1, false);


--
-- Name: invoice_terminated_destinations_id_seq; Type: SEQUENCE SET; Schema: billing; Owner: senid
--

SELECT pg_catalog.setval('billing.invoice_terminated_destinations_id_seq', 1, false);


--
-- Name: invoice_terminated_networks_id_seq; Type: SEQUENCE SET; Schema: billing; Owner: senid
--

SELECT pg_catalog.setval('billing.invoice_terminated_networks_id_seq', 1, false);


--
-- Name: invoices_id_seq; Type: SEQUENCE SET; Schema: billing; Owner: senid
--

SELECT pg_catalog.setval('billing.invoices_id_seq', 1, false);


--
-- PostgreSQL database dump complete
--

