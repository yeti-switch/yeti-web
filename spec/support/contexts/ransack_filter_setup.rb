# frozen_string_literal: true

RSpec.shared_context :ransack_filter_setup do
  def create_record(attrs = {})
    if defined?(trait)
      create factory, trait, attrs
    else
      create factory, attrs
    end
  end

  let(:subject_request) do
    get :index, params: { filter: { filter_key => filter_value } }
  end

  subject { response_data.map { |r| r['id'] } }
end
