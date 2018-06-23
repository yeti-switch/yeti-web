RSpec.resource 'Routin NumberlistActions' do
  include_context :acceptance_admin_user

  let(:collection) { Routing::NumberlistAction.all }
  let(:record) { Routing::NumberlistAction.take }

  include_context :acceptance_index_show, namespace: 'routing', type: 'numberlist-actions'

end
