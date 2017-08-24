select pgq.create_queue('cdr_billing');
select pgq.register_consumer('cdr_billing','cdr_billing');
