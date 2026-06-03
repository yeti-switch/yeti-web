# frozen_string_literal: true

# Populates stats.* tables with synthetic data for visual QA of the active-call
# charts. Run with: bundle exec rake custom_seeds[chart_demo]
#
# Active-call stats are stored as raw per-minute snapshots only (no hourly
# rollup), retained for a month and reduced client-side. To match production:
#   * data spans ~30 days so the 24h / 7d / 30d range picker all show something;
#   * a daily idle window is skipped (no rows) so the client zero-reconstruction
#     and decimation are exercised — absence of a row means zero active calls;
#   * rows that would be zero are dropped, never stored.
#
# Picks the first existing Node / Account / Gateway / Dialpeer. If any of
# those is missing, the relevant chart group is skipped with a notice.

# Truncated to the minute so every per-minute timestamp lands exactly on :00
# seconds (CallsMonitoring writes once per minute).
NOW = Time.now.utc.beginning_of_minute
RNG = Random.new(42)
INSERT_BATCH = 10_000

# Hours of the day to leave with no samples, producing gaps the chart renders
# as drops to zero.
IDLE_HOURS = [3, 4].freeze

def jitter(value, pct: 0.15)
  delta = value * pct
  [value + RNG.rand(-delta..delta), 0].max
end

# Per-minute points over the last `minutes`, as [timestamp, value] pairs,
# skipping the daily idle window. The sinusoid gives a day/night shape.
def minute_points(minutes, base:, amp:, period:)
  pts = []
  minutes.times do |i|
    t = NOW - (minutes - i).minutes
    next if IDLE_HOURS.include?(t.hour)

    pts << [t, (base + amp * Math.sin(i * 2 * Math::PI / period)).round]
  end
  pts
end

def insert_in_batches(model, rows)
  rows.each_slice(INSERT_BATCH) { |slice| model.insert_all(slice) }
end

DAY_MINUTES = 24 * 60
MONTH_MINUTES = 30 * DAY_MINUTES

# Wipe previously seeded / collected stats so re-running produces a clean set.
[
  Stats::ActiveCall,
  Stats::ActiveCallAccount,
  Stats::ActiveCallOrigGateway,
  Stats::ActiveCallTermGateway,
  Stats::TrafficCustomerAccount,
  Stats::TrafficVendorAccount,
  Stats::TerminationQualityStat
].each(&:delete_all)
Rails.logger.debug 'Cleared existing stats.* data'

# Ensure 3 nodes exist so the dashboard stacked chart has multiple series.
# The third node's data starts later than the other two (unequal x-range) —
# worth eyeballing that the stacked area still aligns.
nodes = Node.order(:id).limit(3).to_a
if nodes.size < 3
  pop = Pop.find_or_create_by!(id: 100, name: 'seed-UA11')
  (3 - nodes.size).times do |i|
    suffix = "chart-demo-#{Time.now.to_i}-#{i}"
    nodes << Node.create!(
      id: Node.maximum(:id).to_i + 1 + i,
      pop: pop,
      name: "node-#{suffix}",
      rpc_endpoint: "tcp://127.0.0.1:#{8000 + i}/#{suffix}"
    )
  end
end

# Node #3 spans 15 days instead of 30 to reproduce the unequal-x-range case.
node_minutes = [MONTH_MINUTES, MONTH_MINUTES, 15 * DAY_MINUTES]

account    = Account.order(:id).first
gateway    = Gateway.order(:id).first
dialpeer   = Dialpeer.order(:id).first

Rails.logger.debug "Seeding chart demo data at #{NOW}"
Rails.logger.debug "  nodes:    #{nodes.map(&:id).inspect}"
Rails.logger.debug "  account:  #{account&.id || '(none — account charts skipped)'}"
Rails.logger.debug "  gateway:  #{gateway&.id || '(none — gateway charts skipped)'}"
Rails.logger.debug "  dialpeer: #{dialpeer&.id || '(none — dialpeer chart skipped)'}"

# --- Per-minute active calls per node (~30 days; node-specific span)
if nodes.any?
  rows = []
  nodes.each_with_index do |node, idx|
    minutes = node_minutes[idx] || MONTH_MINUTES
    minute_points(minutes, base: 50 + idx * 20, amp: 25 + idx * 10, period: 360).each do |t, val|
      count = jitter(val).to_i
      next if count <= 0

      rows << { node_id: node.id, count: count, created_at: t }
    end
  end
  insert_in_batches(Stats::ActiveCall, rows)
  Rails.logger.debug "  Stats::ActiveCall: +#{rows.size} (node spans minutes: #{node_minutes.first(nodes.size).inspect})"
end

