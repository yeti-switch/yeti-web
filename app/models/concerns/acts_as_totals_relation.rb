# frozen_string_literal: true

module ActsAsTotalsRelation
  def totals_row_by(*select_sql)
    safe_select_sql = select_sql.map { |sql| Arel.sql(sql) }
    except(:preload, :includes, :eager_load, :limit, :offset, :select, :order)
      .pluck(safe_select_sql)
      .first
  end
end
