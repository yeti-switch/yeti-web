# frozen_string_literal: true

module RspecSqlHelper
  def yeti_execute(sql, *bindings)
    SqlCaller::Yeti.yeti_execute(sql, *bindings)
  end

  def yeti_select_all(sql, *bindings)
    SqlCaller::Yeti.select_all(sql, *bindings).map(&:symbolize_keys)
  end
end