# --- Per-account active calls (~30 days, 1-min step)
if account
  orig = minute_points(MONTH_MINUTES, base: 30, amp: 20, period: 360)
  term = minute_points(MONTH_MINUTES, base: 35, amp: 20, period: 360)
  rows = orig.each_index.map do |i|
    t = orig[i][0]
    originated = jitter(orig[i][1]).to_i
    terminated = jitter(term[i][1]).to_i
    next if originated <= 0 && terminated <= 0

    { account_id: account.id, originated_count: originated, terminated_count: terminated, created_at: t }
  end.compact
  insert_in_batches(Stats::ActiveCallAccount, rows)
  Rails.logger.debug "  Stats::ActiveCallAccount: +#{rows.size}"

  # --- Customer + vendor traffic (48h hourly for dashboard profit/duration)
  rows_customer = Array.new(48) do |i|
    {
      account_id: account.id,
      amount: RNG.rand(100.0..500.0).round(4),
      count: RNG.rand(50..300),
      duration: RNG.rand(1800..14_400),
      profit: RNG.rand(-50.0..150.0).round(4),
      timestamp: NOW - (48 - i).hours
    }
  end
  Stats::TrafficCustomerAccount.insert_all(rows_customer)
  Rails.logger.debug "  Stats::TrafficCustomerAccount: +#{rows_customer.size}"

  rows_vendor = Array.new(48) do |i|
    {
      account_id: account.id,
      amount: RNG.rand(80.0..400.0).round(4),
      count: RNG.rand(50..300),
      duration: RNG.rand(1800..14_400),
      profit: RNG.rand(-30.0..80.0).round(4),
      timestamp: NOW - (48 - i).hours
    }
  end
  Stats::TrafficVendorAccount.insert_all(rows_vendor)
  Rails.logger.debug "  Stats::TrafficVendorAccount: +#{rows_vendor.size}"
end

# --- Per-gateway active calls (orig + term, ~30 days, 1-min step)
if gateway
  rows_orig = minute_points(MONTH_MINUTES, base: 40, amp: 20, period: 360).map do |t, val|
    count = jitter(val).to_i
    next if count <= 0

    { gateway_id: gateway.id, count: count, created_at: t }
  end.compact
  insert_in_batches(Stats::ActiveCallOrigGateway, rows_orig)
  Rails.logger.debug "  Stats::ActiveCallOrigGateway: +#{rows_orig.size}"

  rows_term = minute_points(MONTH_MINUTES, base: 35, amp: 18, period: 360).map do |t, val|
    count = jitter(val).to_i
    next if count <= 0

    { gateway_id: gateway.id, count: count, created_at: t }
  end.compact
  insert_in_batches(Stats::ActiveCallTermGateway, rows_term)
  Rails.logger.debug "  Stats::ActiveCallTermGateway: +#{rows_term.size}"

  # --- PDD distribution for gateway (200 successful calls, last 24h)
  rows_pdd = Array.new(200) do
    pdd_bucket = [0, 1, 1, 2, 2, 2, 3, 3, 4, 5, 6, 8].sample(random: RNG)
    {
      gateway_id: gateway.id,
      dialpeer_id: nil,
      pdd: pdd_bucket + RNG.rand,
      duration: RNG.rand(30..900),
      success: true,
      time_start: NOW - RNG.rand(0..23).hours
    }
  end
  Stats::TerminationQualityStat.insert_all(rows_pdd)
  Rails.logger.debug "  Stats::TerminationQualityStat (gateway): +#{rows_pdd.size}"
end

# --- PDD distribution for dialpeer (200 successful calls, last 24h)
if dialpeer
  rows_pdd = Array.new(200) do
    pdd_bucket = [0, 1, 1, 2, 2, 3, 3, 4, 5, 6, 7, 9].sample(random: RNG)
    {
      gateway_id: nil,
      dialpeer_id: dialpeer.id,
      pdd: pdd_bucket + RNG.rand,
      duration: RNG.rand(30..900),
      success: true,
      time_start: NOW - RNG.rand(0..23).hours
    }
  end
  Stats::TerminationQualityStat.insert_all(rows_pdd)
  Rails.logger.debug "  Stats::TerminationQualityStat (dialpeer): +#{rows_pdd.size}"
end

Rails.logger.debug
Rails.logger.debug 'Visit these URLs to QA the charts (try the 24h / 7d / 30d range picker):'
Rails.logger.debug '  Dashboard (nodes stacked area, profit, duration):  /admin/dashboard'
Rails.logger.debug "  Account #{account.id}: /admin/accounts/#{account.id}" if account
Rails.logger.debug "  Gateway #{gateway.id}: /admin/gateways/#{gateway.id}" if gateway
Rails.logger.debug "  Dialpeer #{dialpeer.id}: /admin/dialpeers/#{dialpeer.id}" if dialpeer
nodes.each { |n| puts "  Node #{n.id}: /admin/nodes/#{n.id}" }
