# frozen_string_literal: true

require 'spec_helper'

describe 'Edit Customers Auth' do
  include_context :login_as_admin

  context 'unset "Tag action value"' do
    include_examples :test_unset_tag_action_value,
                     controller_name: :customers_auths,
                     factory: :customers_auth do

      let(:contractor) { create(:customer) }
      let(:account) { create(:account, contractor: contractor) }
      let(:gateway) { create(:gateway, contractor: contractor) }

      let(:record) do
        create(:customers_auth,
               customer: contractor,
               account: account,
               gateway: gateway,
               tag_action_value: [tag.id])
      end
    end
  end
end
