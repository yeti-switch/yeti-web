# frozen_string_literal: true

class Api::Rest::System::AdminUsersController < Api::RestController
  include SystemApiAuthorizable

  def index
    respond_with resource_collection(AdminUser.all)
  end
end
