ActiveAdmin.register CustomersAuthNormalized, as: 'Normalized Copies' do
  belongs_to :customers_auth

  menu false

  actions :index, :show

  config.batch_actions = false
  config.filters = false

end
