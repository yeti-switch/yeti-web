class Cdr::Base < Yeti::ActiveRecord
  self.abstract_class = true
  establish_connection "#{Rails.env}_cdr".to_sym


  DB_VER = db_version
end
