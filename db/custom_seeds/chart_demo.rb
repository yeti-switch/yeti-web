# frozen_string_literal: true

# Populates stats.* tables with synthetic data for visual QA of the Chart.js
# migration. Run with: bundle exec rake custom_seeds[chart_demo]
#
# Picks the first existing Node / Account / Gateway / Dialpeer. If any of
# those is missing, the relevant chart group is skipped with a notice.

NOW = Time.now.utc
RNG = Random.new(42)

def sin_wave(steps, base:, amp:, period:)
  Array.new(steps) { |i| (base + amp * Math.sin(i * 2 * Math::PI / period)).round.clamp(0, nil) }
end

def jitter(value, pct: 0.15)
  delta = value * pct
  [value + RNG.rand(-delta..delta), 0].max
end

# Ensure 3 nodes exist so the dashboard stacked chart has multiple series.
# Top up with seeded ones if fewer exist. The third node's data starts later
# than the other two — d3/NVD3 had rendering issues when series had different
# x-ranges, so this is the regression case worth eyeballing in Chart.js.
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

# CallsMonitoring writes once per minute, so per-minute tables get a point
# every minute. Node #3 starts ~12h ago instead of 24h to reproduce the
# unequal-x-range case d3/NVD3 had trouble with.
node_minutes = [1440, 1440, 720]
node_agg_hours = [168, 168, 96]

account    = Account.order(:id).first
gateway    = Gateway.order(:id).first
dialpeer   = Dialpeer.order(:id).first

Rails.logger.debug "Seeding chart demo data at #{NOW}"
Rails.logger.debug "  nodes:    #{nodes.map(&:id).inspect}"
Rails.logger.debug "  account:  #{account&.id || '(none — account charts skipped)'}"
Rails.logger.debug "  gateway:  #{gateway&.id || '(none — gateway charts skipped)'}"
Rails.logger.debug "  dialpeer: #{dialpeer&.id || '(none — dialpeer chart skipped)'}"

# --- Per-minute active calls per node (1-min step; node-specific span)
if nodes.any?
  rows = []
  nodes.each_with_index do |node, idx|
    steps = node_minutes[idx] || 1440
    counts = sin_wave(steps, base: 50 + idx * 20, amp: 25 + idx * 10, period: 360)
    counts.each_with_index do |count, i|
      rows << {
        node_id: node.id,
        count: jitter(count).to_i,
        created_at: NOW - (steps - i).minutes
      }
    end
  end
  Stats::ActiveCall.insert_all(rows)
  Rails.logger.debug "  Stats::ActiveCall: +#{rows.size} (node spans 1-min: #{node_minutes.first(nodes.size).inspect})"
end

# --- Hourly aggregated active calls per node (node-specific span)
if nodes.any?
  rows = []
  nodes.each_with_index do |node, idx|
    hours = node_agg_hours[idx] || 168
    avgs = sin_wave(hours, base: 50 + idx * 20, amp: 25 + idx * 10, period: 24)
    avgs.each_with_index do |avg, i|
      time = NOW - (hours - i).hours
      rows << {
        node_id: node.id,
        avg_count: avg.to_f,
        max_count: (avg * 1.4).to_i,
        min_count: (avg * 0.6).to_i,
        calls_time: time,
        created_at: time
      }
    end
  end
  Stats::AggActiveCall.insert_all(rows)
  Rails.logger.debug "  Stats::AggActiveCall: +#{rows.size} (node spans hourly: #{node_agg_hours.first(nodes.size).inspect})"
end

