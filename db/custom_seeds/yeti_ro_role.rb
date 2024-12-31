# frozen_string_literal: true

routing_role = 'yeti_ro'
routing_schemas = %w[
  billing
  class4
  data_import
  gui
  lnp
  logs
  notifications
  ratemanagement
  runtime_stats
  sys
]
routing_schemas_with_partitioning = ['logs']

cdr_role = 'cdr_ro'
cdr_schemas = %w[
  auth_log
  billing
  cdr
  event
  external_data
  reports
  rtp_statistics
  stats
]

cdr_schemas_with_partitioning = %w[
  auth_log
  cdr
  rtp_statistics
]

SqlCaller::Yeti.transaction do
  SqlCaller::Yeti.execute "DROP OWNED BY #{routing_role}"
  SqlCaller::Yeti.execute "DROP ROLE IF EXISTS #{routing_role}"
  SqlCaller::Yeti.execute "CREATE ROLE #{routing_role} NOLOGIN"

  for s in routing_schemas do
    SqlCaller::Yeti.execute "GRANT USAGE ON SCHEMA #{s} TO #{routing_role}"
    SqlCaller::Yeti.execute "GRANT SELECT ON ALL TABLES IN SCHEMA #{s} TO #{routing_role}"
  end

  for s in routing_schemas_with_partitioning do
    SqlCaller::Yeti.execute "ALTER DEFAULT PRIVILEGES IN SCHEMA #{s} GRANT SELECT ON TABLES TO #{routing_role}"
  end
end

Cdr::Cdr.transaction do
  SqlCaller::Cdr.execute "DROP OWNED BY #{cdr_role}"
  SqlCaller::Cdr.execute "DROP ROLE IF EXISTS #{cdr_role}"
  SqlCaller::Cdr.execute "CREATE ROLE #{cdr_role} NOLOGIN"

  for s in cdr_schemas do
    SqlCaller::Cdr.execute "GRANT USAGE ON SCHEMA #{s} TO #{cdr_role}"
    SqlCaller::Cdr.execute "GRANT SELECT ON ALL TABLES IN SCHEMA #{s} TO #{cdr_role}"
  end

  for s in cdr_schemas_with_partitioning do
    SqlCaller::Cdr.execute "ALTER DEFAULT PRIVILEGES IN SCHEMA #{s} GRANT SELECT ON TABLES TO #{cdr_role}"
  end
end
