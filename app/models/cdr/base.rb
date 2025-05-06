# frozen_string_literal: true

class Cdr::Base < ApplicationRecord
  def self.database_config
    config = { writing: :cdr, reading: :cdr }

    unless configurations.configs_for(env_name: Rails.env, name: :cdr_replica, include_hidden: true).nil?
      config[:reading] = :cdr_replica
    end

    config
  end

  self.abstract_class = true
  connects_to(database: database_config)

  DB_VER = LazyObject.new { db_version }
end
