class Api::Rest::Private::CustomersAuthsController < Api::Rest::Private::BaseController

  after_action only: [:index] do
    send_x_headers(@customers_auths)
  end

  before_action only: [:show, :update, :destroy] do
    @customers_auth = CustomersAuth.find(params[:id])
  end


  def index
    @customers_auths = resource_collection(CustomersAuth.all)
    respond_with(@customers_auths)
  end

  def show
    respond_with(@customers_auth, location: nil)
  end

  def create
    @customers_auth = CustomersAuth.create(customers_auth_params)
    respond_with(@customers_auth, location: nil)
  end

  def update
    @customers_auth.update(customers_auth_params)
    respond_with(@customers_auth, location: nil)
  end

  def destroy
    @customers_auth.destroy!
    respond_with(@customers_auth, location: nil)
  end

  private

  def customers_auth_params
    params.require(:customers_auth).permit(
      :name,
      :customer_id,
      :rateplan_id,
      :enabled,
      :ip,
      :account_id,
      :gateway_id,
      :src_rewrite_rule,
      :src_rewrite_result,
      :dst_rewrite_rule,
      :dst_rewrite_result,
      :src_prefix,
      :dst_prefix,
      :x_yeti_auth,
      :name,
      :dump_level_id,
      :capacity,
      :pop_id,
      :uri_domain,
      :src_name_rewrite_rule,
      :src_name_rewrite_result,
      :diversion_policy_id,
      :diversion_rewrite_rule,
      :diversion_rewrite_result,
      :dst_numberlist_id,
      :src_numberlist_id,
      :routing_plan_id,
      :allow_receive_rate_limit,
      :send_billing_information,
      :radius_auth_profile_id,
      :enable_audio_recording,
      :src_number_radius_rewrite_rule,
      :src_number_radius_rewrite_result,
      :dst_number_radius_rewrite_rule,
      :dst_number_radius_rewrite_result,
      :radius_accounting_profile_id,
      :from_domain,
      :to_domain,
      :transport_protocol_id
    )
  end
end
