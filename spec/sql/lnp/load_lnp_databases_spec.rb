# frozen_string_literal: true

RSpec.describe 'lnp.load_lnp_databases' do
  subject do
    yeti_select_all(sql)
  end

  let(:sql) { 'SELECT * FROM lnp.load_lnp_databases()' }

  let!(:lnp_databases) do
    [
      create(:lnp_database, :thinq),
      create(:lnp_database, :sip_redirect),
      create(:lnp_database, :csv),
      create(:lnp_database, :alcazar),
      create(:lnp_database, :coure_anq)
    ]
  end

  it 'responds with correct rows' do
    expect(subject).to match_array(
                         lnp_databases.map do |db|
                           {
                             id: db.id,
                             name: db.name,
                             database_type: db.database_type,
                             parameters: db.database.to_json.to_s
                           }
                         end
                       )
  end
end
