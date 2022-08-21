# frozen_string_literal: true

require 'shared_examples/shared_examples_for_importing_hook'

RSpec.xdescribe Importing::Gateway do
  include_context :init_contractor, name: 'iBasis', vendor: true

  include_context :init_gateway_group, name: 'iBasis Gateway Group'

  include_context :init_codec_group

  let(:preview_item) { described_class.last }

  subject do
    described_class.after_import_hook
    described_class.resolve_object_id([:name])
  end

  it_behaves_like 'after_import_hook when real items do not match' do
    include_context :init_importing_gateway,
                    o_id: 8,
                    name: 'iBasis-NYC-GW2',
                    gateway_group_id: nil,
                    contractor_id: nil,
                    session_refresh_method_id: nil,
                    sdp_alines_filter_type_id: nil,
                    orig_disconnect_policy_id: nil,
                    term_disconnect_policy_id: nil,
                    diversion_send_mode_id: nil,
                    pop_id: nil,
                    codec_group_id: nil,
                    sdp_c_location_id: nil,
                    sensor_level_id: nil,
                    dtmf_send_mode_id: nil,
                    dtmf_receive_mode_id: nil
  end

  it_behaves_like 'after_import_hook when real items match' do
    include_context :init_importing_gateway, name: 'SameName'
    include_context :init_gateway, name: 'SameName'

    let(:real_item) { described_class.import_class.last }
  end
end
