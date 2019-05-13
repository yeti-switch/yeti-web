class AddLegbRuri < ActiveRecord::Migration[5.2]
  def up
    execute %q{
        alter table cdr.cdr add legb_ruri varchar;
        alter table cdr.cdr_archive add legb_ruri varchar;
    }
  end

  def down
    execute %q{
        alter table cdr.cdr drop column legb_ruri;
        alter table cdr.cdr_archive drop column legb_ruri;
    }
  end
end
