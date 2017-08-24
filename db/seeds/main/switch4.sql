--
-- PostgreSQL database dump
--

-- Dumped from database version 9.4.13
-- Dumped by pg_dump version 9.4.13
-- Started on 2017-08-20 19:26:42 EEST

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = switch4, pg_catalog;

--
-- TOC entry 3880 (class 0 OID 0)
-- Dependencies: 457
-- Name: events_id_seq; Type: SEQUENCE SET; Schema: switch4; Owner: yeti
--

SELECT pg_catalog.setval('events_id_seq', 280, true);


--
-- TOC entry 3865 (class 0 OID 19821)
-- Dependencies: 458
-- Data for Name: resource_action; Type: TABLE DATA; Schema: switch4; Owner: yeti
--

INSERT INTO resource_action VALUES (1, 'Reject');
INSERT INTO resource_action VALUES (2, 'Try next route');
INSERT INTO resource_action VALUES (3, 'Accept');


--
-- TOC entry 3863 (class 0 OID 18748)
-- Dependencies: 278
-- Data for Name: resource_type; Type: TABLE DATA; Schema: switch4; Owner: yeti
--

INSERT INTO resource_type VALUES (1, 'Customer account', 503, 'Resource $name $id overloaded', 1);
INSERT INTO resource_type VALUES (3, 'Customer auth', 503, 'Resource $name $id overloaded', 1);
INSERT INTO resource_type VALUES (4, 'Customer gateway', 503, 'Resource $name $id overloaded', 1);
INSERT INTO resource_type VALUES (2, 'Vendor account', 503, 'Resource $name $id overloaded', 2);
INSERT INTO resource_type VALUES (5, 'Vendor gateway', 503, 'Resource $name $id overloaded', 2);
INSERT INTO resource_type VALUES (6, 'Dialpeer', 503, 'Resource $name $id overloaded', 2);


--
-- TOC entry 3881 (class 0 OID 0)
-- Dependencies: 459
-- Name: resource_type_id_seq; Type: SEQUENCE SET; Schema: switch4; Owner: yeti
--

SELECT pg_catalog.setval('resource_type_id_seq', 6, true);


--
-- TOC entry 3882 (class 0 OID 0)
-- Dependencies: 460
-- Name: switch_in_interface_id_seq; Type: SEQUENCE SET; Schema: switch4; Owner: yeti
--

SELECT pg_catalog.setval('switch_in_interface_id_seq', 4, true);


--
-- TOC entry 3883 (class 0 OID 0)
-- Dependencies: 462
-- Name: switch_interface_id_seq; Type: SEQUENCE SET; Schema: switch4; Owner: yeti
--

SELECT pg_catalog.setval('switch_interface_id_seq', 875, true);


--
-- TOC entry 3870 (class 0 OID 19839)
-- Dependencies: 463
-- Data for Name: switch_interface_in; Type: TABLE DATA; Schema: switch4; Owner: yeti
--

INSERT INTO switch_interface_in VALUES (2, 'Diversion', 'varchar', 2, 'uri_user', false, NULL);
INSERT INTO switch_interface_in VALUES (1, 'X-YETI-AUTH', 'varchar', 1, NULL, true, NULL);
INSERT INTO switch_interface_in VALUES (3, 'X-ORIG-IP', 'varchar', 3, NULL, true, NULL);
INSERT INTO switch_interface_in VALUES (4, 'X-ORIG-PORT', 'integer', 4, NULL, true, NULL);


--
-- TOC entry 3868 (class 0 OID 19831)
-- Dependencies: 461
-- Data for Name: switch_interface_out; Type: TABLE DATA; Schema: switch4; Owner: yeti
--

