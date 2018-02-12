class Api::Rest::System::IpAccessController < Api::RestController

  def index
    respond_with addresses
  end

  private

  def addresses
    CustomersAuthNormalized
      .pluck(:ip)
      .uniq
      .map { |ip| IPAddr.new(ip) }
      .map { |ip| "#{ip.to_s}/#{ip.cidr_mask}" }
      .uniq
  end
end
