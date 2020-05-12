# frozen_string_literal: true

module ActsAsTotalsRelation
  def totals_row_by(*select_sql)
    safe_select_sql = Array(select_sql).join(', ')
    except(:preload, :includes, :eager_load, :limit, :offset, :select, :order)
      .pluck(Arel.sql(safe_select_sql))
      .first
  end
end
