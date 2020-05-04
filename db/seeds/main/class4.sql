--
-- PostgreSQL database dump
--

-- Dumped from database version 9.4.13
-- Dumped by pg_dump version 9.4.13
-- Started on 2017-08-20 19:12:27 EEST

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = class4, pg_catalog;

--
-- TOC entry 4309 (class 0 OID 19075)
-- Dependencies: 292
-- Data for Name: area_prefixes; Type: TABLE DATA; Schema: class4; Owner: yeti
--



--
-- TOC entry 4428 (class 0 OID 0)
-- Dependencies: 293
-- Name: area_prefixes_id_seq; Type: SEQUENCE SET; Schema: class4; Owner: yeti
--

SELECT pg_catalog.setval('area_prefixes_id_seq', 1, false);


--
-- TOC entry 4311 (class 0 OID 19083)
-- Dependencies: 294
-- Data for Name: areas; Type: TABLE DATA; Schema: class4; Owner: yeti
--



--
-- TOC entry 4429 (class 0 OID 0)
-- Dependencies: 295
-- Name: areas_id_seq; Type: SEQUENCE SET; Schema: class4; Owner: yeti
--

SELECT pg_catalog.setval('areas_id_seq', 1, false);


--
-- TOC entry 4430 (class 0 OID 0)
-- Dependencies: 297
-- Name: blacklist_items_id_seq; Type: SEQUENCE SET; Schema: class4; Owner: yeti
--

SELECT pg_catalog.setval('blacklist_items_id_seq', 1, true);


--
-- TOC entry 4432 (class 0 OID 0)
-- Dependencies: 301
-- Name: codec_group_codecs_id_seq; Type: SEQUENCE SET; Schema: class4; Owner: yeti
--

SELECT pg_catalog.setval('codec_group_codecs_id_seq', 93, true);


--
-- TOC entry 4319 (class 0 OID 19118)
-- Dependencies: 302
-- Data for Name: codec_groups; Type: TABLE DATA; Schema: class4; Owner: yeti
--

INSERT INTO codec_groups (id, name) VALUES (1, 'Default codec group');


--
-- TOC entry 4433 (class 0 OID 0)
-- Dependencies: 303
-- Name: codec_groups_id_seq; Type: SEQUENCE SET; Schema: class4; Owner: yeti
--

SELECT pg_catalog.setval('codec_groups_id_seq', 11, true);


--
-- TOC entry 4321 (class 0 OID 19126)
-- Dependencies: 304
-- Data for Name: codecs; Type: TABLE DATA; Schema: class4; Owner: yeti
--

INSERT INTO codecs (id, name) VALUES (6, 'telephone-event/8000');
INSERT INTO codecs (id, name) VALUES (7, 'G723/8000');
INSERT INTO codecs (id, name) VALUES (8, 'G729/8000');
INSERT INTO codecs (id, name) VALUES (9, 'PCMU/8000');
INSERT INTO codecs (id, name) VALUES (10, 'PCMA/8000');
INSERT INTO codecs (id, name) VALUES (11, 'iLBC/8000');
INSERT INTO codecs (id, name) VALUES (12, 'speex/8000');
INSERT INTO codecs (id, name) VALUES (13, 'GSM/8000');
INSERT INTO codecs (id, name) VALUES (14, 'G726-32/8000');
INSERT INTO codecs (id, name) VALUES (15, 'G721/8000');
INSERT INTO codecs (id, name) VALUES (16, 'G726-24/8000');
INSERT INTO codecs (id, name) VALUES (17, 'G726-40/8000');
INSERT INTO codecs (id, name) VALUES (18, 'G726-16/8000');
INSERT INTO codecs (id, name) VALUES (19, 'L16/8000');
INSERT INTO codecs (id, name) VALUES (20, 'G722/8000');


--
-- TOC entry 4431 (class 0 OID 0)
-- Dependencies: 299
-- Name: blacklists_id_seq; Type: SEQUENCE SET; Schema: class4; Owner: yeti
--

SELECT pg_catalog.setval('blacklists_id_seq', 1, true);


--
-- TOC entry 4317 (class 0 OID 19109)
-- Dependencies: 300
-- Data for Name: codec_group_codecs; Type: TABLE DATA; Schema: class4; Owner: yeti
--

