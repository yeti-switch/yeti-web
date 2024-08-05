class CodecGroupPtime < ActiveRecord::Migration[7.0]
  def up
    execute %q{
      alter table class4.codec_groups add ptime smallint;

CREATE FUNCTION switch21.load_codec_groups() RETURNS TABLE(id integer, ptime smallint, codecs json)
    LANGUAGE plpgsql COST 10
    AS $$
BEGIN
  RETURN QUERY
    SELECT
      cg.id,
      cg.ptime,
      json_agg(json_build_object(
        'id', c.id,
        'name', c.name,
        'priority', cgc.priority,
        'dynamic_payload_type', cgc.dynamic_payload_type,
        'format_parameters', cgc.format_parameters
      )) as codecs
    FROM class4.codec_groups cg
    LEFT JOIN class4.codec_group_codecs cgc ON cg.id = cgc.codec_group_id
    LEFT JOIN class4.codecs c ON cgc.codec_id=c.id
    GROUP BY cg.id;
END;
$$;

CREATE OR REPLACE FUNCTION switch21.load_codecs() RETURNS TABLE(o_id integer, o_codec_group_id integer, o_codec_name character varying, o_priority integer, o_dynamic_payload_id integer, o_format_params character varying)
    LANGUAGE plpgsql COST 10
    AS $$
BEGIN

  -- TODO: this function replaced by load_codec_groups and should be deleted in future
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
$$;

    }
  end

  def down
    execute %q{
      alter table class4.codec_groups drop column ptime;

DROP FUNCTION switch21.load_codec_groups();

CREATE OR REPLACE FUNCTION switch21.load_codecs() RETURNS TABLE(o_id integer, o_codec_group_id integer, o_codec_name character varying, o_priority integer, o_dynamic_payload_id integer, o_format_params character varying)
    LANGUAGE plpgsql COST 10
    AS $$
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
$$;


    }
  end

end
