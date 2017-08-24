--
-- PostgreSQL database dump
--

-- Dumped from database version 9.4.13
-- Dumped by pg_dump version 9.4.13
-- Started on 2017-08-20 20:32:36 EEST

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = gui, pg_catalog;

--
-- TOC entry 3845 (class 0 OID 19581)
-- Dependencies: 401
-- Data for Name: admin_users; Type: TABLE DATA; Schema: gui; Owner: yeti
--

INSERT INTO admin_users VALUES (3, '$2a$10$2346aIc.UfYbcoRUET4Fwuaqg573IrYcK2dnmxtdg2JC6OqJxK4U2', NULL, NULL, NULL, 479, '2017-08-16 12:10:32.83527+03', '2014-10-13 11:34:08.58971+03', '127.0.0.1', '127.0.0.1', '2012-09-07 15:20:21.93699+03', '2017-08-16 12:10:32.836658+03', 1, true, 'admin', NULL, false, '{}', '{"contractors":30,"accounts":30,"system_countries":30,"routing_groups":30,"importing_routing_groups":30,"jobs":30,"background_tasks":30,"cdrs":30}', '{}');


--
-- TOC entry 3852 (class 0 OID 0)
-- Dependencies: 402
-- Name: admin_users_id_seq; Type: SEQUENCE SET; Schema: gui; Owner: yeti
--

SELECT pg_catalog.setval('admin_users_id_seq', 11, true);


-- Completed on 2017-08-20 20:32:36 EEST

--
-- PostgreSQL database dump complete
--

