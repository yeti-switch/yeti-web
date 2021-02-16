# frozen_string_literal: true

class Api::Rest::System::IpAccessController < Api::RestController
  def index
    render json: addresses
  end

  private

  def addresses
    CustomersAuthNormalized
      .pluck(:ip)
      .uniq
      .map { |ip| IPAddr.new(ip) }
      .map { |ip| "#{ip}/#{ip.cidr_mask}" }
      .uniq
  end
end
