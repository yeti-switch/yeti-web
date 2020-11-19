# frozen_string_literal: true

RSpec.describe BillingInvoice::Fill do
  subject do
    described_class.call(service_params)
  end

  let(:service_params) {}
end
