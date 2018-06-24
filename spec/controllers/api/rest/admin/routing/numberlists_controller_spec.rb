RSpec.describe Api::Rest::Admin::Routing::NumberlistsController, type: :controller do

  include_context :jsonapi_admin_headers

  describe 'editable tag_action and tag_action_value' do

    include_examples :jsonapi_resource_with_multiple_tags do
      let(:resource_type) { 'numberlists' }
      let(:factory_name) { :numberlist }
    end
  end
end

