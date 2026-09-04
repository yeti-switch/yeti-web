# frozen_string_literal: true

class AddUuidToContractors < ActiveRecord::Migration[7.2]
  def up
    execute %q{
      ALTER TABLE public.contractors ADD COLUMN uuid uuid DEFAULT public.uuid_generate_v4() NOT NULL;
      ALTER TABLE public.contractors ADD CONSTRAINT contractors_uuid_key UNIQUE (uuid);
    }
  end

  def down
    execute %q{
      ALTER TABLE public.contractors DROP COLUMN uuid;
    }
  end
end
