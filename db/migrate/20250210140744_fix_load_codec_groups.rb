class FixLoadCodecGroups < ActiveRecord::Migration[7.2]
  def up
    execute %q{
CREATE OR REPLACE FUNCTION switch22.load_codec_groups()
 RETURNS TABLE(id integer, ptime smallint, codecs json)
 LANGUAGE plpgsql
 COST 10
AS $function$
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
      ) ORDER BY cgc.priority DESC ) as codecs
    FROM class4.codec_groups cg
    LEFT JOIN class4.codec_group_codecs cgc ON cg.id = cgc.codec_group_id
    LEFT JOIN class4.codecs c ON cgc.codec_id=c.id
    GROUP BY cg.id;
END;
$function$;

    }
  end


  def down
    execute %q{
CREATE OR REPLACE FUNCTION switch22.load_codec_groups()
 RETURNS TABLE(id integer, ptime smallint, codecs json)
 LANGUAGE plpgsql
 COST 10
AS $function$
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
$function$;

    }
  end
end
