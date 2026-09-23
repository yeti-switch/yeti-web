# frozen_string_literal: true

class Cdr::Base < ApplicationRecord
  self.abstract_class = true

  def self.database_config
    config = { writing: :cdr, reading: :cdr }

    unless configurations.configs_for(env_name: Rails.env, name: :cdr_replica, include_hidden: true).nil?
      config[:reading] = :cdr_replica
    end

    config
  end

  def self.try_replica_with_fallback(&)
    connected_to(role: :reading, &)
  rescue *PG_CONNECTION_ERRORS => e
    Rails.logger.warn("Can't connect to replica #{e.message}, trying primary")
    connected_to(role: :writing, &)
  end

  connects_to(database: database_config)

  DB_VER = LazyObject.new { db_version }
end
