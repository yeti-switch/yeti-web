--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = switch13, pg_catalog;

--
-- Name: events_id_seq; Type: SEQUENCE SET; Schema: switch13; Owner: yeti
--

SELECT pg_catalog.setval('events_id_seq', 280, true);


--
-- Data for Name: resource_action; Type: TABLE DATA; Schema: switch13; Owner: yeti
--

INSERT INTO resource_action VALUES (1, 'Reject');
INSERT INTO resource_action VALUES (2, 'Try next route');
INSERT INTO resource_action VALUES (3, 'Accept');


--
-- Data for Name: resource_type; Type: TABLE DATA; Schema: switch13; Owner: yeti
--

INSERT INTO resource_type VALUES (1, 'Customer account', 480, 'Resource $name $id overloaded', 1);
INSERT INTO resource_type VALUES (3, 'Customer auth', 480, 'Resource $name $id overloaded', 1);
INSERT INTO resource_type VALUES (4, 'Customer gateway', 480, 'Resource $name $id overloaded', 1);
INSERT INTO resource_type VALUES (2, 'Vendor account', 480, 'Resource $name $id overloaded', 2);
INSERT INTO resource_type VALUES (5, 'Vendor gateway', 480, 'Resource $name $id overloaded', 2);
INSERT INTO resource_type VALUES (6, 'Dialpeer', 480, 'Resource $name $id overloaded', 2);


--
-- Name: resource_type_id_seq; Type: SEQUENCE SET; Schema: switch13; Owner: yeti
--

SELECT pg_catalog.setval('resource_type_id_seq', 6, true);


--
-- Name: switch_in_interface_id_seq; Type: SEQUENCE SET; Schema: switch13; Owner: yeti
--

SELECT pg_catalog.setval('switch_in_interface_id_seq', 10, true);


--
-- Name: switch_interface_id_seq; Type: SEQUENCE SET; Schema: switch13; Owner: yeti
--

SELECT pg_catalog.setval('switch_interface_id_seq', 1010, true);


--
-- Data for Name: switch_interface_in; Type: TABLE DATA; Schema: switch13; Owner: yeti
--

INSERT INTO switch_interface_in VALUES (2, 'Diversion', 'varchar', 2, 'uri_user', false, NULL);
INSERT INTO switch_interface_in VALUES (1, 'X-YETI-AUTH', 'varchar', 1, NULL, true, NULL);
INSERT INTO switch_interface_in VALUES (3, 'X-ORIG-IP', 'varchar', 3, NULL, true, NULL);
INSERT INTO switch_interface_in VALUES (4, 'X-ORIG-PORT', 'integer', 4, NULL, true, NULL);
INSERT INTO switch_interface_in VALUES (5, 'X-ORIG-PROTO', 'integer', 5, NULL, true, NULL);
INSERT INTO switch_interface_in VALUES (6, 'P-Asserted-Identity', 'varchar', 6, NULL, true, NULL);
INSERT INTO switch_interface_in VALUES (9, 'Remote-Party-ID', 'varchar', 9, NULL, true, NULL);
INSERT INTO switch_interface_in VALUES (10, 'RPID-Privacy', 'varchar', 10, NULL, true, NULL);
INSERT INTO switch_interface_in VALUES (8, 'P-Preferred-Identity', 'varchar', 7, NULL, true, NULL);
INSERT INTO switch_interface_in VALUES (7, 'Privacy', 'varchar', 8, NULL, true, NULL);


--
-- Data for Name: switch_interface_out; Type: TABLE DATA; Schema: switch13; Owner: yeti
--