INSERT INTO switch_interface_out VALUES (739, 'ruri', 'varchar', false, 10);
INSERT INTO switch_interface_out VALUES (740, 'ruri_host', 'varchar', false, 20);
INSERT INTO switch_interface_out VALUES (741, 'from', 'varchar', false, 30);
INSERT INTO switch_interface_out VALUES (744, 'call_id', 'varchar', false, 60);
INSERT INTO switch_interface_out VALUES (745, 'transparent_dlg_id', 'boolean', false, 70);
INSERT INTO switch_interface_out VALUES (746, 'dlg_nat_handling', 'boolean', false, 80);
INSERT INTO switch_interface_out VALUES (747, 'force_outbound_proxy', 'boolean', false, 90);
INSERT INTO switch_interface_out VALUES (748, 'outbound_proxy', 'varchar', false, 100);
INSERT INTO switch_interface_out VALUES (749, 'aleg_force_outbound_proxy', 'boolean', false, 110);
INSERT INTO switch_interface_out VALUES (750, 'aleg_outbound_proxy', 'varchar', false, 120);
INSERT INTO switch_interface_out VALUES (751, 'next_hop', 'varchar', false, 130);
INSERT INTO switch_interface_out VALUES (752, 'next_hop_1st_req', 'boolean', false, 140);
INSERT INTO switch_interface_out VALUES (753, 'aleg_next_hop', 'varchar', false, 150);
INSERT INTO switch_interface_out VALUES (762, 'enable_session_timer', 'boolean', false, 240);
INSERT INTO switch_interface_out VALUES (763, 'enable_aleg_session_timer', 'boolean', false, 250);
INSERT INTO switch_interface_out VALUES (764, 'session_expires', 'integer', false, 260);
INSERT INTO switch_interface_out VALUES (765, 'minimum_timer', 'integer', false, 270);
INSERT INTO switch_interface_out VALUES (766, 'maximum_timer', 'integer', false, 280);
INSERT INTO switch_interface_out VALUES (768, 'accept_501_reply', 'varchar', false, 300);
INSERT INTO switch_interface_out VALUES (769, 'aleg_session_expires', 'integer', false, 310);
INSERT INTO switch_interface_out VALUES (770, 'aleg_minimum_timer', 'integer', false, 320);
INSERT INTO switch_interface_out VALUES (771, 'aleg_maximum_timer', 'integer', false, 330);
INSERT INTO switch_interface_out VALUES (773, 'aleg_accept_501_reply', 'varchar', false, 350);
INSERT INTO switch_interface_out VALUES (774, 'enable_auth', 'boolean', false, 360);
INSERT INTO switch_interface_out VALUES (775, 'auth_user', 'varchar', false, 370);
INSERT INTO switch_interface_out VALUES (776, 'auth_pwd', 'varchar', false, 380);
INSERT INTO switch_interface_out VALUES (777, 'enable_aleg_auth', 'boolean', false, 390);
INSERT INTO switch_interface_out VALUES (778, 'auth_aleg_user', 'varchar', false, 400);
INSERT INTO switch_interface_out VALUES (779, 'auth_aleg_pwd', 'varchar', false, 410);
INSERT INTO switch_interface_out VALUES (780, 'append_headers', 'varchar', false, 420);
INSERT INTO switch_interface_out VALUES (781, 'append_headers_req', 'varchar', false, 430);
INSERT INTO switch_interface_out VALUES (782, 'aleg_append_headers_req', 'varchar', false, 440);
INSERT INTO switch_interface_out VALUES (784, 'enable_rtprelay', 'boolean', false, 460);
INSERT INTO switch_interface_out VALUES (786, 'rtprelay_msgflags_symmetric_rtp', 'boolean', false, 480);
INSERT INTO switch_interface_out VALUES (787, 'rtprelay_interface', 'varchar', false, 490);
INSERT INTO switch_interface_out VALUES (788, 'aleg_rtprelay_interface', 'varchar', false, 500);
INSERT INTO switch_interface_out VALUES (789, 'rtprelay_transparent_seqno', 'boolean', false, 510);
INSERT INTO switch_interface_out VALUES (790, 'rtprelay_transparent_ssrc', 'boolean', false, 520);
INSERT INTO switch_interface_out VALUES (791, 'outbound_interface', 'varchar', false, 530);
INSERT INTO switch_interface_out VALUES (792, 'aleg_outbound_interface', 'varchar', false, 540);
INSERT INTO switch_interface_out VALUES (793, 'contact_displayname', 'varchar', false, 550);
INSERT INTO switch_interface_out VALUES (794, 'contact_user', 'varchar', false, 560);
INSERT INTO switch_interface_out VALUES (795, 'contact_host', 'varchar', false, 570);
INSERT INTO switch_interface_out VALUES (796, 'contact_port', 'smallint', false, 580);
INSERT INTO switch_interface_out VALUES (797, 'enable_contact_hiding', 'boolean', false, 590);
INSERT INTO switch_interface_out VALUES (798, 'contact_hiding_prefix', 'varchar', false, 600);
INSERT INTO switch_interface_out VALUES (799, 'contact_hiding_vars', 'varchar', false, 610);
INSERT INTO switch_interface_out VALUES (807, 'dtmf_transcoding', 'varchar', false, 690);
INSERT INTO switch_interface_out VALUES (808, 'lowfi_codecs', 'varchar', false, 700);
INSERT INTO switch_interface_out VALUES (814, 'enable_reg_caching', 'boolean', false, 760);
INSERT INTO switch_interface_out VALUES (815, 'min_reg_expires', 'integer', false, 770);
INSERT INTO switch_interface_out VALUES (816, 'max_ua_expires', 'integer', false, 780);
INSERT INTO switch_interface_out VALUES (817, 'time_limit', 'integer', false, 790);
INSERT INTO switch_interface_out VALUES (818, 'resources', 'varchar', false, 800);
INSERT INTO switch_interface_out VALUES (742, 'to', 'varchar', false, 40);
INSERT INTO switch_interface_out VALUES (783, 'disconnect_code_id', 'integer', false, 450);
INSERT INTO switch_interface_out VALUES (772, 'aleg_session_refresh_method_id', 'integer', false, 340);
INSERT INTO switch_interface_out VALUES (812, 'dump_level_id', 'integer', false, 740);
INSERT INTO switch_interface_out VALUES (767, 'session_refresh_method_id', 'integer', false, 290);
INSERT INTO switch_interface_out VALUES (836, 'anonymize_sdp', 'boolean', false, 195);
INSERT INTO switch_interface_out VALUES (837, 'src_name_in', 'varchar', true, 1880);
INSERT INTO switch_interface_out VALUES (838, 'src_name_out', 'varchar', true, 1890);
INSERT INTO switch_interface_out VALUES (839, 'diversion_in', 'varchar', true, 1900);
INSERT INTO switch_interface_out VALUES (840, 'diversion_out', 'varchar', true, 1910);
INSERT INTO switch_interface_out VALUES (754, 'header_filter_type_id', 'integer', false, 160);
INSERT INTO switch_interface_out VALUES (845, 'aleg_single_codec_in_200ok', 'boolean', false, 911);
INSERT INTO switch_interface_out VALUES (756, 'message_filter_type_id', 'integer', false, 180);
INSERT INTO switch_interface_out VALUES (846, 'auth_orig_ip', 'inet', true, 1920);
INSERT INTO switch_interface_out VALUES (758, 'sdp_filter_type_id', 'integer', false, 200);
INSERT INTO switch_interface_out VALUES (847, 'auth_orig_port', 'integer', true, 1930);
INSERT INTO switch_interface_out VALUES (760, 'sdp_alines_filter_type_id', 'integer', false, 220);
INSERT INTO switch_interface_out VALUES (755, 'header_filter_list', 'varchar', false, 170);
INSERT INTO switch_interface_out VALUES (757, 'message_filter_list', 'varchar', false, 190);
INSERT INTO switch_interface_out VALUES (759, 'sdp_filter_list', 'varchar', false, 210);
INSERT INTO switch_interface_out VALUES (761, 'sdp_alines_filter_list', 'varchar', false, 230);
INSERT INTO switch_interface_out VALUES (841, 'aleg_policy_id', 'integer', false, 840);
INSERT INTO switch_interface_out VALUES (842, 'bleg_policy_id', 'integer', false, 850);
INSERT INTO switch_interface_out VALUES (843, 'aleg_codecs_group_id', 'integer', false, 900);
INSERT INTO switch_interface_out VALUES (844, 'bleg_codecs_group_id', 'integer', false, 910);
INSERT INTO switch_interface_out VALUES (848, 'bleg_single_codec_in_200ok', 'boolean', false, 912);
INSERT INTO switch_interface_out VALUES (709, 'customer_id', 'varchar', true, 1650);
INSERT INTO switch_interface_out VALUES (710, 'vendor_id', 'varchar', true, 1660);
INSERT INTO switch_interface_out VALUES (711, 'customer_acc_id', 'varchar', true, 1670);
INSERT INTO switch_interface_out VALUES (712, 'vendor_acc_id', 'varchar', true, 1690);
INSERT INTO switch_interface_out VALUES (827, 'destination_next_rate', 'varchar', true, 1771);
INSERT INTO switch_interface_out VALUES (831, 'destination_next_interval', 'integer', true, 1773);
INSERT INTO switch_interface_out VALUES (830, 'destination_initial_interval', 'integer', true, 1772);
INSERT INTO switch_interface_out VALUES (832, 'destination_rate_policy_id', 'integer', true, 1774);
INSERT INTO switch_interface_out VALUES (833, 'dialpeer_initial_interval', 'integer', true, 1775);
INSERT INTO switch_interface_out VALUES (834, 'dialpeer_next_interval', 'integer', true, 1776);
INSERT INTO switch_interface_out VALUES (835, 'dialpeer_next_rate', 'varchar', true, 1777);
INSERT INTO switch_interface_out VALUES (821, 'cache_time', 'integer', false, 810);
INSERT INTO switch_interface_out VALUES (849, 'ringing_timeout', 'integer', false, 913);
INSERT INTO switch_interface_out VALUES (924, 'try_avoid_transcoding', 'boolean', false, 620);
INSERT INTO switch_interface_out VALUES (925, 'rtprelay_dtmf_filtering', 'boolean', false, 630);
INSERT INTO switch_interface_out VALUES (926, 'rtprelay_dtmf_detection', 'boolean', false, 640);
INSERT INTO switch_interface_out VALUES (927, 'patch_ruri_next_hop', 'boolean', false, 920);
INSERT INTO switch_interface_out VALUES (929, 'rtprelay_force_dtmf_relay', 'boolean', false, 930);
INSERT INTO switch_interface_out VALUES (933, 'aleg_force_symmetric_rtp', 'boolean', false, 935);
INSERT INTO switch_interface_out VALUES (934, 'bleg_force_symmetric_rtp', 'boolean', false, 940);
INSERT INTO switch_interface_out VALUES (937, 'aleg_symmetric_rtp_nonstop', 'boolean', false, 945);
INSERT INTO switch_interface_out VALUES (939, 'bleg_symmetric_rtp_nonstop', 'boolean', false, 950);
INSERT INTO switch_interface_out VALUES (940, 'aleg_symmetric_rtp_ignore_rtcp', 'boolean', false, 955);
INSERT INTO switch_interface_out VALUES (941, 'bleg_symmetric_rtp_ignore_rtcp', 'boolean', false, 960);
INSERT INTO switch_interface_out VALUES (942, 'aleg_rtp_ping', 'boolean', false, 965);
INSERT INTO switch_interface_out VALUES (943, 'bleg_rtp_ping', 'boolean', false, 970);
INSERT INTO switch_interface_out VALUES (946, 'aleg_relay_options', 'boolean', false, 975);
INSERT INTO switch_interface_out VALUES (948, 'bleg_relay_options', 'boolean', false, 980);
INSERT INTO switch_interface_out VALUES (949, 'filter_noaudio_streams', 'boolean', false, 985);
INSERT INTO switch_interface_out VALUES (954, 'aleg_sdp_c_location_id', 'integer', false, 996);
INSERT INTO switch_interface_out VALUES (955, 'bleg_sdp_c_location_id', 'integer', false, 997);
INSERT INTO switch_interface_out VALUES (958, 'trusted_hdrs_gw', 'boolean', false, 998);
INSERT INTO switch_interface_out VALUES (959, 'aleg_append_headers_reply', 'varchar', false, 999);
INSERT INTO switch_interface_out VALUES (951, 'relay_reinvite', 'boolean', false, 990);
INSERT INTO switch_interface_out VALUES (961, 'bleg_sdp_alines_filter_list', 'varchar', false, 1000);
INSERT INTO switch_interface_out VALUES (963, 'bleg_sdp_alines_filter_type_id', 'integer', false, 1001);
INSERT INTO switch_interface_out VALUES (713, 'customer_auth_id', 'varchar', true, 1700);
INSERT INTO switch_interface_out VALUES (714, 'destination_id', 'varchar', true, 1710);
INSERT INTO switch_interface_out VALUES (715, 'dialpeer_id', 'varchar', true, 1720);
INSERT INTO switch_interface_out VALUES (716, 'orig_gw_id', 'varchar', true, 1730);
INSERT INTO switch_interface_out VALUES (717, 'term_gw_id', 'varchar', true, 1740);
INSERT INTO switch_interface_out VALUES (718, 'routing_group_id', 'varchar', true, 1750);
INSERT INTO switch_interface_out VALUES (719, 'rateplan_id', 'varchar', true, 1760);
INSERT INTO switch_interface_out VALUES (721, 'destination_fee', 'varchar', true, 1780);
INSERT INTO switch_interface_out VALUES (723, 'dialpeer_fee', 'varchar', true, 1800);
INSERT INTO switch_interface_out VALUES (726, 'dst_prefix_in', 'varchar', true, 1840);
INSERT INTO switch_interface_out VALUES (727, 'dst_prefix_out', 'varchar', true, 1850);
INSERT INTO switch_interface_out VALUES (728, 'src_prefix_in', 'varchar', true, 1860);
INSERT INTO switch_interface_out VALUES (729, 'src_prefix_out', 'varchar', true, 1870);
INSERT INTO switch_interface_out VALUES (824, 'reply_translations', 'varchar', false, 820);
INSERT INTO switch_interface_out VALUES (720, 'destination_initial_rate', 'varchar', true, 1770);
INSERT INTO switch_interface_out VALUES (722, 'dialpeer_initial_rate', 'varchar', true, 1790);
INSERT INTO switch_interface_out VALUES (850, 'global_tag', 'varchar', false, 914);
INSERT INTO switch_interface_out VALUES (851, 'relay_hold', 'boolean', false, 1002);
INSERT INTO switch_interface_out VALUES (852, 'dead_rtp_time', 'integer', false, 1003);
INSERT INTO switch_interface_out VALUES (853, 'relay_prack', 'boolean', false, 1004);
INSERT INTO switch_interface_out VALUES (854, 'rtp_relay_timestamp_aligning', 'boolean', false, 1005);
INSERT INTO switch_interface_out VALUES (855, 'allow_1xx_wo2tag', 'boolean', false, 1006);
INSERT INTO switch_interface_out VALUES (856, 'invite_timeout', 'integer', false, 1007);
INSERT INTO switch_interface_out VALUES (857, 'srv_failover_timeout', 'integer', false, 1008);
INSERT INTO switch_interface_out VALUES (859, 'rtp_force_relay_cn', 'boolean', false, 1009);
INSERT INTO switch_interface_out VALUES (861, 'dst_country_id', 'integer', true, 1931);
INSERT INTO switch_interface_out VALUES (862, 'dst_network_id', 'integer', true, 1932);
INSERT INTO switch_interface_out VALUES (863, 'aleg_sensor_id', 'smallint', false, 1010);
INSERT INTO switch_interface_out VALUES (866, 'aleg_sensor_level_id', 'smallint', false, 1011);
INSERT INTO switch_interface_out VALUES (867, 'bleg_sensor_id', 'smallint', false, 1012);
INSERT INTO switch_interface_out VALUES (868, 'bleg_sensor_level_id', 'smallint', false, 1013);
INSERT INTO switch_interface_out VALUES (869, 'dst_prefix_routing', 'varchar', true, 1933);
INSERT INTO switch_interface_out VALUES (870, 'src_prefix_routing', 'varchar', true, 1934);
INSERT INTO switch_interface_out VALUES (871, 'routing_plan_id', 'integer', true, 1935);
INSERT INTO switch_interface_out VALUES (872, 'aleg_dtmf_send_mode_id', 'integer', false, 1014);
INSERT INTO switch_interface_out VALUES (873, 'bleg_dtmf_send_mode_id', 'integer', false, 1015);
INSERT INTO switch_interface_out VALUES (874, 'aleg_dtmf_recv_modes', 'integer', false, 1016);
INSERT INTO switch_interface_out VALUES (875, 'bleg_dtmf_recv_modes', 'integer', false, 1017);


--
-- TOC entry 3871 (class 0 OID 19847)
-- Dependencies: 464
-- Data for Name: trusted_headers; Type: TABLE DATA; Schema: switch4; Owner: yeti
--



--
-- TOC entry 3884 (class 0 OID 0)
-- Dependencies: 465
-- Name: trusted_headers_id_seq; Type: SEQUENCE SET; Schema: switch4; Owner: yeti
--

SELECT pg_catalog.setval('trusted_headers_id_seq', 2, true);


-- Completed on 2017-08-20 19:26:42 EEST

--
-- PostgreSQL database dump complete
--

