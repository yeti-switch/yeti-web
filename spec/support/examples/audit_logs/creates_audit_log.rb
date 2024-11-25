# frozen_string_literal: true

# @example usage:
#   include_examples :creates_audit_log do
#     let(:audit_log_attrs) do
#       item = Account.last
#       { event: 'create', item_id: item.id, item_type: item.class.name, whodunnit: admin_user.id.to_s }
#     end
#   end
#  # when several items are created at once
#  include_examples :creates_audit_log, qty: 2 do
#    let(:audit_log_attrs) do
#      [Account.last, CustomersAuth.last].map do |item|
#        { event: 'create', item_id: item.id, item_type: item.class.name, whodunnit: admin_user.id.to_s }
#      end
#    end
#  end
RSpec.shared_examples :creates_audit_log do |qty: 1, ordered: false|
  # Note: we didn't calculate qty by audit_log_attrs, because we want it to be called only after subject,
  # so we could use subject result in audit_log_attrs.

  it 'creates audit log', :aggregate_failures do
    expect { subject }.to change { AuditLogItem.count }.by(qty)
    logs = AuditLogItem.last(qty)
    actual_attrs_list = logs.map { |log| log.attributes.symbolize_keys }
    expected_attrs_list = Array.wrap(audit_log_attrs).map { |attrs| hash_including(attrs) }

    if ordered
      expected_attrs_list.each_with_index do |expected_attrs, index|
        expect(actual_attrs_list[index]).to match(expected_attrs)
      end
    else
      expect(actual_attrs_list).to match_array(expected_attrs_list)
    end
  end
end
