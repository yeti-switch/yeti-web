class Api::Rest::System::AdminUsersController < Api::RestController

  def index
    respond_with resource_collection(AdminUser.all)
  end

end