RSpec.shared_context :acceptance_delete do |namespace: nil, type:|

  resource_path = begin
                    str = "/api/rest/admin"
                    str += "/#{namespace}" if namespace
                    str + "/#{type}"
                  end

  delete "#{resource_path}/:id" do
    let(:id) { record.id }

    example_request 'delete entry' do
      expect(status).to eq(204)
    end
  end

end
