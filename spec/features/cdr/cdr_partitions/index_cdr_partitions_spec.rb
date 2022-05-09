# frozen_string_literal: true

RSpec.describe 'CDR Partitions index', type: :feature do
  include_context :login_as_admin

  before do
    RtpStatistics::TxStream.add_partition_for(1.minute.ago)
    RtpStatistics::RxStream.add_partition_for(1.minute.ago)
    Cdr::Cdr.add_partition_for(1.minute.ago)
    Cdr::AuthLog.add_partition_for(1.minute.ago)
  end

  it 'CDR Partitions is not crashing' do
    visit cdr_partitions_path
  end
end
