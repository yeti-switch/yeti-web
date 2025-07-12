class ContractorNotNulls < ActiveRecord::Migration[7.2]
  def up
    execute %q{
      update public.contractors set enabled = false where enabled is null;
      update public.contractors set customer = false where customer is null;
      update public.contractors set vendor = false where vendor is null;
      update public.contractors set name = '' where name is null;

      alter table public.contractors
        alter column enabled set not null,
        alter column customer set not null,
        alter column vendor set not null,
        alter column name set not null;
    }
  end

  def down
    execute %q{
      alter table public.contractors
        alter column enabled drop not null,
        alter column customer drop not null,
        alter column vendor drop not null,
        alter column name drop not null;
    }
  end
end
