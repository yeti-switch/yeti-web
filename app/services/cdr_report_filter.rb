# frozen_string_literal: true

# Builds a safe CDR filter relation from a report's stored `filter`, expressed
# as a Ransack query string, e.g. "duration_gt=60&success_eq=true".
#
# Ransack whitelists attributes/predicates (Cdr::Cdr.ransackable_attributes) and
# binds values as query parameters, so nothing from the filter is interpolated
# into SQL — this replaces the previous `scope.where(report.filter)`, which
# concatenated raw user input into the query (SQL injection).
#
# Ransack is configured with `ignore_unknown_conditions = false`, so an unknown
# attribute or predicate raises rather than being silently dropped; that is used
# both to reject invalid filters at form-validation time and as a safety net.
module CdrReportFilter
  # Foreign-key columns that get a searchable AJAX value dropdown, mapped to the
  # existing `search_support!` endpoints (return [{id, value}, ...]).
  ASSOCIATION_SEARCH = {
    customer_id: { path: '/contractors/search', params: { q: { customer_eq: true } } },
    vendor_id: { path: '/contractors/search', params: { q: { vendor_eq: true } } },
    customer_acc_id: { path: '/accounts/search', params: {} },
    vendor_acc_id: { path: '/accounts/search', params: {} },
    customer_auth_id: { path: '/customers_auths/search', params: {} },
    orig_gw_id: { path: '/gateways/search', params: { q: { allow_origination_eq: true } } },
    term_gw_id: { path: '/gateways/search', params: { q: { allow_termination_eq: true } } }
  }.freeze

  # Ransack predicates offered per value kind. All are valid Ransack predicates
  # (cont/start/end are native; gteq_datetime/lteq_datetime are registered in
  # config/initializers/ransack.rb), so a built condition passes #error_for.
  PREDICATES_BY_KIND = {
    'number' => %w[eq not_eq gt gteq lt lteq in],
    'string' => %w[eq not_eq cont start end in],
    'boolean' => %w[eq],
    'datetime' => %w[gteq_datetime lteq_datetime eq],
    'association' => %w[eq in]
  }.freeze

  module_function

  # Metadata that drives the condition-builder UI: one entry per filterable
  # column with its value kind, available predicates, and (for FKs) the search
  # endpoint for the value dropdown.
  # @param columns [Array<Symbol,String>]
  # @return [Array<Hash>]
  def columns_metadata(columns = Report::CustomCdr::CDR_COLUMNS)
    columns.map do |name|
      kind = column_kind(name)
      meta = {
        name: name.to_s,
        label: name.to_s.humanize,
        value_type: kind,
        predicates: PREDICATES_BY_KIND.fetch(kind, %w[eq not_eq])
      }
      meta[:search] = ASSOCIATION_SEARCH[name.to_sym] if kind == 'association'
      meta
    end
  end

  # @return [String] one of 'association', 'number', 'boolean', 'datetime', 'string'
  def column_kind(name)
    return 'association' if ASSOCIATION_SEARCH.key?(name.to_sym)

    case Cdr::Cdr.columns_hash[name.to_s]&.type
    when :integer, :decimal, :float then 'number'
    when :boolean then 'boolean'
    when :datetime, :timestamptz, :date, :time then 'datetime'
    else 'string'
    end
  end

  # @param filter [String, nil]
  # @return [Hash] Ransack conditions hash
  def parse(filter)
    Rack::Utils.parse_nested_query(filter.to_s)
  end

  # @param filter [String, nil]
  # @return [ActiveRecord::Relation] where-only relation to merge into a scope
  # @raise [ArgumentError] on an unknown attribute/predicate
  def relation(filter)
    Cdr::Cdr.ransack(parse(filter)).result
  end

  # Validate a filter string.
  # @return [String, nil] an error message, or nil when valid/blank
  def error_for(filter)
    return if filter.blank?

    search = Cdr::Cdr.ransack(parse(filter))
    search.result.to_sql # force the query to build; raises on unknown attr/predicate
    # Ransack silently drops conditions with blank values and (with this app's
    # config) raises on unknown ones. If nothing survived, the input wasn't a
    # usable Ransack query (e.g. raw SQL like "duration > 0") — reject it so the
    # filter isn't silently ignored.
    return 'is not a valid filter expression (use Ransack, e.g. duration_gt=60)' if search.conditions.blank?

    nil
  rescue StandardError => e
    e.message
  end
end
