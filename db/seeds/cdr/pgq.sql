select pgq.create_queue('cdr_billing');
select pgq.register_consumer('cdr_billing','cdr_billing');
select pgq.create_queue('cdr_streaming');
select pgq.create_queue('rtp_statistics');
