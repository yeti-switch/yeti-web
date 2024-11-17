# frozen_string_literal: true

RSpec.shared_context :acceptance_index_show do |type:|
  # let(:collection) { ModelClass.all }
  # let(:record) { ModelClass.take  }

  let(:type) { type }

  resource_path = "/api/rest/admin/#{type}"

  get resource_path do
    before { collection }

    example_request 'get listing' do
      expect(status).to eq(200)
    end
  end

  get "#{resource_path}/:id" do
    let(:id) { record.id }

    example_request 'get specific entry' do
      expect(status).to eq(200)
    end
  end
end
