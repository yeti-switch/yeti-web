class Api::Rest::Private::ContractorsController < Api::RestController

  after_action only: [:index] do
    send_x_headers(@contractors)
  end

  before_action :set_contractor, only: [:show, :update, :destroy]

  def index
    @contractors = resource_collection(Contractor.all)
    respond_with @contractors, serializer: ActiveModel::ArraySerializer, each_serializer: ContractorSerializer
  end

  def show
    respond_with @contractor, location: nil
  end

  def create
    @contractor = Contractor.create(contractor_params)
    respond_with @contractor, location: nil
  end

  def update
    @contractor.update(contractor_params)
    respond_with @contractor, location: nil
  end

  def destroy
    @contractor.destroy!
    respond_with(@contractor, location: nil)
  end

  private

  def set_contractor
    @contractor = Contractor.find(params[:id])
  end

  def contractor_params
    params.require(:contractor).permit(
      :name,
      :enabled,
      :vendor,
      :customer,
      :description,
      :address,
      :phones,
      :smtp_connection_id
    )
  end
end
