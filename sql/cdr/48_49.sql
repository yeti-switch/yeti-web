begin;
insert into sys.version(number,comment) values(49,'More fields for CDR data type');

ALTER TYPE billing.cdr_v2 
    ADD ATTRIBUTE src_prefix_in character varying;
ALTER TYPE billing.cdr_v2 
    ADD ATTRIBUTE src_prefix_out character varying;
ALTER TYPE billing.cdr_v2 
    ADD ATTRIBUTE dst_prefix_in character varying;
ALTER TYPE billing.cdr_v2 
    ADD ATTRIBUTE dst_prefix_out character varying;
ALTER TYPE billing.cdr_v2 
    ADD ATTRIBUTE destination_initial_interval integer;
ALTER TYPE billing.cdr_v2 
    ADD ATTRIBUTE destination_next_interval integer;
ALTER TYPE billing.cdr_v2 
    ADD ATTRIBUTE destination_initial_rate numeric;
ALTER TYPE billing.cdr_v2 
    ADD ATTRIBUTE orig_call_id character varying;
ALTER TYPE billing.cdr_v2 
    ADD ATTRIBUTE term_call_id character varying;
ALTER TYPE billing.cdr_v2 
    ADD ATTRIBUTE local_tag character varying;
ALTER TYPE billing.cdr_v2 
    ADD ATTRIBUTE from_domain character varying;

commit;
