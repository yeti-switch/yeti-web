class RemoteStatsController < ApplicationController

  #ActiveModel::Serializers::JSON.include_root_in_json disabled because out JS charts use old format - without root
  #TODO fix JS and enable include_root_in_json

  before_action :authenticate_admin_user!

  respond_to :json

  def profit
    expires_in 10.minutes, public: true
    render json: Stats::TrafficCustomerAccount.stats(:profit, 48).to_json(root: false)
  end

  def duration
    expires_in 10.minutes, public: true
    render json:Stats::TrafficCustomerAccount.stats(:duration, 48).to_json(root: false)
  end

  def nodes
    expires_in 1.minutes, public: true
    render json:Stats::ActiveCall.to_stacked_chart.to_json(root: false)
  end

  def vendors_traffic
    expires_in 2.minutes, public: true
    render json:Stats::TrafficVendorAccount.to_chart(params[:id]).to_json(root: false)
  end

  def customers_traffic
    expires_in 2.minutes, public: true
    render json:Stats::TrafficCustomerAccount.to_chart(params[:id]).to_json(root: false)
  end


  def hour_nodes
    #expires_in 1.minutes, public: true
    render json:Stats::ActiveCall.to_stacked_chart(1).to_json(root: false)
  end

  def node
    expires_in 1.minutes, public: true
    render json:Stats::ActiveCall.to_chart(params[:id]).to_json(root: false)
  end

  def aggregated_node
    expires_in 30.minutes, public: true
    render json:Stats::AggActiveCall.to_chart(params[:id]).to_json(root: false)
  end

  def cdrs_summary
    #TODO rewrite this SHIT
    @data=CdrSummaryDecorator.new(Cdr::Cdr.ransack(clean_search_params params[:q].to_unsafe_h).result.scoped_stat)
    respond_with(
        originated_calls_count: @data.originated_calls_count,
        rerouted_calls_count: @data.rerouted_calls_count,
        rerouted_calls_percent: @data.rerouted_calls_percent,
        termination_attempts_count: @data.termination_attempts_count,
        calls_duration: @data.decorated_calls_duration,
        acd: @data.decorated_acd,
        origination_asr: @data.decorated_origination_asr,
        termination_asr: @data.decorated_termination_asr,
        profit: @data.decorated_profit,
        origination_cost: @data.decorated_customer_price,
        termination_cost: @data.decorated_vendor_price
    )
  end

  def cdrs_summary_archive
    #TODO rewrite this SHIT
    @data=CdrSummaryDecorator.new(Cdr::CdrArchive.ransack(clean_search_params params[:q].to_unsafe_h).result.scoped_stat)
    respond_with(
        originated_calls_count: @data.originated_calls_count,
        rerouted_calls_count: @data.rerouted_calls_count,
        rerouted_calls_percent: @data.rerouted_calls_percent,
        termination_attempts_count: @data.termination_attempts_count,
        calls_duration: @data.decorated_calls_duration,
        acd: @data.decorated_acd,
        origination_asr: @data.decorated_origination_asr,
        termination_asr: @data.decorated_termination_asr,
        profit: @data.decorated_profit,
        origination_cost: @data.decorated_customer_price,
        termination_cost: @data.decorated_vendor_price
    )
  end


  def term_gateway
    expires_in 2.minutes, public: true
    render json:Stats::ActiveCallTermGateway.to_chart(params[:id]).to_json(root: false)
  end

  def aggregated_term_gateway
    expires_in 10.minutes, public: true
    render json:Stats::AggActiveCallTermGateway.to_chart(params[:id]).to_json(root: false)
  end

  def orig_gateway
    expires_in 2.minutes, public: true
    render json: Stats::ActiveCallOrigGateway.to_chart(params[:id]).to_json(root: false)
  end


  def aggregated_orig_gateway
    expires_in 10.minutes, public: true
    render json:Stats::AggActiveCallOrigGateway.to_chart(params[:id]).to_json(root: false)
  end

  def aggregated_customer_account
    expires_in 10.minutes, public: true
    render json:Stats::AggActiveCallCustomerAccount.to_chart(params[:id]).to_json(root: false)
  end

  def aggregated_vendor_account
    expires_in 10.minutes, public: true
    render json:Stats::AggActiveCallVendorAccount.to_chart(params[:id]).to_json(root: false)
  end

  ######

  def account_active_calls
    expires_in 2.minutes, public: true
    render json:Stats::ActiveCallAccount.new(params[:id]).to_chart.to_json(root: false)
  end

  def customer_account
    expires_in 2.minutes, public: true
    render json: Stats::ActiveCallCustomerAccount.to_chart(params[:id]).to_json(root: false)
  end

  def vendor_account
    expires_in 2.minutes, public: true
    render json:Stats::ActiveCallVendorAccount.to_chart(params[:id]).to_json(root: false)
  end

  def gateway_pdd_distribution
    expires_in 2.minutes, public: true
    render json:Stats::TerminationQualityStat.to_pdd_gateway_chart(params[:id]).to_json(root: false)
  end

  def dialpeer_pdd_distribution
    expires_in 2.minutes, public: true
    render json:Stats::TerminationQualityStat.to_pdd_dialpeer_chart(params[:id]).to_json(root: false)
  end

  private
  def clean_search_params(params)
    if params.is_a? Hash
      params.dup.delete_if { |_, value| value.blank? }
    else
      {}
    end
  end

end