INSERT INTO switch_interface_out VALUES (890, 'src_number_radius', 'varchar', false, 1050, true);
INSERT INTO switch_interface_out VALUES (891, 'dst_number_radius', 'varchar', false, 1051, true);
INSERT INTO switch_interface_out VALUES (892, 'orig_gw_name', 'varchar', false, 1052, true);
INSERT INTO switch_interface_out VALUES (895, 'customer_name', 'varchar', false, 1055, true);
INSERT INTO switch_interface_out VALUES (894, 'customer_auth_name', 'varchar', false, 1054, true);
INSERT INTO switch_interface_out VALUES (896, 'customer_account_name', 'varchar', false, 1056, true);
INSERT INTO switch_interface_out VALUES (900, 'aleg_radius_acc_profile_id', 'smallint', false, 1024, false);
INSERT INTO switch_interface_out VALUES (901, 'bleg_radius_acc_profile_id', 'smallint', false, 1025, false);
INSERT INTO switch_interface_out VALUES (739, 'ruri', 'varchar', false, 10, false);
INSERT INTO switch_interface_out VALUES (899, 'record_audio', 'boolean', false, 1023, false);
INSERT INTO switch_interface_out VALUES (741, 'from', 'varchar', false, 30, false);
INSERT INTO switch_interface_out VALUES (744, 'call_id', 'varchar', false, 60, false);
INSERT INTO switch_interface_out VALUES (745, 'transparent_dlg_id', 'boolean', false, 70, false);
INSERT INTO switch_interface_out VALUES (746, 'dlg_nat_handling', 'boolean', false, 80, false);
INSERT INTO switch_interface_out VALUES (747, 'force_outbound_proxy', 'boolean', false, 90, false);
INSERT INTO switch_interface_out VALUES (748, 'outbound_proxy', 'varchar', false, 100, false);
INSERT INTO switch_interface_out VALUES (749, 'aleg_force_outbound_proxy', 'boolean', false, 110, false);
INSERT INTO switch_interface_out VALUES (750, 'aleg_outbound_proxy', 'varchar', false, 120, false);
INSERT INTO switch_interface_out VALUES (751, 'next_hop', 'varchar', false, 130, false);
INSERT INTO switch_interface_out VALUES (752, 'next_hop_1st_req', 'boolean', false, 140, false);
INSERT INTO switch_interface_out VALUES (753, 'aleg_next_hop', 'varchar', false, 150, false);
INSERT INTO switch_interface_out VALUES (762, 'enable_session_timer', 'boolean', false, 240, false);
INSERT INTO switch_interface_out VALUES (763, 'enable_aleg_session_timer', 'boolean', false, 250, false);
INSERT INTO switch_interface_out VALUES (764, 'session_expires', 'integer', false, 260, false);
INSERT INTO switch_interface_out VALUES (765, 'minimum_timer', 'integer', false, 270, false);
INSERT INTO switch_interface_out VALUES (766, 'maximum_timer', 'integer', false, 280, false);
INSERT INTO switch_interface_out VALUES (768, 'accept_501_reply', 'varchar', false, 300, false);
INSERT INTO switch_interface_out VALUES (769, 'aleg_session_expires', 'integer', false, 310, false);
INSERT INTO switch_interface_out VALUES (770, 'aleg_minimum_timer', 'integer', false, 320, false);
INSERT INTO switch_interface_out VALUES (771, 'aleg_maximum_timer', 'integer', false, 330, false);
INSERT INTO switch_interface_out VALUES (773, 'aleg_accept_501_reply', 'varchar', false, 350, false);
INSERT INTO switch_interface_out VALUES (774, 'enable_auth', 'boolean', false, 360, false);
INSERT INTO switch_interface_out VALUES (775, 'auth_user', 'varchar', false, 370, false);
INSERT INTO switch_interface_out VALUES (776, 'auth_pwd', 'varchar', false, 380, false);
INSERT INTO switch_interface_out VALUES (777, 'enable_aleg_auth', 'boolean', false, 390, false);
INSERT INTO switch_interface_out VALUES (778, 'auth_aleg_user', 'varchar', false, 400, false);
INSERT INTO switch_interface_out VALUES (779, 'auth_aleg_pwd', 'varchar', false, 410, false);
INSERT INTO switch_interface_out VALUES (780, 'append_headers', 'varchar', false, 420, false);
INSERT INTO switch_interface_out VALUES (781, 'append_headers_req', 'varchar', false, 430, false);
INSERT INTO switch_interface_out VALUES (782, 'aleg_append_headers_req', 'varchar', false, 440, false);
INSERT INTO switch_interface_out VALUES (784, 'enable_rtprelay', 'boolean', false, 460, false);
INSERT INTO switch_interface_out VALUES (786, 'rtprelay_msgflags_symmetric_rtp', 'boolean', false, 480, false);
INSERT INTO switch_interface_out VALUES (787, 'rtprelay_interface', 'varchar', false, 490, false);
INSERT INTO switch_interface_out VALUES (788, 'aleg_rtprelay_interface', 'varchar', false, 500, false);
INSERT INTO switch_interface_out VALUES (789, 'rtprelay_transparent_seqno', 'boolean', false, 510, false);
INSERT INTO switch_interface_out VALUES (790, 'rtprelay_transparent_ssrc', 'boolean', false, 520, false);
INSERT INTO switch_interface_out VALUES (791, 'outbound_interface', 'varchar', false, 530, false);
INSERT INTO switch_interface_out VALUES (792, 'aleg_outbound_interface', 'varchar', false, 540, false);
INSERT INTO switch_interface_out VALUES (793, 'contact_displayname', 'varchar', false, 550, false);
INSERT INTO switch_interface_out VALUES (794, 'contact_user', 'varchar', false, 560, false);
INSERT INTO switch_interface_out VALUES (795, 'contact_host', 'varchar', false, 570, false);
INSERT INTO switch_interface_out VALUES (796, 'contact_port', 'smallint', false, 580, false);
INSERT INTO switch_interface_out VALUES (797, 'enable_contact_hiding', 'boolean', false, 590, false);
INSERT INTO switch_interface_out VALUES (798, 'contact_hiding_prefix', 'varchar', false, 600, false);
INSERT INTO switch_interface_out VALUES (799, 'contact_hiding_vars', 'varchar', false, 610, false);
INSERT INTO switch_interface_out VALUES (807, 'dtmf_transcoding', 'varchar', false, 690, false);
INSERT INTO switch_interface_out VALUES (808, 'lowfi_codecs', 'varchar', false, 700, false);
INSERT INTO switch_interface_out VALUES (814, 'enable_reg_caching', 'boolean', false, 760, false);
INSERT INTO switch_interface_out VALUES (815, 'min_reg_expires', 'integer', false, 770, false);
INSERT INTO switch_interface_out VALUES (816, 'max_ua_expires', 'integer', false, 780, false);
INSERT INTO switch_interface_out VALUES (817, 'time_limit', 'integer', false, 790, false);
INSERT INTO switch_interface_out VALUES (818, 'resources', 'varchar', false, 800, false);
INSERT INTO switch_interface_out VALUES (742, 'to', 'varchar', false, 40, false);
INSERT INTO switch_interface_out VALUES (783, 'disconnect_code_id', 'integer', false, 450, false);
INSERT INTO switch_interface_out VALUES (772, 'aleg_session_refresh_method_id', 'integer', false, 340, false);
INSERT INTO switch_interface_out VALUES (812, 'dump_level_id', 'integer', false, 740, false);
INSERT INTO switch_interface_out VALUES (767, 'session_refresh_method_id', 'integer', false, 290, false);
INSERT INTO switch_interface_out VALUES (836, 'anonymize_sdp', 'boolean', false, 195, false);
INSERT INTO switch_interface_out VALUES (837, 'src_name_in', 'varchar', true, 1880, true);
INSERT INTO switch_interface_out VALUES (838, 'src_name_out', 'varchar', true, 1890, true);
INSERT INTO switch_interface_out VALUES (839, 'diversion_in', 'varchar', true, 1900, true);
INSERT INTO switch_interface_out VALUES (840, 'diversion_out', 'varchar', true, 1910, true);
INSERT INTO switch_interface_out VALUES (846, 'auth_orig_ip', 'inet', true, 1920, true);
INSERT INTO switch_interface_out VALUES (713, 'customer_auth_id', 'varchar', true, 1700, true);
INSERT INTO switch_interface_out VALUES (845, 'aleg_single_codec_in_200ok', 'boolean', false, 911, false);
INSERT INTO switch_interface_out VALUES (756, 'message_filter_type_id', 'integer', false, 180, false);
INSERT INTO switch_interface_out VALUES (758, 'sdp_filter_type_id', 'integer', false, 200, false);
INSERT INTO switch_interface_out VALUES (847, 'auth_orig_port', 'integer', true, 1930, true);
INSERT INTO switch_interface_out VALUES (760, 'sdp_alines_filter_type_id', 'integer', false, 220, false);
INSERT INTO switch_interface_out VALUES (757, 'message_filter_list', 'varchar', false, 190, false);
INSERT INTO switch_interface_out VALUES (759, 'sdp_filter_list', 'varchar', false, 210, false);
INSERT INTO switch_interface_out VALUES (761, 'sdp_alines_filter_list', 'varchar', false, 230, false);
INSERT INTO switch_interface_out VALUES (841, 'aleg_policy_id', 'integer', false, 840, false);
INSERT INTO switch_interface_out VALUES (842, 'bleg_policy_id', 'integer', false, 850, false);
INSERT INTO switch_interface_out VALUES (843, 'aleg_codecs_group_id', 'integer', false, 900, false);
INSERT INTO switch_interface_out VALUES (844, 'bleg_codecs_group_id', 'integer', false, 910, false);
INSERT INTO switch_interface_out VALUES (848, 'bleg_single_codec_in_200ok', 'boolean', false, 912, false);
INSERT INTO switch_interface_out VALUES (709, 'customer_id', 'varchar', true, 1650, true);
INSERT INTO switch_interface_out VALUES (710, 'vendor_id', 'varchar', true, 1660, true);
INSERT INTO switch_interface_out VALUES (711, 'customer_acc_id', 'varchar', true, 1670, true);
INSERT INTO switch_interface_out VALUES (712, 'vendor_acc_id', 'varchar', true, 1690, true);
INSERT INTO switch_interface_out VALUES (827, 'destination_next_rate', 'varchar', true, 1771, true);
INSERT INTO switch_interface_out VALUES (831, 'destination_next_interval', 'integer', true, 1773, true);
INSERT INTO switch_interface_out VALUES (830, 'destination_initial_interval', 'integer', true, 1772, true);
INSERT INTO switch_interface_out VALUES (832, 'destination_rate_policy_id', 'integer', true, 1774, true);
INSERT INTO switch_interface_out VALUES (833, 'dialpeer_initial_interval', 'integer', true, 1775, true);
INSERT INTO switch_interface_out VALUES (834, 'dialpeer_next_interval', 'integer', true, 1776, true);
INSERT INTO switch_interface_out VALUES (835, 'dialpeer_next_rate', 'varchar', true, 1777, true);
INSERT INTO switch_interface_out VALUES (821, 'cache_time', 'integer', false, 810, false);
INSERT INTO switch_interface_out VALUES (849, 'ringing_timeout', 'integer', false, 913, false);
INSERT INTO switch_interface_out VALUES (924, 'try_avoid_transcoding', 'boolean', false, 620, false);
INSERT INTO switch_interface_out VALUES (925, 'rtprelay_dtmf_filtering', 'boolean', false, 630, false);
INSERT INTO switch_interface_out VALUES (926, 'rtprelay_dtmf_detection', 'boolean', false, 640, false);
INSERT INTO switch_interface_out VALUES (927, 'patch_ruri_next_hop', 'boolean', false, 920, false);
INSERT INTO switch_interface_out VALUES (929, 'rtprelay_force_dtmf_relay', 'boolean', false, 930, false);
INSERT INTO switch_interface_out VALUES (933, 'aleg_force_symmetric_rtp', 'boolean', false, 935, false);
INSERT INTO switch_interface_out VALUES (934, 'bleg_force_symmetric_rtp', 'boolean', false, 940, false);
INSERT INTO switch_interface_out VALUES (937, 'aleg_symmetric_rtp_nonstop', 'boolean', false, 945, false);
INSERT INTO switch_interface_out VALUES (939, 'bleg_symmetric_rtp_nonstop', 'boolean', false, 950, false);
INSERT INTO switch_interface_out VALUES (940, 'aleg_symmetric_rtp_ignore_rtcp', 'boolean', false, 955, false);
INSERT INTO switch_interface_out VALUES (941, 'bleg_symmetric_rtp_ignore_rtcp', 'boolean', false, 960, false);
INSERT INTO switch_interface_out VALUES (942, 'aleg_rtp_ping', 'boolean', false, 965, false);
INSERT INTO switch_interface_out VALUES (943, 'bleg_rtp_ping', 'boolean', false, 970, false);
INSERT INTO switch_interface_out VALUES (946, 'aleg_relay_options', 'boolean', false, 975, false);
INSERT INTO switch_interface_out VALUES (948, 'bleg_relay_options', 'boolean', false, 980, false);
INSERT INTO switch_interface_out VALUES (949, 'filter_noaudio_streams', 'boolean', false, 985, false);
INSERT INTO switch_interface_out VALUES (954, 'aleg_sdp_c_location_id', 'integer', false, 996, false);
INSERT INTO switch_interface_out VALUES (955, 'bleg_sdp_c_location_id', 'integer', false, 997, false);
INSERT INTO switch_interface_out VALUES (958, 'trusted_hdrs_gw', 'boolean', false, 998, false);
INSERT INTO switch_interface_out VALUES (959, 'aleg_append_headers_reply', 'varchar', false, 999, false);
INSERT INTO switch_interface_out VALUES (961, 'bleg_sdp_alines_filter_list', 'varchar', false, 1000, false);
INSERT INTO switch_interface_out VALUES (963, 'bleg_sdp_alines_filter_type_id', 'integer', false, 1001, false);
INSERT INTO switch_interface_out VALUES (715, 'dialpeer_id', 'varchar', true, 1720, true);
INSERT INTO switch_interface_out VALUES (716, 'orig_gw_id', 'varchar', true, 1730, true);
INSERT INTO switch_interface_out VALUES (717, 'term_gw_id', 'varchar', true, 1740, true);
INSERT INTO switch_interface_out VALUES (718, 'routing_group_id', 'varchar', true, 1750, true);
INSERT INTO switch_interface_out VALUES (719, 'rateplan_id', 'varchar', true, 1760, true);
INSERT INTO switch_interface_out VALUES (721, 'destination_fee', 'varchar', true, 1780, true);
INSERT INTO switch_interface_out VALUES (723, 'dialpeer_fee', 'varchar', true, 1800, true);
INSERT INTO switch_interface_out VALUES (726, 'dst_prefix_in', 'varchar', true, 1840, true);
INSERT INTO switch_interface_out VALUES (727, 'dst_prefix_out', 'varchar', true, 1850, true);
INSERT INTO switch_interface_out VALUES (728, 'src_prefix_in', 'varchar', true, 1860, true);
INSERT INTO switch_interface_out VALUES (729, 'src_prefix_out', 'varchar', true, 1870, true);
INSERT INTO switch_interface_out VALUES (824, 'reply_translations', 'varchar', false, 820, false);
INSERT INTO switch_interface_out VALUES (720, 'destination_initial_rate', 'varchar', true, 1770, true);
INSERT INTO switch_interface_out VALUES (722, 'dialpeer_initial_rate', 'varchar', true, 1790, true);
INSERT INTO switch_interface_out VALUES (850, 'global_tag', 'varchar', false, 914, false);
INSERT INTO switch_interface_out VALUES (852, 'dead_rtp_time', 'integer', false, 1003, false);
INSERT INTO switch_interface_out VALUES (854, 'rtp_relay_timestamp_aligning', 'boolean', false, 1005, false);
INSERT INTO switch_interface_out VALUES (855, 'allow_1xx_wo2tag', 'boolean', false, 1006, false);
INSERT INTO switch_interface_out VALUES (856, 'invite_timeout', 'integer', false, 1007, false);
INSERT INTO switch_interface_out VALUES (857, 'srv_failover_timeout', 'integer', false, 1008, false);
INSERT INTO switch_interface_out VALUES (859, 'rtp_force_relay_cn', 'boolean', false, 1009, false);
INSERT INTO switch_interface_out VALUES (861, 'dst_country_id', 'integer', true, 1931, true);
INSERT INTO switch_interface_out VALUES (862, 'dst_network_id', 'integer', true, 1932, true);
INSERT INTO switch_interface_out VALUES (863, 'aleg_sensor_id', 'smallint', false, 1010, false);
INSERT INTO switch_interface_out VALUES (866, 'aleg_sensor_level_id', 'smallint', false, 1011, false);
INSERT INTO switch_interface_out VALUES (867, 'bleg_sensor_id', 'smallint', false, 1012, false);
INSERT INTO switch_interface_out VALUES (868, 'bleg_sensor_level_id', 'smallint', false, 1013, false);
INSERT INTO switch_interface_out VALUES (869, 'dst_prefix_routing', 'varchar', true, 1933, true);
INSERT INTO switch_interface_out VALUES (870, 'src_prefix_routing', 'varchar', true, 1934, true);
INSERT INTO switch_interface_out VALUES (871, 'routing_plan_id', 'integer', true, 1935, true);
INSERT INTO switch_interface_out VALUES (872, 'aleg_dtmf_send_mode_id', 'integer', false, 1014, false);
INSERT INTO switch_interface_out VALUES (873, 'bleg_dtmf_send_mode_id', 'integer', false, 1015, false);
INSERT INTO switch_interface_out VALUES (874, 'aleg_dtmf_recv_modes', 'integer', false, 1016, false);
INSERT INTO switch_interface_out VALUES (875, 'bleg_dtmf_recv_modes', 'integer', false, 1017, false);
INSERT INTO switch_interface_out VALUES (876, 'suppress_early_media', 'boolean', false, 1018, false);
INSERT INTO switch_interface_out VALUES (877, 'aleg_relay_update', 'boolean', false, 1019, false);
INSERT INTO switch_interface_out VALUES (878, 'bleg_relay_update', 'boolean', false, 1020, false);
INSERT INTO switch_interface_out VALUES (951, 'aleg_relay_reinvite', 'boolean', false, 990, false);
INSERT INTO switch_interface_out VALUES (879, 'bleg_relay_reinvite', 'boolean', false, 991, false);
INSERT INTO switch_interface_out VALUES (880, 'aleg_relay_hold', 'boolean', false, 992, false);
INSERT INTO switch_interface_out VALUES (881, 'bleg_relay_hold', 'boolean', false, 993, false);
INSERT INTO switch_interface_out VALUES (882, 'aleg_relay_prack', 'boolean', false, 994, false);
INSERT INTO switch_interface_out VALUES (883, 'bleg_relay_prack', 'boolean', false, 995, false);
INSERT INTO switch_interface_out VALUES (884, 'destination_prefix', 'varchar', true, 1711, true);
INSERT INTO switch_interface_out VALUES (885, 'dialpeer_prefix', 'varchar', true, 1721, true);
INSERT INTO switch_interface_out VALUES (886, 'lrn', 'varchar', true, 1936, true);
INSERT INTO switch_interface_out VALUES (887, 'lnp_database_id', 'smallint', true, 1937, true);
INSERT INTO switch_interface_out VALUES (888, 'force_one_way_early_media', 'boolean', false, 1021, false);
INSERT INTO switch_interface_out VALUES (889, 'radius_auth_profile_id', 'smallint', false, 1022, false);
INSERT INTO switch_interface_out VALUES (904, 'term_gw_name', 'varchar', false, 1057, true);
INSERT INTO switch_interface_out VALUES (905, 'orig_gw_external_id', 'bigint', false, 1058, true);
INSERT INTO switch_interface_out VALUES (906, 'term_gw_external_id', 'bigint', false, 1059, true);
INSERT INTO switch_interface_out VALUES (909, 'transit_headers_b2a', 'varchar', false, 1027, false);
INSERT INTO switch_interface_out VALUES (907, 'transit_headers_a2b', 'varchar', false, 1026, false);
INSERT INTO switch_interface_out VALUES (714, 'destination_id', 'varchar', true, 1710, true);
INSERT INTO switch_interface_out VALUES (910, 'from_domain', 'varchar', true, 1938, true);
INSERT INTO switch_interface_out VALUES (911, 'to_domain', 'varchar', true, 1939, true);
INSERT INTO switch_interface_out VALUES (912, 'ruri_domain', 'varchar', true, 1940, true);
INSERT INTO switch_interface_out VALUES (913, 'fake_180_timer', 'smallint', false, 1060, true);
INSERT INTO switch_interface_out VALUES (914, 'src_area_id', 'integer', true, 1941, true);
INSERT INTO switch_interface_out VALUES (915, 'dst_area_id', 'integer', true, 1942, true);
INSERT INTO switch_interface_out VALUES (916, 'routing_tag_id', 'smallint', true, 1943, true);
INSERT INTO switch_interface_out VALUES (917, 'bleg_transport_protocol_id', 'smallint', false, 21, false);
INSERT INTO switch_interface_out VALUES (918, 'aleg_outbound_proxy_transport_protocol_id', 'smallint', false, 121, false);
INSERT INTO switch_interface_out VALUES (919, 'bleg_outbound_proxy_transport_protocol_id', 'smallint', false, 101, false);
INSERT INTO switch_interface_out VALUES (920, 'auth_orig_protocol_id', 'smallint', true, 1919, true);
INSERT INTO switch_interface_out VALUES (921, 'aleg_rel100_mode_id', 'smallint', false, 1061, false);
INSERT INTO switch_interface_out VALUES (922, 'bleg_rel100_mode_id', 'smallint', false, 1062, false);
INSERT INTO switch_interface_out VALUES (923, 'pai_in', 'varchar', true, 1944, true);
INSERT INTO switch_interface_out VALUES (1000, 'ppi_in', 'varchar', true, 1945, true);
INSERT INTO switch_interface_out VALUES (1002, 'privacy_in', 'varchar', true, 1946, true);
INSERT INTO switch_interface_out VALUES (1003, 'rpid_in', 'varchar', true, 1947, true);
INSERT INTO switch_interface_out VALUES (1005, 'rpid_privacy_in', 'varchar', true, 1948, true);
INSERT INTO switch_interface_out VALUES (1006, 'pai_out', 'varchar', true, 1949, true);
INSERT INTO switch_interface_out VALUES (1007, 'ppi_out', 'varchar', true, 1950, true);
INSERT INTO switch_interface_out VALUES (1008, 'privacy_out', 'varchar', true, 1951, true);
INSERT INTO switch_interface_out VALUES (1009, 'rpid_out', 'varchar', true, 1952, true);
INSERT INTO switch_interface_out VALUES (1010, 'rpid_privacy_out', 'varchar', true, 1953, true);


--
-- Data for Name: trusted_headers; Type: TABLE DATA; Schema: switch13; Owner: yeti
--



--
-- Name: trusted_headers_id_seq; Type: SEQUENCE SET; Schema: switch13; Owner: yeti
--

SELECT pg_catalog.setval('trusted_headers_id_seq', 2, true);


--
-- PostgreSQL database dump complete
--

