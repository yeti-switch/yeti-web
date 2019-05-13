class LuaExecution < ActiveRecord::Migration[5.2]
  def up

    #SELECT * from switch18.lua_exec(1,('src_name_in','src_number_in','dst_number_in','src_name_out','src_number_out','dst_number_out','src_name_routing','src_number_routing','dst_number_routing',array['diversion_in'],array['diversion_out'],array['diversion_routing'])::switch17.lua_call_context); SELECT * from switch17.lua_exec(1,('src_name_in','src_number_in','dst_number_in','src_name_out','src_number_out','dst_number_out','src_name_routing','src_number_routing','dst_number_routing',array['diversion_in'],array['diversion_out'],array['diversion_routing'])::switch17.lua_call_context);

  execute %q{

      ALTER TABLE sys.lua_scripts ALTER COLUMN id TYPE smallint;

      alter table class4.customers_auth add lua_script_id smallint references sys.lua_scripts(id);
      alter table class4.numberlist_items add lua_script_id smallint references sys.lua_scripts(id);
      alter table class4.numberlists add lua_script_id smallint references sys.lua_scripts(id);
      alter table class4.gateways add lua_script_id smallint references sys.lua_scripts(id);

      CREATE EXTENSION pllua;

      CREATE TYPE switch17.lua_call_context as (
        src_name_in varchar,
        src_number_in varchar,
        dst_number_in varchar,
        src_name_out varchar,
        src_number_out varchar,
        dst_number_out varchar,
        src_name_routing varchar,
        src_number_routing varchar,
        dst_number_routing varchar,
        diversion_in varchar[],
        diversion_routing varchar[],
        diversion_out varchar[]
      );

      CREATE OR REPLACE FUNCTION switch17.lua_clear_cache()
      RETURNS void
      LANGUAGE 'pllua'
      COST 100
      VOLATILE AS
      $BODY$
        if shared.functions_cache ~= nil then
          for k in pairs(shared.functions_cache) do
            shared.functions_cache[k] = nil
          end
        end
      $BODY$;

      CREATE OR REPLACE FUNCTION switch17.lua_exec(
        function_id integer,
        arg switch17.lua_call_context
      ) RETURNS switch17.lua_call_context
      LANGUAGE 'pllua'
      COST 100
      VOLATILE AS
      $BODY$
        local ttl = 5 --seconds
        if shared.functions_cache == nil then
          setshared('functions_cache',{})
        end

        local cached_entry = shared.functions_cache[function_id]

        if cached_entry ~= nil then
          if os.time() < cached_entry.expire_at then
            -- execute cached function
            return cached_entry.func()(arg)
          end
          -- clear cache entry because of expired ttl
          shared.functions_cache[function_id] = nil
        end

        -- try to fetch and compile function
        if shared.prepared_user_function_query == nil then
          -- prepare and cache query
          setshared(
            'prepared_user_function_query',
             server.prepare('SELECT source FROM sys.lua_scripts WHERE id=$1',{"integer"}):save()
          )
        end

        local c = shared.prepared_user_function_query:getcursor({function_id}, true)
        local r = c:fetch(1)
        if r == nil then
          error("no user function with id: "..function_id)
        end

        shared.functions_cache[function_id] = {
          func = assert(load('return function(arg) ' .. r[1].source .. ' end')),
          expire_at = os.time()+ttl
        }
        return shared.functions_cache[function_id].func()(arg)

      $BODY$;
    }
  end

  def down
    execute %q{

      drop FUNCTION switch17.lua_clear_cache();

      drop FUNCTION switch17.lua_exec(
        function_id integer,
        arg switch17.lua_call_context
      );

      drop TYPE switch17.lua_call_context;

      drop EXTENSION pllua;


      ALTER TABLE sys.lua_scripts ALTER COLUMN id TYPE integer;

      alter table class4.customers_auth drop column lua_script_id;
      alter table class4.numberlist_items drop column lua_script_id;
      alter table class4.numberlists drop column lua_script_id;
      alter table class4.gateways drop column lua_script_id;

    }
  end

end
