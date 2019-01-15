# frozen_string_literal: true

class Cdr::Base < Yeti::ActiveRecord
  self.abstract_class = true
  establish_connection SecondBase.config

  DB_VER = LazyObject.new { db_version }
end
