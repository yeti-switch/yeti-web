# frozen_string_literal: true

# == Schema Information
#
# Table name: cdr_exports
# Database name: primary
#
#  id                  :integer(4)       not null, primary key
#  callback_url        :string
#  fields              :string           default([]), not null, is an Array
#  filters             :json             not null
#  rows_count          :integer(4)
#  status              :string           not null
#  time_format         :string           default("with_timezone"), not null
#  time_zone_name      :string
#  type                :string           not null
#  uuid                :uuid             not null
#  created_at          :datetime
#  updated_at          :datetime
#  customer_account_id :integer(4)
#
# Indexes
#
#  index_sys.cdr_exports_on_customer_account_id  (customer_account_id)
#  index_sys.cdr_exports_on_uuid                 (uuid) UNIQUE
#
# Foreign Keys
#
#  fk_rails_e796f29195  (customer_account_id => accounts.id)
#

RSpec.describe CdrExport do
  describe '.create' do
    subject do
      described_class.create(create_params)
    end

    let(:create_params) do
      {
        fields: ['id'],
        filters: {
          time_start_lteq: 1.day.ago.utc.iso8601(3),
          time_start_gteq: Time.now.utc.iso8601(3)
        }
      }
    end
    let(:default_cdr_export_attrs) do
      {
        callback_url: nil,
        fields: [],
        rows_count: nil,
        status: CdrExport::STATUS_PENDING,
        type: 'Base',
        uuid: be_present,
        created_at: be_within(1).of(Time.current),
        updated_at: be_within(1).of(Time.current),
        customer_account_id: nil
      }
    end
    let(:expected_cdr_export_attrs) do
      default_cdr_export_attrs.merge create_params.except(:filters)
    end
    let(:expected_cdr_export_filters) do
      create_params[:filters]
    end

    shared_examples :creates_cdr_export do
      # let(:expected_cdr_export_attrs) {}
      # let(:expected_cdr_export_filters) {}

      it 'creates cdr_export' do
        expect(subject.errors).to be_empty
        expect(subject).to be_persisted
        expect(subject.reload).to have_attributes(expected_cdr_export_attrs)
        expect(subject.filters_json).to match(expected_cdr_export_filters)
      end
    end

    context 'with only required attributes' do
      include_examples :creates_cdr_export
    end

    context 'with valid customer_account_id' do
      let(:create_params) do
        super().merge customer_account_id: account.id
      end
      let!(:account) { FactoryBot.create(:account, :with_customer) }

      include_examples :creates_cdr_export
    end

    context 'with invalid customer_account_id' do
      let(:create_params) do
        super().merge customer_account_id: 999_999_99
      end

      include_examples :does_not_create_record, errors: {
        customer_account: 'is invalid'
      }
    end

    context 'with all allowed filters' do
      let(:create_params) do
        super().merge filters: {
          time_start_lteq: 15.days.ago.utc.iso8601(3),
          time_start_lt: 15.days.ago.utc.iso8601(3),
          time_start_gteq: 10.days.ago.utc.iso8601(3),
          customer_id_eq: 1234,
          customer_external_id_eq: 1235,
          customer_acc_id_eq: 1236,
          customer_acc_external_id_eq: 241_251,
          vendor_id_eq: 1237,
          vendor_external_id_eq: 1238,
          vendor_acc_id_eq: 1239,
          vendor_acc_external_id_eq: 1240,
          is_last_cdr_eq: true,
          success_eq: true,
          customer_auth_id_eq: 1241,
          customer_auth_external_id_eq: 2_151_321,
          failed_resource_type_id_eq: 25,
          src_prefix_in_contains: '1111',
          src_prefix_in_eq: '1111',
          src_prefix_in_in: %w[1111 1112],
          dst_prefix_in_contains: '2222',
          dst_prefix_in_eq: '2222',
          dst_prefix_in_in: %w[2222 2223],
          src_prefix_routing_contains: '3333',
          src_prefix_routing_eq: '3333',
          src_prefix_routing_in: %w[3333 3334],
          dst_prefix_routing_contains: '4444',
          dst_prefix_routing_eq: '4444',
          dst_prefix_routing_in: %w[4444 4445],
          src_prefix_out_contains: '5555',
          src_prefix_out_eq: '5555',
          src_prefix_out_in: %w[5555 5556],
          dst_prefix_out_contains: '6666',
          dst_prefix_out_eq: '6666',
          dst_prefix_out_in: %w[6666 6667],
          src_country_id_eq: 111_222,
          dst_country_id_eq: 111_223,
          routing_tag_ids_include: 2,
          routing_tag_ids_exclude: 5,
          routing_tag_ids_empty: false,
          orig_gw_id_eq: 1242,
          orig_gw_external_id_eq: 1243,
          term_gw_id_eq: 1244,
          term_gw_external_id_eq: 1245,
          duration_eq: 30,
          duration_gteq: 0,
          duration_lteq: 60,
          customer_auth_external_type_eq: 'foo',
          customer_auth_external_type_not_eq: 'bar',
          customer_auth_external_id_in: [1, 2, 3],
          dst_country_iso_in: %w[UA UK],
          src_country_iso_in: %w[UA UK]
        }
      end
      before do
        # add allowed filters must be filled in this test.
        allowed_filters = CdrExport::FiltersModel.attribute_types.keys.map(&:to_sym)
        expect(create_params[:filters].keys).to match_array(allowed_filters)
      end

      include_examples :creates_cdr_export
    end

    context 'with all allowed fields' do
      let(:create_params) do
        super().merge fields: described_class.allowed_fields
      end

      include_examples :creates_cdr_export
    end

    context 'with not allowed filter' do
      let(:create_params) do
        super().merge filters: {
          time_start_lteq: 15.days.ago.utc.iso8601(3),
          time_start_gteq: 10.days.ago.utc.iso8601(3),
          foo: 'bar',
          baz: 'boo'
        }
      end

      include_examples :does_not_create_record, errors: {
        'filters': 'foo, baz not allowed'
      }
    end

    context 'with not allowed field' do
      let(:create_params) do
        super().merge fields: %w[id qwe asd]
      end

      include_examples :does_not_create_record, errors: {
        fields: 'qwe, asd not allowed'
      }
    end

    context 'without attributes' do
      let(:create_params) { {} }

      include_examples :does_not_create_record, errors: {
        fields: "can't be blank",
        filters: "can't be blank"
      }
    end
  end

  describe '#export_sql' do
    subject do
      cdr_export.export_sql
    end

    shared_examples :returns_correct_sql do
      it 'SQL should be valid' do
        expect(subject).to eq(expected_sql)
        expect { Cdr::Cdr.connection.execute(subject) }.not_to raise_error
      end
    end

    let(:cdr_export_attrs) { {} }
    let(:cdr_export) do
      FactoryBot.create(:cdr_export, fields: fields, filters: filters, **cdr_export_attrs)
    end
    let(:fields) do
      %w[success id]
    end
    let(:filters) do
      {
        time_start_gteq: '2018-01-01',
        time_start_lteq: '2018-03-01'
      }
    end
    let(:expected_sql) do
      [
        'SELECT success AS "Success", cdr.cdr.id AS "ID"',
        'FROM "cdr"."cdr"',
        'WHERE',
        "(\"cdr\".\"cdr\".\"time_start\" >= '2018-01-01 00:00:00'",
        'AND',
        "\"cdr\".\"cdr\".\"time_start\" <= '2018-03-01 00:00:00')",
        'ORDER BY cdr.cdr.time_start DESC'
      ].join(' ')
    end

    context 'with only required filters' do
      include_examples :returns_correct_sql
    end

    context 'when added virtual attributes to export cdr' do
      let(:fields) { %w[src_country_name dst_country_name src_network_name dst_network_name] }
      let(:expected_sql) do
        [
          'SELECT',
          'src_c.name AS "Src Country Name",',
          'dst_c.name AS "Dst Country Name",',
          'src_n.name AS "Src Network Name",',
          'dst_n.name AS "Dst Network Name"',
          'FROM "cdr"."cdr"',
          'LEFT JOIN external_data.countries as src_c ON cdr.cdr.src_country_id = src_c.id',
          'LEFT JOIN external_data.countries as dst_c ON cdr.cdr.dst_country_id = dst_c.id',
          'LEFT JOIN external_data.networks as src_n ON cdr.cdr.src_network_id = src_n.id',
          'LEFT JOIN external_data.networks as dst_n ON cdr.cdr.dst_network_id = dst_n.id',
          'WHERE',
          "(\"cdr\".\"cdr\".\"time_start\" >= '2018-01-01 00:00:00'",
          'AND',
          "\"cdr\".\"cdr\".\"time_start\" <= '2018-03-01 00:00:00')",
          'ORDER BY cdr.cdr.time_start DESC'
        ].join(' ')
      end

      include_examples :returns_correct_sql
    end

    context 'when time-format = "round_to_seconds"' do
      let(:fields) { %w[success id time_end] }
      let(:cdr_export_attrs) { super().merge time_format: CdrExport::ROUND_TO_SECONDS_TIME_FORMAT }
      let(:expected_sql) do
        [
          'SELECT success AS "Success",',
          'cdr.cdr.id AS "ID",',
          "to_char(cdr.cdr.time_end, 'YYYY-MM-DD HH24:MI:SS') AS \"Time End\"",
          'FROM "cdr"."cdr"',
          'WHERE',
          "(\"cdr\".\"cdr\".\"time_start\" >= '2018-01-01 00:00:00'",
          'AND',
          "\"cdr\".\"cdr\".\"time_start\" <= '2018-03-01 00:00:00')",
          'ORDER BY cdr.cdr.time_start DESC'
        ].join(' ')
      end

      include_examples :returns_correct_sql
    end

    context 'when time-format = "without_timezone"' do
      let(:fields) { %w[success id time_end] }
      let(:cdr_export_attrs) { super().merge time_format: CdrExport::WITHOUT_TIMEZONE_TIME_FORMAT }
      let(:expected_sql) do
        [
          'SELECT success AS "Success",',
          'cdr.cdr.id AS "ID",',
          'cdr.cdr.time_end::timestamp AS "Time End"',
          'FROM "cdr"."cdr"',
          'WHERE',
          "(\"cdr\".\"cdr\".\"time_start\" >= '2018-01-01 00:00:00'",
          'AND',
          "\"cdr\".\"cdr\".\"time_start\" <= '2018-03-01 00:00:00')",
          'ORDER BY cdr.cdr.time_start DESC'
        ].join(' ')
      end

      include_examples :returns_correct_sql
    end

    context 'when time-format = "with_timezone"' do
      let(:fields) { %w[success id time_end] }
      let(:cdr_export_attrs) { super().merge time_format: CdrExport::WITH_TIMEZONE_TIME_FORMAT }
      let(:expected_sql) do
        [
          'SELECT success AS "Success",',
          'cdr.cdr.id AS "ID",',
          'cdr.cdr.time_end AS "Time End"',
          'FROM "cdr"."cdr"',
          'WHERE',
          "(\"cdr\".\"cdr\".\"time_start\" >= '2018-01-01 00:00:00'",
          'AND',
          "\"cdr\".\"cdr\".\"time_start\" <= '2018-03-01 00:00:00')",
          'ORDER BY cdr.cdr.time_start DESC'
        ].join(' ')
      end

      include_examples :returns_correct_sql
    end

    context 'when filled all filters' do
      let(:filters) do
        {
          time_start_gteq: '2018-01-01',
          time_start_lteq: '2018-03-01',
          success_eq: 'true',
          src_prefix_in_contains: '111111',
          src_prefix_routing_contains: '123123',
          src_prefix_out_contains: '222222',
          dst_prefix_in_contains: '333123',
          dst_prefix_routing_contains: '221133',
          dst_prefix_out_contains: '333221'
        }
      end
      let(:expected_sql) do
        [
          'SELECT success AS "Success", cdr.cdr.id AS "ID"',
          'FROM "cdr"."cdr"',
          'WHERE',
          "(\"cdr\".\"cdr\".\"time_start\" >= '2018-01-01 00:00:00'",
          'AND',
          "\"cdr\".\"cdr\".\"time_start\" <= '2018-03-01 00:00:00'",
          'AND',
          '"cdr"."cdr"."success" = TRUE',
          'AND',
          "\"cdr\".\"cdr\".\"src_prefix_in\" ILIKE '%111111%'",
          'AND',
          "\"cdr\".\"cdr\".\"dst_prefix_in\" ILIKE '%333123%'",
          'AND',
          "\"cdr\".\"cdr\".\"src_prefix_routing\" ILIKE '%123123%'",
          'AND',
          "\"cdr\".\"cdr\".\"dst_prefix_routing\" ILIKE '%221133%'",
          'AND',
          "\"cdr\".\"cdr\".\"src_prefix_out\" ILIKE '%222222%'",
          'AND',
          "\"cdr\".\"cdr\".\"dst_prefix_out\" ILIKE '%333221%')",
          'ORDER BY cdr.cdr.time_start DESC'
        ].join(' ')
      end

      include_examples :returns_correct_sql
    end

    context 'with comma-separated CLI list filters (string input)' do
      let(:filters) do
        {
          time_start_gteq: '2018-01-01',
          time_start_lteq: '2018-03-01',
          src_prefix_in_in: '111, 222,333',
          src_prefix_routing_in: '444',
          src_prefix_out_in: '555,, 666'
        }
      end
      let(:expected_sql) do
        [
          'SELECT success AS "Success", cdr.cdr.id AS "ID"',
          'FROM "cdr"."cdr"',
          'WHERE',
          "(\"cdr\".\"cdr\".\"time_start\" >= '2018-01-01 00:00:00'",
          'AND',
          "\"cdr\".\"cdr\".\"time_start\" <= '2018-03-01 00:00:00'",
          'AND',
          %{"cdr"."cdr"."src_prefix_in" IN ('111', '222', '333')},
          'AND',
          %{"cdr"."cdr"."src_prefix_routing" IN ('444')},
          'AND',
          %{"cdr"."cdr"."src_prefix_out" IN ('555', '666'))},
          'ORDER BY cdr.cdr.time_start DESC'
        ].join(' ')
      end

      include_examples :returns_correct_sql
    end

    context 'with CLI list filters as array (API input)' do
      let(:filters) do
        {
          time_start_gteq: '2018-01-01',
          time_start_lteq: '2018-03-01',
          src_prefix_in_in: %w[111 222]
        }
      end
      let(:expected_sql) do
        [
          'SELECT success AS "Success", cdr.cdr.id AS "ID"',
          'FROM "cdr"."cdr"',
          'WHERE',
          "(\"cdr\".\"cdr\".\"time_start\" >= '2018-01-01 00:00:00'",
          'AND',
          "\"cdr\".\"cdr\".\"time_start\" <= '2018-03-01 00:00:00'",
          'AND',
          %{"cdr"."cdr"."src_prefix_in" IN ('111', '222'))},
          'ORDER BY cdr.cdr.time_start DESC'
        ].join(' ')
      end

      include_examples :returns_correct_sql
    end

    context 'when filled some filters' do
      let(:filters) do
        {
          time_start_gteq: '2018-01-01',
          time_start_lteq: '2018-03-01',
          src_prefix_in_contains: '111111',
          src_prefix_routing_contains: '123123',
          dst_prefix_out_contains: '333221',
          src_country_id_eq: country.id,
          dst_country_id_eq: country.id,
          routing_tag_ids_include: 1,
          routing_tag_ids_exclude: 2,
          customer_auth_external_type_eq: 'term',
          customer_auth_external_type_not_eq: 'em',
          customer_auth_external_id_in: [1, 2, 3],
          dst_country_iso_in: %w[UA UK],
          src_country_iso_in: %w[UA UK]
        }
      end
      let(:country) { System::Country.take! }
      let(:expected_sql) do
        [
          'SELECT success AS "Success", cdr.cdr.id AS "ID"',
          'FROM "cdr"."cdr"',
          'INNER JOIN external_data.countries as src_c ON cdr.cdr.src_country_id = src_c.id',
          'INNER JOIN external_data.countries as dst_c ON cdr.cdr.dst_country_id = dst_c.id',
          'WHERE',
          "\"src_c\".\"iso2\" IN ('UA', 'UK')",
          'AND',
          "\"dst_c\".\"iso2\" IN ('UA', 'UK')",
          'AND',
          '(1 = ANY(routing_tag_ids))',
          'AND',
          'NOT ((2 = ANY(routing_tag_ids)))',
          'AND',
          "(\"cdr\".\"cdr\".\"time_start\" >= '2018-01-01 00:00:00'",
          'AND',
          "\"cdr\".\"cdr\".\"time_start\" <= '2018-03-01 00:00:00'",
          'AND',
          "\"cdr\".\"cdr\".\"src_prefix_in\" ILIKE '%111111%'",
          'AND',
          "\"cdr\".\"cdr\".\"src_prefix_routing\" ILIKE '%123123%'",
          'AND',
          "\"cdr\".\"cdr\".\"dst_prefix_out\" ILIKE '%333221%'",
          'AND',
          "\"cdr\".\"cdr\".\"src_country_id\" = #{country.id}",
          'AND',
          "\"cdr\".\"cdr\".\"dst_country_id\" = #{country.id}",
          'AND',
          "\"cdr\".\"cdr\".\"customer_auth_external_type\" = 'term'",
          'AND',
          "\"cdr\".\"cdr\".\"customer_auth_external_type\" != 'em'",
          'AND',
          '"cdr"."cdr"."customer_auth_external_id" IN (1, 2, 3))',
          'ORDER BY cdr.cdr.time_start DESC'
        ].join(' ')
      end

      include_examples :returns_correct_sql

      context 'with routing_tag_ids_empty false' do
        let(:filters) { super().merge({ routing_tag_ids_empty: false }) }
        let(:expected_sql) do
          [
            'SELECT success AS "Success", cdr.cdr.id AS "ID"',
            'FROM "cdr"."cdr"',
            'INNER JOIN external_data.countries as src_c ON cdr.cdr.src_country_id = src_c.id',
            'INNER JOIN external_data.countries as dst_c ON cdr.cdr.dst_country_id = dst_c.id',
            'WHERE',
            "\"src_c\".\"iso2\" IN ('UA', 'UK')",
            'AND',
            "\"dst_c\".\"iso2\" IN ('UA', 'UK')",
            'AND',
            '(1 = ANY(routing_tag_ids))',
            'AND',
            'NOT ((2 = ANY(routing_tag_ids)))',
            'AND NOT',
            '(routing_tag_ids IS NULL OR routing_tag_ids = \'{}\')',
            'AND',
            "(\"cdr\".\"cdr\".\"time_start\" >= '2018-01-01 00:00:00'",
            'AND',
            "\"cdr\".\"cdr\".\"time_start\" <= '2018-03-01 00:00:00'",
            'AND',
            "\"cdr\".\"cdr\".\"src_prefix_in\" ILIKE '%111111%'",
            'AND',
            "\"cdr\".\"cdr\".\"src_prefix_routing\" ILIKE '%123123%'",
            'AND',
            "\"cdr\".\"cdr\".\"dst_prefix_out\" ILIKE '%333221%'",
            'AND',
            "\"cdr\".\"cdr\".\"src_country_id\" = #{country.id}",
            'AND',
            "\"cdr\".\"cdr\".\"dst_country_id\" = #{country.id}",
            'AND',
            "\"cdr\".\"cdr\".\"customer_auth_external_type\" = 'term'",
            'AND',
            "\"cdr\".\"cdr\".\"customer_auth_external_type\" != 'em'",
            'AND',
            '"cdr"."cdr"."customer_auth_external_id" IN (1, 2, 3))',
            'ORDER BY cdr.cdr.time_start DESC'
          ].join(' ')
        end

        include_examples :returns_correct_sql
      end

      context 'with routing_tag_ids_empty true' do
        let(:filters) { super().merge({ routing_tag_ids_empty: true }) }
        let(:expected_sql) do
          [
            'SELECT success AS "Success", cdr.cdr.id AS "ID"',
            'FROM "cdr"."cdr"',
            'INNER JOIN external_data.countries as src_c ON cdr.cdr.src_country_id = src_c.id',
            'INNER JOIN external_data.countries as dst_c ON cdr.cdr.dst_country_id = dst_c.id',
            'WHERE',
            "\"src_c\".\"iso2\" IN ('UA', 'UK')",
            'AND',
            "\"dst_c\".\"iso2\" IN ('UA', 'UK')",
            'AND',
            '(1 = ANY(routing_tag_ids))',
            'AND',
            'NOT ((2 = ANY(routing_tag_ids)))',
            'AND',
            '(routing_tag_ids IS NULL OR routing_tag_ids = \'{}\')',
            'AND',
            "(\"cdr\".\"cdr\".\"time_start\" >= '2018-01-01 00:00:00'",
            'AND',
            "\"cdr\".\"cdr\".\"time_start\" <= '2018-03-01 00:00:00'",
            'AND',
            "\"cdr\".\"cdr\".\"src_prefix_in\" ILIKE '%111111%'",
            'AND',
            "\"cdr\".\"cdr\".\"src_prefix_routing\" ILIKE '%123123%'",
            'AND',
            "\"cdr\".\"cdr\".\"dst_prefix_out\" ILIKE '%333221%'",
            'AND',
            "\"cdr\".\"cdr\".\"src_country_id\" = #{country.id}",
            'AND',
            "\"cdr\".\"cdr\".\"dst_country_id\" = #{country.id}",
            'AND',
            "\"cdr\".\"cdr\".\"customer_auth_external_type\" = 'term'",
            'AND',
            "\"cdr\".\"cdr\".\"customer_auth_external_type\" != 'em'",
            'AND',
            '"cdr"."cdr"."customer_auth_external_id" IN (1, 2, 3))',
            'ORDER BY cdr.cdr.time_start DESC'
          ].join(' ')
        end

        include_examples :returns_correct_sql
      end
    end

    context 'with time_start_lt' do
      let(:filters) do
        {
          time_start_gteq: '2018-01-01 00:00:00',
          time_start_lt: '2018-03-01 00:00:00'
        }
      end
      let(:expected_sql) do
        [
          'SELECT success AS "Success", cdr.cdr.id AS "ID"',
          'FROM "cdr"."cdr"',
          'WHERE',
          "(\"cdr\".\"cdr\".\"time_start\" >= '2018-01-01 00:00:00'",
          'AND',
          "\"cdr\".\"cdr\".\"time_start\" < '2018-03-01 00:00:00')",
          'ORDER BY cdr.cdr.time_start DESC'
        ].join(' ')
      end

      include_examples :returns_correct_sql
    end
  end

  describe 'multi-value number list filter parsing' do
    subject(:filters) { CdrExport::FiltersModel.new(attribute => input) }

    multi_value_attributes = %i[
      src_prefix_in_in src_prefix_routing_in src_prefix_out_in
      dst_prefix_in_in dst_prefix_routing_in dst_prefix_out_in
    ]

    multi_value_attributes.each do |attr|
      context "for #{attr}" do
        let(:attribute) { attr }

        context 'with a messy comma-separated string' do
          let(:input) { ',, ,,11,2' }

          it 'drops empty and whitespace-only values' do
            expect(filters.public_send(attr)).to eq(%w[11 2])
            expect(filters.as_json).to eq(attr.to_s => %w[11 2])
          end
        end

        context 'with surrounding whitespace around values' do
          let(:input) { " 11 , 2 ,3\t" }

          it 'strips each value' do
            expect(filters.public_send(attr)).to eq(%w[11 2 3])
          end
        end

        context 'with newline-separated values (textarea input)' do
          let(:input) { "11\n2\n\n 3 \r\n4" }

          it 'splits on new lines as well as commas' do
            expect(filters.public_send(attr)).to eq(%w[11 2 3 4])
          end
        end

        context 'with mixed comma and newline separators' do
          let(:input) { "11,2\n3, ,4" }

          it 'splits on either separator' do
            expect(filters.public_send(attr)).to eq(%w[11 2 3 4])
          end
        end

        context 'with only separators and whitespace' do
          let(:input) { ", , ,,\n  \n" }

          it 'becomes nil and is excluded from the serialized filters' do
            expect(filters.public_send(attr)).to be_nil
            expect(filters.as_json).not_to have_key(attr.to_s)
          end
        end

        context 'with an empty string' do
          let(:input) { '' }

          it 'becomes nil and is excluded from the serialized filters' do
            expect(filters.public_send(attr)).to be_nil
            expect(filters.as_json).not_to have_key(attr.to_s)
          end
        end

        context 'with an array containing blanks (API input)' do
          let(:input) { ['11', '', ' ', '2'] }

          it 'rejects blank elements' do
            expect(filters.public_send(attr)).to eq(%w[11 2])
          end
        end

        context 'with an empty array' do
          let(:input) { [] }

          it 'becomes nil and is excluded from the serialized filters' do
            expect(filters.public_send(attr)).to be_nil
            expect(filters.as_json).not_to have_key(attr.to_s)
          end
        end
      end
    end
  end
end
