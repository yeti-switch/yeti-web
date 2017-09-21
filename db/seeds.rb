# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#

# Use seeds in migration. Example "/db/migrate/20170821071806_add_seed_data.rb"

def execute_sql_file(path, connection = ActiveRecord::Base.connection)
  connection.execute(IO.read(path))
end

# "Yeti" database
[
  'pgq',
  'billing',
  'class4',
  'gui',
  'notifications', # depends on gui.admin_users
  'switch4',
  'switch5',
  'switch6',
  'switch7',
  'switch8',
  'switch9',
  'switch10',
  'switch11',
  'switch12',
  'switch13',
  'sys'
].each do |filename|
  execute_sql_file("db/seeds/main/#{filename}.sql");
end

# "Cdr" database
[
  'pgq',
  'billing',
  'reports',
  'sys'
].each do |filename|
  execute_sql_file("db/seeds/cdr/#{filename}.sql", Cdr::Base.connection);
end
