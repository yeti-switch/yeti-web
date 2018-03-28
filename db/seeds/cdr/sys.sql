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

insert into sys.amount_round_modes(id,name) values(1, 'Disable rounding');
insert into sys.amount_round_modes(id,name) values(2, 'Always UP');
insert into sys.amount_round_modes(id,name) values(3, 'Always DOWN');
insert into sys.amount_round_modes(id,name) values(4, 'Math rules');

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
INSERT INTO cdr_tables VALUES (9, 'cdr.cdr_201712', true, true, '2017-12-01', '2018-01-01', true);
INSERT INTO cdr_tables VALUES (10, 'cdr.cdr_201801', true, true, '2018-01-01', '2018-02-01', true);
INSERT INTO cdr_tables VALUES (11, 'cdr.cdr_201802', true, true, '2018-02-01', '2018-03-01', true);
INSERT INTO cdr_tables VALUES (12, 'cdr.cdr_201803', true, true, '2018-03-01', '2018-04-01', true);
INSERT INTO cdr_tables VALUES (13, 'cdr.cdr_201804', true, true, '2018-04-01', '2018-05-01', true);

--
-- TOC entry 2514 (class 0 OID 0)
-- Dependencies: 295
-- Name: cdr_tables_id_seq; Type: SEQUENCE SET; Schema: sys; Owner: yeti
--

SELECT pg_catalog.setval('cdr_tables_id_seq', 13, true);


--
-- TOC entry 2505 (class 0 OID 22336)
-- Dependencies: 296
-- Data for Name: config; Type: TABLE DATA; Schema: sys; Owner: yeti
--

INSERT INTO config VALUES (1, 1);


-- Completed on 2017-08-20 20:58:48 EEST

--
-- PostgreSQL database dump complete
--

