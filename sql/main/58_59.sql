begin;
insert into sys.version(number,comment) values(59,'fix codec dymamic payloads');

CREATE OR REPLACE FUNCTION switch8.load_codecs()
  RETURNS TABLE(o_id integer, o_codec_group_id integer, o_codec_name character varying, o_priority integer, o_dynamic_payload_id integer, o_format_params character varying) AS
  $BODY$
BEGIN
    RETURN
    QUERY SELECT
        cgc.id,
        cgc.codec_group_id,
        c.name ,
        cgc.priority,
        cgc.dynamic_payload_type,
        cgc.format_parameters
    from class4.codec_group_codecs cgc
        JOIN class4.codecs c ON c.id=cgc.codec_id
    order by cgc.codec_group_id,cgc.priority desc ,c.name;
END;
$BODY$
LANGUAGE plpgsql VOLATILE
COST 10
ROWS 1000;

commit;