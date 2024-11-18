# frozen_string_literal: true

RSpec.shared_context :acceptance_delete do |type:|
  resource_path = "/api/rest/admin/#{type}"

  delete "#{resource_path}/:id" do
    let(:id) { record.id }

    example_request 'delete entry' do
      expect(status).to eq(204)
    end
  end
end