# --- Per-account active calls (last 24h, 1-min step)
if account
  rows = Array.new(1440) do |i|
    base = sin_wave(1440, base: 30, amp: 20, period: 360)[i]
    {
      account_id: account.id,
      originated_count: jitter(base).to_i,
      terminated_count: jitter(base + 5).to_i,
      created_at: NOW - (1440 - i).minutes
    }
  end
  Stats::ActiveCallAccount.insert_all(rows)
  Rails.logger.debug "  Stats::ActiveCallAccount: +#{rows.size}"

  # --- Hourly aggregated per-account (last 7 days)
  rows = Array.new(168) do |i|
    avg = sin_wave(168, base: 30, amp: 20, period: 24)[i]
    time = NOW - (168 - i).hours
    {
      account_id: account.id,
      avg_originated_count: avg,
      max_originated_count: (avg * 1.4).to_i,
      min_originated_count: (avg * 0.6).to_i,
      avg_terminated_count: avg + 5,
      max_terminated_count: ((avg + 5) * 1.4).to_i,
      min_terminated_count: ((avg + 5) * 0.6).to_i,
      calls_time: time,
      created_at: time
    }
  end
  Stats::AggActiveCallAccount.insert_all(rows)
  Rails.logger.debug "  Stats::AggActiveCallAccount: +#{rows.size}"

  # --- Customer + vendor traffic (48h hourly for dashboard + 12h for per-acct)
  rows_customer = Array.new(48) do |i|
    time = NOW - (48 - i).hours
    profit = RNG.rand(-50.0..150.0).round(4)
    {
      account_id: account.id,
      amount: RNG.rand(100.0..500.0).round(4),
      count: RNG.rand(50..300),
      duration: RNG.rand(1800..14_400),
      profit: profit,
      timestamp: time
    }
  end
  Stats::TrafficCustomerAccount.insert_all(rows_customer)
  Rails.logger.debug "  Stats::TrafficCustomerAccount: +#{rows_customer.size}"

  rows_vendor = Array.new(48) do |i|
    time = NOW - (48 - i).hours
    {
      account_id: account.id,
      amount: RNG.rand(80.0..400.0).round(4),
      count: RNG.rand(50..300),
      duration: RNG.rand(1800..14_400),
      profit: RNG.rand(-30.0..80.0).round(4),
      timestamp: time
    }
  end
  Stats::TrafficVendorAccount.insert_all(rows_vendor)
  Rails.logger.debug "  Stats::TrafficVendorAccount: +#{rows_vendor.size}"
end

# --- Per-gateway active calls (orig + term, last 24h, 1-min step)
if gateway
  orig_wave = sin_wave(1440, base: 40, amp: 20, period: 360)
  rows_orig = Array.new(1440) do |i|
    {
      gateway_id: gateway.id,
      count: jitter(orig_wave[i]).to_i,
      created_at: NOW - (1440 - i).minutes
    }
  end
  Stats::ActiveCallOrigGateway.insert_all(rows_orig)
  Rails.logger.debug "  Stats::ActiveCallOrigGateway: +#{rows_orig.size}"

  term_wave = sin_wave(1440, base: 35, amp: 18, period: 360)
  rows_term = Array.new(1440) do |i|
    {
      gateway_id: gateway.id,
      count: jitter(term_wave[i]).to_i,
      created_at: NOW - (1440 - i).minutes
    }
  end
  Stats::ActiveCallTermGateway.insert_all(rows_term)
  Rails.logger.debug "  Stats::ActiveCallTermGateway: +#{rows_term.size}"

  # --- Hourly aggregates (last 7 days)
  agg_orig = Array.new(168) do |i|
    avg = sin_wave(168, base: 40, amp: 20, period: 24)[i]
    time = NOW - (168 - i).hours
    {
      gateway_id: gateway.id,
      avg_count: avg.to_f,
      max_count: (avg * 1.4).to_i,
      min_count: (avg * 0.6).to_i,
      calls_time: time,
      created_at: time
    }
  end
  Stats::AggActiveCallOrigGateway.insert_all(agg_orig)
  Rails.logger.debug "  Stats::AggActiveCallOrigGateway: +#{agg_orig.size}"

  agg_term = Array.new(168) do |i|
    avg = sin_wave(168, base: 35, amp: 18, period: 24)[i]
    time = NOW - (168 - i).hours
    {
      gateway_id: gateway.id,
      avg_count: avg.to_f,
      max_count: (avg * 1.4).to_i,
      min_count: (avg * 0.6).to_i,
      calls_time: time,
      created_at: time
    }
  end
  Stats::AggActiveCallTermGateway.insert_all(agg_term)
  Rails.logger.debug "  Stats::AggActiveCallTermGateway: +#{agg_term.size}"

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
Rails.logger.debug 'Visit these URLs to QA the charts:'
Rails.logger.debug '  Dashboard (nodes stacked area, profit, duration):  /admin/dashboard'
Rails.logger.debug "  Account #{account.id}: /admin/accounts/#{account.id}" if account
Rails.logger.debug "  Gateway #{gateway.id}: /admin/gateways/#{gateway.id}" if gateway
Rails.logger.debug "  Dialpeer #{dialpeer.id}: /admin/dialpeers/#{dialpeer.id}" if dialpeer
nodes.each { |n| puts "  Node #{n.id}: /admin/nodes/#{n.id}" }
