require 'spec_helper'

describe CdrExport, type: :model do

  describe '#export_sql' do
    subject do
      cdr_export.export_sql
    end
    let(:cdr_export) do
      FactoryGirl.create(:cdr_export, fields: fields, filters: filters)
    end
    let(:fields) do
      ['success', 'id']
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
        "SELECT success, id",
        'FROM "cdr"."cdr"',
        "WHERE",
        "(\"cdr\".\"cdr\".\"time_start\" >= '2018-01-01 02:00:00.000000'",
        "AND",
        "\"cdr\".\"cdr\".\"time_start\" <= '2018-03-01 02:00:00.000000'",
        "AND",
        "\"cdr\".\"cdr\".\"success\" = 't'",
        "AND",
        "\"cdr\".\"cdr\".\"failed_resource_type_id\" = 3",
        "AND",
        "\"cdr\".\"cdr\".\"src_prefix_routing\" ILIKE '%123123%')",
        " ORDER BY time_start desc"#to_sql makes before ORDER BY 2 spaces
      ]
      expect(subject).to eq(sql.join(' '))
    end
  end

end
