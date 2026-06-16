# frozen_string_literal: true

# Unit-level coverage of the SQL clause builders. These assert the core
# injection-safety invariant directly (without ClickHouse or the request stack):
# every clause emits ONLY allowlist-mapped constants and {param:Type} placeholders;
# caller-supplied values go to @params, never into the SQL text; any key not in an
# allowlist is rejected.
RSpec.describe Mcp::Tools::CdrReport do
  let(:from) { '2026-06-13 00:00:00' }
  let(:to) { '2026-06-13 06:00:00' }

  def tool(args = {})
    described_class.new(args)
  end

  # args with a valid window pre-filled, for clauses that don't care about it
  def windowed(args)
    tool({ 'from' => from, 'to' => to }.merge(args))
  end

  def params_of(instance)
    instance.instance_variable_get(:@params)
  end

  describe '#select_clause' do
    it 'maps dimension and measure keys to their constant fragments, aliased to the key' do
      sql = tool('measures' => %w[calls distinct_src_numbers], 'dimensions' => %w[customer_acc_id hour]).send(:select_clause)
      expect(sql).to eq(
        'customer_acc_id AS customer_acc_id, toStartOfHour(time_start) AS hour, ' \
        'count() AS calls, uniq(src_prefix_in) AS distinct_src_numbers'
      )
    end

    it 'requires at least one measure' do
      expect { tool('dimensions' => ['customer_acc_id']).send(:select_clause) }
        .to raise_error(ArgumentError, /at least one measure/)
    end

    it 'rejects an unknown / injected measure' do
      expect { tool('measures' => ['count() ; DROP TABLE cdrs']).send(:select_clause) }
        .to raise_error(ArgumentError, /unknown measure/)
    end

    it 'rejects a raw PII column as a dimension (only reachable via uniq measures)' do
      expect { tool('measures' => ['calls'], 'dimensions' => ['src_prefix_in']).send(:select_clause) }
        .to raise_error(ArgumentError, /unknown dimension/)
    end
  end

  describe '#group_by_clause' do
    it 'is empty without dimensions' do
      expect(tool('measures' => ['calls']).send(:group_by_clause)).to eq('')
    end

    it 'groups by the dimension fragments' do
      expect(tool('measures' => ['calls'], 'dimensions' => %w[customer_acc_id day]).send(:group_by_clause))
        .to eq('GROUP BY customer_acc_id, toDate(time_start)')
    end
  end

  describe '#where_clause' do
    it 'always emits the UTC-pinned time window with bound params' do
      t = windowed('measures' => ['calls'])
      expect(t.send(:where_clause)).to eq(
        "time_start >= toDateTime({from: String}, 'UTC') AND " \
        "time_start < toDateTime({to: String}, 'UTC')"
      )
      expect(params_of(t)).to include('param_from' => from, 'param_to' => to)
    end

    it 'binds a scalar filter value as a typed param and never inlines it' do
      t = windowed('measures' => ['calls'], 'filters' => [{ 'field' => 'customer_acc_id', 'op' => 'eq', 'value' => 42 }])
      where = t.send(:where_clause)
      expect(where).to include('customer_acc_id = {f1: Int32}')
      expect(where).not_to include('42')
      expect(params_of(t)).to include('param_f1' => 42)
    end

    it 'coerces a boolean filter value to 0/1 for an integer column (success = true → 1)' do
      t = windowed('measures' => ['calls'], 'filters' => [{ 'field' => 'success', 'op' => 'eq', 'value' => true }])
      t.send(:where_clause)
      expect(params_of(t)).to include('param_f1' => 1)
    end

    it 'coerces false to 0' do
      t = windowed('measures' => ['calls'], 'filters' => [{ 'field' => 'success', 'op' => 'eq', 'value' => false }])
      t.send(:where_clause)
      expect(params_of(t)).to include('param_f1' => 0)
    end

    it 'coerces array filter values too' do
      t = windowed('measures' => ['calls'], 'filters' => [{ 'field' => 'success', 'op' => 'in', 'value' => [true, false] }])
      t.send(:where_clause)
      expect(params_of(t)).to include('param_f1' => [1, 0])
    end

    it 'rejects a non-integer filter value as invalid input' do
      expect do
        windowed('measures' => ['calls'],
                 'filters' => [{ 'field' => 'customer_acc_id', 'op' => 'eq', 'value' => 'abc' }]).send(:where_clause)
      end.to raise_error(ArgumentError, /not a valid Int32/)
    end

    it 'binds an array filter value as Array(Type)' do
      t = windowed('measures' => ['calls'], 'filters' => [{ 'field' => 'dst_country_id', 'op' => 'in', 'value' => [1, 7] }])
      expect(t.send(:where_clause)).to include('dst_country_id IN {f1: Array(Int32)}')
      expect(params_of(t)).to include('param_f1' => [1, 7])
    end

    it 'rejects a scalar value for an array operator (no silent coercion)' do
      expect { windowed('measures' => ['calls'], 'filters' => [{ 'field' => 'dst_country_id', 'op' => 'in', 'value' => 1 }]).send(:where_clause) }
        .to raise_error(ArgumentError, /non-empty array/)
    end

    it 'rejects an empty array for an array operator' do
      expect { windowed('measures' => ['calls'], 'filters' => [{ 'field' => 'dst_country_id', 'op' => 'in', 'value' => [] }]).send(:where_clause) }
        .to raise_error(ArgumentError, /non-empty array/)
    end

    it 'rejects a raw PII column as a filter field' do
      expect { windowed('measures' => ['calls'], 'filters' => [{ 'field' => 'sign_orig_ip', 'op' => 'eq', 'value' => 'x' }]).send(:where_clause) }
        .to raise_error(ArgumentError, /unknown filter field/)
    end

    it 'rejects an unknown operator' do
      expect { windowed('measures' => ['calls'], 'filters' => [{ 'field' => 'customer_acc_id', 'op' => 'like', 'value' => 1 }]).send(:where_clause) }
        .to raise_error(ArgumentError, /unknown operator/)
    end

    it 'requires the time window' do
      expect { tool('measures' => ['calls']).send(:where_clause) }.to raise_error(ArgumentError, /`from`.*required/)
    end

    it 'rejects from >= to' do
      expect { tool('measures' => ['calls'], 'from' => to, 'to' => from).send(:where_clause) }
        .to raise_error(ArgumentError, /before/)
    end

    it 'rejects an over-long window' do
      expect { tool('measures' => ['calls'], 'from' => '2026-01-01 00:00:00', 'to' => '2026-03-01 00:00:00').send(:where_clause) }
        .to raise_error(ArgumentError, /window exceeds/)
    end
  end

  describe '#order_clause' do
    it 'defaults to the first measure descending' do
      expect(tool('measures' => %w[asr calls]).send(:order_clause)).to eq('asr DESC')
    end

    it 'honours an explicit allowlisted field and direction' do
      expect(tool('measures' => ['calls'], 'order_by' => { 'field' => 'calls', 'dir' => 'asc' }).send(:order_clause))
        .to eq('calls ASC')
    end

    it 'forces direction to ASC/DESC even for a malicious dir' do
      expect(tool('measures' => ['calls'], 'order_by' => { 'field' => 'calls', 'dir' => 'asc; DROP TABLE cdrs' }).send(:order_clause))
        .to eq('calls DESC')
    end

    it 'rejects an unknown / injected order_by field' do
      expect { tool('measures' => ['calls'], 'order_by' => { 'field' => 'calls; DROP' }).send(:order_clause) }
        .to raise_error(ArgumentError, /must be one of the selected/)
    end

    it 'rejects an allowlisted field that is not in this query\'s SELECT' do
      expect { tool('measures' => ['calls'], 'order_by' => { 'field' => 'asr' }).send(:order_clause) }
        .to raise_error(ArgumentError, /must be one of the selected/)
    end
  end

  describe '#limit' do
    it 'defaults to DEFAULT_LIMIT' do
      expect(tool('measures' => ['calls']).send(:limit)).to eq(described_class::DEFAULT_LIMIT)
    end

    it 'clamps to MAX_LIMIT' do
      expect(tool('measures' => ['calls'], 'limit' => 10_000).send(:limit)).to eq(described_class::MAX_LIMIT)
    end

    it 'clamps to a minimum of 1' do
      expect(tool('measures' => ['calls'], 'limit' => 0).send(:limit)).to eq(1)
    end

    it 'rejects a non-integer limit' do
      expect { tool('measures' => ['calls'], 'limit' => 'abc').send(:limit) }
        .to raise_error(ArgumentError, /limit must be an integer/)
    end
  end

  describe '#build_sql injection properties' do
    it 'rejects a malicious (non-integer) filter value rather than binding or inlining it' do
      # For an integer column the value is coerced/validated, so an injection-shaped
      # string is rejected outright — it never reaches the SQL or the params.
      # (Binding-of-valid-values safety is covered by the #where_clause specs.)
      expect do
        windowed(
          'measures' => ['calls'],
          'dimensions' => ['customer_acc_id'],
          'filters' => [{ 'field' => 'customer_acc_id', 'op' => 'eq', 'value' => '1); DROP TABLE cdrs;--' }]
        ).send(:build_sql)
      end.to raise_error(ArgumentError, /not a valid Int32/)
    end

    it 'rejects injection routed through any key (measure/dimension/filter field/op/order)' do
      [
        { 'measures' => ['count(); DROP'] },
        { 'measures' => ['calls'], 'dimensions' => ['1; DROP'] },
        { 'measures' => ['calls'], 'filters' => [{ 'field' => 'x; DROP', 'op' => 'eq', 'value' => 1 }] },
        { 'measures' => ['calls'], 'filters' => [{ 'field' => 'customer_acc_id', 'op' => 'eq); DROP--', 'value' => 1 }] },
        { 'measures' => ['calls'], 'order_by' => { 'field' => 'calls; DROP' } }
      ].each do |bad|
        expect { windowed(bad).send(:build_sql) }.to raise_error(ArgumentError)
      end
    end

    it 'produces a statement whose only braces are typed {param:Type} placeholders' do
      t = windowed(
        'measures' => %w[calls distinct_src_numbers],
        'dimensions' => ['customer_acc_id'],
        'filters' => [{ 'field' => 'dst_country_id', 'op' => 'in', 'value' => [1] }]
      )
      sql = t.send(:build_sql)
      expect(sql).to start_with('SELECT ')
      expect(sql).to include('FROM cdrs')
      expect(sql).to include('GROUP BY customer_acc_id')
      expect(sql).to include('SETTINGS max_execution_time')
      expect(sql).to end_with('FORMAT JSON') # so the gem parses the body to a Hash
      # every {...} in the final SQL is one of our generated typed params
      placeholders = sql.scan(/\{[^}]*\}/)
      expect(placeholders).not_to be_empty
      expect(placeholders).to all(match(/\A\{(from|to|f\d+): /))
    end
  end
end
