class TeamsDns < ActiveRecord::Migration[7.2]
  def up
    execute %q{
      create schema dns;
      create table dns.dns_zones(
        id smallserial primary key,
        name varchar not null unique,
        soa_mname varchar not null,
        soa_rname varchar not null,
        serial bigint not null default 0,
        refresh smallint not null default 600,
        retry smallint not null default 600,
        expire smallint not null default 1800,
        minimum smallint not null default 3600
      );

      create table dns.dns_records(
        id serial primary key,
        zone_id smallint not null references dns.dns_zones(id),
        name varchar not null,
        record_type varchar not null,
        content varchar not null,
        contractor_id integer references public.contractors(id)
      );

      create index on dns.dns_records using btree (zone_id);
      create index on dns.dns_records using btree (contractor_id);
    }
  end

  def down
    execute %q{
      drop schema dns cascade;
    }
  end

end
