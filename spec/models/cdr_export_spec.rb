# frozen_string_literal: true

# == Schema Information
#
# Table name: cdr_exports
#
#  id           :integer(4)       not null, primary key
#  callback_url :string
#  fields       :string           default([]), not null, is an Array
#  filters      :json             not null
#  rows_count   :integer(4)
#  status       :string           not null
#  type         :string           not null
#  created_at   :datetime
#  updated_at   :datetime
#

RSpec.describe CdrExport, type: :model do
  describe '#export_sql' do
    subject do
      cdr_export.export_sql
    end
    let(:cdr_export) do
      FactoryBot.create(:cdr_export, fields: fields, filters: filters)
    end
    let(:fields) do
      %w[success id]
    end
    let(:filters) do
      {
        time_start_gteq: '2018-01-01',
        time_start_lteq: '2018-03-01',
        success_eq: 'true',
        failed_resource_type_id_eq: '3',
        src_prefix_routing_contains: '123123'
      }
    end

    it 'SQL should be valid' do
      sql = [
        'SELECT success AS "Success", cdr.cdr.id AS "ID"',
        'FROM "cdr"."cdr"',
        'WHERE',
        "(\"cdr\".\"cdr\".\"time_start\" >= '2018-01-01 00:00:00'",
        'AND',
        "\"cdr\".\"cdr\".\"time_start\" <= '2018-03-01 00:00:00'",
        'AND',
        '"cdr"."cdr"."success" = TRUE',
        'AND',
        '"cdr"."cdr"."failed_resource_type_id" = 3',
        'AND',
        "\"cdr\".\"cdr\".\"src_prefix_routing\" ILIKE '%123123%')",
        'ORDER BY time_start desc'
      ]
      expect(subject).to eq(sql.join(' '))
    end

    context 'when added virtual attributes to export cdr' do
      let(:fields) { %w[src_country_name dst_country_name src_network_name dst_network_name] }

      it 'SQL should be valid' do
        sql = [
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
          "\"cdr\".\"cdr\".\"time_start\" <= '2018-03-01 00:00:00'",
          'AND',
          '"cdr"."cdr"."success" = TRUE',
          'AND',
          '"cdr"."cdr"."failed_resource_type_id" = 3',
          'AND',
          "\"cdr\".\"cdr\".\"src_prefix_routing\" ILIKE '%123123%')",
          'ORDER BY time_start desc'
        ]
        expect(subject).to eq(sql.join(' '))
      end
    end
  end
end
