class Api::Rest::System::IpAccessController < Api::RestController

  def index
    respond_with addresses
  end

  private

  def addresses
    CustomersAuth.all.map{|a| "#{a.ip.to_s}/#{a.ip.cidr_mask}"}.uniq
  end
end