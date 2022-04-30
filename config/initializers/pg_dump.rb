# frozen_string_literal: true

ActiveRecord::Tasks::DatabaseTasks.structure_dump_flags = [
  '-T', 'cdr.cdr_2*',
  '-T', 'auth_log.auth_log_2*',
  '-T', 'rtp_statistics.streams_2*',
  '-T', 'rtp_statistics.rx_streams_2*',
  '-T', 'rtp_statistics.tx_streams_2*',
  '-T', 'logs.api_requests_2*',
  '-T', 'pgq.*',
  '-T', 'pgq_ext.*'
]
