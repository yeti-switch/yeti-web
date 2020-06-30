# frozen_string_literal: true

RSpec.describe 'Index Report Realtime Termination Distributions' do
  include_context :login_as_admin
  include_context :init_routing_tag_collection

  let!(:customer) { create :customer }
  let!(:account) { create :account, contractor: customer }
  let!(:customers_auth) { create :customers_auth, customer: customer }
  let!(:destination) { create :destination }
  let!(:dialpeer) { create :dialpeer }
  let!(:rateplan) { create :rateplan }
  let!(:pop) { Pop.take || create(:pop) }
  let!(:node) { Node.take || create(:node) }
  let(:destination_rate_policy) { DestinationRatePolicy.take! }
  let(:dump_level) { DumpLevel.take! }

  it 'n+1 checks' do
    termination_distributions = create_list(:realtime_termination_distribution, 2,
                                            customer: customer,
                                            customer_acc: account,
                                            customer_auth: customers_auth,
                                            destination: destination,
                                            dialpeer: dialpeer,
                                            rateplan: rateplan,
                                            destination_rate_policy: destination_rate_policy,
                                            pop: pop,
                                            node: node,
                                            routing_tag_ids: [@tag_us.id, @tag_ua.id])
    visit report_realtime_termination_distributions_path
    termination_distributions.each do |td|
      expect(page).to have_css('.col-id', text: td.id)
    end
  end
end
