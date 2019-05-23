# frozen_string_literal: true

RSpec.shared_context :ransack_filter_setup do |opts|
  let(:pk) { opts && opts[:pk] || :id }

  def create_record(attrs = {})
    record_attrs = defined?(factory_attrs) ? attrs.merge(factory_attrs) : attrs
    if defined?(trait)
      create factory, trait, record_attrs
    else
      create factory, record_attrs
    end
  end

  def primary_key_for(record)
    record.try(pk).to_s
  end

  let(:subject_request) do
    get :index, params: { filter: { filter_key => filter_value } }
  end

  subject { response_data.map { |r| r['id'] } }
end
