# frozen_string_literal: true

class CdrBase < ActiveRecord::Base
  self.abstract_class = true

  def self.execute_sp(sql, *bindings)
    perform_sp(:execute, sql, *bindings)
  end

  def self.fetch_sp(sql, *bindings)
    perform_sp(:select_all, sql, *bindings)
  end

  def self.fetch_sp_val(sql, *bindings)
    perform_sp(:select_value, sql, *bindings)
  end

  protected

  def self.perform_sp(method, sql, *bindings)
    sql = send(:sanitize_sql_array, bindings.unshift(sql)) if bindings.any?
    connection.send(method, sql)
  end
end
