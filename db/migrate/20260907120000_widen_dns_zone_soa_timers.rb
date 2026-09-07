# frozen_string_literal: true

class WidenDnsZoneSoaTimers < ActiveRecord::Migration[7.2]
  def up
    execute %q{
      alter table dns.dns_zones alter column refresh type integer;
      alter table dns.dns_zones alter column retry type integer;
      alter table dns.dns_zones alter column expire type integer;
      alter table dns.dns_zones alter column minimum type integer;
    }
  end

  def down
    execute %q{
      alter table dns.dns_zones alter column refresh type smallint;
      alter table dns.dns_zones alter column retry type smallint;
      alter table dns.dns_zones alter column expire type smallint;
      alter table dns.dns_zones alter column minimum type smallint;
    }
  end
end
