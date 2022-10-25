--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = notifications, pg_catalog;

--
-- Data for Name: event_subscriptions; Type: TABLE DATA; Schema: notifications; Owner: yeti
--

INSERT INTO event_subscriptions (id, event, send_to) VALUES (1, 'DialpeerLocked', NULL);
INSERT INTO event_subscriptions (id, event, send_to) VALUES (2, 'GatewayLocked', NULL);
INSERT INTO event_subscriptions (id, event, send_to) VALUES (3, 'DialpeerUnlocked', NULL);
INSERT INTO event_subscriptions (id, event, send_to) VALUES (4, 'GatewayUnlocked', NULL);
INSERT INTO event_subscriptions (id, event, send_to) VALUES (5, 'DestinationQualityAlarmFired', NULL);
INSERT INTO event_subscriptions (id, event, send_to) VALUES (6, 'DestinationQualityAlarmCleared', NULL);
INSERT INTO event_subscriptions (id, event, send_to) VALUES (7, 'AccountLowThesholdReached', '{}');
INSERT INTO event_subscriptions (id, event, send_to) VALUES (8, 'AccountHighThesholdReached', '{}');
INSERT INTO event_subscriptions (id, event, send_to) VALUES (9, 'AccountLowThesholdCleared', '{}');
INSERT INTO event_subscriptions (id, event, send_to) VALUES (10, 'AccountHighThesholdCleared', '{}');


--
-- Name: alerts_id_seq; Type: SEQUENCE SET; Schema: notifications; Owner: yeti
--

SELECT pg_catalog.setval('alerts_id_seq', 10, true);


--
-- Data for Name: attachments; Type: TABLE DATA; Schema: notifications; Owner: yeti
--



--
-- Name: attachments_id_seq; Type: SEQUENCE SET; Schema: notifications; Owner: yeti
--

SELECT pg_catalog.setval('attachments_id_seq', 1, false);


--
-- Data for Name: contacts; Type: TABLE DATA; Schema: notifications; Owner: yeti
--

INSERT INTO contacts (id, contractor_id, admin_user_id, email, notes, created_at, updated_at) VALUES (1, NULL, 3, 'admin@example.com', NULL, '2017-08-14 12:56:41.750231+03', '2017-08-14 12:56:41.750231+03');


--
-- Name: contacts_id_seq; Type: SEQUENCE SET; Schema: notifications; Owner: yeti
--

SELECT pg_catalog.setval('contacts_id_seq', 1, true);


--
-- Name: email_log_id_seq; Type: SEQUENCE SET; Schema: notifications; Owner: yeti
--

SELECT pg_catalog.setval('email_log_id_seq', 1, false);


--
-- Data for Name: email_logs; Type: TABLE DATA; Schema: notifications; Owner: yeti
--



--
-- PostgreSQL database dump complete
--
