# frozen_string_literal: true

class FixDnsZoneSoaDefaults < ActiveRecord::Migration[7.2]
  def up
    execute %q{
      alter table dns.dns_zones alter column expire set default 1209600;
      alter table dns.dns_zones alter column minimum set default 300;

      update dns.dns_zones set expire = 1209600 where expire = 1800;
      update dns.dns_zones set minimum = 300 where minimum = 3600;
    }
  end

  def down
    execute %q{
      alter table dns.dns_zones alter column expire set default 1800;
      alter table dns.dns_zones alter column minimum set default 3600;

      update dns.dns_zones set expire = 1800 where expire = 1209600;
      update dns.dns_zones set minimum = 3600 where minimum = 300;
    }
  end
end
