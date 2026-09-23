# frozen_string_literal: true

class Cdr::Base < ApplicationRecord
  self.abstract_class = true

  def self.replica_configured?
    !configurations.configs_for(env_name: Rails.env, name: :cdr_replica, include_hidden: true).nil?
  end

  def self.database_config
    config = { writing: :cdr, reading: :cdr }
    config[:reading] = :cdr_replica if replica_configured?
    config
  end

  # nil without a configured replica: the reading role is the cdr database itself then.
  def self.replica_connection_pool
    connected_to(role: :reading) { connection_pool } if replica_configured?
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
