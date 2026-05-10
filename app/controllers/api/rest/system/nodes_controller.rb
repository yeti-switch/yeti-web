# frozen_string_literal: true

class Api::Rest::System::NodesController < Api::RestController
  include SystemApiAuthorizable

  def index
    respond_with resource_collection(Node.includes(:pop).all)
  end
end
