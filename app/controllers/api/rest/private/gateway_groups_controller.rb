class Api::Rest::Private::GatewayGroupsController < Api::RestController

  after_action only: [:index] do
    send_x_headers(@gateway_groups)
  end

  before_action only: [:show, :update, :destroy] do
    @gateway_group = GatewayGroup.find(params[:id])
  end


  def index
    @gateway_groups = resource_collection(GatewayGroup.all)
    respond_with(@gateway_groups)
  end

  def show
    respond_with(@gateway_group, location: nil)
  end

  def create
    @gateway_group = GatewayGroup.create(gateway_group_params)
    respond_with(@gateway_group, location: nil)
  end

  def update
    @gateway_group.update(gateway_group_params)
    respond_with(@gateway_group, location: nil)
  end

  def destroy
    @gateway_group.destroy!
    respond_with(@gateway_group, location: nil)
  end

  private

  def gateway_group_params
    params.require(:gateway_group).permit(
      :name,
      :vendor_id
    )
  end
end
