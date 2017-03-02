class Api::Rest::Private::DialpeerNextRatesController < Api::RestController

  after_filter only: [:index] do
    send_x_headers(@dialpeer_next_rates)
  end

  before_filter do
    @dialpeer = Dialpeer.find(params[:dialpeer_id])
    @dialpeer_next_rates = @dialpeer.dialpeer_next_rates
  end

  before_filter only: [:show, :update, :delete] do
    @dialpeer_next_rate = @dialpeer_next_rates.find(params[:id])
  end


  def index
    @dialpeer_next_rates = resource_collection(@dialpeer_next_rates)
    respond_with(@dialpeer_next_rates)
  end

  def show
    respond_with(@dialpeer_next_rate, location: nil)
  end

  def create
    @dialpeer_next_rate = @dialpeer_next_rates.create(dialpeer_next_rate_params)
    respond_with(@dialpeer_next_rate, location: nil)
  end

  def update
    @dialpeer_next_rate.update(dialpeer_next_rate_params)
    respond_with(@dialpeer_next_rate, location: nil)
  end

  def destroy
    @dialpeer_next_rate.destroy!
    respond_with(@dialpeer_next_rate, location: nil)
  end

  private

  def dialpeer_next_rate_params
    params.require(:dialpeer_next_rate).permit(
        :rate,
        :initial_interval,
        :next_interval,
        :connect_fee,
        :apply_time,
        :external_id
    )
  end

end