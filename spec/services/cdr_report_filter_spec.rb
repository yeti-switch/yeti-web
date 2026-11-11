# frozen_string_literal: true

RSpec.describe CdrReportFilter do
  describe '.error_for' do
    it 'accepts blank input' do
      expect(described_class.error_for(nil)).to be_nil
      expect(described_class.error_for('')).to be_nil
    end

    it 'accepts a valid Ransack query' do
      expect(described_class.error_for('duration_gt=60&success_eq=true')).to be_nil
    end

    it 'rejects raw SQL (no usable Ransack conditions)' do
      expect(described_class.error_for('duration > 0')).to be_present
    end

    it 'rejects a SQL injection attempt' do
      expect(described_class.error_for('duration > 0); DROP TABLE cdr.cdr;--')).to be_present
    end

    it 'rejects an unknown attribute' do
      expect(described_class.error_for('bogus_attr_eq=1')).to be_present
    end

    it 'rejects a condition with a blank value' do
      expect(described_class.error_for('duration_gt=')).to be_present
    end
  end

  describe '.columns_metadata' do
    subject(:metadata) { described_class.columns_metadata }

    def meta_for(name)
      metadata.find { |m| m[:name] == name }
    end

    it 'returns an entry per filterable column' do
      expect(metadata.map { |m| m[:name] }).to match_array(Report::CustomCdr::CDR_COLUMNS.map(&:to_s))
    end

    it 'classifies value kinds from the column type' do
      expect(meta_for('duration')).to include(value_type: 'number')
      expect(meta_for('success')).to include(value_type: 'boolean')
      expect(meta_for('time_start')).to include(value_type: 'datetime')
      expect(meta_for('dst_prefix_in')).to include(value_type: 'string')
    end

    it 'marks foreign keys as association with a search endpoint' do
      expect(meta_for('customer_id')).to include(
        value_type: 'association',
        search: { path: '/contractors/search', params: { q: { customer_eq: true } } }
      )
    end

    it 'only advertises predicates that build a valid Ransack condition' do
      sample = {
        'number' => '1', 'string' => 'x', 'boolean' => 'true',
        'datetime' => '2026-01-01', 'association' => '1'
      }
      metadata.each do |m|
        m[:predicates].each do |predicate|
          value = sample.fetch(m[:value_type])
          expect(described_class.error_for("#{m[:name]}_#{predicate}=#{value}")).to(
            be_nil, "expected #{m[:name]}_#{predicate} to be valid"
          )
        end
      end
    end
  end

  describe '.relation' do
    it 'builds a parameterized WHERE rather than interpolating raw SQL' do
      sql = described_class.relation('duration_gt=60').to_sql
      expect(sql).to include('"duration"')
      expect(sql).to match(/> 60\b/)
    end

    it 'escapes string values instead of letting them break out of the query' do
      sql = described_class.relation("src_prefix_in_eq=x' OR '1'='1").to_sql
      # the single quote is doubled (escaped); the payload is treated as data
      expect(sql).to include("''")
      expect(sql).not_to match(/OR '1'='1/i)
    end
  end
end
