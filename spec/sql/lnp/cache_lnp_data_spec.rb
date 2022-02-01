# frozen_string_literal: true

RSpec.describe 'lnp.cache_lnp_data' do
  subject do
    SqlCaller::Yeti.select_all(sql, *sql_params)
  end

  let(:sql) { 'SELECT * FROM lnp.cache_lnp_data(?::smallint,?::varchar,?::varchar,?::varchar,?::varchar)' }
  let(:sql_params) do
    [db.id, dst, lrn, tag, data]
  end

  let!(:dst) { '1111-dst' }
  let!(:lrn) { 'lrn-2222' }
  let!(:tag) { 'lrn-tag' }
  let!(:data) { 'lrn-data' }

  context 'no caching' do
    let! (:db) { create(:lnp_database, :thinq, cache_ttl: 0) }

    it 'no caching' do
      expect { subject }.not_to change { Lnp::Cache.count }
    end
  end

  context 'caching' do
    let! (:db) { create(:lnp_database, :thinq, cache_ttl: 600) }

    it 'caching' do
      expect { subject }.to change { Lnp::Cache.count }.by(1)
    end
  end
end
