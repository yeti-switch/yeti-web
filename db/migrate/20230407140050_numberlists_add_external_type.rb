class NumberlistsAddExternalType < ActiveRecord::Migration[7.0]
  def up
    execute 'ALTER TABLE class4.numberlists DROP CONSTRAINT numberlists_external_id_key'

    add_column 'class4.numberlists', :external_type, :string
    execute %q{
        CREATE UNIQUE INDEX numberlists_external_id_key_uniq
            ON class4.numberlists USING btree (external_id)
            WHERE external_type IS NULL
    }
    execute %q{
        CREATE UNIQUE INDEX numberlists_external_id_external_type_key_uniq
            ON class4.numberlists USING btree(external_id,external_type)
    }
  end

  def down
    execute 'DROP INDEX numberlists_external_id_key_uniq'
    execute 'DROP INDEX numberlists_external_id_external_type_key_uniq'
    remove_column 'class4.numberlists', :external_type

    execute 'ALTER TABLE ONLY class4.numberlists ADD CONSTRAINT numberlists_external_id_key UNIQUE (external_id)'
  end
end
