# frozen_string_literal: true

# @example usage:
#   include_examples :does_not_create_audit_log
RSpec.shared_examples :does_not_create_audit_log do
  it 'dos not create audit log' do
    expect { subject }.not_to change { AuditLogItem.count }
  end
end
