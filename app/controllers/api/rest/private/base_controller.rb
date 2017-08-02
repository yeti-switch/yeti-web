class Api::Rest::Private::BaseController < Api::RestController
  include Knock::Authenticable
  undef :current_admin_user

  before_action :authenticate_admin_user
end
