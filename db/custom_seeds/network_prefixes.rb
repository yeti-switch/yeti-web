# frozen_string_literal: true

# Loads global telephony reference data (network types, networks, countries and
# network prefixes) from checked-in YAML into sys.*.
#
# The bulk of the work is parsing db/network_data/**/*.yml (~232 files, ~96 MB)
# and loading ~39k networks + ~486k prefixes. Both parsing (CPU-bound, Psych holds
# the GVL) and the prefix insert (index maintenance) dominate the wall-clock, so
# the per-file work is fanned out across processes: each worker parses its slice of
# files and COPYs the rows straight into Postgres over its own backend.
#
# Tunable: SEED_WORKERS (default 0).
# 0 or 1: load sequentially in the current process (no fork) — lower peak RAM, but slow.
# 2+: fan the per-file parse+COPY out across N forked worker processes. Past ~4 the win is
# capped by the largest single file (UnitedStates.yml), which one worker must parse and COPY alone.
#
# Atomicity: Phase 1 always COPYs file-by-file with no transaction around the whole load, so a
# mid-run failure leaves the tables partially loaded at ANY worker count (forked workers also
# cannot share a transaction). Recoverable: the task first TRUNCATEs the tables (a re-run fully
# reloads) and a post-load count check raises on mismatch.

require 'parallel'
require_relative '../../lib/copy_data_loader'

workers = Integer(ENV.fetch('SEED_WORKERS', 0))

net_cols = %w[id name type_id uuid].freeze
np_cols  = %w[id prefix number_min_length number_max_length uuid country_id network_id].freeze

# --- Phase 0: global data, serially, in one transaction ---------------------
puts 'loading global data'
network_types    = YAML.load_file('db/network_types.yml')
networks         = YAML.load_file('db/networks.yml')
countries        = YAML.load_file('db/countries.yml')
network_prefixes = YAML.load_file('db/network_prefixes.yml')

System::NetworkPrefix.transaction do
  puts 'truncating old data'
  # TRUNCATE is atomic and reclaims space (unlike delete_all). CASCADE covers the
  # 4 tables' mutual FKs; all are wiped together anyway.
  ActiveRecord::Base.connection.execute(
    'TRUNCATE sys.network_prefixes, sys.networks, sys.network_types, sys.countries CASCADE'
  )

  puts 'insert new global'
  System::NetworkType.insert_all!(network_types)     if network_types.any?
  System::Network.insert_all!(networks)              if networks.any?
  System::Country.insert_all!(countries)             if countries.any?
  System::NetworkPrefix.insert_all!(network_prefixes) if network_prefixes.any?
end

# --- Phase 1: parse + COPY each file, fanned out across processes ------------
# Bin-pack files by byte size (greedy longest-processing-time: sort desc, assign
# each to the currently-smallest bin). This isolates the two huge files
# (UnitedStates.yml, Mexico.yml) into their own bins instead of stacking them
# behind other work.
bins_qty = workers > 0 ? workers : 1
files = Dir.glob('db/network_data/**/*.yml').sort
bins  = Array.new(bins_qty) { { size: 0, files: [] } }
files.sort_by { |f| -File.size(f) }.each do |f|
  bin = bins.min_by { |b| b[:size] }
  bin[:files] << f
  bin[:size]  += File.size(f)
end

if workers > 1
  puts "loading #{files.size} network data files with #{workers} workers"
else
  workers = 0
  puts "loading #{files.size} network data files serially (no workers)"
end

# Drop the parent's DB connection before forking so no worker inherits (and later
# corrupts) a live socket. Each process opens its own fresh connection lazily.
ActiveRecord::Base.connection_handler.clear_all_connections!

results = Parallel.map(bins, in_processes: workers) do |bin|
  # Belt-and-suspenders: ensure no inherited socket is reused in this child.
  ActiveRecord::Base.connection_handler.clear_all_connections!
  n_net = 0
  n_np  = 0
  current_file = nil

  begin
    bin[:files].each do |f|
      current_file = f
      data = YAML.load_file(f, aliases: true)
      nets = data['networks'] || []
      nps  = data['network_prefixes'] || []

      # networks BEFORE prefixes (FK: network_prefixes.network_id => networks.id).
      unless nets.empty?
        CopyDataLoader.load(model_class: System::Network, data: nets, columns: net_cols)
        n_net += nets.size
      end

      next if nps.empty?

      CopyDataLoader.load(model_class: System::NetworkPrefix, data: nps, columns: np_cols)
      n_np += nps.size
    end
  rescue StandardError => e
    # Name the offending file, then let Parallel propagate the failure to the parent.
    warn "error loading #{current_file}: #{e.class}: #{e.message}"
    raise
  end

  { networks: n_net, prefixes: n_np, files: bin[:files].size }
end

if workers > 1
  results.each_with_index do |r, i|
    puts "  worker #{i}: #{r[:files]} files, #{r[:networks]} networks, #{r[:prefixes]} prefixes"
  end
else
  r = results.first
  puts "  serial: #{r[:files]} files, #{r[:networks]} networks, #{r[:prefixes]} prefixes"
end

# --- Post-load verify (compensates for the lost single-transaction atomicity) --
# Expected total = rows the workers COPYd + the global rows inserted in Phase 0.
expected_net = results.sum { |r| r[:networks] } + networks.size
expected_np  = results.sum { |r| r[:prefixes] } + network_prefixes.size
actual_net   = System::Network.count
actual_np    = System::NetworkPrefix.count

raise "network count mismatch: expected #{expected_net}, got #{actual_net}" unless expected_net == actual_net
raise "prefix count mismatch: expected #{expected_np}, got #{actual_np}" unless expected_np == actual_np

puts "verified #{actual_net} networks, #{actual_np} prefixes loaded"

# --- Phase 3: sequences -----------------------------------------------------
System::NetworkPrefix.transaction do
  SqlCaller::Yeti.execute "SELECT pg_catalog.setval('sys.network_types_id_seq', MAX(id), true) FROM sys.network_types"
  SqlCaller::Yeti.execute "SELECT pg_catalog.setval('sys.networks_id_seq', MAX(id), true) FROM sys.networks"
  SqlCaller::Yeti.execute "SELECT pg_catalog.setval('sys.countries_id_seq', MAX(id), true) FROM sys.countries"
  SqlCaller::Yeti.execute "SELECT pg_catalog.setval('sys.network_prefixes_id_seq', MAX(id), true) FROM sys.network_prefixes"
end
