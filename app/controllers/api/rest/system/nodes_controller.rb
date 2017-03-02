class Api::Rest::System::NodesController < Api::RestController

  def index
    respond_with resource_collection(Node.includes(:pop).all)
  end

end