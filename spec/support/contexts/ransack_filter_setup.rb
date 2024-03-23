# frozen_string_literal: true

RSpec.shared_context :ransack_filter_setup do
  def create_record(attrs = {})
    record_attrs = defined?(factory_attrs) ? attrs.merge(factory_attrs) : attrs
    if defined?(trait)
      create_record_with_trait(factory, trait, record_attrs)
    else
      create factory, record_attrs
    end
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

  let(:response_ids) do
    response_data.map { |r| r['id'] }
  end
  let(:json_api_request_query) do
    current = super() || {}
    current.deep_merge(filter: { filter_key => filter_value })
  end
end
