class GwGroupSpellingFix < ActiveRecord::Migration[7.2]
  def up
    execute %q{
      update class4.codecs SET name = 'Priority/Weight balancing' 
      where name = 'Priority/Weigth balancing';

      update class4.codecs SET name = 'Priority/Weight balancing. Prefer gateways from same POP' 
      where name = 'Priority/Weigth balancing. Prefer gateways from same POP';

      update class4.codecs SET name = 'Priority/Weight balancing. Exclude gateways from other POPs' 
      where name = 'Priority/Weigth balancing. Exclude gateways from other POPs';
    }
  end

  def down
    execute %q{
      update class4.codecs SET name = 'Priority/Weigth balancing' 
      where name = 'Priority/Weight balancing';

      update class4.codecs SET name = 'Priority/Weigth balancing. Prefer gateways from same POP' 
      where name = 'Priority/Weight balancing. Prefer gateways from same POP';

      update class4.codecs SET name = 'Priority/Weigth balancing. Exclude gateways from other POPs' 
      where name = 'Priority/Weight balancing. Exclude gateways from other POPs';
    }
  end
end
