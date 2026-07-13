# frozen_string_literal: true

RSpec.shared_context :ransack_filter_setup do
  def create_record(attrs = {})
    record_attrs = defined?(factory_attrs) ? attrs.merge(factory_attrs) : attrs
    record =
      if defined?(trait)
        create_record_with_trait(factory, trait, record_attrs)
      else
        create factory, record_attrs
      end
    # Specs whose endpoint only exposes records linked to the authenticated
    # principal (customer-v1 filters gate visibility by customers_auth and token
    # allow-lists) define `authorize_ransack_record` to make each created record
    # visible. The collapsed shared examples build every covering record through
    # here, so the hook runs once per record regardless of the covering-set size
    # or its internal naming (suitable_record / smaller_record / record_str ...).
    authorize_ransack_record(record) if respond_to?(:authorize_ransack_record)
    record
  end

  def create_record_with_trait(factory, trait, record_attrs)
    if trait.is_a?(Array)
      create factory, *trait, record_attrs
    else
      create factory, trait, record_attrs
    end
  end

  def primary_key_for(record)
    primary_key = defined?(pk) ? pk : :id
    record.try(primary_key).to_s
  end

  # Issue a fresh index request with `filter` merged onto the spec's base query,
  # then assert primary-key inclusion/exclusion. Unlike the memoized `subject`,
  # this is re-issuable within a single example (Rails rebuilds request/response
  # on every `get`), so a whole operator matrix collapses into one example under
  # `aggregate_failures` instead of one example (with duplicate record inserts)
  # per operator.
  def assert_filter(filter_key, filter_value, includes:, excludes:)
    perform_ransack_filter_request(filter_key => filter_value)
    ids = response_data.map { |record| record['id'] }
    Array.wrap(includes).each do |record|
      expect(ids).to include(primary_key_for(record)),
                     "filter #{filter_key}=#{filter_value.inspect} expected to include id " \
                     "#{primary_key_for(record)}, got #{ids.inspect}"
    end
    Array.wrap(excludes).each do |record|
      expect(ids).not_to include(primary_key_for(record)),
                         "filter #{filter_key}=#{filter_value.inspect} expected to exclude id " \
                         "#{primary_key_for(record)}, got #{ids.inspect}"
    end
  end

  # Runs one index request with `filter` deep-merged onto the spec's base query.
  # Request specs (which define json_api_request_path) go through the HTTP path;
  # controller specs hit `get :index`.
  def perform_ransack_filter_request(filter)
    query = (json_api_request_query || {}).deep_merge(filter: filter)
    if respond_to?(:json_api_request_path)
      get json_api_request_path, params: query, headers: json_api_request_headers
    else
      get :index, params: query
    end
  end

  let(:response_ids) do
    response_data.map { |r| r['id'] }
  end
  let(:json_api_request_query) do
    base = super() || {}
    # Legacy single-filter examples (filter_by_name / filter_by_external_id and
    # the inline controller filter contexts) set filter_key/filter_value and
    # expect them merged in here. The collapsed matrix examples leave them unset
    # and inject each operator's filter per-request via assert_filter instead.
    return base unless respond_to?(:filter_key) && filter_key

    base.deep_merge(filter: { filter_key => filter_value })
  end
end
