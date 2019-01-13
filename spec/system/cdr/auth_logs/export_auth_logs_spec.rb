# frozen_string_literal: true

require 'spec_helper'

describe 'Export Auth Logs' do
  include_context :login_as_admin

  before { create(:gateway) }

  let!(:item) do
    create :auth_log, :with_id
  end

  before do
    visit auth_logs_path(format: :csv)
  end

  subject { CSV.parse(page.body).slice(0, 2).transpose }

  it 'has expected header and values' do
    expect(subject).to match_array(
      [
        ['Id', item.id.to_s],
        ['Request time', item.request_time.to_s],
        ['Pop name', item.pop.try(:name)],
        ['Node name', item.node.try(:name)],
        ['Gateway name', item.gateway.try(:name)],
        ['Transport protocol', item.transport_protocol.try(:name)],
        ['Transport remote ip', item.transport_remote_ip.to_s],
        ['Transport remote port', item.transport_remote_port.to_s],
        ['Transport local ip', item.transport_local_ip.to_s],
        ['Transport local port', item.transport_local_port.to_s],
        ['Origination protocol', item.origination_protocol.try(:name)],
        ['Origination ip', item.origination_ip.to_s],
        ['Origination port', item.origination_port.to_s],
        ['Username', item.username.to_s],
        ['Realm', item.realm.to_s],
        ['Request method', item.request_method.to_s],
        ['Ruri', item.ruri.to_s],
        ['From uri', item.from_uri.to_s],
        ['To uri', item.to_uri.to_s],
        ['Call', item.call_id.to_s],
        ['Success', item.success.to_s],
        ['Code', item.code.to_s],
        ['Reason', item.reason.to_s],
        ['Internal reason', item.internal_reason.to_s],
        ['Nonce', item.nonce.to_s],
        ['Response', item.response.to_s],
        ['X yeti auth', item.x_yeti_auth.to_s],
        ['Diversion', item.diversion.to_s],
        ['Pai', item.pai.to_s],
        ['Ppi', item.ppi.to_s],
        ['Privacy', item.privacy.to_s],
        ['Rpid', item.rpid.to_s],
        ['Rpid privacy', item.rpid_privacy.to_s]

      ]
    )
  end
end
