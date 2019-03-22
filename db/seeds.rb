# frozen_string_literal: true

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
  'switch13',
  'switch14',
  'switch15',
  'switch16',
  'switch17',
  'sys'
].each do |filename|
  execute_sql_file("db/seeds/main/#{filename}.sql")
end

# "Cdr" database
%w[
  pgq
  billing
  reports
  sys
].each do |filename|
  execute_sql_file("db/seeds/cdr/#{filename}.sql", Cdr::Base.connection)
end

# Create partition for current+next monthes if not exists
Cdr::Table.add_partition
Cdr::AuthLogTable.add_partition
Cdr::RtpStatistic.add_partitions
