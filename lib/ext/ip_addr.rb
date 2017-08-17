class IPAddr
  def cidr_mask
    case (@family)
    when Socket::AF_INET
      32 - Math.log2((1<<32) - @mask_addr).to_i
    when Socket::AF_INET6
      128 - Math.log2((1<<128) - @mask_addr).to_i
    else
      raise AddressFamilyError, "unsupported address family"
    end
  end
end