INSERT INTO codec_group_codecs (id, codec_group_id, codec_id, priority, dynamic_payload_type, format_parameters) VALUES (19, 1, 6, 64, NULL, NULL);
INSERT INTO codec_group_codecs (id, codec_group_id, codec_id, priority, dynamic_payload_type, format_parameters) VALUES (20, 1, 7, 27, NULL, NULL);
INSERT INTO codec_group_codecs (id, codec_group_id, codec_id, priority, dynamic_payload_type, format_parameters) VALUES (21, 1, 8, 66, NULL, NULL);
INSERT INTO codec_group_codecs (id, codec_group_id, codec_id, priority, dynamic_payload_type, format_parameters) VALUES (22, 1, 9, 99, NULL, NULL);
INSERT INTO codec_group_codecs (id, codec_group_id, codec_id, priority, dynamic_payload_type, format_parameters) VALUES (23, 1, 10, 40, NULL, NULL);
INSERT INTO codec_group_codecs (id, codec_group_id, codec_id, priority, dynamic_payload_type, format_parameters) VALUES (24, 1, 11, 93, NULL, NULL);
INSERT INTO codec_group_codecs (id, codec_group_id, codec_id, priority, dynamic_payload_type, format_parameters) VALUES (25, 1, 12, 32, NULL, NULL);
INSERT INTO codec_group_codecs (id, codec_group_id, codec_id, priority, dynamic_payload_type, format_parameters) VALUES (26, 1, 13, 8, NULL, NULL);
INSERT INTO codec_group_codecs (id, codec_group_id, codec_id, priority, dynamic_payload_type, format_parameters) VALUES (27, 1, 14, 68, NULL, NULL);
INSERT INTO codec_group_codecs (id, codec_group_id, codec_id, priority, dynamic_payload_type, format_parameters) VALUES (28, 1, 15, 23, NULL, NULL);
INSERT INTO codec_group_codecs (id, codec_group_id, codec_id, priority, dynamic_payload_type, format_parameters) VALUES (29, 1, 16, 33, NULL, NULL);
INSERT INTO codec_group_codecs (id, codec_group_id, codec_id, priority, dynamic_payload_type, format_parameters) VALUES (30, 1, 17, 59, NULL, NULL);
INSERT INTO codec_group_codecs (id, codec_group_id, codec_id, priority, dynamic_payload_type, format_parameters) VALUES (31, 1, 18, 95, NULL, NULL);
INSERT INTO codec_group_codecs (id, codec_group_id, codec_id, priority, dynamic_payload_type, format_parameters) VALUES (32, 1, 19, 6, NULL, NULL);


--
-- TOC entry 4434 (class 0 OID 0)
-- Dependencies: 305
-- Name: codecs_id_seq; Type: SEQUENCE SET; Schema: class4; Owner: yeti
--

SELECT pg_catalog.setval('codecs_id_seq', 20, true);


--
-- TOC entry 4323 (class 0 OID 19134)
-- Dependencies: 306
-- Data for Name: customers_auth; Type: TABLE DATA; Schema: class4; Owner: yeti
--



--
-- TOC entry 4435 (class 0 OID 0)
-- Dependencies: 307
-- Name: customers_auth_id_seq; Type: SEQUENCE SET; Schema: class4; Owner: yeti
--

SELECT pg_catalog.setval('customers_auth_id_seq', 20083, true);


--
-- TOC entry 4325 (class 0 OID 19150)
-- Dependencies: 308
-- Data for Name: destination_rate_policy; Type: TABLE DATA; Schema: class4; Owner: yeti
--

INSERT INTO destination_rate_policy (id, name) VALUES (1, 'Fixed');
INSERT INTO destination_rate_policy (id, name) VALUES (2, 'Based on used dialpeer');
INSERT INTO destination_rate_policy (id, name) VALUES (3, 'MIN(Fixed,Based on used dialpeer)');
INSERT INTO destination_rate_policy (id, name) VALUES (4, 'MAX(Fixed,Based on used dialpeer)');


--
-- TOC entry 4306 (class 0 OID 18506)
-- Dependencies: 273
-- Data for Name: destinations; Type: TABLE DATA; Schema: class4; Owner: yeti
--



--
-- TOC entry 4436 (class 0 OID 0)
-- Dependencies: 309
-- Name: destinations_id_seq; Type: SEQUENCE SET; Schema: class4; Owner: yeti
--

SELECT pg_catalog.setval('destinations_id_seq', 4201530, true);


--
-- TOC entry 4327 (class 0 OID 19158)
-- Dependencies: 310
-- Data for Name: dialpeer_next_rates; Type: TABLE DATA; Schema: class4; Owner: yeti
--



--
-- TOC entry 4437 (class 0 OID 0)
-- Dependencies: 311
-- Name: dialpeer_next_rates_id_seq; Type: SEQUENCE SET; Schema: class4; Owner: yeti
--

SELECT pg_catalog.setval('dialpeer_next_rates_id_seq', 1, false);


--
-- TOC entry 4307 (class 0 OID 18526)
-- Dependencies: 274
-- Data for Name: dialpeers; Type: TABLE DATA; Schema: class4; Owner: yeti
--

SELECT pg_catalog.setval('disconnect_code_id_seq', 122, true);


--
-- TOC entry 4305 (class 0 OID 18474)
-- Dependencies: 271
-- Data for Name: disconnect_code_namespace; Type: TABLE DATA; Schema: class4; Owner: yeti
--

INSERT INTO disconnect_code_namespace (id, name) VALUES (2, 'SIP');
INSERT INTO disconnect_code_namespace (id, name) VALUES (0, 'TM');
INSERT INTO disconnect_code_namespace (id, name) VALUES (1, 'TS');
INSERT INTO disconnect_code_namespace (id, name) VALUES (3, 'RADIUS');

--
-- TOC entry 4438 (class 0 OID 0)
-- Dependencies: 312
-- Name: dialpeers_id_seq; Type: SEQUENCE SET; Schema: class4; Owner: yeti
--

SELECT pg_catalog.setval('dialpeers_id_seq', 1376783, true);


--
-- TOC entry 4330 (class 0 OID 19171)
-- Dependencies: 313
-- Data for Name: disconnect_code; Type: TABLE DATA; Schema: class4; Owner: yeti
--

INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (126, 1, true, false, 200, 'NoAck', NULL, NULL, false, true, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (127, 1, true, false, 200, 'NoPrack', NULL, NULL, false, true, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (128, 1, true, false, 200, 'Session Timeout', NULL, NULL, false, true, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (129, 1, true, false, 200, 'Internal Error', NULL, NULL, false, true, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (113, 0, false, false, 404, 'No routes', NULL, '', false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (57, 2, false, false, 401, 'Unauthorized', NULL, NULL, false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (59, 2, false, false, 403, 'Forbidden', NULL, NULL, false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (65, 2, false, false, 409, 'Conflict', NULL, NULL, false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (66, 2, false, false, 410, 'Gone', NULL, NULL, false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (89, 2, false, false, 485, 'Ambiguous', NULL, NULL, false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (95, 2, false, false, 493, 'Undecipherable', NULL, NULL, false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (106, 2, false, false, 603, 'Decline', NULL, NULL, false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (110, 0, false, false, 403, 'Cant find customer or customer locked', NULL, NULL, false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (111, 0, false, false, 404, 'Cant find destination prefix', NULL, NULL, false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (62, 2, false, false, 406, 'Not Acceptable', NULL, NULL, false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (63, 2, false, false, 407, 'Proxy Authentication Required', NULL, NULL, false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (109, 2, true, false, 200, 'OK', NULL, '', true, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (64, 2, false, false, 408, 'Request Timeout', NULL, NULL, false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (67, 2, false, false, 412, 'Conditional Request Failed', NULL, NULL, false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (93, 2, false, false, 489, 'Bad Event', NULL, NULL, false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (68, 2, false, false, 413, 'Request Entity Too Large', NULL, NULL, false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (69, 2, false, false, 414, 'Request-URI Too Long', NULL, NULL, false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (51, 2, false, false, 300, 'Multiple Choices', NULL, NULL, false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (52, 2, false, false, 301, 'Moved Permanently', NULL, NULL, false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (53, 2, false, false, 302, 'Moved Temporarily', NULL, NULL, false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (54, 2, false, false, 305, 'Use Proxy', NULL, NULL, false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (55, 2, false, false, 380, 'Alternative Service', NULL, NULL, false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (56, 2, false, false, 400, 'Bad Request', NULL, NULL, false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (58, 2, false, false, 402, 'Payment Required', NULL, NULL, false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (61, 2, false, false, 405, 'Method Not Allowed', NULL, NULL, false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (140, 1, true, false, 488, 'Codecs group $cg not found', NULL, 'Not Acceptable Here', false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (141, 1, true, false, 488, 'Codecs not matched', NULL, 'Not Acceptable Here', false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (70, 2, false, false, 415, 'Unsupported Media Type', NULL, NULL, false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (71, 2, false, false, 416, 'Unsupported URI Scheme', NULL, NULL, false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (72, 2, false, false, 417, 'Unknown Resource-Priority', NULL, NULL, false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (73, 2, false, false, 420, 'Bad Extension', NULL, NULL, false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (74, 2, false, false, 421, 'Extension Required', NULL, NULL, false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (75, 2, false, false, 422, 'Session Interval Too Small', NULL, NULL, false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (76, 2, false, false, 423, 'Interval Too Brief', NULL, NULL, false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (77, 2, false, false, 424, 'Bad Location Information', NULL, NULL, false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (78, 2, false, false, 428, 'Use Identity Header', NULL, NULL, false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (79, 2, false, false, 429, 'Provide Referrer Identity', NULL, NULL, false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (80, 2, false, false, 433, 'Anonymity Disallowed', NULL, NULL, false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (81, 2, false, false, 436, 'Bad Identity-Info', NULL, NULL, false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (82, 2, false, false, 437, 'Unsupported Certificate', NULL, NULL, false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (83, 2, false, false, 438, 'Invalid Identity Header', NULL, NULL, false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (84, 2, false, false, 480, 'Temporarily Unavailable', NULL, NULL, false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (85, 2, false, false, 481, 'Call/Transaction Does Not Exist', NULL, NULL, false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (86, 2, false, false, 482, 'Loop Detected', NULL, NULL, false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (87, 2, false, false, 483, 'Too Many Hops', NULL, NULL, false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (88, 2, false, false, 484, 'Address Incomplete', NULL, NULL, false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (91, 2, false, false, 487, 'Request Terminated', NULL, NULL, false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (92, 2, false, false, 488, 'Not Acceptable Here', NULL, NULL, false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (94, 2, false, false, 491, 'Request Pending', NULL, NULL, false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (96, 2, false, false, 494, 'Security Agreement Required', NULL, NULL, false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (97, 2, false, false, 500, 'Server Internal Error', NULL, NULL, false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (98, 2, false, false, 501, 'Not Implemented', NULL, NULL, false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (99, 2, false, false, 502, 'Bad Gateway', NULL, NULL, false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (101, 2, false, false, 504, 'Server Time-out', NULL, NULL, false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (102, 2, false, false, 505, 'Version Not Supported', NULL, NULL, false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (103, 2, false, false, 513, 'Message Too Large', NULL, NULL, false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (104, 2, false, false, 580, 'Precondition Failure', NULL, NULL, false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (105, 2, false, false, 600, 'Busy Everywhere', NULL, NULL, false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (107, 2, false, false, 604, 'Does Not Exist Anywhere', NULL, NULL, false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (108, 2, false, false, 606, 'Not Acceptable', NULL, NULL, false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (125, 1, true, false, 200, 'Rtp timeout', NULL, '', false, true, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (100, 2, false, false, 503, 'Service Unavailable', NULL, '', false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (90, 2, true, false, 486, 'Busy Here', NULL, '', false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (114, 1, true, false, 400, 'cant parse From in req', NULL, 'Bad Request', false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (115, 1, true, false, 400, 'cant parse To in req', NULL, 'Bad Request', false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (116, 1, true, false, 400, 'cant parse Contact in req', NULL, 'Bad Request', false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (112, 0, false, true, 403, 'Rejected by destination', NULL, 'Rejected by dst', false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (121, 1, true, false, 500, 'failed to get active connection', NULL, 'Internal Server Error', false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (122, 1, true, false, 500, 'db broken connection', NULL, 'Internal Server Error', false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (123, 1, true, false, 500, 'db conversion exception', NULL, 'Internal Server Error', false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (124, 1, true, false, 500, 'db base exception', NULL, 'Internal Server Error', false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (60, 2, false, false, 404, 'Not Found', NULL, '', false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (117, 1, true, false, 500, 'no such prepared query', NULL, 'Internal Server Error', false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (118, 1, true, false, 500, 'empty response from database', NULL, 'Internal Server Error', false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (119, 1, true, false, 500, 'read from tuple failed', NULL, 'Internal Server Error', false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (120, 1, true, false, 500, 'profile evaluation failed', NULL, 'Internal Server Error', false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (130, 1, true, false, 408, 'SIP transaction timeout', NULL, NULL, false, true, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (131, 1, true, false, 480, 'Gateway not registered', NULL, NULL, false, true, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (1500, 1, true, false, 500, 'SDP processing exception', NULL, NULL, false, true, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (1501, 1, true, false, 500, 'SDP parsing failed', NULL, NULL, false, true, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (1502, 1, true, false, 500, 'SDP empty answer', NULL, NULL, false, true, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (1503, 1, true, false, 500, 'SDP invalid streams count', NULL, NULL, false, true, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (1504, 1, true, false, 500, 'SDP inv streams types', NULL, NULL, false, true, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (8000, 0, true, true, 403, 'Not enough customer balance', NULL, NULL, false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (8001, 0, true, true, 403, 'Destination number blacklisted', NULL, NULL, false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (8002, 0, true, true, 403, 'Source number blacklisted', NULL, NULL, false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (8003, 0, true, true, 503, 'No response from LNP DB', NULL, NULL, false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, success,  successnozerolen,store_cdr,silently_drop) VALUES (8004,0,true,true,403,'Rejected by Auth record',false,false,true,false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, success,  successnozerolen,store_cdr,silently_drop) VALUES (8005,0,true,true,403,'Origination gateway is disabled',false,false,true,false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, success,  successnozerolen,store_cdr,silently_drop) VALUES (8006,0,true,true,403,'No destination with appropriate price found',false,false,true,false);

INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (1505, 1, false, false, 487, 'Ringing timeout', NULL, NULL, false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (2001, 3, true, false, 503, 'Radius response timeout', NULL, NULL, false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (2002, 3, true, false, 503, 'Radius request error', NULL, NULL, false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (2003, 3, true, false, 503, 'Invalid radius profile', NULL, NULL, false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (2004, 3, true, false, 503, 'Invalid radius response', NULL, NULL, false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (2005, 3, true, false, 402, 'Radius reject', NULL, NULL, false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (2006, 3, true, false, 503, 'Radius unsupported', NULL, NULL, false, false, true, false);


insert into disconnect_code (id,namespace_id,code,reason) values (1506, 1, 480,  'Customer account $id overloaded');
insert into disconnect_code (id,namespace_id,code,reason) values (1507, 1, 480,  'Customer auth $id overloaded');
insert into disconnect_code (id,namespace_id,code,reason) values (1508, 1, 480,  'Customer gateway $id overloaded');
insert into disconnect_code (id,namespace_id,code,reason) values (1509, 1, 480,  'Vendor account $id overloaded');
insert into disconnect_code (id,namespace_id,code,reason) values (1510, 1, 480,  'Vendor gateway $id overloaded');
insert into disconnect_code (id,namespace_id,code,reason) values (1511, 1, 480,  'Dialpeer $id overloaded');
insert into disconnect_code (id,namespace_id,code,reason) values (1512, 1, 480,  'Account $id total capacity reached');
insert into disconnect_code (id,namespace_id,code,reason) values (1600, 1, 503,  'Resource cache error');
insert into disconnect_code (id,namespace_id,code,reason) values (1601, 1, 503,  'Unknown resource overload');


insert into class4.disconnect_code(
  id,
  namespace_id,
  stop_hunting,
  pass_reason_to_originator,
  code,
  reason,
  success,
  successnozerolen,
  store_cdr,
  silently_drop
) values( 50, 2, false,false, 478, 'Unresolvable destination', false, false, true, false);

--
-- TOC entry 4439 (class 0 OID 0)
-- Dependencies: 314
-- Name: disconnect_code_id_seq; Type: SEQUENCE SET; Schema: class4; Owner: yeti
--


--
-- TOC entry 4440 (class 0 OID 0)
-- Dependencies: 316
-- Name: disconnect_code_policy_codes_id_seq; Type: SEQUENCE SET; Schema: class4; Owner: yeti
--

SELECT pg_catalog.setval('disconnect_code_policy_codes_id_seq', 3, true);


--
-- TOC entry 4441 (class 0 OID 0)
-- Dependencies: 318
-- Name: disconnect_code_policy_id_seq; Type: SEQUENCE SET; Schema: class4; Owner: yeti
--

SELECT pg_catalog.setval('disconnect_code_policy_id_seq', 2, true);


--
-- TOC entry 4336 (class 0 OID 19203)
-- Dependencies: 319
-- Data for Name: disconnect_initiators; Type: TABLE DATA; Schema: class4; Owner: yeti
--

INSERT INTO disconnect_initiators (id, name) VALUES (0, 'Traffic manager');
INSERT INTO disconnect_initiators (id, name) VALUES (1, 'Traffic switch');
INSERT INTO disconnect_initiators (id, name) VALUES (2, 'Destination');
INSERT INTO disconnect_initiators (id, name) VALUES (3, 'Origination');


--
-- TOC entry 4334 (class 0 OID 19195)
-- Dependencies: 317
-- Data for Name: disconnect_policy; Type: TABLE DATA; Schema: class4; Owner: yeti
--



--
-- TOC entry 4332 (class 0 OID 19185)
-- Dependencies: 315
-- Data for Name: disconnect_policy_code; Type: TABLE DATA; Schema: class4; Owner: yeti
--



--
-- TOC entry 4337 (class 0 OID 19209)
-- Dependencies: 320
-- Data for Name: diversion_policy; Type: TABLE DATA; Schema: class4; Owner: yeti
--

INSERT INTO diversion_policy (id, name) VALUES (1, 'Clear header');


--
-- TOC entry 4338 (class 0 OID 19215)
-- Dependencies: 321
-- Data for Name: dtmf_receive_modes; Type: TABLE DATA; Schema: class4; Owner: yeti
--

INSERT INTO class4.dtmf_receive_modes (id, name) VALUES (1, 'RFC 2833');
INSERT INTO class4.dtmf_receive_modes (id, name) VALUES (2, 'SIP INFO application/dtmf-relay OR application/dtmf');
INSERT INTO class4.dtmf_receive_modes (id, name) VALUES (3, 'RFC 2833 OR SIP INFO');
INSERT INTO class4.dtmf_receive_modes (id, name) values (4, 'Inband');
INSERT INTO class4.dtmf_receive_modes (id, name) values (5, 'Inband OR RFC 2833');



--
-- TOC entry 4339 (class 0 OID 19221)
-- Dependencies: 322
-- Data for Name: dtmf_send_modes; Type: TABLE DATA; Schema: class4; Owner: yeti
--

INSERT INTO dtmf_send_modes (id, name) VALUES (0, 'Disable sending');
INSERT INTO dtmf_send_modes (id, name) VALUES (1, 'RFC 2833');
INSERT INTO dtmf_send_modes (id, name) VALUES (2, 'SIP INFO application/dtmf-relay');
INSERT INTO dtmf_send_modes (id, name) VALUES (4, 'SIP INFO application/dtmf');


--
-- TOC entry 4340 (class 0 OID 19227)
-- Dependencies: 323
-- Data for Name: dump_level; Type: TABLE DATA; Schema: class4; Owner: yeti
--

INSERT INTO dump_level (id, name, log_sip, log_rtp) VALUES (3, 'Capture all traffic', true, true);
INSERT INTO dump_level (id, name, log_sip, log_rtp) VALUES (0, 'Capture nothing', false, false);
INSERT INTO dump_level (id, name, log_sip, log_rtp) VALUES (2, 'Capture rtp traffic', true, false);
INSERT INTO dump_level (id, name, log_sip, log_rtp) VALUES (1, 'Capture signaling traffic', true, false);


--
-- TOC entry 4341 (class 0 OID 19235)
-- Dependencies: 324
-- Data for Name: filter_types; Type: TABLE DATA; Schema: class4; Owner: yeti
--

INSERT INTO filter_types (id, name) VALUES (0, 'Transparent');
INSERT INTO filter_types (id, name) VALUES (1, 'Blacklist');
INSERT INTO filter_types (id, name) VALUES (2, 'Whitelist');


--
-- TOC entry 4342 (class 0 OID 19241)
-- Dependencies: 325
-- Data for Name: gateway_groups; Type: TABLE DATA; Schema: class4; Owner: yeti
--



--
-- TOC entry 4442 (class 0 OID 0)
-- Dependencies: 326
-- Name: gateway_groups_id_seq; Type: SEQUENCE SET; Schema: class4; Owner: yeti
--

SELECT pg_catalog.setval('gateway_groups_id_seq', 2, true);


--
-- TOC entry 4344 (class 0 OID 19250)
-- Dependencies: 327
-- Data for Name: gateway_rel100_modes; Type: TABLE DATA; Schema: class4; Owner: yeti
--

INSERT INTO gateway_rel100_modes (id, name) VALUES (0, 'Disabled');
INSERT INTO gateway_rel100_modes (id, name) VALUES (1, 'Supported');
INSERT INTO gateway_rel100_modes (id, name) VALUES (2, 'Supported not announced');
INSERT INTO gateway_rel100_modes (id, name) VALUES (3, 'Require');
INSERT INTO gateway_rel100_modes (id, name) VALUES (4, 'Ignored');


--
-- TOC entry 4308 (class 0 OID 18545)
-- Dependencies: 275
-- Data for Name: gateways; Type: TABLE DATA; Schema: class4; Owner: yeti
--



--
-- TOC entry 4443 (class 0 OID 0)
-- Dependencies: 328
-- Name: gateways_id_seq; Type: SEQUENCE SET; Schema: class4; Owner: yeti
--

SELECT pg_catalog.setval('gateways_id_seq', 15, true);


--
-- TOC entry 4346 (class 0 OID 19258)
-- Dependencies: 329
-- Data for Name: lnp_cache; Type: TABLE DATA; Schema: class4; Owner: yeti
--



--
-- TOC entry 4444 (class 0 OID 0)
-- Dependencies: 330
-- Name: lnp_cache_id_seq; Type: SEQUENCE SET; Schema: class4; Owner: yeti
--

SELECT pg_catalog.setval('lnp_cache_id_seq', 1, false);


--
-- TOC entry 4348 (class 0 OID 19266)
-- Dependencies: 331
-- Data for Name: lnp_databases; Type: TABLE DATA; Schema: class4; Owner: yeti
--



--
-- TOC entry 4445 (class 0 OID 0)
-- Dependencies: 332
-- Name: lnp_databases_id_seq; Type: SEQUENCE SET; Schema: class4; Owner: yeti
--

SELECT pg_catalog.setval('lnp_databases_id_seq', 1, false);


--
-- TOC entry 4350 (class 0 OID 19275)
-- Dependencies: 333
-- Data for Name: numberlist_actions; Type: TABLE DATA; Schema: class4; Owner: yeti
--

INSERT INTO numberlist_actions (id, name) VALUES (1, 'Reject call');
INSERT INTO numberlist_actions (id, name) VALUES (2, 'Allow call');


--
-- TOC entry 4313 (class 0 OID 19091)
-- Dependencies: 296
-- Data for Name: numberlist_items; Type: TABLE DATA; Schema: class4; Owner: yeti
--



--
-- TOC entry 4351 (class 0 OID 19281)
-- Dependencies: 334
-- Data for Name: numberlist_modes; Type: TABLE DATA; Schema: class4; Owner: yeti
--

INSERT INTO class4.numberlist_modes (id, name) VALUES (1, 'Strict number match');
INSERT INTO class4.numberlist_modes (id, name) VALUES (2, 'Prefix match');
INSERT INTO class4.numberlist_modes (id, name) VALUES (3, 'Random');

--
-- TOC entry 4315 (class 0 OID 19099)
-- Dependencies: 298
-- Data for Name: numberlists; Type: TABLE DATA; Schema: class4; Owner: yeti
--



--
-- TOC entry 4352 (class 0 OID 19287)
-- Dependencies: 335
-- Data for Name: radius_accounting_profile_interim_attributes; Type: TABLE DATA; Schema: class4; Owner: yeti
--



--
-- TOC entry 4446 (class 0 OID 0)
-- Dependencies: 336
-- Name: radius_accounting_profile_interim_attributes_id_seq; Type: SEQUENCE SET; Schema: class4; Owner: yeti
--

SELECT pg_catalog.setval('radius_accounting_profile_interim_attributes_id_seq', 1, false);


--
-- TOC entry 4354 (class 0 OID 19296)
-- Dependencies: 337
-- Data for Name: radius_accounting_profile_start_attributes; Type: TABLE DATA; Schema: class4; Owner: yeti
--



--
-- TOC entry 4447 (class 0 OID 0)
-- Dependencies: 338
-- Name: radius_accounting_profile_start_attributes_id_seq; Type: SEQUENCE SET; Schema: class4; Owner: yeti
--

SELECT pg_catalog.setval('radius_accounting_profile_start_attributes_id_seq', 1, false);


--
-- TOC entry 4356 (class 0 OID 19305)
-- Dependencies: 339
-- Data for Name: radius_accounting_profile_stop_attributes; Type: TABLE DATA; Schema: class4; Owner: yeti
--



--
-- TOC entry 4448 (class 0 OID 0)
-- Dependencies: 340
-- Name: radius_accounting_profile_stop_attributes_id_seq; Type: SEQUENCE SET; Schema: class4; Owner: yeti
--

SELECT pg_catalog.setval('radius_accounting_profile_stop_attributes_id_seq', 1, false);


--
-- TOC entry 4358 (class 0 OID 19314)
-- Dependencies: 341
-- Data for Name: radius_accounting_profiles; Type: TABLE DATA; Schema: class4; Owner: yeti
--



--
-- TOC entry 4449 (class 0 OID 0)
-- Dependencies: 342
-- Name: radius_accounting_profiles_id_seq; Type: SEQUENCE SET; Schema: class4; Owner: yeti
--

SELECT pg_catalog.setval('radius_accounting_profiles_id_seq', 1, false);


--
-- TOC entry 4360 (class 0 OID 19328)
-- Dependencies: 343
-- Data for Name: radius_auth_profile_attributes; Type: TABLE DATA; Schema: class4; Owner: yeti
--



--
-- TOC entry 4450 (class 0 OID 0)
-- Dependencies: 344
-- Name: radius_auth_profile_attributes_id_seq; Type: SEQUENCE SET; Schema: class4; Owner: yeti
--

SELECT pg_catalog.setval('radius_auth_profile_attributes_id_seq', 1, false);


--
-- TOC entry 4362 (class 0 OID 19337)
-- Dependencies: 345
-- Data for Name: radius_auth_profiles; Type: TABLE DATA; Schema: class4; Owner: yeti
--



--
-- TOC entry 4451 (class 0 OID 0)
-- Dependencies: 346
-- Name: radius_auth_profiles_id_seq; Type: SEQUENCE SET; Schema: class4; Owner: yeti
--

SELECT pg_catalog.setval('radius_auth_profiles_id_seq', 1, false);


--
-- TOC entry 4364 (class 0 OID 19348)
-- Dependencies: 347
-- Data for Name: rate_profit_control_modes; Type: TABLE DATA; Schema: class4; Owner: yeti
--

INSERT INTO rate_profit_control_modes (id, name) VALUES (1, 'no control');
INSERT INTO rate_profit_control_modes (id, name) VALUES (2, 'per call');


--
-- TOC entry 4365 (class 0 OID 19354)
-- Dependencies: 348
-- Data for Name: rateplans; Type: TABLE DATA; Schema: class4; Owner: yeti
--



--
-- TOC entry 4452 (class 0 OID 0)
-- Dependencies: 349
-- Name: rateplans_id_seq; Type: SEQUENCE SET; Schema: class4; Owner: yeti
--

SELECT pg_catalog.setval('rateplans_id_seq', 13, true);


--
-- TOC entry 4367 (class 0 OID 19363)
-- Dependencies: 350
-- Data for Name: registrations; Type: TABLE DATA; Schema: class4; Owner: yeti
--



--
-- TOC entry 4453 (class 0 OID 0)
-- Dependencies: 351
-- Name: registrations_id_seq; Type: SEQUENCE SET; Schema: class4; Owner: yeti
--

SELECT pg_catalog.setval('registrations_id_seq', 4, true);


--
-- TOC entry 4369 (class 0 OID 19376)
-- Dependencies: 352
-- Data for Name: routing_groups; Type: TABLE DATA; Schema: class4; Owner: yeti
--

INSERT INTO routing_groups (id, name) VALUES (20, 'Example Group #1');
INSERT INTO routing_groups (id, name) VALUES (21, 'Example Group #2');


--
-- TOC entry 4454 (class 0 OID 0)
-- Dependencies: 353
-- Name: routing_groups_id_seq; Type: SEQUENCE SET; Schema: class4; Owner: yeti
--

SELECT pg_catalog.setval('routing_groups_id_seq', 21, true);


--
-- TOC entry 4371 (class 0 OID 19384)
-- Dependencies: 354
-- Data for Name: routing_plan_groups; Type: TABLE DATA; Schema: class4; Owner: yeti
--



--
-- TOC entry 4455 (class 0 OID 0)
-- Dependencies: 355
-- Name: routing_plan_groups_id_seq; Type: SEQUENCE SET; Schema: class4; Owner: yeti
--

SELECT pg_catalog.setval('routing_plan_groups_id_seq', 1, false);


--
-- TOC entry 4373 (class 0 OID 19389)
-- Dependencies: 356
-- Data for Name: routing_plan_lnp_rules; Type: TABLE DATA; Schema: class4; Owner: yeti
--



--
-- TOC entry 4456 (class 0 OID 0)
-- Dependencies: 357
-- Name: routing_plan_lnp_rules_id_seq; Type: SEQUENCE SET; Schema: class4; Owner: yeti
--

SELECT pg_catalog.setval('routing_plan_lnp_rules_id_seq', 1, false);


--
-- TOC entry 4375 (class 0 OID 19398)
-- Dependencies: 358
-- Data for Name: routing_plan_static_routes; Type: TABLE DATA; Schema: class4; Owner: yeti
--



--
-- TOC entry 4457 (class 0 OID 0)
-- Dependencies: 359
-- Name: routing_plan_static_routes_id_seq; Type: SEQUENCE SET; Schema: class4; Owner: yeti
--

SELECT pg_catalog.setval('routing_plan_static_routes_id_seq', 1, false);


--
-- TOC entry 4377 (class 0 OID 19408)
-- Dependencies: 360
-- Data for Name: routing_plans; Type: TABLE DATA; Schema: class4; Owner: yeti
--



--
-- TOC entry 4458 (class 0 OID 0)
-- Dependencies: 361
-- Name: routing_plans_id_seq; Type: SEQUENCE SET; Schema: class4; Owner: yeti
--

SELECT pg_catalog.setval('routing_plans_id_seq', 1, false);


--
-- TOC entry 4379 (class 0 OID 19419)
-- Dependencies: 362
-- Data for Name: routing_tag_detection_rules; Type: TABLE DATA; Schema: class4; Owner: yeti
--



--
-- TOC entry 4459 (class 0 OID 0)
-- Dependencies: 363
-- Name: routing_tag_detection_rules_id_seq; Type: SEQUENCE SET; Schema: class4; Owner: yeti
--

SELECT pg_catalog.setval('routing_tag_detection_rules_id_seq', 1, false);


--
-- TOC entry 4381 (class 0 OID 19424)
-- Dependencies: 364
-- Data for Name: routing_tags; Type: TABLE DATA; Schema: class4; Owner: yeti
--



--
-- TOC entry 4460 (class 0 OID 0)
-- Dependencies: 365
-- Name: routing_tags_id_seq; Type: SEQUENCE SET; Schema: class4; Owner: yeti
--

SELECT pg_catalog.setval('routing_tags_id_seq', 1, false);


--
-- TOC entry 4383 (class 0 OID 19432)
-- Dependencies: 366
-- Data for Name: sdp_c_location; Type: TABLE DATA; Schema: class4; Owner: yeti
--

INSERT INTO sdp_c_location (id, name) VALUES (0, 'On session and media level');
INSERT INTO sdp_c_location (id, name) VALUES (1, 'On session level');
INSERT INTO sdp_c_location (id, name) VALUES (2, 'On media level');


--
-- TOC entry 4384 (class 0 OID 19438)
-- Dependencies: 367
-- Data for Name: session_refresh_methods; Type: TABLE DATA; Schema: class4; Owner: yeti
--

INSERT INTO session_refresh_methods (id, value, name) VALUES (1, 'INVITE', 'Invite');
INSERT INTO session_refresh_methods (id, value, name) VALUES (2, 'UPDATE', 'Update request');
INSERT INTO session_refresh_methods (id, value, name) VALUES (3, 'UPDATE_FALLBACK_INVITE', 'Update request and invite if unsupported');


--
-- TOC entry 4461 (class 0 OID 0)
-- Dependencies: 368
-- Name: session_refresh_methods_id_seq; Type: SEQUENCE SET; Schema: class4; Owner: yeti
--

SELECT pg_catalog.setval('session_refresh_methods_id_seq', 3, true);


--
-- TOC entry 4386 (class 0 OID 19446)
-- Dependencies: 369
-- Data for Name: sortings; Type: TABLE DATA; Schema: class4; Owner: yeti
--

INSERT INTO sortings (id, name, description, use_static_routes) VALUES (2, 'LCR, No ACD&ASR control', 'Without ACD&ASR control', false);
INSERT INTO sortings (id, name, description, use_static_routes) VALUES (3, 'Prio,LCR, ACD&ASR control', 'Same as default, but priotity has more weight', false);
INSERT INTO sortings (id, name, description, use_static_routes) VALUES (1, 'LCR,Prio, ACD&ASR control', 'Default dialpeer sorting method', false);
INSERT INTO sortings (id, name, description, use_static_routes) VALUES (4, 'LCRD, Prio, ACD&ASR control', 'Same as default, but take in account diff between costs', false);
INSERT INTO sortings (id, name, description, use_static_routes) VALUES (5, 'Route testing', NULL, false);
INSERT INTO sortings (id, name, description, use_static_routes) VALUES (6, 'QD-Static, LCR, ACD&ASR control', NULL, true);
INSERT INTO sortings (id, name, description, use_static_routes) VALUES (7, 'Static only, No ACD&ASR control', NULL, true);


--
-- TOC entry 4462 (class 0 OID 0)
-- Dependencies: 370
-- Name: sortings_id_seq; Type: SEQUENCE SET; Schema: class4; Owner: yeti
--

SELECT pg_catalog.setval('sortings_id_seq', 3, true);


--
-- TOC entry 4388 (class 0 OID 19455)
-- Dependencies: 371
-- Data for Name: transport_protocols; Type: TABLE DATA; Schema: class4; Owner: yeti
--

INSERT INTO class4.transport_protocols (id, name) VALUES (1, 'UDP');
INSERT INTO class4.transport_protocols (id, name) VALUES (2, 'TCP');
INSERT INTO class4.transport_protocols (id, name) VALUES (3, 'TLS');



INSERT INTO tag_actions VALUES (1, 'Clear tags');
INSERT INTO tag_actions VALUES (2, 'Remove selected tags');
INSERT INTO tag_actions VALUES (3, 'Append selected tags');
INSERT INTO tag_actions VALUES (4, 'Intersection with selected tags');
INSERT INTO tag_actions VALUES (5, 'Replace with selected tags');

insert into class4.routing_tag_modes(id,name) values( 0, 'OR');
insert into class4.routing_tag_modes(id,name) values( 1, 'AND');


insert into class4.gateway_inband_dtmf_filtering_modes(id,name) values('1','Inherit configuration from other call leg');
insert into class4.gateway_inband_dtmf_filtering_modes(id,name) values('2','Disable');
insert into class4.gateway_inband_dtmf_filtering_modes(id,name) values('3','Remove DTMF');

insert into class4.routeset_discriminators(name) values('default');
select setval('class4.routeset_discriminators_id_seq'::regclass, 1, true);


insert into class4.gateway_media_encryption_modes(id, name) values(0, 'Disable');
insert into class4.gateway_media_encryption_modes(id, name) values(1, 'SRTP SDES');
insert into class4.gateway_media_encryption_modes(id, name) values(2, 'SRTP DTLS');
insert into class4.gateway_media_encryption_modes(id, name) values(3, 'SRTP ZRTP');

insert into class4.gateway_network_protocol_priorities(id, name) values(0, 'force IPv4');
insert into class4.gateway_network_protocol_priorities(id, name) values(1, 'force IPv6');
insert into class4.gateway_network_protocol_priorities(id, name) values(2, 'Any');
insert into class4.gateway_network_protocol_priorities(id, name) values(3, 'prefer IPv4');
insert into class4.gateway_network_protocol_priorities(id, name) values(4, 'prefer IPv6');

insert into class4.gateway_group_balancing_modes(id,name) values(1,'Priority/Weigth balancing');
insert into class4.gateway_group_balancing_modes(id,name) values(2,'Priority/Weigth balancing. Prefer gateways from same POP');
insert into class4.gateway_group_balancing_modes(id,name) values(3,'Priority/Weigth balancing. Exclude gateways from other POPs');


